import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

class SharedPreferencesJournalRepository implements JournalRepository {
  SharedPreferencesJournalRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _entriesKey = 'homemix.journal.entries.v1';
  static const _favoriteRecipeIdsKey = 'homemix.journal.favorite_recipe_ids.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<JournalEntry>> loadEntries() async {
    final json = await _preferences.getString(_entriesKey);
    if (json == null) {
      return const [];
    }

    final decoded = jsonDecode(json);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Dữ liệu nhật ký không hợp lệ.');
    }

    final entries = decoded.map(_readEntry).toList();
    entries.sort((first, second) => second.date.compareTo(first.date));
    return entries;
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) {
    final json = jsonEncode([
      for (final entry in entries)
        {
          'id': entry.id,
          'recipeId': entry.recipeId,
          'recipeName': entry.recipeName,
          'date': entry.date.toIso8601String(),
          'rating': entry.rating,
          'note': entry.note,
          'imagePath': entry.imagePath,
        },
    ]);
    return _preferences.setString(_entriesKey, json);
  }

  @override
  Future<Set<String>> loadFavoriteRecipeIds() async {
    final ids = await _preferences.getStringList(_favoriteRecipeIdsKey);
    if (ids == null) {
      return const {};
    }
    if (ids.any((id) => id.trim().isEmpty)) {
      throw const FormatException(
        'Danh sách công thức yêu thích không hợp lệ.',
      );
    }
    return ids.toSet();
  }

  @override
  Future<void> saveFavoriteRecipeIds(Set<String> recipeIds) {
    final ids = recipeIds.toList()..sort();
    return _preferences.setStringList(_favoriteRecipeIdsKey, ids);
  }

  JournalEntry _readEntry(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Một mục nhật ký không hợp lệ.');
    }
    final id = value['id'];
    final recipeId = value['recipeId'];
    final recipeName = value['recipeName'];
    final dateValue = value['date'];
    final rating = value['rating'];
    final note = value['note'];
    final imagePath = value['imagePath'];

    if (id is! String ||
        id.isEmpty ||
        recipeId is! String ||
        recipeId.isEmpty ||
        recipeName is! String ||
        recipeName.isEmpty ||
        dateValue is! String ||
        note is! String ||
        (rating != null && (rating is! int || rating < 1 || rating > 5)) ||
        (imagePath != null && imagePath is! String)) {
      throw const FormatException('Một mục nhật ký chứa dữ liệu không hợp lệ.');
    }

    final date = DateTime.tryParse(dateValue);
    if (date == null) {
      throw const FormatException('Ngày pha chế trong nhật ký không hợp lệ.');
    }

    return JournalEntry(
      id: id,
      recipeId: recipeId,
      recipeName: recipeName,
      date: date,
      rating: rating as int?,
      note: note,
      imagePath: imagePath as String?,
    );
  }
}
