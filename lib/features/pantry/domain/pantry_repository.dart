import 'pantry_ingredient.dart';

abstract interface class PantryRepository {
  List<PantryIngredient> getIngredients();

  void addIngredient(PantryIngredient ingredient);

  void updateIngredient(PantryIngredient ingredient);

  void deleteIngredient(String id);
}
