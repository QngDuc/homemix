import '../../../domain/entities/drink_recipe.dart';
import '../domain/practice_recipe.dart';
import '../domain/practice_recipe_repository.dart';

class MockPracticeRecipeRepository implements PracticeRecipeRepository {
  const MockPracticeRecipeRepository();

  static const _guidedRecipes = <String, _GuidedRecipe>{
    'peach-lemongrass-tea': _GuidedRecipe(
      preparationMinutes: 5,
      mixingMinutes: 5,
      tools: ['Ấm đun nước', 'Ly đong', 'Bình lắc hoặc lọ có nắp', 'Ly cao'],
      steps: [
        PracticeStep(
          title: 'Ủ trà đen',
          instruction: 'Dùng nước nóng khoảng 90–95°C để ủ trà trong 4 phút. Lọc bỏ bã và để trà nguội bớt trước khi pha.',
          suggestedSeconds: 240,
          visual: PracticeStepVisual.brew,
        ),
        PracticeStep(
          title: 'Làm thơm sả',
          instruction: 'Rửa sạch sả, cắt bỏ phần gốc già rồi đập dập nhẹ một nhánh để hương thơm thoát ra.',
          visual: PracticeStepVisual.prepare,
        ),
        PracticeStep(
          title: 'Lắc phần trà trái cây',
          instruction: 'Cho trà, nước cam, mật ong, sả và đá vào bình lắc. Đậy kín, lắc đều khoảng 8 giây.',
          suggestedSeconds: 8,
          visual: PracticeStepVisual.mix,
        ),
        PracticeStep(
          title: 'Hoàn thiện ly trà',
          instruction: 'Rót ra ly, thêm đào ngâm và một nhánh sả. Nếm thử trước khi thêm mật ong vì đào ngâm đã có vị ngọt.',
          visual: PracticeStepVisual.garnish,
        ),
      ],
    ),
    'matcha-latte': _GuidedRecipe(
      preparationMinutes: 2,
      mixingMinutes: 4,
      tools: [
        'Rây bột nhỏ',
        'Bát pha matcha',
        'Chổi chasen hoặc cây đánh bọt',
        'Ly cao',
      ],
      steps: [
        PracticeStep(
          title: 'Rây matcha',
          instruction: 'Rây bột matcha vào bát khô để làm tơi bột, giúp matcha hòa tan mịn và không vón cục.',
          visual: PracticeStepVisual.prepare,
        ),
        PracticeStep(
          title: 'Đánh matcha với nước ấm',
          instruction: 'Rót khoảng 60 ml nước ở 75–80°C vào bát. Đánh nhanh theo hình chữ M đến khi mặt trà có lớp bọt mịn.',
          suggestedSeconds: 20,
          visual: PracticeStepVisual.whisk,
        ),
        PracticeStep(
          title: 'Điều chỉnh vị ngọt',
          instruction: 'Khuấy mật ong vào matcha khi còn ấm để tan đều. Nếm thử và thêm từng ít một nếu muốn ngọt hơn.',
          visual: PracticeStepVisual.mix,
        ),
        PracticeStep(
          title: 'Rót latte',
          instruction: 'Rót sữa lạnh và đá vào ly, sau đó rót matcha lên trên. Khuấy nhẹ trước khi uống để hòa quyện các lớp.',
          visual: PracticeStepVisual.garnish,
        ),
      ],
    ),
    'strawberry-yogurt': _GuidedRecipe(
      preparationMinutes: 2,
      mixingMinutes: 3,
      tools: ['Dao và thớt sạch', 'Máy xay sinh tố', 'Ly đong', 'Ly phục vụ'],
      steps: [
        PracticeStep(
          title: 'Sơ chế dâu tây',
          instruction: 'Rửa dâu dưới vòi nước sạch, để ráo, bỏ cuống rồi cắt đôi. Loại bỏ quả bị dập hoặc có mùi lạ.',
          visual: PracticeStepVisual.prepare,
        ),
        PracticeStep(
          title: 'Cho nguyên liệu vào cối',
          instruction: 'Cho dâu, sữa chua, sữa tươi, mật ong và đá vào máy xay. Đậy nắp chắc chắn trước khi khởi động.',
          visual: PracticeStepVisual.measure,
        ),
        PracticeStep(
          title: 'Xay đến khi mịn',
          instruction: 'Xay ở tốc độ vừa trong 20–30 giây. Dừng máy khi hỗn hợp mịn, không còn miếng dâu lớn.',
          suggestedSeconds: 25,
          visual: PracticeStepVisual.blend,
        ),
        PracticeStep(
          title: 'Nếm và phục vụ',
          instruction: 'Nếm thử, thêm một chút mật ong nếu cần rồi rót ra ly lạnh. Dùng ngay để giữ độ sánh và hương dâu tươi.',
          visual: PracticeStepVisual.garnish,
        ),
      ],
    ),
  };

  @override
  List<PracticeRecipe> enrichRecipes(List<DrinkRecipe> recipes) {
    return [
      for (final recipe in recipes)
        _buildPracticeRecipe(recipe, _guidedRecipes[recipe.id]),
    ];
  }

  PracticeRecipe _buildPracticeRecipe(
    DrinkRecipe recipe,
    _GuidedRecipe? guided,
  ) {
    if (guided != null) {
      return PracticeRecipe(
        recipe: recipe,
        preparationMinutes: guided.preparationMinutes,
        mixingMinutes: guided.mixingMinutes,
        tools: guided.tools,
        steps: guided.steps,
      );
    }

    final preparationMinutes = recipe.minutes ~/ 3;
    return PracticeRecipe(
      recipe: recipe,
      preparationMinutes: preparationMinutes,
      mixingMinutes: recipe.minutes - preparationMinutes,
      tools: _toolsFor(recipe),
      steps: [
        for (var index = 0; index < recipe.steps.length; index++)
          PracticeStep(
            title: 'Bước ${index + 1}',
            instruction: recipe.steps[index],
            visual: index == recipe.steps.length - 1
                ? PracticeStepVisual.garnish
                : PracticeStepVisual.mix,
          ),
      ],
    );
  }

  List<String> _toolsFor(DrinkRecipe recipe) => switch (recipe.category) {
    DrinkCategory.tea => ['Ấm đun nước', 'Ly đong', 'Rây lọc', 'Ly phục vụ'],
    DrinkCategory.coffee => ['Dụng cụ pha cà phê', 'Ly đong', 'Thìa khuấy'],
    DrinkCategory.mocktail => ['Ly cao', 'Thìa khuấy', 'Dụng cụ ép chanh'],
    DrinkCategory.smoothie => ['Dao và thớt sạch', 'Máy xay sinh tố', 'Ly'],
    DrinkCategory.plantMilk => ['Máy xay sinh tố', 'Rây lọc', 'Nồi nhỏ'],
  };
}

class _GuidedRecipe {
  const _GuidedRecipe({
    required this.preparationMinutes,
    required this.mixingMinutes,
    required this.tools,
    required this.steps,
  });

  final int preparationMinutes;
  final int mixingMinutes;
  final List<String> tools;
  final List<PracticeStep> steps;
}
