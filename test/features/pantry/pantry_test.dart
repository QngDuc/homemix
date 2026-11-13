import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUpJournalStorage();
  });

  testWidgets('keeps Discover and Pantry navigation available', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    expect(find.text('Chào bạn,'), findsOneWidget);

    await tester.tap(find.text('Pantry').last);
    await tester.pumpAndSettle();
    expect(find.text('Pantry'), findsWidgets);
    expect(find.text('Trà đen'), findsOneWidget);
    expect(find.text('Còn hạn'), findsWidgets);
    expect(find.text('Sắp hết hạn'), findsWidgets);
    expect(find.text('Đã hết hạn'), findsOneWidget);

    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('Chào bạn,'), findsOneWidget);

    await tester.tap(find.text('Pantry').last);
    await tester.pumpAndSettle();
    expect(find.text('Trà đen'), findsOneWidget);
  });

  testWidgets('adds, edits, searches, filters, and deletes ingredients', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pantry').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('pantry-add-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('pantry-save-button')));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập tên nguyên liệu'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('pantry-name-field')),
      'Chanh vàng',
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

    expect(find.text('Chanh vàng'), findsOneWidget);
    expect(find.text('2 quả'), findsOneWidget);

    await tester.tap(find.byTooltip('Chỉnh sửa Chanh vàng'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('pantry-name-field')),
      'Chanh xanh',
    );
    await tester.enterText(
      find.byKey(const ValueKey('pantry-quantity-field')),
      '3',
    );
    await tester.tap(find.byKey(const ValueKey('pantry-save-button')));
    await tester.pumpAndSettle();

    expect(find.text('Chanh xanh'), findsOneWidget);
    expect(find.text('3 quả'), findsOneWidget);
    expect(find.text('Chanh vàng'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('pantry-search-field')),
      'chanh xanh',
    );
    await tester.pumpAndSettle();
    expect(find.text('Chanh xanh'), findsOneWidget);
    expect(find.text('Trà đen'), findsNothing);

    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    final categoryList = find.byKey(const ValueKey('pantry-category-list'));
    await tester.drag(categoryList, const Offset(-350, 0));
    await tester.pumpAndSettle();
    final fruitCategory = find.byKey(
      const ValueKey('pantry-category-Trái cây'),
    );
    await tester.ensureVisible(fruitCategory);
    await tester.pumpAndSettle();
    await tester.tap(fruitCategory);
    await tester.pumpAndSettle();
    expect(find.text('Chanh xanh'), findsNothing);
    expect(find.text('Cam tươi'), findsOneWidget);

    await tester.drag(categoryList, const Offset(350, 0));
    await tester.pumpAndSettle();
    final allCategories = find.byKey(const ValueKey('pantry-category-Tất cả'));
    await tester.ensureVisible(allCategories);
    await tester.pumpAndSettle();
    await tester.tap(allCategories);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Xóa Chanh xanh'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa').last);
    await tester.pumpAndSettle();

    expect(find.text('Chanh xanh'), findsNothing);
  });

  testWidgets('fits Pantry on a compact Android viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ProviderScope(child: MainApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pantry').last);
    await tester.pumpAndSettle();

    expect(find.text('Pantry'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
