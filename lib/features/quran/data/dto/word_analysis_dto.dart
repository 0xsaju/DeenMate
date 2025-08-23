import 'package:json_annotation/json_annotation.dart';

part 'word_analysis_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class WordAnalysisDto {
  const WordAnalysisDto({
    required this.verseKey,
    required this.words,
  });

  @JsonKey(name: 'verse_key')
  final String verseKey;
  final List<WordDto> words;

  factory WordAnalysisDto.fromJson(Map<String, dynamic> json) =>
      _$WordAnalysisDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WordAnalysisDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WordDto {
  const WordDto({
    required this.id,
    required this.position,
    required this.textUthmani,
    required this.textIndopak,
    required this.transliteration,
    required this.translation,
    required this.arabicText,
    this.grammar,
    this.root,
    this.lemma,
    this.stem,
    this.partOfSpeech,
    this.gender,
    this.number,
    this.person,
    this.tense,
    this.mood,
    this.voice,
  });

  final int id;
  final int position;
  @JsonKey(name: 'text_uthmani')
  final String textUthmani;
  @JsonKey(name: 'text_indopak')
  final String textIndopak;
  final String transliteration;
  final String translation;
  @JsonKey(name: 'arabic_text')
  final String arabicText;
  final String? grammar;
  final String? root;
  final String? lemma;
  final String? stem;
  @JsonKey(name: 'part_of_speech')
  final String? partOfSpeech;
  final String? gender;
  final String? number;
  final String? person;
  final String? tense;
  final String? mood;
  final String? voice;

  factory WordDto.fromJson(Map<String, dynamic> json) =>
      _$WordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WordDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WordAnalysisResourceDto {
  const WordAnalysisResourceDto({
    required this.id,
    required this.name,
    required this.languageName,
    required this.slug,
    this.description,
    this.source,
  });

  final int id;
  final String name;
  @JsonKey(name: 'language_name')
  final String languageName;
  final String slug;
  final String? description;
  final String? source;

  factory WordAnalysisResourceDto.fromJson(Map<String, dynamic> json) =>
      _$WordAnalysisResourceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$WordAnalysisResourceDtoToJson(this);
}
