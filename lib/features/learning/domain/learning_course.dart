enum CourseLevel {
  beginner('Beginner', 'Cơ bản'),
  intermediate('Intermediate', 'Trung cấp'),
  advanced('Advanced', 'Nâng cao');

  const CourseLevel(this.label, this.displayName);

  final String label;
  final String displayName;
}

enum CourseArtworkType { bartending, fruitTea, coffee }

class LearningCourse {
  const LearningCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.artwork,
    required this.chapters,
  });

  final String id;
  final String title;
  final String description;
  final CourseLevel level;
  final CourseArtworkType artwork;
  final List<CourseChapter> chapters;

  List<CourseLesson> get lessons => [
    for (final chapter in chapters) ...chapter.lessons,
  ];

  int get totalMinutes =>
      lessons.fold(0, (total, lesson) => total + lesson.estimatedMinutes);
}

class CourseChapter {
  const CourseChapter({required this.title, required this.lessons});

  final String title;
  final List<CourseLesson> lessons;
}

class CourseLesson {
  const CourseLesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.estimatedMinutes,
    required this.sections,
    required this.ingredients,
    required this.tools,
    required this.technique,
    required this.tips,
  });

  final String id;
  final String title;
  final String summary;
  final int estimatedMinutes;
  final List<LessonSection> sections;
  final List<String> ingredients;
  final List<String> tools;
  final String technique;
  final List<String> tips;
}

class LessonSection {
  const LessonSection({required this.title, required this.body});

  final String title;
  final String body;
}
