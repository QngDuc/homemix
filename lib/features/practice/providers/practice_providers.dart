import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discover/providers/discover_providers.dart';
import '../data/mock_practice_recipe_repository.dart';
import '../domain/practice_recipe.dart';
import '../domain/practice_recipe_repository.dart';

final practiceRecipeRepositoryProvider = Provider<PracticeRecipeRepository>(
  (ref) => const MockPracticeRecipeRepository(),
);

final practiceRecipesProvider = FutureProvider<List<PracticeRecipe>>((
  ref,
) async {
  final recipes = await ref.watch(recipesProvider.future);
  return ref.watch(practiceRecipeRepositoryProvider).enrichRecipes(recipes);
});

final practiceRecipeProvider = FutureProvider.family<PracticeRecipe?, String>((
  ref,
  recipeId,
) async {
  final recipes = await ref.watch(practiceRecipesProvider.future);
  for (final recipe in recipes) {
    if (recipe.recipe.id == recipeId) {
      return recipe;
    }
  }
  return null;
});
