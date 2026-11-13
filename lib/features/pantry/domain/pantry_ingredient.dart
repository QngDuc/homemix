import 'package:flutter/material.dart';

enum PantryCategory {
  tea('Trà', Icons.emoji_food_beverage_rounded, Color(0xFFDCEBC6)),
  coffee('Cà phê', Icons.coffee_rounded, Color(0xFFEAD8C8)),
  fruit('Trái cây', Icons.spa_rounded, Color(0xFFFFE5B8)),
  dairy('Sữa & kem', Icons.icecream_rounded, Color(0xFFF9E1E3)),
  syrup('Siro', Icons.water_drop_rounded, Color(0xFFE7DDF4)),
  other('Khác', Icons.kitchen_rounded, Color(0xFFE5E9EF));

  const PantryCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

enum PantryExpiryStatus {
  fresh('Còn hạn', Color(0xFF638B2F), Color(0xFFEAF2DA)),
  expiringSoon('Sắp hết hạn', Color(0xFFB36B25), Color(0xFFFFF0D8)),
  expired('Đã hết hạn', Color(0xFFC65363), Color(0xFFFBE4E6));

  const PantryExpiryStatus(
    this.label,
    this.foregroundColor,
    this.backgroundColor,
  );

  final String label;
  final Color foregroundColor;
  final Color backgroundColor;
}

class PantryIngredient {
  const PantryIngredient({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    this.note,
  });

  final String id;
  final String name;
  final PantryCategory category;
  final double quantity;
  final String unit;
  final DateTime expiryDate;
  final String? note;

  PantryExpiryStatus get expiryStatus {
    final today = DateUtils.dateOnly(DateTime.now());
    final expiry = DateUtils.dateOnly(expiryDate);
    if (expiry.isBefore(today)) {
      return PantryExpiryStatus.expired;
    }
    if (expiry.difference(today).inDays <= 3) {
      return PantryExpiryStatus.expiringSoon;
    }
    return PantryExpiryStatus.fresh;
  }

  String get formattedQuantity {
    final value = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toString();
    return '$value $unit';
  }
}
