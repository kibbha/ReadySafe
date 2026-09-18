import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';

class CommunicationPlanScreen extends StatefulWidget {
  const CommunicationPlanScreen({super.key});

  @override
  State<CommunicationPlanScreen> createState() => _CommunicationPlanScreenState();
}

class _CommunicationPlanScreenState extends State<CommunicationPlanScreen> {
  final _storage = LocalStorageService();
  final _contactName = TextEditingController();
  final _contactPhone = TextEditingController();
  final _schoolWork = TextEditingController();
  final _notes = TextEditingController();
  final _safeMessage = TextEditingController();

  bool _loading = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _contactName.dispose();
    _contactPhone.dispose();
    _schoolWork.dispose();
    _notes.dispose();
    _safeMessage.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final plan = await _storage.communicationPlan();
    if (!mounted) return;
    _contactName.text = plan['outOfAreaContact'] ?? '';
    _contactPhone.text = plan['outOfAreaPhone'] ?? '';
    _schoolWork.text = plan['schoolWork'] ?? '';
    _notes.text = plan['reconnectNotes'] ?? '';
    _safeMessage.text = plan['safeMessage'] ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    await _storage.saveCommunicationPlan({
      'outOfAreaContact': _contactName.text.trim(),
      'outOfAreaPhone': _contactPhone.text.trim(),
      'schoolWork': _schoolWork.text.trim(),
      'reconnectNotes': _notes.text.trim(),
      'safeMessage': _safeMessage.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saved = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _copySafeMessage() async {
    final message = _safeMessage.text.trim();
    if (message.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message copié.')),
    );
  }

  Future<void> _openSms() async {
    final message = _safeMessage.text.trim();
    final uri = Uri(
      scheme: 'sms',
      queryParameters: message.isEmpty ? null : {'body': message},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de communication'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_outlined),
            label: Text(_saved ? 'Enregistré' : 'Enregistrer'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffe2f3ef), Color(0xfffff4e7)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(Icons.connect_without_contact_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rester joignable même si le foyer est séparé',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Préparez un contact extérieur, les informations école/travail et un message court à envoyer rapidement.',
                              style: TextStyle(color: Color(0xff65747a), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Contact extérieur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                TextField(
                  controller: _contactName,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactPhone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('École / travail / garde', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                TextField(
                  controller: _schoolWork,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Adresses, téléphones, consignes utiles',
                    prefixIcon: Icon(Icons.business_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Plan de reconnexion', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                TextField(
                  controller: _notes,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Que faire si appels et données mobiles ne fonctionnent plus ?',
                    prefixIcon: Icon(Icons.route_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Message « Je suis en sécurité »', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                TextField(
                  controller: _safeMessage,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message prêt à envoyer',
                    prefixIcon: Icon(Icons.sms_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copySafeMessage,
                        icon: const Icon(Icons.copy_rounded),
                        label: const Text('Copier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openSms,
                        icon: const Icon(Icons.sms_rounded),
                        label: const Text('Ouvrir SMS'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xffeaf6f4),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.task_alt_rounded, color: Color(0xff087f83)),
                          SizedBox(width: 8),
                          Text('À préparer en famille', style: TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      SizedBox(height: 8),
                      _PlanTip('Chaque personne connaît au moins un contact à joindre.'),
                      _PlanTip('Les enfants savent où se rendre si le domicile est inaccessible.'),
                      _PlanTip('Le point de rassemblement principal et l’alternative sont connus.'),
                      _PlanTip('Les informations importantes existent aussi hors du téléphone.'),
                      _PlanTip('Le plan est revu après un changement d’école, de travail ou de domicile.'),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _PlanTip extends StatelessWidget {
  const _PlanTip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 18, color: Color(0xff087f83)),
            const SizedBox(width: 7),
            Expanded(child: Text(text, style: const TextStyle(height: 1.3))),
          ],
        ),
      );
}
