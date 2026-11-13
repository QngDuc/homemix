import '../domain/learning_catalog_repository.dart';
import '../domain/learning_course.dart';
import 'mock_learning_courses.dart';

class MockLearningCatalogRepository implements LearningCatalogRepository {
  const MockLearningCatalogRepository();

  @override
  List<LearningCourse> getCourses() => mockLearningCourses;

  @override
  LearningCourse? getCourse(String courseId) {
    for (final course in mockLearningCourses) {
      if (course.id == courseId) {
        return course;
      }
    }
    return null;
  }
}
