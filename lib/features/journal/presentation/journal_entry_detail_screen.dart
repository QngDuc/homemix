import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../discover/providers/discover_providers.dart';
import '../domain/journal_entry.dart';
import '../providers/journal_providers.dart';
import '../widgets/journal_artwork.dart';
import '../widgets/journal_entry_form.dart';
import '../widgets/journal_rating_stars.dart';

class JournalEntryDetailScreen extends ConsumerWidget {
  const JournalEntryDetailScreen({required this.entryId, super.key});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(journalEntriesProvider);
    final recipes = ref.watch(recipesProvider);
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: entries.when(
          loading: () =>
              const FeatureLoadingState(message: 'Đang mở mục nhật ký...'),
          error: (error, stackTrace) => FeatureErrorState(
            message: 'Chưa thể đọc mục nhật ký đã lưu.',
            onRetry: () => ref.invalidate(journalEntriesProvider),
          ),
          data: (items) {
            JournalEntry? entry;
            for (final item in items) {
              if (item.id == entryId) {
                entry = item;
                break;
              }
            }
            if (entry == null) {
              return const FeatureEmptyState(
                title: 'Không tìm thấy mục nhật ký',
                message: 'Mục này có thể đã được xóa.',
              );
            }

            return recipes.when(
              loading: () =>
                  const FeatureLoadingState(message: 'Đang tải công thức...'),
              error: (error, stackTrace) => FeatureErrorState(
                message: 'Chưa thể tải công thức của mục này.',
                onRetry: () => ref.invalidate(recipesProvider),
              ),
              data: (allRecipes) {
                DrinkRecipe? recipe;
                for (final item in allRecipes) {
                  if (item.id == entry!.recipeId) {
                    recipe = item;
                    break;
                  }
                }
                return _JournalEntryDetail(
                  entry: entry!,
                  recipe: recipe,
                  onEdit: () => _editEntry(context, ref, entry!),
                  onDelete: () => _deleteEntry(context, ref, entry!),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _editEntry(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final draft = await showJournalEntryForm(
      context,
      initialRating: entry.rating,
      initialNote: entry.note,
      title: 'Chỉnh sửa nhật ký',
      saveLabel: 'Cập nhật',
    );
    if (draft == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(journalEntriesProvider.notifier)
          .updateEntry(entry.id, draft);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('Đã cập nhật nhật ký.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Không thể cập nhật nhật ký: $error')),
          );
      }
    }
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    JournalEntry entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục nhật ký?'),
        content: Text('Bạn có muốn xóa "${entry.recipeName}" khỏi Journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(journalEntriesProvider.notifier).deleteEntry(entry.id);
      if (context.mounted) {
        context.go('/journal');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text('Không thể xóa mục nhật ký: $error')),
          );
      }
    }
  }
}

class _JournalEntryDetail extends StatelessWidget {
  const _JournalEntryDetail({
    required this.entry,
    required this.recipe,
    required this.onEdit,
    required this.onDelete,
  });

  final JournalEntry entry;
  final DrinkRecipe? recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          key: const ValueKey('journal-detail-back'),
                          onPressed: () => context.pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Spacer(),
                        IconButton(
                          key: const ValueKey('journal-entry-edit'),
                          tooltip: 'Chỉnh sửa nhật ký',
                          onPressed: onEdit,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.edit_rounded),
                        ),
                        IconButton(
                          key: const ValueKey('journal-entry-delete'),
                          tooltip: 'Xóa nhật ký',
                          onPressed: onDelete,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.coral,
                          ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    JournalArtwork(
                      recipe: recipe,
                      imagePath: entry.imagePath,
                      height: 220,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      entry.recipeName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Pha ngày ${_formatDate(entry.date)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    JournalRatingStars(rating: entry.rating, size: 22),
                    const SizedBox(height: 22),
                    _DetailPanel(
                      title: 'Ghi chú của bạn',
                      icon: Icons.edit_note_rounded,
                      child: Text(
                        entry.note.isEmpty ? 'Chưa có ghi chú.' : entry.note,
                        style: Theme.of(context).textTheme.bodyLarge
                            ?.copyWith(height: 1.5),
                      ),
                    ),
                    if (entry.imagePath == null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Ảnh cá nhân chưa được hỗ trợ; hình minh hoạ công thức đang được sử dụng.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (recipe != null) ...[
                      const SizedBox(height: 21),
                      Text(
                        'Công thức đã thực hiện',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      _DetailPanel(
                        title: 'Nguyên liệu',
                        icon: Icons.eco_rounded,
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < recipe!.ingredients.length;
                              index++
                            ) ...[
                              if (index > 0) const Divider(height: 17),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      recipe!.ingredients[index].name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: AppColors.navy),
                                    ),
                                  ),
                                  Text(
                                    recipe!.ingredients[index].formattedAmount,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.navy,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _DetailPanel(
                        title: 'Các bước pha',
                        icon: Icons.format_list_numbered_rounded,
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < recipe!.steps.length;
                              index++
                            )
                              Padding(
                                padding: const EdgeInsets.only(bottom: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.coral,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        recipe!.steps[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.navy,
                                              height: 1.4,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          key: const ValueKey('journal-open-recipe'),
                          onPressed: () =>
                              context.push('/discover/recipe/${recipe!.id}'),
                          icon: const Icon(Icons.menu_book_rounded),
                          label: const Text('Mở công thức'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.coral, size: 19),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
