import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../providers/journal_providers.dart';

class FavoriteRecipeButton extends ConsumerWidget {
  const FavoriteRecipeButton({
    required this.recipeId,
    this.backgroundColor,
    this.iconSize = 20,
    super.key,
  });

  final String recipeId;
  final Color? backgroundColor;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteRecipeIdsProvider);
    final isFavorite = favorites.asData?.value.contains(recipeId) ?? false;
    final isLoading = favorites.isLoading;
    final hasError = favorites.hasError;
    final tooltip = hasError
        ? 'Thử tải lại yêu thích'
        : isLoading
        ? 'Đang tải yêu thích'
        : isFavorite
        ? 'Bỏ yêu thích'
        : 'Thêm vào yêu thích';

    return Material(
      color: backgroundColor ?? AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        onPressed: isLoading
            ? null
            : hasError
            ? () {
                ref.invalidate(favoriteRecipeIdsProvider);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Đang thử tải lại danh sách yêu thích.'),
                    ),
                  );
              }
            : () => _toggle(context, ref),
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.coral : AppColors.navy,
          size: iconSize,
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(favoriteRecipeIdsProvider.notifier).toggle(recipeId);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Không thể cập nhật yêu thích: $error')),
          );
      }
    }
  }
}
