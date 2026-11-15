import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_state.dart';
import '../domain/pantry_ingredient.dart';
import '../providers/pantry_providers.dart';
import '../widgets/pantry_ingredient_card.dart';
import '../widgets/pantry_ingredient_form.dart';

class PantryScreen extends ConsumerStatefulWidget {
  const PantryScreen({super.key});

  @override
  ConsumerState<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends ConsumerState<PantryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Set<PantryCategory>? _selectedCategories;
  String _selectedCategoryLabel = 'Tất cả';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = ref.watch(pantryIngredientsProvider);
    final filteredIngredients = ingredients.where((ingredient) {
      final matchesCategory =
          _selectedCategories == null ||
          _selectedCategories!.contains(ingredient.category);
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          ingredient.name.toLowerCase().contains(query) ||
          ingredient.category.label.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    final expiringCount = ingredients
        .where(
          (ingredient) =>
              ingredient.expiryStatus == PantryExpiryStatus.expiringSoon,
        )
        .length;
    return Scaffold(
      backgroundColor: AppColors.white,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('pantry-add-button'),
        tooltip: 'Thêm nguyên liệu',
        onPressed: _addIngredient,
        backgroundColor: AppColors.coral,
        foregroundColor: AppColors.white,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const ValueKey('pantry-list'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 112),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 393),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PantryHeader(),
                        const SizedBox(height: 20),
                        TextField(
                          key: const ValueKey('pantry-search-field'),
                          controller: _searchController,
                          onChanged: (value) =>
                              setState(() => _searchQuery = value.trim()),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Tìm nguyên liệu...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.coral,
                            ),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Xóa tìm kiếm',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _CategoryFilters(
                          selectedLabel: _selectedCategoryLabel,
                          onSelected: _selectCategory,
                        ),
                        if (expiringCount > 0) ...[
                          const SizedBox(height: 12),
                          _FreshnessReminder(count: expiringCount),
                        ],
                        const SizedBox(height: 16),
                        if (filteredIngredients.isEmpty)
                          FeatureEmptyState(
                            title: ingredients.isEmpty
                                ? 'Pantry đang trống'
                                : 'Không tìm thấy nguyên liệu',
                            message: ingredients.isEmpty
                                ? 'Thêm nguyên liệu đầu tiên để bắt đầu nhé.'
                                : 'Thử từ khóa khác hoặc chọn danh mục khác.',
                          )
                        else
                          GridView.builder(
                            key: const ValueKey('pantry-grid'),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredIngredients.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  mainAxisExtent: 96,
                                ),
                            itemBuilder: (context, index) {
                              final ingredient = filteredIngredients[index];
                              return PantryIngredientCard(
                                ingredient: ingredient,
                                onEdit: () => _editIngredient(ingredient),
                                onDelete: () => _confirmDelete(ingredient),
                              );
                            },
                          ),
                        const SizedBox(height: 18),
                        Text(
                          'Có ${ingredients.length} nguyên liệu trong tủ',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ít nguyên liệu, nhiều cách pha.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectCategory(String label) {
    setState(() {
      _selectedCategoryLabel = label;
      _selectedCategories = switch (label) {
        'Trái cây' => {PantryCategory.fruit},
        'Sữa' => {PantryCategory.dairy},
        'Trà & cà phê' => {PantryCategory.tea, PantryCategory.coffee},
        'Tạo ngọt' => {PantryCategory.syrup},
        _ => null,
      };
    });
  }

  Future<void> _addIngredient() async {
    final ingredient = await _showIngredientForm();
    if (ingredient == null || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).add(ingredient);
    _showMessage('Đã thêm ${ingredient.name} vào Pantry.');
  }

  Future<void> _editIngredient(PantryIngredient ingredient) async {
    final updated = await _showIngredientForm(ingredient: ingredient);
    if (updated == null || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).update(updated);
    _showMessage('Đã cập nhật ${updated.name}.');
  }

  Future<PantryIngredient?> _showIngredientForm({
    PantryIngredient? ingredient,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return showModalBottomSheet<PantryIngredient>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => PantryIngredientForm(ingredient: ingredient),
    );
  }

  Future<void> _confirmDelete(PantryIngredient ingredient) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nguyên liệu?'),
        content: Text('Bạn có chắc muốn xóa ${ingredient.name} khỏi Pantry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Giữ lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) {
      return;
    }
    ref.read(pantryIngredientsProvider.notifier).delete(ingredient.id);
    _showMessage('Đã xóa ${ingredient.name}.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PantryHeader extends StatelessWidget {
  const _PantryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Tủ nguyên liệu',
                style: Theme.of(context).textTheme.headlineMedium,
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
        const SizedBox(height: 8),
        Text(
          'Quản lý nguyên liệu có sẵn tại nhà.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.selectedLabel,
    required this.onSelected,
  });

  final String selectedLabel;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        key: const ValueKey('pantry-category-list'),
        scrollDirection: Axis.horizontal,
        children: [
          for (final label in const [
            'Tất cả',
            'Trái cây',
            'Sữa',
            'Trà & cà phê',
            'Tạo ngọt',
          ])
            _FilterChip(
              label: label,
              selected: selectedLabel == label,
              onTap: () => onSelected(label),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
        key: ValueKey('pantry-category-$label'),
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
        backgroundColor: AppColors.cream,
        side: BorderSide(color: selected ? AppColors.navy : AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}

class _FreshnessReminder extends StatelessWidget {
  const _FreshnessReminder({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.pastelPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.priority_high_rounded,
            size: 15,
            color: Color(0xFFAA4C62),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count nguyên liệu sắp hết hạn',
              style: const TextStyle(
                color: Color(0xFFAA4C62),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            'Dùng sớm',
            style: TextStyle(color: Color(0xFFAA4C62), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
