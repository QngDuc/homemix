import 'package:flutter/material.dart';

import '../domain/pantry_ingredient.dart';

final _today = DateUtils.dateOnly(DateTime.now());

final mockPantryIngredients = <PantryIngredient>[
  PantryIngredient(
    id: 'pantry-black-tea',
    name: 'Trà đen',
    category: PantryCategory.tea,
    quantity: 120,
    unit: 'g',
    expiryDate: _today.add(const Duration(days: 180)),
    note: 'Để nơi khô ráo, kín mùi.',
  ),
  PantryIngredient(
    id: 'pantry-peach',
    name: 'Đào ngâm',
    category: PantryCategory.fruit,
    quantity: 1,
    unit: 'hũ',
    expiryDate: _today.add(const Duration(days: 2)),
    note: 'Đã mở nắp, bảo quản lạnh.',
  ),
  PantryIngredient(
    id: 'pantry-fresh-orange',
    name: 'Cam tươi',
    category: PantryCategory.fruit,
    quantity: 4,
    unit: 'quả',
    expiryDate: _today.add(const Duration(days: 5)),
  ),
  PantryIngredient(
    id: 'pantry-mint',
    name: 'Lá bạc hà',
    category: PantryCategory.other,
    quantity: 1,
    unit: 'bó',
    expiryDate: _today.add(const Duration(days: 1)),
  ),
  PantryIngredient(
    id: 'pantry-condensed-milk',
    name: 'Sữa đặc',
    category: PantryCategory.dairy,
    quantity: 380,
    unit: 'g',
    expiryDate: _today.add(const Duration(days: 24)),
  ),
  PantryIngredient(
    id: 'pantry-coffee',
    name: 'Cà phê xay',
    category: PantryCategory.coffee,
    quantity: 250,
    unit: 'g',
    expiryDate: _today.add(const Duration(days: 90)),
  ),
  PantryIngredient(
    id: 'pantry-honey',
    name: 'Mật ong',
    category: PantryCategory.syrup,
    quantity: 1,
    unit: 'chai',
    expiryDate: _today.subtract(const Duration(days: 2)),
    note: 'Kiểm tra mùi vị trước khi dùng.',
  ),
  PantryIngredient(
    id: 'pantry-oat-milk',
    name: 'Sữa yến mạch',
    category: PantryCategory.dairy,
    quantity: 500,
    unit: 'ml',
    expiryDate: _today.add(const Duration(days: 3)),
  ),
];
