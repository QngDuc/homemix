import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../domain/pantry_ingredient.dart';

class PantryIngredientCard extends StatelessWidget {
  const PantryIngredientCard({
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final PantryIngredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final status = ingredient.expiryStatus;
    final dateText =
        '${ingredient.expiryDate.day.toString().padLeft(2, '0')}/'
        '${ingredient.expiryDate.month.toString().padLeft(2, '0')}';
    final imagePath = _ingredientImagePath(ingredient.name);

    return Material(
      key: ValueKey('pantry-ingredient-${ingredient.id}'),
      color: ingredient.category == PantryCategory.tea
          ? const Color(0xFFEEF4E3)
          : AppColors.cream,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 30),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: imagePath == null
                        ? ColoredBox(
                            color: ingredient.category.color,
                            child: Icon(
                              ingredient.category.icon,
                              color: AppColors.navy,
                              size: 24,
                            ),
                          )
                        : Image.asset(imagePath, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ingredient.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ingredient.formattedQuantity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8,
            right: 4,
            bottom: 0,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    status == PantryExpiryStatus.expiringSoon
                        ? 'HSD: $dateText · SẮP HẾT'
                        : 'HSD: $dateText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: status == PantryExpiryStatus.expiringSoon
                          ? status.foregroundColor
                          : AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
                IconButton(
                  key: ValueKey('edit-${ingredient.id}'),
                  tooltip: 'Chỉnh sửa ${ingredient.name}',
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.edit_outlined, size: 15),
                ),
                IconButton(
                  key: ValueKey('delete-${ingredient.id}'),
                  tooltip: 'Xóa ${ingredient.name}',
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 15,
                    color: AppColors.coral,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String? _ingredientImagePath(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('dâu tây')) {
    return 'assets/images/figma/ingredient_strawberry.png';
  }
  if (normalized.contains('chanh vàng')) {
    return 'assets/images/figma/ingredient_lemon.png';
  }
  if (normalized.contains('cam')) {
    return 'assets/images/figma/ingredient_orange.png';
  }
  if (normalized.contains('sữa')) {
    return 'assets/images/figma/ingredient_milk.png';
  }
  if (normalized.contains('matcha')) {
    return 'assets/images/figma/ingredient_matcha.png';
  }
  if (normalized.contains('đường')) {
    return 'assets/images/figma/ingredient_sugar.png';
  }
  if (normalized.contains('mật ong')) {
    return 'assets/images/figma/ingredient_honey.png';
  }
  if (normalized.contains('bạc hà')) {
    return 'assets/images/figma/ingredient_mint.png';
  }
  return null;
}
