import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';
import 'package:homemix/features/journal/data/shared_preferences_journal_repository.dart';
import 'package:homemix/features/journal/domain/journal_entry.dart';
import 'package:homemix/features/journal/domain/journal_repository.dart';
import 'package:homemix/features/journal/providers/journal_providers.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(setUpJournalStorage);

  test('entries and favorites persist across repository instances', () async {
    final repository = SharedPreferencesJournalRepository();
    final container = ProviderContainer(
      overrides: [journalRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    await container.read(journalEntriesProvider.future);
    final entry = await container
        .read(journalEntriesProvider.notifier)
        .addEntry(
          recipeId: 'peach-tea',
          recipeName: 'Trà đào cam sả',
          date: DateTime(2026, 6, 1),
          rating: 5,
          note: 'Ít ngọt',
        );
    await container
        .read(journalEntriesProvider.notifier)
        .updateEntry(
          entry.id,
          const JournalEntryDraft(rating: null, note: 'Giảm syrup lần sau'),
        );
    await container.read(favoriteRecipeIdsProvider.future);
    await container
        .read(favoriteRecipeIdsProvider.notifier)
        .toggle('peach-tea');
    await container
        .read(favoriteRecipeIdsProvider.notifier)
        .toggle('peach-tea');
    await container
        .read(favoriteRecipeIdsProvider.notifier)
        .toggle('peach-tea');

    final reopenedRepository = SharedPreferencesJournalRepository();
    final savedEntries = await reopenedRepository.loadEntries();
    final savedFavorites = await reopenedRepository.loadFavoriteRecipeIds();

    expect(savedEntries, hasLength(1));
    expect(savedEntries.single.note, 'Giảm syrup lần sau');
    expect(savedEntries.single.rating, isNull);
    expect(savedFavorites, {'peach-tea'});
  });

  testWidgets('searches, filters, edits, and deletes journal entries', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _MemoryJournalRepository([
      JournalEntry(
        id: 'newest',
        recipeId: 'peach-tea',
        recipeName: 'Trà đào cam sả',
        date: DateTime.now(),
        rating: 5,
        note: 'Thơm dịu',
      ),
      JournalEntry(
        id: 'older',
        recipeId: 'matcha-latte',
        recipeName: 'Matcha latte',
        date: DateTime.now().subtract(const Duration(days: 12)),
        rating: 3,
        note: 'Lần sau đánh lâu hơn',
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [journalRepositoryProvider.overrideWithValue(repository)],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();

    expect(find.text('Trà đào cam sả'), findsOneWidget);
    expect(find.text('Matcha latte'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('journal-search')),
      'matcha',
    );
    await tester.pumpAndSettle();
    expect(find.text('Matcha latte'), findsOneWidget);
    expect(find.text('Trà đào cam sả'), findsNothing);
    final threeStarFilter = find.byKey(const ValueKey('journal-rating-3'));
    await tester.ensureVisible(threeStarFilter);
    await tester.pumpAndSettle();
    await tester.tap(threeStarFilter);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('journal-period-week')));
    await tester.pumpAndSettle();
    expect(find.text('Không tìm thấy mục phù hợp'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('journal-period-anytime')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('journal-entry-older')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('journal-entry-edit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bỏ đánh giá'));
    await tester.enterText(
      find.byKey(const ValueKey('journal-form-note')),
      'Đã chỉnh sửa',
    );
    await tester.tap(find.byKey(const ValueKey('journal-form-save')));
    await tester.pumpAndSettle();

    final editedEntry = repository.entries.singleWhere(
      (entry) => entry.id == 'older',
    );
    expect(editedEntry.rating, isNull);
    expect(editedEntry.note, 'Đã chỉnh sửa');

    await tester.tap(find.byKey(const ValueKey('journal-entry-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Xóa'));
    await tester.pumpAndSettle();
    expect(repository.entries, hasLength(1));
    expect(find.text('Hành trình pha chế của bạn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorites opened from Discover appear in Journal', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    final recipe = find.text('Trà đào cam sả').first;
    await tester.ensureVisible(recipe);
    await tester.pumpAndSettle();
    await tester.tap(recipe);
    await tester.pumpAndSettle();
    final favoriteButton = find.byTooltip('Thêm vào yêu thích');
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Journal').last);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Yêu thích'));
    await tester.pumpAndSettle();

    expect(find.text('Trà đào cam sả'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _MemoryJournalRepository implements JournalRepository {
  _MemoryJournalRepository(this.entries);

  List<JournalEntry> entries;
  final Set<String> favoriteIds = {};

  @override
  Future<List<JournalEntry>> loadEntries() async => List.of(entries);

  @override
  Future<Set<String>> loadFavoriteRecipeIds() async => Set.of(favoriteIds);

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    this.entries = List.of(entries);
  }

  @override
  Future<void> saveFavoriteRecipeIds(Set<String> recipeIds) async {
    favoriteIds
      ..clear()
      ..addAll(recipeIds);
  }
}
