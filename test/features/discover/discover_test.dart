import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(setUpJournalStorage);

  testWidgets('loads mock recipes and filters them by search query', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();

    expect(find.text('Trà đào cam sả'), findsWidgets);
    expect(find.text('Sinh tố xoài'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'xoài');
    await tester.pumpAndSettle();

    expect(find.text('Sinh tố xoài'), findsOneWidget);
    expect(find.text('Trà đào cam sả'), findsNothing);
    expect(find.text('1 món'), findsOneWidget);

    final recipeTitle = find.text('Sinh tố xoài');
    await tester.ensureVisible(recipeTitle);
    await tester.pumpAndSettle();
    await tester.tap(recipeTitle);
    await tester.pumpAndSettle();
    expect(find.text('Nguyên liệu'), findsOneWidget);
  });

  testWidgets('favorite action can be toggled from a recipe card', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();

    final favoriteButton = find.byTooltip('Thêm vào yêu thích').first;
    await tester.ensureVisible(favoriteButton);
    await tester.pumpAndSettle();
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Bỏ yêu thích'), findsOneWidget);
  });

  testWidgets('fits the six-tab layout on a compact phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();

    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Journal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
