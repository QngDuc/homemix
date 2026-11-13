import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/app/app.dart';
import 'package:homemix/features/learning/data/shared_preferences_learning_progress_repository.dart';
import 'package:homemix/features/learning/domain/learning_progress.dart';
import 'package:homemix/features/learning/domain/learning_progress_repository.dart';
import 'package:homemix/features/learning/providers/learning_providers.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../support/journal_storage_test_setup.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUpJournalStorage();
  });

  testWidgets('filters courses and navigates through lesson progress', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final progressRepository = _MemoryLearningProgressRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          learningProgressRepositoryProvider.overrideWithValue(
            progressRepository,
          ),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Learning').last);
    await tester.pumpAndSettle();

    expect(find.text('Bartending cơ bản'), findsOneWidget);
    expect(find.text('Nghệ thuật pha trà trái cây'), findsOneWidget);
    expect(find.text('Cà phê và các phương pháp pha chế'), findsOneWidget);

    final intermediateFilter = find.byKey(
      const ValueKey('learning-level-Intermediate'),
    );
    await tester.ensureVisible(intermediateFilter);
    await tester.pumpAndSettle();
    await tester.tap(intermediateFilter);
    await tester.pumpAndSettle();
    expect(find.text('Nghệ thuật pha trà trái cây'), findsOneWidget);
    expect(find.text('Bartending cơ bản'), findsNothing);

    await tester.drag(
      find.byKey(const ValueKey('learning-level-list')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    final allFilter = find.byKey(const ValueKey('learning-level-Tất cả'));
    await tester.ensureVisible(allFilter);
    await tester.pumpAndSettle();
    await tester.tap(allFilter);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('learning-course-bartending-basics')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nội dung khóa học'), findsOneWidget);
    expect(find.text('3 bài học'), findsOneWidget);

    final firstLesson = find.byKey(
      const ValueKey('learning-lesson-bartending-tools'),
    );
    await tester.ensureVisible(firstLesson);
    await tester.pumpAndSettle();
    await tester.tap(firstLesson);
    await tester.pumpAndSettle();
    expect(find.text('Dụng cụ và vệ sinh quầy pha chế'), findsOneWidget);
    expect(
      progressRepository.progress.statusFor('bartending-tools'),
      LessonLearningStatus.inProgress,
    );

    final nextButton = find.byKey(const ValueKey('learning-next-button'));
    await tester.ensureVisible(nextButton);
    await tester.pumpAndSettle();
    await tester.tap(nextButton);
    await tester.pumpAndSettle();
    expect(find.text('Cân bằng chua, ngọt và thơm'), findsOneWidget);

    final previousButton = find.byKey(
      const ValueKey('learning-previous-button'),
    );
    await tester.ensureVisible(previousButton);
    await tester.pumpAndSettle();
    await tester.tap(previousButton);
    await tester.pumpAndSettle();
    expect(find.text('Dụng cụ và vệ sinh quầy pha chế'), findsOneWidget);

    final completeButton = find.byKey(
      const ValueKey('learning-complete-button'),
    );
    await tester.ensureVisible(completeButton);
    await tester.pumpAndSettle();
    await tester.tap(completeButton);
    await tester.pumpAndSettle();

    expect(
      progressRepository.progress.statusFor('bartending-tools'),
      LessonLearningStatus.completed,
    );
    expect(find.text('1/3 bài trong khóa học đã hoàn thành'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('persists in-progress and completed lesson IDs locally', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    addTearDown(() => SharedPreferencesAsyncPlatform.instance = null);
    final repository = SharedPreferencesLearningProgressRepository();
    final progress = const LearningProgress()
        .startLesson('bartending-tools')
        .setLessonCompleted('bartending-flavor-balance', true);

    await repository.save(progress);
    final restored = await repository.load();

    expect(
      restored.statusFor('bartending-tools'),
      LessonLearningStatus.inProgress,
    );
    expect(
      restored.statusFor('bartending-flavor-balance'),
      LessonLearningStatus.completed,
    );
  });
}

class _MemoryLearningProgressRepository implements LearningProgressRepository {
  LearningProgress progress = const LearningProgress();

  @override
  Future<LearningProgress> load() async => progress;

  @override
  Future<void> save(LearningProgress progress) async {
    this.progress = progress;
  }
}
