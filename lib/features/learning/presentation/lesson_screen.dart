import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import '../providers/learning_providers.dart';
import '../widgets/course_artwork.dart';
import '../widgets/learning_progress_bar.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({
    required this.courseId,
    required this.lessonId,
    super.key,
  });

  final String courseId;
  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _startRequested = false;
  bool _savingCompletion = false;

  @override
  void didUpdateWidget(covariant LessonScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessonId != widget.lessonId) {
      _startRequested = false;
      _savingCompletion = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = ref.watch(learningCourseProvider(widget.courseId));
    if (course == null) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: const SafeArea(
          child: FeatureEmptyState(
            title: 'Không tìm thấy khóa học',
            message: 'Hãy quay lại lộ trình để chọn một khóa học khác.',
          ),
        ),
      );
    }

    final lessonIndex = course.lessons.indexWhere(
      (lesson) => lesson.id == widget.lessonId,
    );
    if (lessonIndex < 0) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: const SafeArea(
          child: FeatureEmptyState(
            title: 'Không tìm thấy bài học',
            message: 'Bài học này có thể đã được cập nhật.',
          ),
        ),
      );
    }
    final lesson = course.lessons[lessonIndex];
    final progress = ref.watch(learningProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: progress.when(
          loading: () =>
              const FeatureLoadingState(message: 'Đang mở bài học...'),
          error: (error, stackTrace) => FeatureErrorState(
            message: 'Chưa thể tải tiến độ học đã lưu.',
            onRetry: () => ref.invalidate(learningProgressProvider),
          ),
          data: (value) {
            final status = value.statusFor(lesson.id);
            _startLessonIfNeeded(lesson.id, status);
            return _LessonContent(
              course: course,
              lesson: lesson,
              lessonIndex: lessonIndex,
              progress: value,
              isSaving: _savingCompletion,
              onComplete: () => _toggleCompletion(lesson.id, status),
              onPrevious: lessonIndex == 0
                  ? null
                  : () => _openLesson(course, lessonIndex - 1),
              onNext: lessonIndex == course.lessons.length - 1
                  ? null
                  : () => _openLesson(course, lessonIndex + 1),
            );
          },
        ),
      ),
    );
  }

  void _startLessonIfNeeded(String lessonId, LessonLearningStatus status) {
    if (status != LessonLearningStatus.notStarted || _startRequested) {
      return;
    }
    _startRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startLesson(lessonId));
      }
    });
  }

  Future<void> _startLesson(String lessonId) async {
    try {
      await ref.read(learningProgressProvider.notifier).startLesson(lessonId);
    } catch (error) {
      if (mounted) {
        _showError('Không thể lưu tiến độ bài học: $error');
      }
    }
  }

  Future<void> _toggleCompletion(
    String lessonId,
    LessonLearningStatus status,
  ) async {
    setState(() => _savingCompletion = true);
    try {
      await ref
          .read(learningProgressProvider.notifier)
          .setLessonCompleted(
            lessonId,
            status != LessonLearningStatus.completed,
          );
    } catch (error) {
      if (mounted) {
        _showError('Không thể lưu trạng thái bài học: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _savingCompletion = false);
      }
    }
  }

  void _openLesson(LearningCourse course, int index) {
    context.go(
      '/learning/course/${course.id}/lesson/${course.lessons[index].id}',
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LessonContent extends StatelessWidget {
  const _LessonContent({
    required this.course,
    required this.lesson,
    required this.lessonIndex,
    required this.progress,
    required this.isSaving,
    required this.onComplete,
    required this.onPrevious,
    required this.onNext,
  });

  final LearningCourse course;
  final CourseLesson lesson;
  final int lessonIndex;
  final LearningProgress progress;
  final bool isSaving;
  final VoidCallback onComplete;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final status = progress.statusFor(lesson.id);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      key: const ValueKey('learning-lesson-back-button'),
                      onPressed: () =>
                          context.go('/learning/course/${course.id}'),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.white,
                      ),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: 10),
                    CourseArtwork(artwork: course.artwork, height: 150),
                    const SizedBox(height: 15),
                    Text(
                      course.title.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.coral,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.summary,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: AppColors.muted, height: 1.5),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _LessonInfo(
                          icon: Icons.schedule_rounded,
                          label: '${lesson.estimatedMinutes} phút',
                        ),
                        _LessonInfo(
                          icon: status == LessonLearningStatus.completed
                              ? Icons.check_circle_rounded
                              : status == LessonLearningStatus.inProgress
                              ? Icons.pending_rounded
                              : Icons.radio_button_unchecked_rounded,
                          label: status.label,
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    LearningProgressBar(
                      progress: progress.percentFor(course) / 100,
                      label:
                          '${progress.completedCountFor(course)}/${course.lessons.length} bài trong khóa học đã hoàn thành',
                    ),
                    const SizedBox(height: 25),
                    for (final section in lesson.sections) ...[
                      Text(
                        section.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      _ReadingCard(text: section.body),
                      const SizedBox(height: 18),
                    ],
                    _LessonListPanel(
                      title: 'Nguyên liệu cần chuẩn bị',
                      icon: Icons.local_cafe_rounded,
                      items: lesson.ingredients,
                    ),
                    const SizedBox(height: 12),
                    _LessonListPanel(
                      title: 'Dụng cụ',
                      icon: Icons.kitchen_rounded,
                      items: lesson.tools,
                    ),
                    const SizedBox(height: 18),
                    _HighlightedPanel(
                      title: 'Kỹ thuật cần nhớ',
                      icon: Icons.tips_and_updates_rounded,
                      text: lesson.technique,
                      color: AppColors.pastelPink,
                    ),
                    const SizedBox(height: 12),
                    _LessonListPanel(
                      title: 'Lưu ý quan trọng',
                      icon: Icons.lightbulb_outline_rounded,
                      items: lesson.tips,
                      accentColor: AppColors.orange,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('learning-complete-button'),
                        onPressed: isSaving ? null : onComplete,
                        icon: Icon(
                          status == LessonLearningStatus.completed
                              ? Icons.undo_rounded
                              : Icons.check_rounded,
                        ),
                        label: Text(
                          status == LessonLearningStatus.completed
                              ? 'Bỏ đánh dấu hoàn thành'
                              : 'Đánh dấu đã hoàn thành',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              status == LessonLearningStatus.completed
                              ? AppColors.navy
                              : AppColors.coral,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            key: const ValueKey('learning-previous-button'),
                            onPressed: onPrevious,
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Bài trước'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.navy,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            key: const ValueKey('learning-next-button'),
                            onPressed: onNext,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Bài tiếp theo'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Bài ${lessonIndex + 1} / ${course.lessons.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
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

class _LessonInfo extends StatelessWidget {
  const _LessonInfo({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.coral),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}

class _LessonListPanel extends StatelessWidget {
  const _LessonListPanel({
    required this.title,
    required this.icon,
    required this.items,
    this.accentColor = AppColors.green,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.circle, color: accentColor, size: 7),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.navy),
                  ),
                ),
              ],
            ),
            if (item != items.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _HighlightedPanel extends StatelessWidget {
  const _HighlightedPanel({
    required this.title,
    required this.icon,
    required this.text,
    required this.color,
  });

  final String title;
  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.navy, size: 19),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.navy, height: 1.5),
          ),
        ],
      ),
    );
  }
}
