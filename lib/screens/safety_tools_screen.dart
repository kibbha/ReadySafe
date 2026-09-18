import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/local_storage_service.dart';
import 'communication_plan_screen.dart';
import 'emergency_screen.dart';
import 'online_maps_screen.dart';

class SafetyToolsScreen extends StatefulWidget {
  const SafetyToolsScreen({super.key});

  @override
  State<SafetyToolsScreen> createState() => _SafetyToolsScreenState();
}

class _SafetyToolsScreenState extends State<SafetyToolsScreen> {
  final _storage = LocalStorageService();
  String _safeMessage = 'Je suis en sécurité. Je te contacte dès que possible.';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await _storage.communicationPlan();
    if (!mounted) return;
    setState(() {
      _safeMessage = (plan['safeMessage'] ?? '').trim().isEmpty
          ? _safeMessage
          : plan['safeMessage']!.trim();
    });
  }

  Future<void> _copyMessage() async {
    await Clipboard.setData(ClipboardData(text: _safeMessage));
    if (!mounted) return;
    final en = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(en ? 'Message copied.' : 'Message copié.')),
    );
  }

  Future<void> _openSms() async {
    final uri = Uri(scheme: 'sms', queryParameters: {'body': _safeMessage});
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    final tools = [
      _Tool(
        en ? 'Visual SOS signal' : 'Signal SOS visuel',
        en ? 'Show a highly visible full-screen SOS signal.' : 'Afficher un signal plein écran très visible.',
        Icons.sos_rounded,
        const Color(0xffd92d36),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SosVisualSignalScreen()),
        ),
      ),
      _Tool(
        en ? 'Emergency numbers' : 'Numéros d’urgence',
        en ? 'Direct access to services for the active country.' : 'Accès direct aux services du pays actif.',
        Icons.phone_in_talk_rounded,
        const Color(0xffd92d36),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
        ),
      ),
      _Tool(
        en ? 'Map & landmarks' : 'Carte & repères',
        en ? 'Find useful places and your personal landmarks.' : 'Retrouver les points importants et vos repères personnels.',
        Icons.map_rounded,
        const Color(0xff147343),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OnlineMapsScreen()),
        ),
      ),
      _Tool(
        en ? 'Communication plan' : 'Plan de communication',
        en ? 'Contacts, reconnection and household instructions.' : 'Contacts, reconnexion et consignes famille.',
        Icons.connect_without_contact_rounded,
        const Color(0xff087f83),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunicationPlanScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(en ? 'Emergency tools' : 'Outils d’urgence')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffe3f3f0), Color(0xfffff4e8)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xff087f83),
                  child: Icon(Icons.handyman_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        en
                            ? 'Simple tools, immediately accessible'
                            : 'Des outils simples, immédiatement accessibles',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        en
                            ? 'Signal, communication, emergency numbers and landmarks without cluttering the screen.'
                            : 'Signal, communication, numéros d’urgence et repères : sans transformer l’écran en cockpit d’avion.',
                        style: const TextStyle(color: Color(0xff65747a), height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 150,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) => _ToolCard(tool: tools[index]),
          ),
          const SizedBox(height: 16),
          Text(en ? 'Quick message' : 'Message rapide', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xffd8e6e5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sms_outlined, color: Color(0xff087f83)),
                    const SizedBox(width: 8),
                    Text(
                      en ? '“I am safe”' : '« Je suis en sécurité »',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_safeMessage, style: const TextStyle(height: 1.35)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyMessage,
                        icon: const Icon(Icons.copy_rounded),
                        label: Text(en ? 'Copy' : 'Copier'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _openSms,
                        icon: const Icon(Icons.sms_rounded),
                        label: const Text('SMS'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xffeaf6f4),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.offline_bolt_rounded, color: Color(0xff087f83)),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    en
                        ? 'First-aid guides, kits, contacts, family plans and personal landmarks are designed to remain useful offline. Map tiles and some searches may require connectivity.'
                        : 'Les fiches de premiers secours, les kits, les contacts, les plans familiaux et les repères personnels sont conçus pour rester utiles hors ligne. La carte de fond et certaines recherches peuvent nécessiter une connexion.',
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SosVisualSignalScreen extends StatefulWidget {
  const SosVisualSignalScreen({super.key});

  @override
  State<SosVisualSignalScreen> createState() => _SosVisualSignalScreenState();
}

class _SosVisualSignalScreenState extends State<SosVisualSignalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final en = Localizations.localeOf(context).languageCode == 'en';
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(en ? 'Visual SOS signal' : 'Signal SOS visuel'),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = _running ? _controller.value : 0.25;
          final background = Color.lerp(
            const Color(0xffd00014),
            Colors.white,
            pulse,
          )!;
          final foreground = pulse > .55 ? const Color(0xffb00016) : Colors.white;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            color: background,
            width: double.infinity,
            height: double.infinity,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sos_rounded, size: 110, color: foreground),
                    const SizedBox(height: 16),
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      en ? 'VISUAL SIGNAL' : 'SIGNAL VISUEL',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 34),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: .78),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(210, 54),
                      ),
                      onPressed: _toggle,
                      icon: Icon(_running ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(
                        _running
                            ? (en ? 'Pause' : 'Mettre en pause')
                            : (en ? 'Restart' : 'Relancer'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .68),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        en
                            ? 'This signal may help attract attention. It does not replace calling emergency services or locally recommended signalling methods.'
                            : 'Ce signal peut aider à attirer l’attention. Il ne remplace pas l’appel aux services d’urgence ni les moyens de signalisation recommandés localement.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tool {
  const _Tool(this.title, this.subtitle, this.icon, this.color, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});
  final _Tool tool;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: tool.onTap,
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              border: Border.all(color: const Color(0xffdbe6e7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tool.color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(tool.icon, color: tool.color),
                ),
                const Spacer(),
                Text(
                  tool.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  tool.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xff65747a), height: 1.2),
                ),
              ],
            ),
          ),
        ),
      );
}
