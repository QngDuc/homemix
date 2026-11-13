import '../../../domain/entities/drink_recipe.dart';

enum PracticeStepVisual { prepare, brew, measure, mix, whisk, blend, garnish }

class PracticeStep {
  const PracticeStep({
    required this.title,
    required this.instruction,
    this.suggestedSeconds,
    this.visual = PracticeStepVisual.mix,
  });

  final String title;
  final String instruction;
  final int? suggestedSeconds;
  final PracticeStepVisual visual;
}

class PracticeRecipe {
  const PracticeRecipe({
    required this.recipe,
    required this.preparationMinutes,
    required this.mixingMinutes,
    required this.tools,
    required this.steps,
  });

  final DrinkRecipe recipe;
  final int preparationMinutes;
  final int mixingMinutes;
  final List<String> tools;
  final List<PracticeStep> steps;

  String amountFor(RecipeIngredient ingredient, int servings) {
    final amount = ingredient.amount * servings / recipe.servings;
    final formatted = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(1);
    return '$formatted ${ingredient.unit}';
  }
}
