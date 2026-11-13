import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_learning_catalog_repository.dart';
import '../data/shared_preferences_learning_progress_repository.dart';
import '../domain/learning_catalog_repository.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import '../domain/learning_progress_repository.dart';

final learningCatalogRepositoryProvider = Provider<LearningCatalogRepository>(
  (ref) => const MockLearningCatalogRepository(),
);

final learningCoursesProvider = Provider<List<LearningCourse>>(
  (ref) => ref.watch(learningCatalogRepositoryProvider).getCourses(),
);

final learningCourseProvider = Provider.family<LearningCourse?, String>(
  (ref, courseId) =>
      ref.watch(learningCatalogRepositoryProvider).getCourse(courseId),
);

final learningProgressRepositoryProvider = Provider<LearningProgressRepository>(
  (ref) => SharedPreferencesLearningProgressRepository(),
);

final learningProgressProvider =
    AsyncNotifierProvider<LearningProgressNotifier, LearningProgress>(
      LearningProgressNotifier.new,
    );

class LearningProgressNotifier extends AsyncNotifier<LearningProgress> {
  late LearningProgressRepository _repository;

  @override
  Future<LearningProgress> build() {
    _repository = ref.watch(learningProgressRepositoryProvider);
    return _repository.load();
  }

  Future<void> startLesson(String lessonId) {
    return _update((progress) => progress.startLesson(lessonId));
  }

  Future<void> setLessonCompleted(String lessonId, bool completed) {
    return _update(
      (progress) => progress.setLessonCompleted(lessonId, completed),
    );
  }

  Future<void> _update(
    LearningProgress Function(LearningProgress progress) transform,
  ) async {
    final previous = state.requireValue;
    final updated = transform(previous);
    if (updated.completedLessonIds.length ==
            previous.completedLessonIds.length &&
        updated.inProgressLessonIds.length ==
            previous.inProgressLessonIds.length &&
        updated.completedLessonIds.containsAll(previous.completedLessonIds) &&
        updated.inProgressLessonIds.containsAll(previous.inProgressLessonIds)) {
      return;
    }

    state = AsyncData(updated);
    try {
      await _repository.save(updated);
    } catch (error, stackTrace) {
      state = AsyncData(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
