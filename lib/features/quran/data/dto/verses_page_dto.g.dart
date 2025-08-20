// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verses_page_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersesPageDto _$VersesPageDtoFromJson(Map<String, dynamic> json) =>
    VersesPageDto(
      verses: (json['verses'] as List<dynamic>?)
              ?.map(
                  (e) => VerseDto.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const <VerseDto>[],
      pagination: PaginationDto.fromJson(
          Map<String, dynamic>.from(json['pagination'] as Map)),
    );

Map<String, dynamic> _$VersesPageDtoToJson(VersesPageDto instance) =>
    <String, dynamic>{
      'verses': instance.verses.map((e) => e.toJson()).toList(),
      'pagination': instance.pagination.toJson(),
    };

PaginationDto _$PaginationDtoFromJson(Map<String, dynamic> json) =>
    PaginationDto(
      totalPages: (json['total_pages'] as num).toInt(),
      currentPage: (json['current_page'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationDtoToJson(PaginationDto instance) =>
    <String, dynamic>{
      'total_pages': instance.totalPages,
      'current_page': instance.currentPage,
    };
