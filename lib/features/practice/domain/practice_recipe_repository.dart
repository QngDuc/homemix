import '../../../domain/entities/drink_recipe.dart';
import 'practice_recipe.dart';

abstract interface class PracticeRecipeRepository {
  List<PracticeRecipe> enrichRecipes(List<DrinkRecipe> recipes);
}
