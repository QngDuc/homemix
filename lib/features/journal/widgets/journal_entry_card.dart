import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../domain/journal_entry.dart';
import 'journal_artwork.dart';
import 'journal_rating_stars.dart';

class JournalEntryCard extends StatelessWidget {
  const JournalEntryCard({
    required this.entry,
    required this.recipe,
    super.key,
  });

  final JournalEntry entry;
  final DrinkRecipe? recipe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: ValueKey('journal-entry-${entry.id}'),
        borderRadius: BorderRadius.circular(22),
        onTap: () => context.push('/journal/entry/${entry.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 82,
                height: 82,
                child: JournalArtwork(
                  recipe: recipe,
                  imagePath: entry.imagePath,
                  height: 82,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.recipeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(entry.date),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 5),
                    JournalRatingStars(rating: entry.rating, size: 14),
                    if (entry.note.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        entry.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppColors.navy),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
