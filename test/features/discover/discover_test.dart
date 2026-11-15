import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';
import 'package:homemix/app/router/app_router.dart';

import '../../support/auth_test_setup.dart';
import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(setUpJournalStorage);

  testWidgets('loads mock recipes and filters them by search query', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testMainApp());
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

  testWidgets('renders Mojito detail from a direct route', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testMainApp());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainApp)),
    );
    container
        .read(appRouterProvider)
        .go('/discover/recipe/non-alcoholic-mojito');
    await tester.pumpAndSettle();

    expect(find.text('Mojito không cồn'), findsWidgets);
    expect(find.text('Nguyên liệu'), findsOneWidget);
    expect(find.text('4 món cần có'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('discover-practice-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('favorite action can be toggled from a recipe card', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testMainApp());
    await tester.pumpAndSettle();

    final favoriteButton = find.byTooltip('Thêm vào yêu thích').first;
    await tester.ensureVisible(favoriteButton);
    await tester.pumpAndSettle();
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Bỏ yêu thích'), findsWidgets);
  });

  testWidgets('fits the five-tab layout on a compact phone viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(testMainApp());
    await tester.pumpAndSettle();

    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Nhật ký'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
