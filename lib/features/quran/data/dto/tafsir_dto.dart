import 'package:json_annotation/json_annotation.dart';

part 'tafsir_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class TafsirDto {
  const TafsirDto({
    required this.verseKey,
    required this.text,
    required this.resourceId,
    required this.resourceName,
    this.languageName,
    this.languageCode,
  });

  @JsonKey(name: 'verse_key')
  final String verseKey;
  final String text;
  @JsonKey(name: 'resource_id')
  final int resourceId;
  @JsonKey(name: 'resource_name')
  final String resourceName;
  @JsonKey(name: 'language_name')
  final String? languageName;
  @JsonKey(name: 'language_code')
  final String? languageCode;

  factory TafsirDto.fromJson(Map<String, dynamic> json) =>
      _$TafsirDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TafsirDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TafsirResourceDto {
  const TafsirResourceDto({
    required this.id,
    required this.name,
    required this.authorName,
    required this.languageName,
    required this.slug,
    this.description,
    this.source,
    this.license,
  });

  final int id;
  final String name;
  @JsonKey(name: 'author_name')
  final String authorName;
  @JsonKey(name: 'language_name')
  final String languageName;
  final String slug;
  final String? description;
  final String? source;
  final String? license;

  factory TafsirResourceDto.fromJson(Map<String, dynamic> json) =>
      _$TafsirResourceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TafsirResourceDtoToJson(this);
}
