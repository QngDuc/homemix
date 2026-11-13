import 'journal_entry.dart';

abstract interface class JournalRepository {
  Future<List<JournalEntry>> loadEntries();

  Future<void> saveEntries(List<JournalEntry> entries);

  Future<Set<String>> loadFavoriteRecipeIds();

  Future<void> saveFavoriteRecipeIds(Set<String> recipeIds);
}
