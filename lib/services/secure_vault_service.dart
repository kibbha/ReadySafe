import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureVaultItem {
  const SecureVaultItem({
    required this.id,
    required this.title,
    required this.category,
    this.reference = '',
    this.location = '',
    this.notes = '',
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String category;
  final String reference;
  final String location;
  final String notes;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'reference': reference,
        'location': location,
        'notes': notes,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SecureVaultItem.fromJson(Map<String, dynamic> json) => SecureVaultItem(
        id: '${json['id'] ?? ''}',
        title: '${json['title'] ?? ''}',
        category: '${json['category'] ?? ''}',
        reference: '${json['reference'] ?? ''}',
        location: '${json['location'] ?? ''}',
        notes: '${json['notes'] ?? ''}',
        updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}') ?? DateTime.now(),
      );
}

class SecureVaultService {
  SecureVaultService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _vaultKey = 'readysafe.secure_vault.v1';
  final FlutterSecureStorage _storage;

  Future<List<SecureVaultItem>> items() async {
    try {
      final raw = await _storage.read(key: _vaultKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => SecureVaultItem.fromJson(Map<String, dynamic>.from(item)))
          .where((item) => item.id.isNotEmpty && item.title.isNotEmpty)
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<SecureVaultItem> items) async {
    final payload = jsonEncode(items.map((item) => item.toJson()).toList());
    await _storage.write(key: _vaultKey, value: payload);
  }

  Future<void> upsert(SecureVaultItem value) async {
    final current = await items();
    final next = <SecureVaultItem>[
      value,
      ...current.where((item) => item.id != value.id),
    ];
    await saveAll(next);
  }

  Future<void> remove(String id) async {
    final current = await items();
    await saveAll(current.where((item) => item.id != id).toList());
  }

  Future<int> count() async => (await items()).length;

  Future<void> clear() async => _storage.delete(key: _vaultKey);
}
