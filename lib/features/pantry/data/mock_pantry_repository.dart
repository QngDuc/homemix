import '../domain/pantry_ingredient.dart';
import '../domain/pantry_repository.dart';
import 'mock_pantry_data.dart';

class MockPantryRepository implements PantryRepository {
  MockPantryRepository() : _ingredients = [...mockPantryIngredients];

  final List<PantryIngredient> _ingredients;

  @override
  List<PantryIngredient> getIngredients() => List.unmodifiable(_ingredients);

  @override
  void addIngredient(PantryIngredient ingredient) {
    _ingredients.insert(0, ingredient);
  }

  @override
  void updateIngredient(PantryIngredient ingredient) {
    final index = _ingredients.indexWhere((item) => item.id == ingredient.id);
    if (index == -1) {
      throw StateError('Không tìm thấy nguyên liệu cần cập nhật.');
    }
    _ingredients[index] = ingredient;
  }

  @override
  void deleteIngredient(String id) {
    final index = _ingredients.indexWhere((item) => item.id == id);
    if (index == -1) {
      throw StateError('Không tìm thấy nguyên liệu cần xóa.');
    }
    _ingredients.removeAt(index);
  }
}
