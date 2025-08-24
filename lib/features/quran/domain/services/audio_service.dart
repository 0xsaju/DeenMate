import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

/// Comprehensive audio service for Quran recitation
/// Handles playback, downloads, and offline audio management
class QuranAudioService {
  QuranAudioService([Dio? dio]) : _dio = dio ?? Dio();
  
  final Dio _dio;
  
  /// Callback to prompt user for download when audio is not available offline
  /// Returns true if user wants to download, false to play online
  Future<bool> Function(dynamic verse)? onPromptDownload;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<AudioState> _stateController = StreamController<AudioState>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<AudioDownloadProgress> _downloadController = StreamController<AudioDownloadProgress>.broadcast();

  // Current playback state
  AudioState _currentState = AudioState.stopped;
  List<VerseAudio> _playlist = [];
  int _currentIndex = 0;
  RepeatMode _repeatMode = RepeatMode.off;
  bool _autoAdvance = true;
  double _playbackSpeed = 1.0;
  Timer? _positionTimer;

  // Getters for streams
  Stream<AudioState> get stateStream => _stateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<AudioDownloadProgress> get downloadStream => _downloadController.stream;

  // Getters for current state
  AudioState get currentState => _currentState;
  List<VerseAudio> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  RepeatMode get repeatMode => _repeatMode;
  bool get autoAdvance => _autoAdvance;
  double get playbackSpeed => _playbackSpeed;
  VerseAudio? get currentVerse => _playlist.isNotEmpty && _currentIndex < _playlist.length 
    ? _playlist[_currentIndex] 
    : null;

