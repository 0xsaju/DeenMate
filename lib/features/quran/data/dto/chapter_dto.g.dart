// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterDto _$ChapterDtoFromJson(Map<String, dynamic> json) => ChapterDto(
      id: (json['id'] as num).toInt(),
      nameArabic: json['name_arabic'] as String,
      nameSimple: json['name_simple'] as String,
      versesCount: (json['verses_count'] as num).toInt(),
      revelationPlace: json['revelation_place'] as String,
    );

Map<String, dynamic> _$ChapterDtoToJson(ChapterDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_arabic': instance.nameArabic,
      'name_simple': instance.nameSimple,
      'verses_count': instance.versesCount,
      'revelation_place': instance.revelationPlace,
    };
