import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(setUpJournalStorage);

  testWidgets(
    'updates drink matches when Pantry ingredients are added/deleted',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const ProviderScope(child: MainApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mix Now'));
      await tester.pumpAndSettle();

      expect(
        find.text('8 nguyên liệu trong Pantry · 0 món pha ngay'),
        findsOneWidget,
      );
      final mojito = find.text('Mojito không cồn');
      await tester.ensureVisible(mojito);
      await tester.pumpAndSettle();
      final mojitoCard = find.byKey(
        const ValueKey('mix-recommendation-non-alcoholic-mojito'),
      );
      expect(
        find.descendant(
          of: mojitoCard,
          matching: find.text('25% nguyên liệu có sẵn'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Pantry').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pantry-add-button')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('pantry-name-field')),
        'Chanh xanh',
      );
      await tester.enterText(
        find.byKey(const ValueKey('pantry-quantity-field')),
        '2',
      );
      await tester.enterText(
        find.byKey(const ValueKey('pantry-unit-field')),
        'quả',
      );
      await tester.tap(find.byKey(const ValueKey('pantry-save-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mix Now'));
      await tester.pumpAndSettle();
      expect(
        find.text('9 nguyên liệu trong Pantry · 0 món pha ngay'),
        findsOneWidget,
      );
      final updatedMojito = find.text('Mojito không cồn');
      await tester.ensureVisible(updatedMojito);
      await tester.pumpAndSettle();
      final updatedMojitoCard = find.byKey(
        const ValueKey('mix-recommendation-non-alcoholic-mojito'),
      );
      expect(
        find.descendant(
          of: updatedMojitoCard,
          matching: find.text('50% nguyên liệu có sẵn'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Pantry').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Xóa Chanh xanh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xóa').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mix Now'));
      await tester.pumpAndSettle();

      expect(
        find.text('8 nguyên liệu trong Pantry · 0 món pha ngay'),
        findsOneWidget,
      );
      final restoredMojito = find.text('Mojito không cồn');
      await tester.ensureVisible(restoredMojito);
      await tester.pumpAndSettle();
      final restoredMojitoCard = find.byKey(
        const ValueKey('mix-recommendation-non-alcoholic-mojito'),
      );
      expect(
        find.descendant(
          of: restoredMojitoCard,
          matching: find.text('25% nguyên liệu có sẵn'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'searches and filters recipes, opens details, and links to Practice',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(const ProviderScope(child: MainApp()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mix Now'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('mix-search-field')),
        'mojito',
      );
      await tester.pumpAndSettle();
      expect(find.text('Mojito không cồn'), findsOneWidget);
      expect(find.text('Trà đào cam sả'), findsNothing);

      await tester.tap(find.byTooltip('Xóa tìm kiếm'));
      await tester.pumpAndSettle();
      final categories = find.byKey(const ValueKey('mix-category-list'));
      await tester.drag(categories, const Offset(-300, 0));
      await tester.pumpAndSettle();
      final mocktailFilter = find.byKey(
        const ValueKey('mix-category-Mocktail'),
      );
      await tester.ensureVisible(mocktailFilter);
      await tester.pumpAndSettle();
      await tester.tap(mocktailFilter);
      await tester.pumpAndSettle();
      expect(find.text('Mojito không cồn'), findsOneWidget);
      expect(find.text('Cà phê sữa đá'), findsNothing);

      await tester.tap(find.text('Mojito không cồn'));
      await tester.pumpAndSettle();
      expect(find.text('Nguyên liệu'), findsOneWidget);
      expect(find.text('Lá bạc hà'), findsOneWidget);
      expect(find.text('Cách pha'), findsOneWidget);

      final practiceButton = find.byKey(const ValueKey('mix-practice-button'));
      await tester.ensureVisible(practiceButton);
      await tester.pumpAndSettle();
      await tester.tap(practiceButton);
      await tester.pumpAndSettle();
      expect(find.text('Mojito không cồn'), findsOneWidget);
      expect(find.text('Bước 1/3'), findsOneWidget);
    },
  );
}
