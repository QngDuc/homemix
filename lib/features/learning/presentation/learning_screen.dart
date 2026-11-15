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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LearningSummary(
          completedCount: completedCount,
          totalLessonCount: ref
              .read(learningCoursesProvider)
              .fold(0, (total, course) => total + course.lessons.length),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView(
            key: const ValueKey('learning-level-list'),
            scrollDirection: Axis.horizontal,
            children: [
              _LevelFilterChip(
                label: 'Tất cả',
                keyLabel: 'Tất cả',
                selected: _selectedLevel == null,
                onTap: () => setState(() => _selectedLevel = null),
              ),
              for (final level in CourseLevel.values)
                _LevelFilterChip(
                  label: level.displayName,
                  keyLabel: level.label,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Học pha chế',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 23, fontWeight: FontWeight.w600),
              ),
            ),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'home',
                    style: TextStyle(color: AppColors.navy),
                  ),
                  TextSpan(
                    text: 'mix',
                    style: TextStyle(color: AppColors.coral),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Học pha chế\nnhư chuyên gia',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 26, height: 1.35),
        ),
        const SizedBox(height: 6),
        Text(
          'Nâng cao kỹ năng pha chế\nqua từng bước nhỏ.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
      ],
    );
  }
}

class _LearningSummary extends StatelessWidget {
  const _LearningSummary({
    required this.completedCount,
    required this.totalLessonCount,
  });

  final int completedCount;
  final int totalLessonCount;

  @override
  Widget build(BuildContext context) {
    final percent = totalLessonCount == 0
        ? 0
        : (completedCount / totalLessonCount * 100).round();

    return Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF4E3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hành trình pha chế',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontSize: 16),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFF4B6F20),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Đã hoàn thành $completedCount/$totalLessonCount bài',
            style: const TextStyle(color: Color(0xFF4B6F20), fontSize: 12),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 4,
              color: AppColors.green,
              backgroundColor: const Color(0xFFDCE6CA),
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
    required this.keyLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String keyLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        key: ValueKey('learning-level-$keyLabel'),
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
