import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../domain/learning_course.dart';
import '../domain/learning_progress.dart';
import '../providers/learning_providers.dart';
import '../widgets/learning_course_card.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  CourseLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(learningCoursesProvider);
    final progress = ref.watch(learningProgressProvider);
    final filteredCourses = courses
        .where(
          (course) => _selectedLevel == null || course.level == _selectedLevel,
        )
        .toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LearningHeader(),
                      const SizedBox(height: 20),
                      progress.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: FeatureLoadingState(
                            message: 'Đang tải tiến độ học...',
                          ),
                        ),
                        error: (error, stackTrace) => FeatureErrorState(
                          message: 'Chưa thể đọc tiến độ học đã lưu.',
                          onRetry: () =>
                              ref.invalidate(learningProgressProvider),
                        ),
                        data: (value) =>
                            _buildCourseList(context, filteredCourses, value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(
    BuildContext context,
    List<LearningCourse> courses,
    LearningProgress progress,
  ) {
    final completedCount = progress.completedLessonIds.length;
    final startedCount = progress.inProgressLessonIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LearningSummary(
          completedCount: completedCount,
          startedCount: startedCount,
          courseCount: ref.read(learningCoursesProvider).length,
        ),
        const SizedBox(height: 24),
        Text('Lộ trình học', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 11),
        SizedBox(
          height: 42,
          child: ListView(
            key: const ValueKey('learning-level-list'),
            scrollDirection: Axis.horizontal,
            children: [
              _LevelFilterChip(
                label: 'Tất cả',
                selected: _selectedLevel == null,
                onTap: () => setState(() => _selectedLevel = null),
              ),
              for (final level in CourseLevel.values)
                _LevelFilterChip(
                  label: level.label,
                  selected: _selectedLevel == level,
                  onTap: () => setState(() => _selectedLevel = level),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (courses.isEmpty)
          const FeatureEmptyState(
            title: 'Chưa có khóa học ở cấp độ này',
            message: 'Chọn một cấp độ khác để khám phá lộ trình học nhé.',
          )
        else
          for (var index = 0; index < courses.length; index++) ...[
            LearningCourseCard(course: courses[index], progress: progress),
            if (index < courses.length - 1) const SizedBox(height: 13),
          ],
      ],
    );
  }
}

class _LearningHeader extends StatelessWidget {
  const _LearningHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LEARNING',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.coral,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Học pha chế, từng bước một',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 6),
              Text(
                'Từ những kỹ thuật đầu tiên đến công thức bạn yêu thích.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.pastelPink,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_book_rounded, color: AppColors.coral),
        ),
      ],
    );
  }
}

class _LearningSummary extends StatelessWidget {
  const _LearningSummary({
    required this.completedCount,
    required this.startedCount,
    required this.courseCount,
  });

  final int completedCount;
  final int startedCount;
  final int courseCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_stories_rounded, color: AppColors.coral),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              '$courseCount lộ trình · $startedCount đang học · $completedCount bài đã hoàn thành',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelFilterChip extends StatelessWidget {
  const _LevelFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        key: ValueKey('learning-level-$label'),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: AppColors.navy,
        backgroundColor: AppColors.white,
        side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }
}
