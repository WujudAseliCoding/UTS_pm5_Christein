/// Categories available in the local question bank.
enum QuizCategory {
  flutter(
    label: 'Flutter',
    shortLabel: 'Flutter',
    description: 'Widget, layout, dan lifecycle',
  ),
  dart(
    label: 'Dart',
    shortLabel: 'Dart',
    description: 'Sintaks, async, dan OOP',
  ),
  general(
    label: 'Wawasan Umum',
    shortLabel: 'Umum',
    description: 'Sains, budaya, dan pengetahuan dasar',
  );

  const QuizCategory({
    required this.label,
    required this.shortLabel,
    required this.description,
  });

  final String label;
  final String shortLabel;
  final String description;

  static QuizCategory? fromName(String? name) {
    for (final category in values) {
      if (category.name == name) return category;
    }
    return null;
  }
}

/// Immutable quiz configuration chosen on the home page.
class QuizSettings {
  const QuizSettings({
    this.category,
    this.questionCount = 10,
    this.shuffleQuestions = true,
    this.shuffleOptions = true,
  });

  /// `null` means a mixed quiz across all categories.
  final QuizCategory? category;
  final int questionCount;
  final bool shuffleQuestions;
  final bool shuffleOptions;

  String get categoryLabel => category?.label ?? 'Campuran';

  QuizSettings copyWith({
    QuizCategory? category,
    bool clearCategory = false,
    int? questionCount,
    bool? shuffleQuestions,
    bool? shuffleOptions,
  }) {
    return QuizSettings(
      category: clearCategory ? null : category ?? this.category,
      questionCount: questionCount ?? this.questionCount,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'category': category?.name,
    'questionCount': questionCount,
    'shuffleQuestions': shuffleQuestions,
    'shuffleOptions': shuffleOptions,
  };

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    return QuizSettings(
      category: QuizCategory.fromName(json['category'] as String?),
      questionCount: (json['questionCount'] as num?)?.toInt() ?? 10,
      shuffleQuestions: json['shuffleQuestions'] as bool? ?? true,
      shuffleOptions: json['shuffleOptions'] as bool? ?? true,
    );
  }
}
