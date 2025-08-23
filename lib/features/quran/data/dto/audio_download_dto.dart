import 'package:json_annotation/json_annotation.dart';

part 'audio_download_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class AudioDownloadDto {
  const AudioDownloadDto({
    required this.chapterId,
    required this.recitationId,
    required this.status,
    required this.totalBytes,
    this.downloadedBytes = 0,
    this.downloadPath,
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(name: 'chapter_id')
  final int chapterId;
  @JsonKey(name: 'recitation_id')
  final int recitationId;
  final String status; // 'pending', 'downloading', 'completed', 'failed', 'paused'
  @JsonKey(name: 'total_bytes')
  final int totalBytes;
  @JsonKey(name: 'downloaded_bytes')
  final int downloadedBytes;
  @JsonKey(name: 'download_path')
  final String? downloadPath;
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  double get progress => totalBytes > 0 ? downloadedBytes / totalBytes : 0.0;
  bool get isCompleted => status == 'completed';
  bool get isDownloading => status == 'downloading';
  bool get isFailed => status == 'failed';
  bool get isPaused => status == 'paused';

  AudioDownloadDto copyWith({
    int? chapterId,
    int? recitationId,
    String? status,
    int? totalBytes,
    int? downloadedBytes,
    String? downloadPath,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioDownloadDto(
      chapterId: chapterId ?? this.chapterId,
      recitationId: recitationId ?? this.recitationId,
      status: status ?? this.status,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      downloadPath: downloadPath ?? this.downloadPath,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AudioDownloadDto.fromJson(Map<String, dynamic> json) =>
      _$AudioDownloadDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AudioDownloadDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AudioDownloadProgressDto {
  const AudioDownloadProgressDto({
    required this.chapterId,
    required this.recitationId,
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    this.speed,
    this.eta,
  });

  @JsonKey(name: 'chapter_id')
  final int chapterId;
  @JsonKey(name: 'recitation_id')
  final int recitationId;
  final double progress;
  @JsonKey(name: 'downloaded_bytes')
  final int downloadedBytes;
  @JsonKey(name: 'total_bytes')
  final int totalBytes;
  final double? speed; // bytes per second
  final Duration? eta;

  factory AudioDownloadProgressDto.fromJson(Map<String, dynamic> json) =>
      _$AudioDownloadProgressDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AudioDownloadProgressDtoToJson(this);
}
