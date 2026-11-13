import 'package:flutter/foundation.dart';

import 'practice_recipe.dart';

class PracticeResult {
  const PracticeResult({
    required this.recipeId,
    required this.recipeName,
    required this.servings,
    required this.completedSteps,
    required this.totalSteps,
    required this.rating,
    required this.completedAt,
  });

  final String recipeId;
  final String recipeName;
  final int servings;
  final int completedSteps;
  final int totalSteps;
  final int? rating;
  final DateTime completedAt;

  PracticeResult withRating(int? value) => PracticeResult(
    recipeId: recipeId,
    recipeName: recipeName,
    servings: servings,
    completedSteps: completedSteps,
    totalSteps: totalSteps,
    rating: value,
    completedAt: completedAt,
  );
}

class PracticeSessionController extends ChangeNotifier {
  PracticeSessionController(this.recipe) : servings = recipe.recipe.servings;

  final PracticeRecipe recipe;
  final Set<int> _completedStepIndices = {};
  int currentStepIndex = 0;
  int servings;
  int? rating;
  bool isFinished = false;
  DateTime? completedAt;

  Set<int> get completedStepIndices => Set.unmodifiable(_completedStepIndices);

  int get completedStepCount => _completedStepIndices.length;

  double get progress =>
      recipe.steps.isEmpty ? 0 : completedStepCount / recipe.steps.length;

  bool get currentStepIsComplete =>
      _completedStepIndices.contains(currentStepIndex);

  bool get canGoNext =>
      currentStepIsComplete && currentStepIndex < recipe.steps.length - 1;

  void setServings(int value) {
    if (value < 1 || value > 12) {
      throw RangeError.range(value, 1, 12, 'servings');
    }
    if (servings == value) {
      return;
    }
    servings = value;
    notifyListeners();
  }

  void completeCurrentStep() {
    if (isFinished || currentStepIsComplete) {
      return;
    }
    _completedStepIndices.add(currentStepIndex);
    if (_completedStepIndices.length == recipe.steps.length) {
      isFinished = true;
      completedAt = DateTime.now();
    }
    notifyListeners();
  }

  void goPrevious() {
    if (isFinished || currentStepIndex == 0) {
      return;
    }
    currentStepIndex--;
    notifyListeners();
  }

  void goNext() {
    if (isFinished || !canGoNext) {
      return;
    }
    currentStepIndex++;
    notifyListeners();
  }

  void setRating(int value) {
    if (value < 1 || value > 5) {
      throw RangeError.range(value, 1, 5, 'rating');
    }
    rating = value;
    notifyListeners();
  }

  PracticeResult createResult() => PracticeResult(
    recipeId: recipe.recipe.id,
    recipeName: recipe.recipe.name,
    servings: servings,
    completedSteps: completedStepCount,
    totalSteps: recipe.steps.length,
    rating: rating,
    completedAt: completedAt ?? DateTime.now(),
  );

  void restart() {
    currentStepIndex = 0;
    _completedStepIndices.clear();
    servings = recipe.recipe.servings;
    rating = null;
    isFinished = false;
    completedAt = null;
    notifyListeners();
  }
}
