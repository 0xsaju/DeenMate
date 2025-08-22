class ChapterDownloadDto {
  ChapterDownloadDto({
    required this.chapterId,
    required this.status,
    this.downloadedAt,
    this.totalPages = 0,
    this.downloadedPages = 0,
    this.sizeBytes = 0,
  });

  final int chapterId;
  final String status; // 'pending', 'downloading', 'completed', 'failed'
  final DateTime? downloadedAt;
  final int totalPages;
  final int downloadedPages;
  final int sizeBytes;

  double get progress => totalPages > 0 ? downloadedPages / totalPages : 0.0;

  Map<String, dynamic> toMap() => {
        'chapterId': chapterId,
        'status': status,
        'downloadedAt': downloadedAt?.toIso8601String(),
        'totalPages': totalPages,
        'downloadedPages': downloadedPages,
        'sizeBytes': sizeBytes,
      };

  static ChapterDownloadDto fromMap(Map<String, dynamic> map) =>
      ChapterDownloadDto(
        chapterId: map['chapterId'] as int,
        status: map['status'] as String,
        downloadedAt: map['downloadedAt'] != null
            ? DateTime.parse(map['downloadedAt'] as String)
            : null,
        totalPages: (map['totalPages'] ?? 0) as int,
        downloadedPages: (map['downloadedPages'] ?? 0) as int,
        sizeBytes: (map['sizeBytes'] ?? 0) as int,
      );

  ChapterDownloadDto copyWith({
    String? status,
    DateTime? downloadedAt,
    int? totalPages,
    int? downloadedPages,
    int? sizeBytes,
  }) =>
      ChapterDownloadDto(
        chapterId: chapterId,
        status: status ?? this.status,
        downloadedAt: downloadedAt ?? this.downloadedAt,
        totalPages: totalPages ?? this.totalPages,
        downloadedPages: downloadedPages ?? this.downloadedPages,
        sizeBytes: sizeBytes ?? this.sizeBytes,
      );
}
