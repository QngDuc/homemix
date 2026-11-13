import 'learning_course.dart';

abstract interface class LearningCatalogRepository {
  List<LearningCourse> getCourses();

  LearningCourse? getCourse(String courseId);
}
