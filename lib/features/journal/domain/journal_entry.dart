class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.date,
    required this.rating,
    required this.note,
    this.imagePath,
  });

  final String id;
  final String recipeId;
  final String recipeName;
  final DateTime date;
  final int? rating;
  final String note;
  final String? imagePath;

  JournalEntry copyWith({
    int? rating,
    String? note,
    bool clearRating = false,
  }) => JournalEntry(
    id: id,
    recipeId: recipeId,
    recipeName: recipeName,
    date: date,
    rating: clearRating ? null : rating ?? this.rating,
    note: note ?? this.note,
    imagePath: imagePath,
  );
}

class JournalEntryDraft {
  const JournalEntryDraft({required this.rating, required this.note});

  final int? rating;
  final String note;
}
