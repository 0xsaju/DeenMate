// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafsir_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TafsirDto _$TafsirDtoFromJson(Map<String, dynamic> json) => TafsirDto(
      verseKey: json['verse_key'] as String,
      text: json['text'] as String,
      resourceId: (json['resource_id'] as num).toInt(),
      resourceName: json['resource_name'] as String,
      languageName: json['language_name'] as String?,
      languageCode: json['language_code'] as String?,
    );

Map<String, dynamic> _$TafsirDtoToJson(TafsirDto instance) => <String, dynamic>{
      'verse_key': instance.verseKey,
      'text': instance.text,
      'resource_id': instance.resourceId,
      'resource_name': instance.resourceName,
      'language_name': instance.languageName,
      'language_code': instance.languageCode,
    };

TafsirResourceDto _$TafsirResourceDtoFromJson(Map<String, dynamic> json) =>
    TafsirResourceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      authorName: json['author_name'] as String,
      languageName: json['language_name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      source: json['source'] as String?,
      license: json['license'] as String?,
    );

Map<String, dynamic> _$TafsirResourceDtoToJson(TafsirResourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author_name': instance.authorName,
      'language_name': instance.languageName,
      'slug': instance.slug,
      'description': instance.description,
      'source': instance.source,
      'license': instance.license,
    };
