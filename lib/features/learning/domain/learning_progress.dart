import 'learning_course.dart';

enum LessonLearningStatus {
  notStarted('Chưa học'),
  inProgress('Đang học'),
  completed('Đã hoàn thành');

  const LessonLearningStatus(this.label);

  final String label;
}

class LearningProgress {
  const LearningProgress({
    this.completedLessonIds = const {},
    this.inProgressLessonIds = const {},
  });

  final Set<String> completedLessonIds;
  final Set<String> inProgressLessonIds;

  LessonLearningStatus statusFor(String lessonId) {
    if (completedLessonIds.contains(lessonId)) {
      return LessonLearningStatus.completed;
    }
    if (inProgressLessonIds.contains(lessonId)) {
      return LessonLearningStatus.inProgress;
    }
    return LessonLearningStatus.notStarted;
  }

  int completedCountFor(LearningCourse course) {
    return course.lessons
        .where((lesson) => completedLessonIds.contains(lesson.id))
        .length;
  }

  int percentFor(LearningCourse course) {
    if (course.lessons.isEmpty) {
      return 0;
    }
    return (completedCountFor(course) * 100 / course.lessons.length).round();
  }

  LearningProgress startLesson(String lessonId) {
    if (completedLessonIds.contains(lessonId) ||
        inProgressLessonIds.contains(lessonId)) {
      return this;
    }
    return LearningProgress(
      completedLessonIds: completedLessonIds,
      inProgressLessonIds: {...inProgressLessonIds, lessonId},
    );
  }

  LearningProgress setLessonCompleted(String lessonId, bool completed) {
    final nextCompleted = {...completedLessonIds};
    final nextInProgress = {...inProgressLessonIds};
    if (completed) {
      nextCompleted.add(lessonId);
      nextInProgress.remove(lessonId);
    } else {
      nextCompleted.remove(lessonId);
      nextInProgress.add(lessonId);
    }
    return LearningProgress(
      completedLessonIds: nextCompleted,
      inProgressLessonIds: nextInProgress,
    );
  }
}
