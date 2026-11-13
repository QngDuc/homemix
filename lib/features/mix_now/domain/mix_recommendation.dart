import '../../../domain/entities/drink_recipe.dart';
import '../../pantry/domain/pantry_ingredient.dart';

enum RecipeMatchStatus {
  ready('Có thể pha ngay'),
  missingFew('Thiếu một vài nguyên liệu'),
  notEnough('Chưa đủ nguyên liệu');

  const RecipeMatchStatus(this.label);

  final String label;
}

class MatchedRecipeIngredient {
  const MatchedRecipeIngredient({
    required this.recipeIngredient,
    this.pantryIngredient,
    this.isSubstitution = false,
  });

  final RecipeIngredient recipeIngredient;
  final PantryIngredient? pantryIngredient;
  final bool isSubstitution;

  bool get isAvailable => pantryIngredient != null;
}

class MixRecommendation {
  const MixRecommendation({required this.recipe, required this.ingredients});

  final DrinkRecipe recipe;
  final List<MatchedRecipeIngredient> ingredients;

  int get availableIngredientCount =>
      ingredients.where((ingredient) => ingredient.isAvailable).length;

  int get missingIngredientCount =>
      ingredients.length - availableIngredientCount;

  int get matchPercentage => ingredients.isEmpty
      ? 0
      : (availableIngredientCount * 100 / ingredients.length).round();

  bool get canMakeNow => missingIngredientCount == 0;

  RecipeMatchStatus get status {
    if (canMakeNow) {
      return RecipeMatchStatus.ready;
    }
    if (matchPercentage >= 50) {
      return RecipeMatchStatus.missingFew;
    }
    return RecipeMatchStatus.notEnough;
  }

  List<MatchedRecipeIngredient> get missingIngredients => ingredients
      .where((ingredient) => !ingredient.isAvailable)
      .toList(growable: false);

  List<MatchedRecipeIngredient> get substitutions => ingredients
      .where((ingredient) => ingredient.isSubstitution)
      .toList(growable: false);
}
