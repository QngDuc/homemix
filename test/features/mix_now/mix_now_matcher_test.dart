import 'package:flutter_test/flutter_test.dart';
import 'package:homemix/data/repositories/mock_recipe_repository.dart';
import 'package:homemix/domain/entities/drink_recipe.dart';
import 'package:homemix/features/mix_now/domain/mix_now_matcher.dart';
import 'package:homemix/features/mix_now/domain/mix_recommendation.dart';
import 'package:homemix/features/pantry/domain/pantry_ingredient.dart';
import 'package:homemix/features/pantry/data/mock_pantry_repository.dart';

void main() {
  test(
    'matches Pantry items, suggests substitutes, and ignores expired stock',
    () async {
      final recipes = await const MockRecipeRepository().getRecipes();
      final pantry = MockPantryRepository().getIngredients();
      final recommendations = MixNowMatcher.recommend(
        recipes: recipes,
        pantry: pantry,
      );
      final peachTea = recommendations.singleWhere(
        (item) => item.recipe.id == 'peach-lemongrass-tea',
      );

      expect(peachTea.matchPercentage, 60);
      expect(peachTea.status, RecipeMatchStatus.missingFew);
      expect(peachTea.substitutions.single.pantryIngredient?.name, 'Cam tươi');
      expect(
        peachTea.missingIngredients.map((item) => item.recipeIngredient.name),
        containsAll(['Sả', 'Mật ong']),
      );
    },
  );

  test(
    'sorts ready recipes first, then simpler recipes at the same match rate',
    () {
      final recipes = [
        _recipe(
          id: 'hard',
          ingredientNames: const ['Táo', 'Lê'],
          difficulty: 'Khó',
        ),
        _recipe(
          id: 'easy',
          ingredientNames: const ['Cam', 'Ổi'],
          difficulty: 'Dễ',
        ),
        _recipe(id: 'ready', ingredientNames: const ['Chanh']),
      ];
      final pantry = <PantryIngredient>[
        ...MockPantryRepository().getIngredients(),
        _pantryItem('pantry-apple', 'Táo'),
        _pantryItem('pantry-orange', 'Cam'),
        _pantryItem('pantry-lime', 'Chanh'),
      ];

      final recommendations = MixNowMatcher.recommend(
        recipes: recipes,
        pantry: pantry,
      );

      expect(recommendations.map((item) => item.recipe.id).toList(), [
        'ready',
        'easy',
        'hard',
      ]);
    },
  );
}

DrinkRecipe _recipe({
  required String id,
  required List<String> ingredientNames,
  String difficulty = 'Vừa',
}) {
  return DrinkRecipe(
    id: id,
    name: id,
    description: '',
    category: DrinkCategory.tea,
    artwork: DrinkArtworkStyle.peachTea,
    ingredients: [
      for (final name in ingredientNames)
        RecipeIngredient(name: name, amount: 1, unit: 'phần'),
    ],
    steps: const [],
    minutes: 5,
    difficulty: difficulty,
    servings: 1,
    isFeatured: false,
  );
}

PantryIngredient _pantryItem(String id, String name) {
  return PantryIngredient(
    id: id,
    name: name,
    category: PantryCategory.other,
    quantity: 1,
    unit: 'phần',
    expiryDate: DateTime.now().add(const Duration(days: 30)),
  );
}
