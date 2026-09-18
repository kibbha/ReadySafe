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

  Future<void> _copySafeMessage(bool en) async {
    final message = _safeMessage.text.trim();
    if (message.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: message));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(en ? 'Message copied.' : 'Message copié.')),
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

  Future<void> _callContact() async {
    final phone = _contactPhone.text.trim();
    if (phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: Text(en ? 'Communication plan' : 'Plan de communication'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: Icon(_saved ? Icons.check_rounded : Icons.save_outlined),
            label: Text(
              _saved
                  ? (en ? 'Saved' : 'Enregistré')
                  : (en ? 'Save' : 'Enregistrer'),
            ),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(
                          Icons.connect_without_contact_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              en
                                  ? 'Stay connected even when the household is separated'
                                  : 'Rester joignable même si le foyer est séparé',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              en
                                  ? 'Prepare an out-of-area contact, school/work information and a short message that can be sent quickly.'
                                  : 'Préparez un contact extérieur, les informations école/travail et un message court à envoyer rapidement.',
                              style: const TextStyle(
                                color: Color(0xff65747a),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Out-of-area contact' : 'Contact extérieur',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _contactName,
                  decoration: InputDecoration(
                    labelText: en ? 'Name' : 'Nom',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactPhone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: en ? 'Phone' : 'Téléphone',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    suffixIcon: IconButton(
                      tooltip: en ? 'Call contact' : 'Appeler le contact',
                      onPressed: _contactPhone.text.trim().isEmpty
                          ? null
                          : _callContact,
                      icon: const Icon(Icons.call_rounded),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'School / work / childcare' : 'École / travail / garde',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _schoolWork,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: en
                        ? 'Addresses, phone numbers, release procedures'
                        : 'Adresses, téléphones, consignes utiles',
                    prefixIcon: const Icon(Icons.business_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? 'Reconnection plan' : 'Plan de reconnexion',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _notes,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: en
                        ? 'What will everyone do if calls and mobile data stop working?'
                        : 'Que faire si appels et données mobiles ne fonctionnent plus ?',
                    prefixIcon: const Icon(Icons.route_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  en ? '“I am safe” message' : 'Message « Je suis en sécurité »',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: _safeMessage,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: en ? 'Ready-to-send message' : 'Message prêt à envoyer',
                    prefixIcon: const Icon(Icons.sms_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copySafeMessage(en),
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(en ? 'Copy' : 'Copier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openSms,
                        icon: const Icon(Icons.sms_rounded),
                        label: Text(en ? 'Open SMS' : 'Ouvrir SMS'),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.task_alt_rounded,
                            color: Color(0xff087f83),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            en ? 'Prepare as a household' : 'À préparer en famille',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _PlanTip(
                        en
                            ? 'Everyone knows at least one person to contact.'
                            : 'Chaque personne connaît au moins un contact à joindre.',
                      ),
                      _PlanTip(
                        en
                            ? 'Children know where to go if home is inaccessible.'
                            : 'Les enfants savent où se rendre si le domicile est inaccessible.',
                      ),
                      _PlanTip(
                        en
                            ? 'Primary and backup meeting places are known.'
                            : 'Le point de rassemblement principal et l’alternative sont connus.',
                      ),
                      _PlanTip(
                        en
                            ? 'Important information also exists outside the phone.'
                            : 'Les informations importantes existent aussi hors du téléphone.',
                      ),
                      _PlanTip(
                        en
                            ? 'The plan is reviewed after school, work or address changes.'
                            : 'Le plan est revu après un changement d’école, de travail ou de domicile.',
                      ),
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
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: Color(0xff087f83),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(height: 1.3),
              ),
            ),
          ],
        ),
      );
}
