class NoteDto {
  NoteDto({
    required this.verseKey,
    required this.text,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String verseKey; // e.g., "2:255"
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'verseKey': verseKey,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static NoteDto fromMap(Map<String, dynamic> map) => NoteDto(
        verseKey: map['verseKey'] as String,
        text: map['text'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}
