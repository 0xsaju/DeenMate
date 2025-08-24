class RecitationResourceDto {
  RecitationResourceDto({
    required this.id, 
    required this.name,
    this.languageName,
    this.style,
  });
  
  final int id;
  final String name;
  final String? languageName;
  final String? style;

  factory RecitationResourceDto.fromJson(Map<String, dynamic> json) {
    return RecitationResourceDto(
      id: (json['id'] ?? 0) as int,
      name: (json['reciter_name'] ?? json['name'] ?? 'Unknown').toString(),
      languageName: json['translated_name']?['language_name'] as String?,
      style: json['style'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language_name': languageName,
      'style': style,
    };
  }
}
