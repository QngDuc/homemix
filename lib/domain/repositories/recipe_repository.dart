import '../entities/drink_recipe.dart';

abstract interface class RecipeRepository {
  Future<List<DrinkRecipe>> getRecipes();
}
