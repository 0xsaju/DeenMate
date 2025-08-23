import 'package:json_annotation/json_annotation.dart';

part 'translation_resource_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TranslationResourceDto {
  const TranslationResourceDto({
    required this.id,
    required this.name,
    required this.authorName,
    required this.languageName,
    required this.slug,
    this.direction,
    this.source,
    this.comments,
    this.license,
    this.licenseUrl,
    this.translatedName,
  });

  final int id;
  final String? name;
  @JsonKey(name: 'author_name')
  final String? authorName;
  @JsonKey(name: 'language_name')
  final String? languageName;
  final String? slug;
  final String? direction;
  final String? source;
  final String? comments;
  final String? license;
  @JsonKey(name: 'license_url')
  final String? licenseUrl;
  @JsonKey(name: 'translated_name')
  final TranslatedNameDto? translatedName;

  factory TranslationResourceDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationResourceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationResourceDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslatedNameDto {
  const TranslatedNameDto({
    required this.name,
    required this.languageName,
  });

  final String? name;
  @JsonKey(name: 'language_name')
  final String? languageName;

  factory TranslatedNameDto.fromJson(Map<String, dynamic> json) =>
      _$TranslatedNameDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TranslatedNameDtoToJson(this);
}