  /// Initialize the audio service
  Future<void> initialize() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _updateState(_mapPlayerState(state));
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _durationController.add(duration);
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((_) {
      _onTrackComplete();
    });
  }

  /// Set the playlist for playback
  Future<void> setPlaylist(List<VerseAudio> verses) async {
    _playlist = verses;
    _currentIndex = 0;
    if (kDebugMode) {
      print('Audio: Playlist set with ${verses.length} verses');
    }
  }

  /// Play a specific verse with smart online/offline handling
  Future<void> playVerse(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    _currentIndex = index;
    final verse = _playlist[index];
    
    if (kDebugMode) {
      print('Audio: Playing verse ${verse.verseKey}');
    }

    try {
      // Check if audio is available offline
      final localPath = await _getLocalAudioPath(verse);
      
      if (localPath != null && File(localPath).existsSync()) {
        // Play from local file
        await _audioPlayer.play(DeviceFileSource(localPath));
        if (kDebugMode) {
          print('Audio: Playing from local file: $localPath');
        }
        _updateState(AudioState.playing);
      } else if (verse.onlineUrl != null) {
        // Check if we should prompt user for download
        if (onPromptDownload != null) {
          final shouldDownload = await onPromptDownload!(verse);
          
          if (shouldDownload) {
            // Download the verse audio first
            _updateState(AudioState.buffering);
            await downloadVerseAudio(verse);
            
            // Now play from local file
            final newLocalPath = await _getLocalAudioPath(verse);
            if (newLocalPath != null && File(newLocalPath).existsSync()) {
              await _audioPlayer.play(DeviceFileSource(newLocalPath));
              _updateState(AudioState.playing);
            } else {
              throw Exception('Failed to download verse ${verse.verseKey}');
            }
          } else {
            // User chose to play online
            await _audioPlayer.play(UrlSource(verse.onlineUrl!));
            _updateState(AudioState.playing);
          }
        } else {
          // No prompt callback, play online directly
          await _audioPlayer.play(UrlSource(verse.onlineUrl!));
          _updateState(AudioState.playing);
        }
        
        if (kDebugMode) {
          print('Audio: Playing from online: ${verse.onlineUrl}');
        }
      } else {
        throw Exception('No audio source available for verse ${verse.verseKey}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Audio: Error playing verse ${verse.verseKey}: $e');
      }
      _updateState(AudioState.error);
    }
  }

  /// Play the current verse
  Future<void> play() async {
    if (_playlist.isEmpty) return;
    
    if (_currentState == AudioState.paused) {
      await _audioPlayer.resume();
    } else {
      await playVerse(_currentIndex);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _updateState(AudioState.stopped);
  }

  /// Play next verse
  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      await playVerse(_currentIndex + 1);
    } else if (_repeatMode == RepeatMode.all) {
      await playVerse(0);
    }
  }

  /// Play previous verse
  Future<void> previous() async {
    if (_currentIndex > 0) {
      await playVerse(_currentIndex - 1);
    } else if (_repeatMode == RepeatMode.all) {
      await playVerse(_playlist.length - 1);
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    if (kDebugMode) {
      print('Audio: Repeat mode set to $mode');
    }
  }

  /// Set auto advance
  void setAutoAdvance(bool enabled) {
    _autoAdvance = enabled;
    if (kDebugMode) {
      print('Audio: Auto advance set to $enabled');
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioPlayer.setPlaybackRate(speed);
    if (kDebugMode) {
      print('Audio: Playback speed set to ${speed}x');
    }
  }

  /// Download verse audio for offline use
  Future<void> downloadVerseAudio(VerseAudio verse, {
    Function(double progress)? onProgress,
  }) async {
    if (verse.onlineUrl == null) {
      throw Exception('No online URL available for verse ${verse.verseKey}');
    }

    final localPath = await _getLocalAudioPath(verse);
    if (localPath == null) {
      throw Exception('Could not determine local path for verse ${verse.verseKey}');
    }

    final file = File(localPath);
    if (file.existsSync()) {
      if (kDebugMode) {
        print('Audio: Verse ${verse.verseKey} already downloaded');
      }
      return;
    }

    try {
      // Create directory if it doesn't exist
      await file.parent.create(recursive: true);

      // Download with progress tracking
      await _dio.download(
        verse.onlineUrl!,
        localPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            onProgress?.call(progress);
            _downloadController.add(AudioDownloadProgress(
              verseKey: verse.verseKey,
              progress: progress,
              isComplete: progress >= 1.0,
            ));
          }
        },
      );

      if (kDebugMode) {
        print('Audio: Downloaded verse ${verse.verseKey} to $localPath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Audio: Error downloading verse ${verse.verseKey}: $e');
      }
      rethrow;
    }
  }

  /// Download entire chapter audio
  Future<void> downloadChapterAudio(
    int chapterId,
    int reciterId,
    List<VerseAudio> verses, {
    Function(double progress, String currentVerse)? onProgress,
  }) async {
    for (int i = 0; i < verses.length; i++) {
      final verse = verses[i];
      final verseProgress = i / verses.length;
      
      onProgress?.call(verseProgress, verse.verseKey);
      
      await downloadVerseAudio(
        verse,
        onProgress: (progress) {
          final totalProgress = (i + progress) / verses.length;
          onProgress?.call(totalProgress, verse.verseKey);
        },
      );
    }
    
    onProgress?.call(1.0, 'Complete');
  }

  /// Download all Quran audio for a specific reciter
  Future<void> downloadFullQuranAudio(
    int reciterId, {
    Function(double progress, String currentChapter)? onProgress,
  }) async {
    onProgress?.call(0.0, 'Starting full Quran download...');
    
    // For full Quran download, we'll need to iterate through all 114 chapters
    final totalChapters = 114;
    
    for (int chapterId = 1; chapterId <= totalChapters; chapterId++) {
      final chapterProgress = (chapterId - 1) / totalChapters;
      
      onProgress?.call(chapterProgress, 'Downloading Surah $chapterId...');
      
      // For this implementation, we'll need to create verse audio objects
      // This is a simplified version - in practice, you'd get the actual verses
      final verses = await _createVerseAudioList(chapterId, reciterId);
      
      if (verses.isNotEmpty) {
        await downloadChapterAudio(
          chapterId,
          reciterId,
          verses,
          onProgress: (progress, verse) {
            final totalProgress = ((chapterId - 1) + progress) / totalChapters;
            onProgress?.call(totalProgress, 'Surah $chapterId - $verse');
          },
        );
      }
    }
    
    onProgress?.call(1.0, 'Full Quran download complete!');
  }

  /// Helper method to create verse audio list for a chapter
  Future<List<VerseAudio>> _createVerseAudioList(int chapterId, int reciterId) async {
    // This would integrate with your verse API to get actual verse data
    // For now, return empty list - this needs to be implemented based on your API
    return [];
  }

  /// Check if verse audio is downloaded
  Future<bool> isVerseDownloaded(VerseAudio verse) async {
    final localPath = await _getLocalAudioPath(verse);
    return localPath != null && File(localPath).existsSync();
  }

  /// Get downloaded audio size for a chapter
  Future<double> getChapterAudioSize(int chapterId, int reciterId) async {
    double totalSize = 0;
    final audioDir = await _getAudioDirectory();
    final chapterDir = Directory('$audioDir/reciter_$reciterId/chapter_$chapterId');
    
    if (chapterDir.existsSync()) {
      await for (final file in chapterDir.list()) {
        if (file is File && file.path.endsWith('.mp3')) {
          final stat = await file.stat();
          totalSize += stat.size;
        }
      }
    }
    
    return totalSize / (1024 * 1024); // Return size in MB
  }

  /// Delete downloaded chapter audio
  Future<void> deleteChapterAudio(int chapterId, int reciterId) async {
    final audioDir = await _getAudioDirectory();
    final chapterDir = Directory('$audioDir/reciter_$reciterId/chapter_$chapterId');
    
    if (chapterDir.existsSync()) {
      await chapterDir.delete(recursive: true);
      if (kDebugMode) {
        print('Audio: Deleted chapter $chapterId audio for reciter $reciterId');
      }
    }
  }

  /// Get storage statistics
  Future<AudioStorageStats> getStorageStats() async {
    final audioDir = await _getAudioDirectory();
    final dir = Directory(audioDir);
    
    if (!dir.existsSync()) {
      return AudioStorageStats(totalSizeMB: 0, fileCount: 0, chaptersCount: 0);
    }

    double totalSize = 0;
    int fileCount = 0;
    Set<int> chapters = {};

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.mp3')) {
        final stat = await entity.stat();
        totalSize += stat.size;
        fileCount++;
        
        // Extract chapter ID from path
        final pathParts = entity.path.split('/');
        for (final part in pathParts) {
          if (part.startsWith('chapter_')) {
            final chapterId = int.tryParse(part.substring(8));
            if (chapterId != null) {
              chapters.add(chapterId);
            }
          }
        }
      }
    }

    return AudioStorageStats(
      totalSizeMB: totalSize / (1024 * 1024),
      fileCount: fileCount,
      chaptersCount: chapters.length,
    );
  }

  // Private methods

  AudioState _mapPlayerState(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        return AudioState.playing;
      case PlayerState.paused:
        return AudioState.paused;
      case PlayerState.stopped:
        return AudioState.stopped;
      case PlayerState.completed:
        return AudioState.stopped;
      case PlayerState.disposed:
        return AudioState.stopped;
    }
  }

  void _updateState(AudioState state) {
    _currentState = state;
    _stateController.add(state);
    
    if (kDebugMode) {
      print('Audio: State changed to $state');
    }
  }

  void _onTrackComplete() {
    if (_repeatMode == RepeatMode.one) {
      // Repeat current verse
      playVerse(_currentIndex);
    } else if (_autoAdvance && _currentIndex < _playlist.length - 1) {
      // Auto advance to next verse
      next();
    } else if (_autoAdvance && _repeatMode == RepeatMode.all) {
      // Start over if at end and repeat all is enabled
      playVerse(0);
    } else {
      // Stop playback
      _updateState(AudioState.stopped);
    }
  }

  Future<String?> _getLocalAudioPath(VerseAudio verse) async {
    final audioDir = await _getAudioDirectory();
    return '$audioDir/reciter_${verse.reciterId}/chapter_${verse.chapterId}/${verse.verseKey.replaceAll(':', '_')}.mp3';
  }

  Future<String> _getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/quran_audio';
  }



  void dispose() {
    _audioPlayer.dispose();
    _stateController.close();
    _positionController.close();
    _durationController.close();
    _downloadController.close();
    _positionTimer?.cancel();
  }
}

