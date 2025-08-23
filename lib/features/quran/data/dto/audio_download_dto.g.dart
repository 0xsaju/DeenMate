// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_download_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioDownloadDto _$AudioDownloadDtoFromJson(Map<String, dynamic> json) =>
    AudioDownloadDto(
      chapterId: (json['chapter_id'] as num).toInt(),
      recitationId: (json['recitation_id'] as num).toInt(),
      status: json['status'] as String,
      totalBytes: (json['total_bytes'] as num).toInt(),
      downloadedBytes: (json['downloaded_bytes'] as num?)?.toInt() ?? 0,
      downloadPath: json['download_path'] as String?,
      errorMessage: json['error_message'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$AudioDownloadDtoToJson(AudioDownloadDto instance) =>
    <String, dynamic>{
      'chapter_id': instance.chapterId,
      'recitation_id': instance.recitationId,
      'status': instance.status,
      'total_bytes': instance.totalBytes,
      'downloaded_bytes': instance.downloadedBytes,
      'download_path': instance.downloadPath,
      'error_message': instance.errorMessage,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

AudioDownloadProgressDto _$AudioDownloadProgressDtoFromJson(
        Map<String, dynamic> json) =>
    AudioDownloadProgressDto(
      chapterId: (json['chapter_id'] as num).toInt(),
      recitationId: (json['recitation_id'] as num).toInt(),
      progress: (json['progress'] as num).toDouble(),
      downloadedBytes: (json['downloaded_bytes'] as num).toInt(),
      totalBytes: (json['total_bytes'] as num).toInt(),
      speed: (json['speed'] as num?)?.toDouble(),
      eta: json['eta'] == null
          ? null
          : Duration(microseconds: (json['eta'] as num).toInt()),
    );

Map<String, dynamic> _$AudioDownloadProgressDtoToJson(
        AudioDownloadProgressDto instance) =>
    <String, dynamic>{
      'chapter_id': instance.chapterId,
      'recitation_id': instance.recitationId,
      'progress': instance.progress,
      'downloaded_bytes': instance.downloadedBytes,
      'total_bytes': instance.totalBytes,
      'speed': instance.speed,
      'eta': instance.eta?.inMicroseconds,
    };
