import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/shared_preferences_journal_repository.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => SharedPreferencesJournalRepository(),
);

final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
      JournalEntriesNotifier.new,
    );

final favoriteRecipeIdsProvider =
    AsyncNotifierProvider<FavoriteRecipesNotifier, Set<String>>(
      FavoriteRecipesNotifier.new,
    );

class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  late JournalRepository _repository;

  @override
  Future<List<JournalEntry>> build() {
    _repository = ref.watch(journalRepositoryProvider);
    return _repository.loadEntries();
  }

  Future<JournalEntry> addEntry({
    required String recipeId,
    required String recipeName,
    required DateTime date,
    required int? rating,
    required String note,
    String? imagePath,
  }) async {
    if (recipeId.trim().isEmpty || recipeName.trim().isEmpty) {
      throw ArgumentError('Công thức của nhật ký không được để trống.');
    }
    if (rating != null && (rating < 1 || rating > 5)) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }
    final previous = await _currentEntries();
    var timestamp = DateTime.now().microsecondsSinceEpoch;
    while (previous.any((entry) => entry.id == 'journal-$timestamp')) {
      timestamp++;
    }
    final entry = JournalEntry(
      id: 'journal-$timestamp',
      recipeId: recipeId,
      recipeName: recipeName,
      date: date,
      rating: rating,
      note: note.trim(),
      imagePath: imagePath,
    );
    await _update((entries) => [entry, ...entries]);
    return entry;
  }

  Future<void> updateEntry(String id, JournalEntryDraft draft) async {
    final rating = draft.rating;
    if (rating != null && (rating < 1 || rating > 5)) {
      throw RangeError.range(rating, 1, 5, 'rating');
    }
    await _update((entries) {
      var found = false;
      final updated = [
        for (final entry in entries)
          if (entry.id == id)
            entry.copyWith(
              rating: draft.rating,
              note: draft.note.trim(),
              clearRating: draft.rating == null,
            )
          else
            entry,
      ];
      found = entries.any((entry) => entry.id == id);
      if (!found) {
        throw StateError('Không tìm thấy mục nhật ký cần cập nhật.');
      }
      return updated;
    });
  }

  Future<void> deleteEntry(String id) {
    return _update((entries) {
      if (!entries.any((entry) => entry.id == id)) {
        throw StateError('Không tìm thấy mục nhật ký cần xóa.');
      }
      return entries.where((entry) => entry.id != id).toList();
    });
  }

  Future<List<JournalEntry>> _currentEntries() async {
    if (state.hasValue) {
      return state.requireValue;
    }
    return future;
  }

  Future<void> _update(
    List<JournalEntry> Function(List<JournalEntry> current) transform,
  ) async {
    final previous = await _currentEntries();
    final updated = transform(previous)
      ..sort((first, second) => second.date.compareTo(first.date));
    state = AsyncData(updated);
    try {
      await _repository.saveEntries(updated);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

class FavoriteRecipesNotifier extends AsyncNotifier<Set<String>> {
  late JournalRepository _repository;

  @override
  Future<Set<String>> build() {
    _repository = ref.watch(journalRepositoryProvider);
    return _repository.loadFavoriteRecipeIds();
  }

  Future<void> toggle(String recipeId) async {
    if (recipeId.trim().isEmpty) {
      throw ArgumentError.value(recipeId, 'recipeId', 'Mã công thức rỗng.');
    }
    final previous = state.hasValue ? state.requireValue : await future;
    final updated = {...previous};
    if (!updated.add(recipeId)) {
      updated.remove(recipeId);
    }
    state = AsyncData(updated);
    try {
      await _repository.saveFavoriteRecipeIds(updated);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
