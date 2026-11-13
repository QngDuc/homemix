import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/mock_recipe_repository.dart';
import '../../../domain/entities/drink_recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';

final recipeRepositoryProvider = Provider<RecipeRepository>(
  (ref) => const MockRecipeRepository(),
);

final recipesProvider = FutureProvider<List<DrinkRecipe>>(
  (ref) => ref.watch(recipeRepositoryProvider).getRecipes(),
);
