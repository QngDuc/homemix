import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import 'course_artwork.dart';

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
    final cardColor = switch (course.artwork) {
      CourseArtworkType.bartending => const Color(0xFFEEF4E3),
      CourseArtworkType.fruitTea => AppColors.cream,
      CourseArtworkType.coffee => const Color(0xFFF9E1E5),
    };

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        key: ValueKey('learning-course-${course.id}'),
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/learning/course/${course.id}'),
        child: SizedBox(
          height: 124,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 100,
                  child: CourseArtwork(artwork: course.artwork, height: 100),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 14, height: 1.1),
                      ),
                      Text(
                        '${course.level.displayName} · '
                        '${course.lessons.length} bài · '
                        '${_formatDuration(course.totalMinutes)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 10,
                          height: 1.1,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$completed/${course.lessons.length} bài',
                              style: const TextStyle(
                                color: Color(0xFF4B6F20),
                                fontSize: 10,
                                height: 1.1,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(
                              color: Color(0xFF4B6F20),
                              fontSize: 10,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 4,
                          color: AppColors.green,
                          backgroundColor: const Color(0xFFDCE6CA),
                        ),
                      ),
                      Container(
                        height: 26,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.navy,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiếp tục học',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
