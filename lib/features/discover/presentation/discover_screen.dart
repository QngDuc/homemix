import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../../core/widgets/feature_state.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../providers/discover_providers.dart';
import '../widgets/recipe_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  DrinkCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WelcomeHeader(),
                const SizedBox(height: 22),
                TextField(
                  controller: _searchController,
                  onChanged: (value) =>
                      setState(() => _searchQuery = value.trim()),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Tìm đồ uống, nguyên liệu...',
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.coral,
                    ),
                    suffixIcon: Icon(
                      Icons.tune_rounded,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                recipes.when(
                  data: (items) => _buildCatalog(context, items),
                  loading: () => const Padding(
                    padding: EdgeInsets.only(top: 72),
                    child: FeatureLoadingState(
                      message: 'Đang chuẩn bị công thức...',
                    ),
                  ),
                  error: (error, stackTrace) => FeatureErrorState(
                    message: 'Chưa thể tải danh sách công thức.',
                    onRetry: () => ref.invalidate(recipesProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, List<DrinkRecipe> recipes) {
    final filtered = recipes.where((recipe) {
      final matchesCategory =
          _selectedCategory == null || recipe.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.description.toLowerCase().contains(query) ||
          recipe.category.label.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
    final popularRecipes = recipes
        .where(
          (recipe) =>
              recipe.id == 'non-alcoholic-mojito' ||
              recipe.id == 'strawberry-yogurt',
        )
        .toList();

    if (_searchQuery.isNotEmpty || _selectedCategory != null) {
      return _RecipeResults(
        recipes: filtered,
        countLabel: '${filtered.length} món',
        title: _searchQuery.isEmpty
            ? 'Công thức dành cho bạn'
            : 'Kết quả tìm kiếm',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PreferenceCategories(
          selectedCategory: _selectedCategory,
          onSelected: (category) =>
              setState(() => _selectedCategory = category),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Đồ uống nổi bật',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedCategory = null),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 218,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final recipe in popularRecipes) ...[
                SizedBox(width: 164, child: RecipeCard(recipe: recipe)),
                const SizedBox(width: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        _PantryInvitation(onTap: () => context.go('/mix-now')),
        const SizedBox(height: 24),
        _RecipeResults(
          recipes: filtered,
          countLabel: '${filtered.length} món',
          title: 'Công thức dành cho bạn',
        ),
      ],
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Mở nguyên liệu',
              onPressed: () => context.go('/pantry'),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cream,
                foregroundColor: AppColors.navy,
                fixedSize: const Size(40, 40),
              ),
              icon: const Icon(Icons.menu_rounded, size: 20),
            ),
            Expanded(
              child: Center(
                child: Text.rich(
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Tài khoản',
              onSelected: (action) {
                if (action == 'logout') unawaited(_signOut(context, ref));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18),
                      SizedBox(width: 10),
                      Text('Đăng xuất'),
                    ],
                  ),
                ),
              ],
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(
                  'assets/images/figma/profile_avatar.png',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'CHÀO BẠN, NHÀ PHA CHẾ TẠI GIA',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFFAA4C62),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bạn muốn pha món gì hôm nay?',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 26, height: 1.35),
        ),
      ],
    );
  }
}

Future<void> _signOut(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(authRepositoryProvider).logout();
  } on FirebaseAuthException catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
  }
}

class _PreferenceCategories extends StatelessWidget {
  const _PreferenceCategories({
    required this.selectedCategory,
    required this.onSelected,
  });

  final DrinkCategory? selectedCategory;
  final ValueChanged<DrinkCategory> onSelected;

  static const _categories = <(String, DrinkCategory, String)>[
    (
      'Không cồn',
      DrinkCategory.mocktail,
      'assets/images/figma/discover_mojito.png',
    ),
    (
      'Trà trái cây',
      DrinkCategory.tea,
      'assets/images/figma/discover_strawberry_drink.png',
    ),
    ('Cà phê', DrinkCategory.coffee, 'assets/images/figma/discover_coffee.png'),
    (
      'Tốt cho sức khỏe',
      DrinkCategory.plantMilk,
      'assets/images/figma/discover_mojito.png',
    ),
    (
      'Sinh tố',
      DrinkCategory.smoothie,
      'assets/images/figma/discover_smoothie.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Món ngon theo gu', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final (label, category, imagePath) in _categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      key: ValueKey('discover-preference-$label'),
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onSelected(category),
                      child: SizedBox(
                        width: 63,
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                imagePath,
                                width: 40,
                                height: 43,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: Text(
                                label,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.navy,
                                  fontSize: 10,
                                  height: 1.25,
                                ),
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
        ),
      ],
    );
  }
}

class _PantryInvitation extends StatelessWidget {
  const _PantryInvitation({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pastelPink,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: const SizedBox(
          height: 72,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: Color(0xFFAA4C62)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pha từ nguyên liệu sẵn có',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tủ nguyên liệu nhỏ, sáng tạo vô tận.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: AppColors.navy),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeResults extends StatelessWidget {
  const _RecipeResults({
    required this.recipes,
    required this.countLabel,
    required this.title,
  });

  final List<DrinkRecipe> recipes;
  final String countLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Text(countLabel, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 12),
        if (recipes.isEmpty)
          const FeatureEmptyState(
            title: 'Chưa tìm thấy món phù hợp',
            message: 'Thử từ khóa khác hoặc chọn một danh mục nhé.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 560 ? 3 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recipes.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 218,
                ),
                itemBuilder: (context, index) =>
                    RecipeCard(recipe: recipes[index]),
              );
            },
          ),
      ],
    );
  }
}
