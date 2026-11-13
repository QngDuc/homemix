import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../providers/practice_providers.dart';
import '../widgets/practice_recipe_card.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(practiceRecipesProvider);

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
                      const _PracticeHeader(),
                      const SizedBox(height: 20),
                      recipes.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: FeatureLoadingState(
                            message: 'Đang chuẩn bị công thức...',
                          ),
                        ),
                        error: (error, stackTrace) => FeatureErrorState(
                          message: 'Chưa thể tải công thức để thực hành.',
                          onRetry: () =>
                              ref.invalidate(practiceRecipesProvider),
                        ),
                        data: (items) => items.isEmpty
                            ? const FeatureEmptyState(
                                title: 'Chưa có công thức thực hành',
                                message:
                                    'Các công thức mới sẽ xuất hiện tại đây.',
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chọn món để bắt đầu',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  for (
                                    var index = 0;
                                    index < items.length;
                                    index++
                                  ) ...[
                                    PracticeRecipeCard(
                                      practiceRecipe: items[index],
                                    ),
                                    if (index < items.length - 1)
                                      const SizedBox(height: 11),
                                  ],
                                ],
                              ),
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
}

class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRACTICE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.coral,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cùng pha từng bước',
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Chuẩn bị nguyên liệu, theo dõi thời gian và hoàn thành món uống của bạn.',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.navy, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_drink_rounded,
              color: AppColors.coral,
            ),
          ),
        ],
      ),
    );
  }
}
