import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import '../providers/learning_providers.dart';
import '../widgets/course_artwork.dart';
import '../widgets/learning_course_card.dart';
import '../widgets/learning_lesson_tile.dart';
import '../widgets/learning_progress_bar.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final course = ref.watch(learningCourseProvider(courseId));
    if (course == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Column(
            children: [
              _BackButton(),
              const Expanded(
                child: FeatureEmptyState(
                  title: 'Không tìm thấy khóa học',
                  message: 'Khóa học này có thể đã được cập nhật.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = ref.watch(learningProgressProvider);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: progress.when(
          loading: () =>
              const FeatureLoadingState(message: 'Đang tải khóa học...'),
          error: (error, stackTrace) => FeatureErrorState(
            message: 'Chưa thể tải tiến độ của khóa học.',
            onRetry: () => ref.invalidate(learningProgressProvider),
          ),
          data: (value) => _CourseContent(course: course, progress: value),
        ),
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.course, required this.progress});

  final LearningCourse course;
  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BackButton(),
                    const SizedBox(height: 10),
                    Stack(
                      children: [
                        CourseArtwork(artwork: course.artwork, height: 180),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: LearningLevelBadge(level: course.level),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.muted, height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CourseInfo(
                          icon: Icons.menu_book_rounded,
                          label: '${course.lessons.length} bài học',
                        ),
                        _CourseInfo(
                          icon: Icons.schedule_rounded,
                          label: formatLearningDuration(course.totalMinutes),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    LearningProgressBar(
                      progress: progress.percentFor(course) / 100,
                      label:
                          '${progress.completedCountFor(course)}/${course.lessons.length} bài đã hoàn thành',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Nội dung khóa học',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 13),
                    for (final chapter in course.chapters) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 9),
                        child: Text(
                          chapter.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      for (final lesson in chapter.lessons) ...[
                        LearningLessonTile(
                          courseId: course.id,
                          lesson: lesson,
                          status: progress.statusFor(lesson.id),
                        ),
                        const SizedBox(height: 9),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey('learning-back-button'),
      onPressed: () => context.go('/learning'),
      style: IconButton.styleFrom(backgroundColor: AppColors.white),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }
}

class _CourseInfo extends StatelessWidget {
  const _CourseInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.coral, size: 16),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
