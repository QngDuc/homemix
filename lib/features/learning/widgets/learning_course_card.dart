import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import 'course_artwork.dart';
import 'learning_progress_bar.dart';

class LearningCourseCard extends StatelessWidget {
  const LearningCourseCard({
    required this.course,
    required this.progress,
    super.key,
  });

  final LearningCourse course;
  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final completed = progress.completedCountFor(course);
    final percent = progress.percentFor(course);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        key: ValueKey('learning-course-${course.id}'),
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/learning/course/${course.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CourseArtwork(artwork: course.artwork, height: 132),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _LevelBadge(level: course.level),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                course.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${course.lessons.length} bài',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 13),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(course.totalMinutes),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LearningProgressBar(
                progress: percent / 100,
                label: '$completed/${course.lessons.length} bài đã hoàn thành',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LearningLevelBadge extends StatelessWidget {
  const LearningLevelBadge({required this.level, super.key});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) => _LevelBadge(level: level);
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (level) {
      CourseLevel.beginner => (
        const Color(0xFFEAF2DA),
        const Color(0xFF638B2F),
      ),
      CourseLevel.intermediate => (
        const Color(0xFFFFF0D8),
        const Color(0xFFB36B25),
      ),
      CourseLevel.advanced => (
        const Color(0xFFE9E2F3),
        const Color(0xFF715B9A),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        level.label,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String formatLearningDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes phút';
  }
  final hours = minutes ~/ 60;
  final remaining = minutes % 60;
  return remaining == 0 ? '$hours giờ' : '$hours giờ $remaining phút';
}

String _formatDuration(int minutes) => formatLearningDuration(minutes);
