import 'package:flutter/material.dart';

import '../services/secure_vault_service.dart';

class SecureVaultScreen extends StatefulWidget {
  const SecureVaultScreen({super.key});

  @override
  State<SecureVaultScreen> createState() => _SecureVaultScreenState();
}

class _SecureVaultScreenState extends State<SecureVaultScreen> {
  final _service = SecureVaultService();

  List<SecureVaultItem> _items = [];
  bool _loading = true;
  bool _revealed = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.items();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Le stockage sécurisé n’est pas disponible sur cet appareil.';
      });
    }
  }

  Future<void> _edit([SecureVaultItem? existing]) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final reference = TextEditingController(text: existing?.reference ?? '');
    final location = TextEditingController(text: existing?.location ?? '');
    final notes = TextEditingController(text: existing?.notes ?? '');
    var category = existing?.category ?? 'Identité';

    final result = await showDialog<SecureVaultItem>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Ajouter au coffre' : 'Modifier'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Identité', child: Text('Identité')),
                    DropdownMenuItem(value: 'Santé', child: Text('Santé')),
                    DropdownMenuItem(value: 'Assurance', child: Text('Assurance')),
                    DropdownMenuItem(value: 'Logement', child: Text('Logement')),
                    DropdownMenuItem(value: 'Véhicule', child: Text('Véhicule')),
                    DropdownMenuItem(value: 'Voyage', child: Text('Voyage')),
                    DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => category = value);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reference,
                  decoration: const InputDecoration(
                    labelText: 'Référence / numéro utile',
                    prefixIcon: Icon(Icons.numbers_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: location,
                  decoration: const InputDecoration(
                    labelText: 'Où trouver l’original',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notes,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: Icon(Icons.notes_rounded),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                Navigator.pop(
                  dialogContext,
                  SecureVaultItem(
                    id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                    title: title.text.trim(),
                    category: category,
                    reference: reference.text.trim(),
                    location: location.text.trim(),
                    notes: notes.text.trim(),
                    updatedAt: DateTime.now(),
                  ),
                );
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );

    title.dispose();
    reference.dispose();
    location.dispose();
    notes.dispose();

    if (result == null) return;

    try {
      await _service.upsert(result);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Impossible d’enregistrer dans le coffre sécurisé.');
    }
  }

  Future<void> _delete(SecureVaultItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette entrée ?'),
        content: Text(item.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _service.remove(item.id);
    await _load();
  }

  String _mask(String value) {
    if (value.trim().isEmpty) return 'Non renseigné';
    if (_revealed) return value;
    return '••••••••';
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7faf9),
      appBar: AppBar(
        title: const Text('Coffre sécurisé'),
        actions: [
          IconButton(
            tooltip: _revealed ? 'Masquer les valeurs' : 'Afficher les valeurs',
            onPressed: () => setState(() => _revealed = !_revealed),
            icon: Icon(_revealed ? Icons.visibility_off_rounded : Icons.visibility_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Ajouter'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 96),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xffe4f3f0), Color(0xfffff4e8)],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xff087f83),
                        child: Icon(Icons.lock_rounded, color: Colors.white),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations sensibles chiffrées sur l’appareil',
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Utilisez ce coffre pour les références, emplacements et notes utiles. Les valeurs sont masquées à l’écran par défaut.',
                              style: TextStyle(color: Color(0xff65747a), height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffffeeee),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xffb00020),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (_items.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Icon(Icons.lock_open_rounded, size: 40, color: Color(0xff087f83)),
                          SizedBox(height: 8),
                          Text(
                            'Le coffre est vide',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ajoutez uniquement les informations dont vous auriez besoin rapidement en situation d’urgence.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xff65747a)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._items.map(
                    (item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xffe4f2f0),
                          child: Icon(_icon(item.category), color: const Color(0xff087f83)),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: Text(
                          '${item.category} · mis à jour le ${_date(item.updatedAt)}',
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                        children: [
                          _Line(label: 'Référence', value: _mask(item.reference)),
                          _Line(label: 'Original', value: _mask(item.location)),
                          _Line(label: 'Notes', value: _mask(item.notes)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _edit(item),
                                  icon: const Icon(Icons.edit_outlined),
                                  label: const Text('Modifier'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Supprimer',
                                onPressed: () => _delete(item),
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff4c7),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security_rounded, color: Color(0xff9a6a00)),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Ce coffre protège des données texte avec le stockage sécurisé du système. Il ne stocke pas encore de photos ou PDF de documents. Pour un accès d’urgence, conservez aussi les informations indispensables sous une forme physique sûre.',
                          style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _icon(String category) {
    switch (category) {
      case 'Identité':
        return Icons.badge_outlined;
      case 'Santé':
        return Icons.medical_information_outlined;
      case 'Assurance':
        return Icons.shield_outlined;
      case 'Logement':
        return Icons.home_outlined;
      case 'Véhicule':
        return Icons.directions_car_outlined;
      case 'Voyage':
        return Icons.luggage_outlined;
      default:
        return Icons.lock_outline_rounded;
    }
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 92,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xff65747a),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
}