// Data classes

class VerseAudio {
  const VerseAudio({
    required this.verseKey,
    required this.chapterId,
    required this.verseNumber,
    required this.reciterId,
    this.onlineUrl,
    this.localPath,
  });

  final String verseKey;
  final int chapterId;
  final int verseNumber;
  final int reciterId;
  final String? onlineUrl;
  final String? localPath;
}

enum AudioState {
  stopped,
  playing,
  paused,
  buffering,
  error,
}

enum RepeatMode {
  off,
  one,
  all,
}

class AudioDownloadProgress {
  const AudioDownloadProgress({
    required this.verseKey,
    required this.progress,
    required this.isComplete,
    this.status,
  });

  final String verseKey;
  final double progress;
  final bool isComplete;
  final String? status;
}

class AudioStorageStats {
  const AudioStorageStats({
    required this.totalSizeMB,
    required this.fileCount,
    required this.chaptersCount,
  });

  final double totalSizeMB;
  final int fileCount;
  final int chaptersCount;
}

// Providers

final quranAudioServiceProvider = Provider<QuranAudioService>((ref) {
  // Create a basic implementation that works without throwing
  return QuranAudioService();
});

final audioStateProvider = StreamProvider<AudioState>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.stateStream;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.positionStream;
});

final audioDurationProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.durationStream;
});

final audioDownloadProgressProvider = StreamProvider<AudioDownloadProgress>((ref) {
  final service = ref.watch(quranAudioServiceProvider);
  return service.downloadStream;
});

final audioStorageStatsProvider = FutureProvider<AudioStorageStats>((ref) async {
  final service = ref.watch(quranAudioServiceProvider);
  return service.getStorageStats();
});
