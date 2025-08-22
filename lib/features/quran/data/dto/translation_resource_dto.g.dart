// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_resource_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationResourceDto _$TranslationResourceDtoFromJson(
        Map<String, dynamic> json) =>
    TranslationResourceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      authorName: json['author_name'] as String,
      languageName: json['language_name'] as String,
      slug: json['slug'] as String,
      direction: json['direction'] as String?,
      source: json['source'] as String?,
      comments: json['comments'] as String?,
      license: json['license'] as String?,
      licenseUrl: json['license_url'] as String?,
      translatedName: json['translated_name'] == null
          ? null
          : TranslatedNameDto.fromJson(
              json['translated_name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TranslationResourceDtoToJson(
        TranslationResourceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'author_name': instance.authorName,
      'language_name': instance.languageName,
      'slug': instance.slug,
      'direction': instance.direction,
      'source': instance.source,
      'comments': instance.comments,
      'license': instance.license,
      'license_url': instance.licenseUrl,
      'translated_name': instance.translatedName?.toJson(),
    };

TranslatedNameDto _$TranslatedNameDtoFromJson(Map<String, dynamic> json) =>
    TranslatedNameDto(
      name: json['name'] as String,
      languageName: json['language_name'] as String,
    );

Map<String, dynamic> _$TranslatedNameDtoToJson(TranslatedNameDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'language_name': instance.languageName,
    };
