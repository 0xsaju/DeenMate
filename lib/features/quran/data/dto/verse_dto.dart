import 'package:json_annotation/json_annotation.dart';

part 'verse_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class VerseDto {
  const VerseDto({
    required this.verseKey,
    required this.verseNumber,
    required this.textUthmani,
    this.translations = const [],
    this.audio,
  });

  @JsonKey(name: 'verse_key')
  final String verseKey; // e.g., 1:1
  @JsonKey(name: 'verse_number')
  final int verseNumber; // within surah
  @JsonKey(name: 'text_uthmani')
  final String textUthmani;
  final List<TranslationDto> translations;
  final AudioDto? audio;

  factory VerseDto.fromJson(Map<String, dynamic> json) =>
      _$VerseDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VerseDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TranslationDto {
  const TranslationDto({
    required this.resourceId,
    required this.text,
  });

  @JsonKey(name: 'resource_id')
  final int resourceId;
  final String text;
  // language_name is not always provided by the API; omit for compatibility

  factory TranslationDto.fromJson(Map<String, dynamic> json) =>
      _$TranslationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AudioDto {
  const AudioDto({required this.url, this.duration});
  final String url;
  final double? duration;

  factory AudioDto.fromJson(Map<String, dynamic> json) =>
      _$AudioDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AudioDtoToJson(this);
}
