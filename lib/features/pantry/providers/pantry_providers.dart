import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_pantry_repository.dart';
import '../domain/pantry_ingredient.dart';
import '../domain/pantry_repository.dart';

final pantryRepositoryProvider = Provider<PantryRepository>(
  (ref) => MockPantryRepository(),
);

final pantryIngredientsProvider =
    NotifierProvider<PantryIngredientsNotifier, List<PantryIngredient>>(
      PantryIngredientsNotifier.new,
    );

class PantryIngredientsNotifier extends Notifier<List<PantryIngredient>> {
  late PantryRepository _repository;

  @override
  List<PantryIngredient> build() {
    _repository = ref.watch(pantryRepositoryProvider);
    return _repository.getIngredients();
  }

  void add(PantryIngredient ingredient) {
    _repository.addIngredient(ingredient);
    _refresh();
  }

  void update(PantryIngredient ingredient) {
    _repository.updateIngredient(ingredient);
    _refresh();
  }

  void delete(String id) {
    _repository.deleteIngredient(id);
    _refresh();
  }

  void _refresh() {
    state = _repository.getIngredients();
  }
}
