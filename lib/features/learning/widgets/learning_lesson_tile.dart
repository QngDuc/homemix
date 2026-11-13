import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';

class LearningLessonTile extends StatelessWidget {
  const LearningLessonTile({
    required this.courseId,
    required this.lesson,
    required this.status,
    super.key,
  });

  final String courseId;
  final CourseLesson lesson;
  final LessonLearningStatus status;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      LessonLearningStatus.notStarted => (
        Icons.play_circle_outline_rounded,
        AppColors.muted,
      ),
      LessonLearningStatus.inProgress => (
        Icons.pending_rounded,
        const Color(0xFFB36B25),
      ),
      LessonLearningStatus.completed => (
        Icons.check_circle_rounded,
        const Color(0xFF638B2F),
      ),
    };

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('learning-lesson-${lesson.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () =>
            context.push('/learning/course/$courseId/lesson/${lesson.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 25),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lesson.estimatedMinutes} phút · ${status.label}',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: color, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
