class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.label,
    required this.category,
    this.recommendedQuantity,
    this.unit,
    this.hasExpiry = false,
    this.expiryReminderDays = 30,
    this.notes,
  });

  final String id;
  final String label;
  final String category;
  final num? recommendedQuantity;
  final String? unit;
  final bool hasExpiry;
  final int expiryReminderDays;
  final String? notes;
}

/// User-entered stock information for one emergency-kit item.
class KitStockEntry {
  const KitStockEntry({
    required this.itemId,
    this.quantityOwned = 0,
    this.expiryDate,
    this.updatedAt,
    this.notes = '',
    this.reminderEnabled = false,
    this.reminderDays = 30,
  });

  final String itemId;
  final num quantityOwned;
  final DateTime? expiryDate;
  final DateTime? updatedAt;
  final String notes;
  final bool reminderEnabled;
  final int reminderDays;

  bool get isExpired =>
      expiryDate != null && expiryDate!.isBefore(DateTime.now());

  bool expiresWithin(int days) {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    return !expiryDate!.isBefore(now) && !expiryDate!.isAfter(limit);
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'quantityOwned': quantityOwned,
        'expiryDate': expiryDate?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'notes': notes,
        'reminderEnabled': reminderEnabled,
        'reminderDays': reminderDays,
      };

  factory KitStockEntry.fromJson(Map<String, dynamic> json) => KitStockEntry(
        itemId: json['itemId'] as String,
        quantityOwned: (json['quantityOwned'] as num?) ?? 0,
        expiryDate: json['expiryDate'] == null
            ? null
            : DateTime.tryParse(json['expiryDate'] as String),
        updatedAt: json['updatedAt'] == null
            ? null
            : DateTime.tryParse(json['updatedAt'] as String),
        notes: (json['notes'] as String?) ?? '',
        reminderEnabled: (json['reminderEnabled'] as bool?) ?? false,
        reminderDays: (json['reminderDays'] as num?)?.toInt() ?? 30,
      );
}