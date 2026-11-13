import '../../../domain/entities/drink_recipe.dart';
import '../../pantry/domain/pantry_ingredient.dart';
import 'mix_recommendation.dart';

class MixNowMatcher {
  const MixNowMatcher._();

  static const _substitutions = <String, List<String>>{
    'nuoc cam': ['cam tuoi'],
    'nuoc nong': ['nuoc loc'],
    'chanh xanh': ['chanh vang'],
    'chanh vang': ['chanh xanh'],
    'nuoc cot chanh': ['chanh xanh', 'chanh vang'],
    'tra xanh': ['tra den'],
    'sua tuoi': ['sua yen mach'],
    'siro duong': ['duong mia'],
    'duong mia': ['mat ong'],
  };

  static List<MixRecommendation> recommend({
    required List<DrinkRecipe> recipes,
    required List<PantryIngredient> pantry,
  }) {
    final availableIngredients = pantry
        .where(
          (ingredient) => ingredient.expiryStatus != PantryExpiryStatus.expired,
        )
        .toList(growable: false);
    final recommendations = recipes
        .map(
          (recipe) => MixRecommendation(
            recipe: recipe,
            ingredients: recipe.ingredients
                .map((recipeIngredient) {
                  final normalizedName = normalizeIngredientName(
                    recipeIngredient.name,
                  );
                  final directMatch = availableIngredients.firstOrNullWhere(
                    (ingredient) =>
                        normalizeIngredientName(ingredient.name) ==
                        normalizedName,
                  );
                  if (directMatch != null) {
                    return MatchedRecipeIngredient(
                      recipeIngredient: recipeIngredient,
                      pantryIngredient: directMatch,
                    );
                  }

                  final alternatives =
                      _substitutions[normalizedName] ?? const [];
                  final substitute = availableIngredients.firstOrNullWhere(
                    (ingredient) => alternatives.contains(
                      normalizeIngredientName(ingredient.name),
                    ),
                  );
                  return MatchedRecipeIngredient(
                    recipeIngredient: recipeIngredient,
                    pantryIngredient: substitute,
                    isSubstitution: substitute != null,
                  );
                })
                .toList(growable: false),
          ),
        )
        .toList();

    recommendations.sort((left, right) {
      if (left.canMakeNow != right.canMakeNow) {
        return left.canMakeNow ? -1 : 1;
      }
      final percentageOrder = right.matchPercentage.compareTo(
        left.matchPercentage,
      );
      if (percentageOrder != 0) {
        return percentageOrder;
      }
      final difficultyOrder = _difficultyRank(left.recipe.difficulty)
          .compareTo(_difficultyRank(right.recipe.difficulty));
      if (difficultyOrder != 0) {
        return difficultyOrder;
      }
      return left.recipe.minutes.compareTo(right.recipe.minutes);
    });

    return recommendations;
  }

  static String normalizeIngredientName(String value) {
    final normalized = value.toLowerCase().trim();
    final withoutAccents = normalized.replaceAllMapped(
      RegExp(
        '[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
      ),
      (match) {
        final character = match[0]!;
        if ('àáạảãâầấậẩẫăằắặẳẵ'.contains(character)) return 'a';
        if ('èéẹẻẽêềếệểễ'.contains(character)) return 'e';
        if ('ìíịỉĩ'.contains(character)) return 'i';
        if ('òóọỏõôồốộổỗơờớợởỡ'.contains(character)) return 'o';
        if ('ùúụủũưừứựửữ'.contains(character)) return 'u';
        if ('ỳýỵỷỹ'.contains(character)) return 'y';
        return 'd';
      },
    );
    return withoutAccents
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int _difficultyRank(String difficulty) {
    return switch (normalizeIngredientName(difficulty)) {
      'de' || 'easy' || 'beginner' => 0,
      'vua' || 'trung binh' || 'medium' || 'intermediate' => 1,
      'kho' || 'advanced' => 2,
      _ => 3,
    };
  }
}

extension on Iterable<PantryIngredient> {
  PantryIngredient? firstOrNullWhere(bool Function(PantryIngredient) test) {
    for (final ingredient in this) {
      if (test(ingredient)) {
        return ingredient;
      }
    }
    return null;
  }
}
