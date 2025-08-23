// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_analysis_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WordAnalysisDto _$WordAnalysisDtoFromJson(Map<String, dynamic> json) =>
    WordAnalysisDto(
      verseKey: json['verse_key'] as String,
      words: (json['words'] as List<dynamic>)
          .map((e) => WordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$WordAnalysisDtoToJson(WordAnalysisDto instance) =>
    <String, dynamic>{
      'verse_key': instance.verseKey,
      'words': instance.words.map((e) => e.toJson()).toList(),
    };

WordDto _$WordDtoFromJson(Map<String, dynamic> json) => WordDto(
      id: (json['id'] as num).toInt(),
      position: (json['position'] as num).toInt(),
      textUthmani: json['text_uthmani'] as String,
      textIndopak: json['text_indopak'] as String,
      transliteration: json['transliteration'] as String,
      translation: json['translation'] as String,
      arabicText: json['arabic_text'] as String,
      grammar: json['grammar'] as String?,
      root: json['root'] as String?,
      lemma: json['lemma'] as String?,
      stem: json['stem'] as String?,
      partOfSpeech: json['part_of_speech'] as String?,
      gender: json['gender'] as String?,
      number: json['number'] as String?,
      person: json['person'] as String?,
      tense: json['tense'] as String?,
      mood: json['mood'] as String?,
      voice: json['voice'] as String?,
    );

Map<String, dynamic> _$WordDtoToJson(WordDto instance) => <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'text_uthmani': instance.textUthmani,
      'text_indopak': instance.textIndopak,
      'transliteration': instance.transliteration,
      'translation': instance.translation,
      'arabic_text': instance.arabicText,
      'grammar': instance.grammar,
      'root': instance.root,
      'lemma': instance.lemma,
      'stem': instance.stem,
      'part_of_speech': instance.partOfSpeech,
      'gender': instance.gender,
      'number': instance.number,
      'person': instance.person,
      'tense': instance.tense,
      'mood': instance.mood,
      'voice': instance.voice,
    };

WordAnalysisResourceDto _$WordAnalysisResourceDtoFromJson(
        Map<String, dynamic> json) =>
    WordAnalysisResourceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      languageName: json['language_name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$WordAnalysisResourceDtoToJson(
        WordAnalysisResourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'language_name': instance.languageName,
      'slug': instance.slug,
      'description': instance.description,
      'source': instance.source,
    };
