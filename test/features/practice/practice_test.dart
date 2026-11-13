import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';
import 'package:homemix/features/journal/providers/journal_providers.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(setUpJournalStorage);

  testWidgets('starts from Discover with the selected recipe', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    final recipe = find.text('Trà đào cam sả').first;
    await tester.ensureVisible(recipe);
    await tester.pumpAndSettle();
    await tester.tap(recipe);
    await tester.pumpAndSettle();

    final startButton = find.byKey(const ValueKey('discover-practice-button'));
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pumpAndSettle();

    expect(find.text('Trà đào cam sả'), findsOneWidget);
    expect(find.text('Chuẩn bị 5 phút'), findsOneWidget);
    expect(find.text('Pha 5 phút'), findsOneWidget);
    expect(find.text('Ấm đun nước'), findsOneWidget);
    expect(find.text('Bước 1/4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('guides Matcha through timers, steps, rating, and Journal save', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();

    expect(find.text('Matcha latte'), findsOneWidget);
    expect(find.text('Dâu tây sữa chua'), findsOneWidget);
    final matchaRecipe = find.byKey(
      const ValueKey('practice-recipe-matcha-latte'),
    );
    await tester.ensureVisible(matchaRecipe);
    await tester.pumpAndSettle();
    await tester.tap(matchaRecipe);
    await tester.pumpAndSettle();
    expect(find.text('Bột matcha'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('practice-serving-increase')));
    await tester.pumpAndSettle();
    expect(find.text('4 g'), findsOneWidget);

    final configureTimer = find.byKey(
      const ValueKey('practice-timer-configure'),
    );
    await tester.ensureVisible(configureTimer);
    await tester.pumpAndSettle();
    await tester.tap(configureTimer);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('practice-timer-seconds-field')),
      '2',
    );
    await tester.tap(find.byKey(const ValueKey('practice-timer-save')));
    await tester.pumpAndSettle();
    expect(find.text('00:02'), findsOneWidget);

    final timerStart = find.byKey(const ValueKey('practice-timer-start'));
    await tester.ensureVisible(timerStart);
    await tester.pumpAndSettle();
    await tester.tap(timerStart);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('practice-timer-pause')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('00:01'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('practice-timer-reset')));
    await tester.pumpAndSettle();
    expect(find.text('00:02'), findsOneWidget);

    final firstStepComplete = find.byKey(
      const ValueKey('practice-complete-step'),
    );
    await tester.ensureVisible(firstStepComplete);
    await tester.pumpAndSettle();
    await tester.tap(firstStepComplete);
    await tester.pumpAndSettle();
    final nextStep = find.byKey(const ValueKey('practice-next-step'));
    await tester.ensureVisible(nextStep);
    await tester.pumpAndSettle();
    await tester.tap(nextStep);
    await tester.pumpAndSettle();
    expect(find.text('Đánh matcha với nước ấm'), findsOneWidget);

    final previousStep = find.byKey(const ValueKey('practice-previous-step'));
    await tester.ensureVisible(previousStep);
    await tester.pumpAndSettle();
    await tester.tap(previousStep);
    await tester.pumpAndSettle();
    expect(find.text('Rây matcha'), findsOneWidget);
    await tester.ensureVisible(nextStep);
    await tester.pumpAndSettle();
    await tester.tap(nextStep);
    await tester.pumpAndSettle();

    for (var index = 1; index < 4; index++) {
      final completeStep = find.byKey(const ValueKey('practice-complete-step'));
      await tester.ensureVisible(completeStep);
      await tester.pumpAndSettle();
      await tester.tap(completeStep);
      await tester.pumpAndSettle();
      if (index < 3) {
        await tester.ensureVisible(nextStep);
        await tester.pumpAndSettle();
        await tester.tap(nextStep);
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('Bạn đã hoàn thành!'), findsOneWidget);
    expect(find.text('4/4 bước đã hoàn thành'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('practice-rating-5')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-save-journal')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('journal-form-cancel')));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainApp)),
    );
    expect(await container.read(journalEntriesProvider.future), isEmpty);

    await tester.tap(find.byKey(const ValueKey('practice-save-journal')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('journal-form-note')),
      'Matcha mịn, lần sau giảm mật ong.',
    );
    await tester.tap(find.byKey(const ValueKey('journal-form-save')));
    await tester.pumpAndSettle();
    expect(find.text('Đã lưu vào Journal'), findsOneWidget);

    final savedEntries = container.read(journalEntriesProvider).requireValue;
    expect(savedEntries, hasLength(1));
    expect(savedEntries.single.recipeId, 'matcha-latte');
    expect(savedEntries.single.recipeName, 'Matcha latte');
    expect(savedEntries.single.rating, 5);
    expect(savedEntries.single.note, 'Matcha mịn, lần sau giảm mật ong.');
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('practice-restart')));
    await tester.pumpAndSettle();
    expect(find.text('Bước 1/4'), findsOneWidget);
  });

  testWidgets('cancels the timer when leaving a practice session', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();

    final recipeCard = find.byKey(
      const ValueKey('practice-recipe-matcha-latte'),
    );
    await tester.ensureVisible(recipeCard);
    await tester.pumpAndSettle();
    await tester.tap(recipeCard);
    await tester.pumpAndSettle();
    expect(find.text('00:30'), findsOneWidget);

    final startTimer = find.byKey(const ValueKey('practice-timer-start'));
    await tester.ensureVisible(startTimer);
    await tester.pumpAndSettle();
    await tester.tap(startTimer);
    await tester.pump();
    await tester.ensureVisible(
      find.byKey(const ValueKey('practice-session-back')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('practice-session-back')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Chọn món để bắt đầu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
