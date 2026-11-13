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
    final dateText = MaterialLocalizations.of(context)
        .formatMediumDate(ingredient.expiryDate);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: ingredient.category.color,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              ingredient.category.icon,
              color: AppColors.navy,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  ingredient.category.label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      ingredient.formattedQuantity,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _ExpiryBadge(status: status),
                    Text(
                      'HSD $dateText',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
                if (ingredient.note case final note?
                    when note.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: ValueKey('edit-${ingredient.id}'),
                tooltip: 'Chỉnh sửa ${ingredient.name}',
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                  color: AppColors.navy,
                ),
              ),
              IconButton(
                key: ValueKey('delete-${ingredient.id}'),
                tooltip: 'Xóa ${ingredient.name}',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 19,
                  color: AppColors.coral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.status});

  final PantryExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.foregroundColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
