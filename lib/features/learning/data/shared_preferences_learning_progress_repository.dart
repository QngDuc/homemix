import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/learning_progress.dart';
import '../domain/learning_progress_repository.dart';

class SharedPreferencesLearningProgressRepository
    implements LearningProgressRepository {
  SharedPreferencesLearningProgressRepository({
    SharedPreferencesAsync? preferences,
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  static const _progressKey = 'homemix.learning.progress.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<LearningProgress> load() async {
    final json = await _preferences.getString(_progressKey);
    if (json == null) {
      return const LearningProgress();
    }

    final decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic> ||
        decoded['completed'] is! List<dynamic> ||
        decoded['inProgress'] is! List<dynamic>) {
      throw const FormatException('Dữ liệu tiến độ học không hợp lệ.');
    }

    final completed = _readIds(decoded['completed']!);
    final inProgress = _readIds(decoded['inProgress']!)..removeAll(completed);
    return LearningProgress(
      completedLessonIds: completed,
      inProgressLessonIds: inProgress,
    );
  }

  @override
  Future<void> save(LearningProgress progress) {
    final json = jsonEncode({
      'completed': progress.completedLessonIds.toList()..sort(),
      'inProgress': progress.inProgressLessonIds.toList()..sort(),
    });
    return _preferences.setString(_progressKey, json);
  }

  Set<String> _readIds(Object value) {
    final ids = value as List<dynamic>;
    if (ids.any((id) => id is! String)) {
      throw const FormatException('Danh sách bài học đã lưu không hợp lệ.');
    }
    return ids.cast<String>().toSet();
  }
}
