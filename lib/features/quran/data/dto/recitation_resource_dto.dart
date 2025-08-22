class RecitationResourceDto {
  RecitationResourceDto({required this.id, required this.name});
  final int id;
  final String name;

  factory RecitationResourceDto.fromJson(Map<String, dynamic> json) {
    return RecitationResourceDto(
      id: (json['id'] ?? 0) as int,
      name:
          (json['transliterated_name'] ?? json['name'] ?? 'Unknown').toString(),
    );
  }
}
