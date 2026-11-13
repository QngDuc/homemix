enum DrinkCategory {
  tea('Trà'),
  coffee('Cà phê'),
  mocktail('Mocktail'),
  smoothie('Sinh tố'),
  plantMilk('Sữa hạt');

  const DrinkCategory(this.label);

  final String label;
}

enum DrinkArtworkStyle {
  peachTea,
  mojito,
  lemonTea,
  mango,
  latte,
  walnutMilk,
  berry,
  matcha,
  strawberryYogurt,
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.amount,
    required this.unit,
  });

  final String name;
  final double amount;
  final String unit;

  String get formattedAmount {
    final value = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();
    return '$value $unit';
  }
}

class DrinkRecipe {
  const DrinkRecipe({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.artwork,
    required this.ingredients,
    required this.steps,
    required this.minutes,
    required this.difficulty,
    required this.servings,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String description;
  final DrinkCategory category;
  final DrinkArtworkStyle artwork;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final int minutes;
  final String difficulty;
  final int servings;
  final bool isFeatured;
}
