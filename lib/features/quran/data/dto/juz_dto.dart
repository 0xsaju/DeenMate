/// Manual DTOs for Quran navigation units without codegen
class JuzDto {
  const JuzDto({
    required this.id,
    required this.juzNumber,
    required this.verseMapping,
    this.firstVerseId,
    this.lastVerseId,
    this.verseCount,
  });

  final int id;
  final int juzNumber;
  final int? firstVerseId;
  final int? lastVerseId;
  final int? verseCount;
  /// Format: {chapterId: [startVerse, endVerse]}
  final Map<int, List<int>> verseMapping;

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
    }

  factory JuzDto.fromJson(Map<String, dynamic> json) {
    final mapping = <int, List<int>>{};
    final raw = json['verse_mapping'];
    if (raw is Map) {
      raw.forEach((k, v) {
        final chapterId = int.tryParse(k.toString()) ?? 0;
        if (chapterId <= 0) return;
        if (v is List && v.isNotEmpty) {
          final start = v.length > 0 ? _toInt(v[0]) : 0;
          final end = v.length > 1 ? _toInt(v[1]) : start;
          mapping[chapterId] = [start, end];
        }
      });
    }
    return JuzDto(
      id: _toInt(json['id'] ?? json['juz_number'] ?? 0),
      juzNumber: _toInt(json['juz_number'] ?? json['id'] ?? 0),
      firstVerseId: json['first_verse_id'] == null ? null : _toInt(json['first_verse_id']),
      lastVerseId: json['last_verse_id'] == null ? null : _toInt(json['last_verse_id']),
      verseCount: json['verse_count'] == null ? null : _toInt(json['verse_count']),
      verseMapping: mapping,
    );
  }

  Map<String, dynamic> toJson() {
    final mapping = <String, List<int>>{};
    verseMapping.forEach((k, v) {
      if (v.isNotEmpty) {
        mapping[k.toString()] = [v[0], v.length > 1 ? v[1] : v[0]];
      }
    });
    return {
      'id': id,
      'juz_number': juzNumber,
      'first_verse_id': firstVerseId,
      'last_verse_id': lastVerseId,
      'verse_count': verseCount,
      'verse_mapping': mapping,
    };
  }

  @override
  String toString() => 'JuzDto(id: $id, juzNumber: $juzNumber)';
}

class PageDto {
  const PageDto({
    required this.id,
    required this.pageNumber,
    required this.juzNumber,
    this.hizbNumber,
    this.firstVerseId,
    this.lastVerseId,
    this.verseCount,
  });

  final int id;
  final int pageNumber;
  final int juzNumber;
  final int? hizbNumber;
  final int? firstVerseId;
  final int? lastVerseId;
  final int? verseCount;

  factory PageDto.fromJson(Map<String, dynamic> json) => PageDto(
        id: JuzDto._toInt(json['id'] ?? json['page_number'] ?? 0),
        pageNumber: JuzDto._toInt(json['page_number'] ?? json['id'] ?? 0),
        juzNumber: JuzDto._toInt(json['juz_number'] ?? 0),
        hizbNumber: json['hizb_number'] == null ? null : JuzDto._toInt(json['hizb_number']),
        firstVerseId: json['first_verse_id'] == null ? null : JuzDto._toInt(json['first_verse_id']),
        lastVerseId: json['last_verse_id'] == null ? null : JuzDto._toInt(json['last_verse_id']),
        verseCount: json['verse_count'] == null ? null : JuzDto._toInt(json['verse_count']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'page_number': pageNumber,
        'juz_number': juzNumber,
        'hizb_number': hizbNumber,
        'first_verse_id': firstVerseId,
        'last_verse_id': lastVerseId,
        'verse_count': verseCount,
      };

  @override
  String toString() => 'PageDto(id: $id, pageNumber: $pageNumber)';
}

class HizbDto {
  const HizbDto({
    required this.id,
    required this.hizbNumber,
    required this.juzNumber,
    this.quarterNumber,
    this.firstVerseId,
    this.lastVerseId,
    this.verseCount,
  });

  final int id;
  final int hizbNumber;
  final int juzNumber;
  final int? quarterNumber;
  final int? firstVerseId;
  final int? lastVerseId;
  final int? verseCount;

  factory HizbDto.fromJson(Map<String, dynamic> json) => HizbDto(
        id: JuzDto._toInt(json['id'] ?? json['hizb_number'] ?? 0),
        hizbNumber: JuzDto._toInt(json['hizb_number'] ?? json['id'] ?? 0),
        juzNumber: JuzDto._toInt(json['juz_number'] ?? 0),
        quarterNumber: json['quarter_number'] == null ? null : JuzDto._toInt(json['quarter_number']),
        firstVerseId: json['first_verse_id'] == null ? null : JuzDto._toInt(json['first_verse_id']),
        lastVerseId: json['last_verse_id'] == null ? null : JuzDto._toInt(json['last_verse_id']),
        verseCount: json['verse_count'] == null ? null : JuzDto._toInt(json['verse_count']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hizb_number': hizbNumber,
        'juz_number': juzNumber,
        'quarter_number': quarterNumber,
        'first_verse_id': firstVerseId,
        'last_verse_id': lastVerseId,
        'verse_count': verseCount,
      };

  @override
  String toString() => 'HizbDto(id: $id, hizbNumber: $hizbNumber)';
}

class RukuDto {
  const RukuDto({
    required this.id,
    required this.rukuNumber,
    required this.chapterId,
    this.firstVerseId,
    this.lastVerseId,
    this.verseCount,
  });

  final int id;
  final int rukuNumber;
  final int chapterId;
  final int? firstVerseId;
  final int? lastVerseId;
  final int? verseCount;

  factory RukuDto.fromJson(Map<String, dynamic> json) => RukuDto(
        id: JuzDto._toInt(json['id'] ?? json['ruku_number'] ?? 0),
        rukuNumber: JuzDto._toInt(json['ruku_number'] ?? json['id'] ?? 0),
        chapterId: JuzDto._toInt(json['chapter_id'] ?? 0),
        firstVerseId: json['first_verse_id'] == null ? null : JuzDto._toInt(json['first_verse_id']),
        lastVerseId: json['last_verse_id'] == null ? null : JuzDto._toInt(json['last_verse_id']),
        verseCount: json['verse_count'] == null ? null : JuzDto._toInt(json['verse_count']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ruku_number': rukuNumber,
        'chapter_id': chapterId,
        'first_verse_id': firstVerseId,
        'last_verse_id': lastVerseId,
        'verse_count': verseCount,
      };

  @override
  String toString() => 'RukuDto(id: $id, rukuNumber: $rukuNumber)';
}
