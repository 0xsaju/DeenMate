import 'package:json_annotation/json_annotation.dart';
import 'verse_dto.dart';

part 'verses_page_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class VersesPageDto {
  const VersesPageDto({
    required this.verses,
    required this.pagination,
  });

  final List<VerseDto> verses;
  final PaginationDto pagination;

  factory VersesPageDto.fromJson(Map<String, dynamic> json) =>
      _$VersesPageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$VersesPageDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaginationDto {
  const PaginationDto({
    required this.totalPages,
    required this.currentPage,
  });

  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'current_page')
  final int currentPage;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationDtoToJson(this);
}
