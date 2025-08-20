import 'package:json_annotation/json_annotation.dart';

part 'chapter_dto.g.dart';

@JsonSerializable()
class ChapterDto {
  const ChapterDto({
    required this.id,
    required this.nameArabic,
    required this.nameSimple,
    required this.versesCount,
    required this.revelationPlace,
  });

  final int id;
  @JsonKey(name: 'name_arabic')
  final String nameArabic;
  @JsonKey(name: 'name_simple')
  final String nameSimple;
  @JsonKey(name: 'verses_count')
  final int versesCount;
  @JsonKey(name: 'revelation_place')
  final String revelationPlace; // Meccan/Medinan

  factory ChapterDto.fromJson(Map<String, dynamic> json) =>
      _$ChapterDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChapterDtoToJson(this);
}
