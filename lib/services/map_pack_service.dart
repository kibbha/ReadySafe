import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../data/country_repository.dart';
import '../models/map_pack.dart';

abstract interface class OfflineMapProvider {
  Future<List<MapPack>> catalog(String? countryCode);
  Future<MapPack> download(String packId, void Function(double progress) onProgress);
  Future<MapPack> verify(String packId);
  Future<void> pause(String packId);
  Future<MapPack> resume(String packId, void Function(double progress) onProgress);
  Future<void> delete(String packId);
  Future<String?> localStyleUri(String packId);
}

/// Production PMTiles provider.
/// Catalog entries are read from assets/maps/catalog.json. Only entries with
/// HTTPS URL, byte size and SHA-256 are considered downloadable. Archives are
/// stored in the app documents directory and verified before being installed.
class PmTilesOfflineMapProvider implements OfflineMapProvider {
  final http.Client _client;
  PmTilesOfflineMapProvider({http.Client? client}) : _client = client ?? http.Client();

  List<MapPack>? _catalog;
  final Map<String, MapPackState> _runtimeState = {};
  final Map<String, int> _runtimeBytes = {};
  final Set<String> _cancelled = {};

  Future<Directory> _mapsDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/offline_maps');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<List<MapPack>> _loadCatalog() async {
    if (_catalog != null) return _catalog!;
    final raw = await rootBundle.loadString('assets/maps/catalog.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final entries = (decoded['packs'] as List<dynamic>? ?? const []);
    final configured = <String, MapPack>{};
    for (final value in entries) {
      final m = value as Map<String, dynamic>;
      final uri = Uri.tryParse(m['url']?.toString() ?? '');
      final size = int.tryParse(m['bytes']?.toString() ?? '');
      final hash = m['sha256']?.toString().toLowerCase();
      if (uri == null || uri.scheme != 'https' || size == null || size <= 0 || hash == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash)) continue;
      configured[m['id'].toString()] = MapPack(id:m['id'].toString(),countryCode:m['countryCode'].toString(),nameKey:m['nameKey'].toString(),version:m['version'].toString(),state:MapPackState.available,estimatedBytes:size,downloadUri:uri,sha256:hash);
    }
    final result = <MapPack>[];
    for (final country in CountryRepository.supported) {
      final id='${country.isoCode}-national';
      result.add(configured[id] ?? MapPack(id:id,countryCode:country.isoCode,nameKey:country.nameKey,version:'pending',state:MapPackState.unavailable));
    }
    _catalog=result;
    return result;
  }

  Future<MapPack> _current(MapPack base) async {
    final dir=await _mapsDir();
    final file=File('${dir.path}/${base.id}-${base.version}.pmtiles');
    if(await file.exists()){
      final ok=await _hash(file)==base.sha256;
      if(ok)return base.copyWith(state:MapPackState.installed,localPath:file.path,downloadedBytes:await file.length());
      await file.delete();
    }
    return base.copyWith(state:_runtimeState[base.id]??base.state,downloadedBytes:_runtimeBytes[base.id]??0);
  }

  @override Future<List<MapPack>> catalog(String? countryCode) async {
    final all=await _loadCatalog();
    final out=<MapPack>[];
    for(final p in all.where((p)=>countryCode==null||p.countryCode==countryCode)){out.add(await _current(p));}
    return out;
  }

  Future<MapPack> _base(String id) async => (await _loadCatalog()).firstWhere((p)=>p.id==id);
  Future<String> _hash(File f) async => sha256.convert(await f.openRead().fold<List<int>>(<int>[],(a,b)=>a..addAll(b))).toString();

  @override Future<MapPack> download(String packId,void Function(double progress) onProgress) async {
    final base=await _base(packId);
    if(!base.isConfigured)throw StateError('Map pack is not configured');
    _cancelled.remove(packId);_runtimeState[packId]=MapPackState.downloading;_runtimeBytes[packId]=0;
    final dir=await _mapsDir();final part=File('${dir.path}/$packId.part');final target=File('${dir.path}/${base.id}-${base.version}.pmtiles');
    if(await part.exists())await part.delete();
    final request=http.Request('GET',base.downloadUri!);final response=await _client.send(request);
    if(response.statusCode<200||response.statusCode>=300){_runtimeState[packId]=MapPackState.failed;throw HttpException('Map download failed (${response.statusCode})');}
    final sink=part.openWrite();var received=0;
    try{await for(final chunk in response.stream){if(_cancelled.contains(packId)){_runtimeState[packId]=MapPackState.paused;break;}sink.add(chunk);received+=chunk.length;_runtimeBytes[packId]=received;onProgress((received/base.estimatedBytes!).clamp(0,1));}}finally{await sink.flush();await sink.close();}
    if(_cancelled.contains(packId))return base.copyWith(state:MapPackState.paused,downloadedBytes:received);
    if(received!=base.estimatedBytes){await part.delete();_runtimeState[packId]=MapPackState.failed;throw StateError('Downloaded map size mismatch');}
    if(await _hash(part)!=base.sha256){await part.delete();_runtimeState[packId]=MapPackState.failed;throw StateError('Downloaded map checksum mismatch');}
    if(await target.exists())await target.delete();await part.rename(target.path);_runtimeState[packId]=MapPackState.installed;_runtimeBytes[packId]=received;onProgress(1);
    return base.copyWith(state:MapPackState.installed,localPath:target.path,downloadedBytes:received);
  }

  @override Future<MapPack> verify(String packId) async {final base=await _base(packId);return _current(base);}
  @override Future<void> pause(String packId) async {_cancelled.add(packId);_runtimeState[packId]=MapPackState.paused;}
  @override Future<MapPack> resume(String packId,void Function(double progress) onProgress)=>download(packId,onProgress);
  @override Future<void> delete(String packId) async {final base=await _base(packId);final dir=await _mapsDir();for(final f in [File('${dir.path}/${base.id}-${base.version}.pmtiles'),File('${dir.path}/$packId.part')]){if(await f.exists())await f.delete();}_runtimeState.remove(packId);_runtimeBytes.remove(packId);_cancelled.remove(packId);}
  @override Future<String?> localStyleUri(String packId) async {final pack=await verify(packId);return pack.isInstalled&&pack.localPath!=null?'pmtiles://file://${pack.localPath}':null;}
}

/// Safe fallback retained for tests/integrations that explicitly need an empty catalog.
class UnconfiguredOfflineMapProvider implements OfflineMapProvider {
  @override Future<List<MapPack>> catalog(String? countryCode) async=>CountryRepository.supported.where((c)=>countryCode==null||c.isoCode==countryCode).map((c)=>MapPack(id:'${c.isoCode}-national',countryCode:c.isoCode,nameKey:c.nameKey,version:'unconfigured',state:MapPackState.unavailable)).toList();
  Never _no()=>throw StateError('No licensed offline map provider configured');
  @override Future<MapPack> download(String id,void Function(double) p)async=>_no();
  @override Future<MapPack> verify(String id)async=>_no();
  @override Future<void> pause(String id)async=>_no();
  @override Future<MapPack> resume(String id,void Function(double) p)async=>_no();
  @override Future<void> delete(String id)async{}
  @override Future<String?> localStyleUri(String id)async=>null;
}
