/// Utility functions for text processing in Quran module
class QuranTextUtils {
  /// Clean HTML tags from translation text, particularly <sup> footnote references
  static String sanitizeTranslationText(String text) {
    if (text.isEmpty) return text;
    
    return text
        // Remove <sup> tags with content (footnote references)
        .replaceAll(RegExp(r'<sup[^>]*>[\s\S]*?<\/sup>', dotAll: true), ' ')
        // Remove any remaining HTML tags
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        // Normalize whitespace
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Clean Arabic text (remove diacritics if needed)
  static String sanitizeArabicText(String text) {
    if (text.isEmpty) return text;
    
    // For now, just return as-is, but this could be extended
    // to remove specific diacritics or normalize text
    return text.trim();
  }

  /// Extract chapter and verse number from verse key (format: "chapter:verse")
  static Map<String, int> parseVerseKey(String verseKey) {
    final parts = verseKey.split(':');
    return {
      'chapter': int.tryParse(parts.first) ?? 1,
      'verse': int.tryParse(parts.length > 1 ? parts.last : '1') ?? 1,
    };
  }

  /// Format verse key from chapter and verse numbers
  static String formatVerseKey(int chapterId, int verseNumber) {
    return '$chapterId:$verseNumber';
  }

  /// Clean search query text
  static String sanitizeSearchQuery(String query) {
    return query
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .toLowerCase();
  }

  /// Check if text contains Arabic characters
  static bool containsArabic(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  /// Check if text contains HTML tags
  static bool containsHtml(String text) {
    return RegExp(r'<[^>]+>').hasMatch(text);
  }
}
