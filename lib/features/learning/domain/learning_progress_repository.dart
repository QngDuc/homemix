import 'learning_progress.dart';

abstract interface class LearningProgressRepository {
  Future<LearningProgress> load();

  Future<void> save(LearningProgress progress);
}
