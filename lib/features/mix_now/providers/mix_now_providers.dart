import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discover/providers/discover_providers.dart';
import '../../pantry/providers/pantry_providers.dart';
import '../domain/mix_now_matcher.dart';
import '../domain/mix_recommendation.dart';

final mixRecommendationsProvider =
    Provider<AsyncValue<List<MixRecommendation>>>((ref) {
      final recipes = ref.watch(recipesProvider);
      final pantry = ref.watch(pantryIngredientsProvider);
      return recipes.whenData(
        (items) => MixNowMatcher.recommend(recipes: items, pantry: pantry),
      );
    });

final mixRecipeByIdProvider =
    Provider.family<AsyncValue<MixRecommendation?>, String>(
      (ref, recipeId) => ref
          .watch(mixRecommendationsProvider)
          .whenData(
            (recommendations) => recommendations
                .where((recommendation) => recommendation.recipe.id == recipeId)
                .firstOrNull,
          ),
    );
