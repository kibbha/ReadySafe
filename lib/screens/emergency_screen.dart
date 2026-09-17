import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app/app_scope.dart';
import '../app/localizations.dart';
import '../models/country_profile.dart';
import '../services/emergency_call_service.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, this.callService});
  final EmergencyCallService? callService;

  IconData _icon(EmergencyService service) {
    final key = '${service.id} ${service.nameKey}'.toLowerCase();
    if (key.contains('rega') || key.contains('air_rescue')) return Icons.helicopter_outlined;
    if (key.contains('police')) return Icons.local_police_outlined;
    if (key.contains('fire')) return Icons.local_fire_department_outlined;
    if (key.contains('ambulance') || key.contains('medical')) return Icons.emergency_outlined;
    if (key.contains('poison')) return Icons.science_outlined;
    if (key.contains('youth')) return Icons.child_care_outlined;
    if (key.contains('help')) return Icons.support_agent_outlined;
    return Icons.sos_outlined;
  }

  String _flag(String iso) {
    if (iso.length != 2) return '🌐';
    return String.fromCharCodes(iso.toUpperCase().codeUnits.map((c) => 0x1F1E6 + c - 65));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final country = AppScope.of(context).activeCountry!;
    final caller = callService ?? DeviceEmergencyCallService();
    final callable = country.services.where((s) => s.isCallable).toList();
    EmergencyService? primary;
    for (final s in callable) {
      if (s.nameKey.contains('ambulance')) { primary = s; break; }
    }
    primary ??= callable.isEmpty ? null : callable.first;
    final others = primary == null ? callable : callable.where((s) => s != primary).toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.get('emergencies'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xffdbe5e7))),
            child: Row(children: [
              Container(width: 54, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xfff7fafb), borderRadius: BorderRadius.circular(12)), child: Text(_flag(country.isoCode), style: const TextStyle(fontSize: 28))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.get(country.nameKey), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                Text(t.get('emergency_hint'), style: const TextStyle(fontSize: 12, color: Color(0xff65747a))),
              ])),
              const Icon(Icons.verified_outlined, color: Color(0xff087f83)),
            ]),
          ),
          if (primary != null) ...[const SizedBox(height: 14), _DangerHero(service: primary, callService: caller)],
          if (others.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Numéros utiles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 9),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: others.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.18, crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemBuilder: (_, i) => _EmergencyTile(service: others[i], icon: _icon(others[i]), callService: caller),
            ),
          ],
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.verified_user_outlined, color: Color(0xff087f83)), const SizedBox(width: 8), Text(t.get('official_sources'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))]),
            const SizedBox(height: 5),
            ...country.sources.map((source) => ListTile(dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero, title: Text(source.host, style: const TextStyle(fontWeight: FontWeight.w700)), trailing: const Icon(Icons.open_in_new, size: 17), onTap: () => launchUrl(source, mode: LaunchMode.externalApplication))),
            Text(country.verifiedOn != null ? t.get('verified_on', {'date': country.verifiedOn!.toIso8601String().substring(0, 10)}) : t.get('numbers_unverified'), style: const TextStyle(fontSize: 12, color: Color(0xff65747a))),
          ]))),
        ],
      ),
    );
  }
}

class _DangerHero extends StatelessWidget {
  const _DangerHero({required this.service, required this.callService});
  final EmergencyService service;
  final EmergencyCallService callService;
  @override Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xffffeded), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xffffcaca))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: Theme.of(context).colorScheme.error, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 27)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('DANGER IMMÉDIAT', style: TextStyle(fontSize: 12, letterSpacing: .4, fontWeight: FontWeight.w900, color: Color(0xff9d1c24))),
            Text('Appelez le ${service.number ?? ''}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            Text(t.get(service.nameKey), style: const TextStyle(fontSize: 13, color: Color(0xff65747a))),
          ])),
        ]),
        const SizedBox(height: 13),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size.fromHeight(48)),
          onPressed: () => _call(context, t, service, callService), icon: const Icon(Icons.call), label: Text('Appeler ${service.number ?? ''}', style: const TextStyle(fontWeight: FontWeight.w900)),
        )),
      ]),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  const _EmergencyTile({required this.service, required this.icon, required this.callService});
  final EmergencyService service; final IconData icon; final EmergencyCallService callService;
  @override Widget build(BuildContext context) {
    final t=AppLocalizations.of(context);
    final isRega = service.id == 'rega';
    return Card(margin: EdgeInsets.zero, child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () => _call(context,t,service,callService), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 40,height:40,decoration:BoxDecoration(color:isRega?const Color(0xffe8f5f5):const Color(0xffffe9e9),borderRadius:BorderRadius.circular(12)),child:Icon(icon,color:isRega?const Color(0xff087f83):Theme.of(context).colorScheme.error,size:23)),
        const Spacer(), const Icon(Icons.call_outlined, size: 18, color: Color(0xff87969a)),
      ]),
      const Spacer(),
      Text(service.number ?? '—',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:isRega?const Color(0xff087f83):Theme.of(context).colorScheme.error)),
      Text(t.get(service.nameKey),maxLines:2,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:13,fontWeight:FontWeight.w800,height:1.1)),
    ]))));
  }
}

Future<void> _call(BuildContext context, AppLocalizations t, EmergencyService service, EmergencyCallService caller) async {
  final number=service.number; if(number==null||!service.isCallable)return;
  final ok=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(icon:Icon(Icons.phone_in_talk,color:Theme.of(context).colorScheme.error,size:34),title:Text(t.get('call_confirm_title')),content:Text(t.get('call_confirm_body',{'number':number,'service':t.get(service.nameKey)})),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:Text(t.get('cancel'))),FilledButton(style:FilledButton.styleFrom(backgroundColor:Theme.of(context).colorScheme.error),onPressed:()=>Navigator.pop(c,true),child:Text(t.get('call')))]))??false;
  if(!ok||!context.mounted)return; final launched=await caller.call(number); if(!launched&&context.mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t.get('call_failed'))));
}
