import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../../core/error/failures.dart';

/// Audio state for Athan playback
class AthanAudioState {
  const AthanAudioState({
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.duration,
    this.position,
  });
  final bool isPlaying;
  final bool isLoading;
  final Failure? error;
  final Duration? duration;
  final Duration? position;

  AthanAudioState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Failure? error,
    Duration? duration,
    Duration? position,
  }) {
    return AthanAudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }
}

/// Athan Audio Provider using audioplayers
class AthanAudioNotifier extends StateNotifier<AthanAudioState> {
  AthanAudioNotifier() : super(const AthanAudioState()) {
    _setupAudioPlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _previewStopTimer;

  void _setupAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState playerState) {
      state = state.copyWith(
        isPlaying: playerState == PlayerState.playing,
        isLoading: playerState == PlayerState.playing,
      );
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      state = state.copyWith(duration: duration);
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      state = state.copyWith(position: position);
    });
  }

  /// Preview Athan audio
  Future<void> previewAthan(String muadhinVoice) async {
    try {
      state = state.copyWith(isLoading: true);

      // Stop any currently playing audio
      await _audioPlayer.stop();
      _previewStopTimer?.cancel();

      // Simple direct path approach
      final audioPath = 'assets/audio/athan/${muadhinVoice}_athan.mp3';

      // Load the audio file
      ByteData? bytes;
      try {
        bytes = await rootBundle.load(audioPath);
      } catch (e) {
        // Fallback: try alternative paths
        final fallbackPaths = [
          'assets/audio/athan/default_athan.mp3', // Ultimate fallback
          'audio/athan/${muadhinVoice}_athan.mp3',
        ];

        for (final path in fallbackPaths) {
          try {
            bytes = await rootBundle.load(path);
            break;
          } catch (fallbackError) {
            // Continue to next fallback
          }
        }
      }

      if (bytes == null) {
        throw Failure.audioPlaybackFailure(
          message:
              'Athan asset not found for "$muadhinVoice". Expected at $audioPath',
        );
      }

      // Write to temporary file and play
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${muadhinVoice}_athan.mp3');
      await file.writeAsBytes(bytes.buffer.asUint8List());

      // Ensure no looping and set a comfortable preview volume
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      // Play preview with reduced duration (30 seconds max for preview)
      await _audioPlayer.play(
        DeviceFileSource(file.path),
        volume: 0.6,
      );

      // Use 30 seconds for preview instead of 10 to give a better sense of the full Azan
      _previewStopTimer = Timer(const Duration(seconds: 30), () async {
        try {
          await _audioPlayer.stop();
        } catch (_) {}
        if (mounted) {
          state = state.copyWith(isPlaying: false, isLoading: false);
        }
      });

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: Failure.audioPlaybackFailure(
          message: 'Failed to play Athan preview: $e',
        ),
      );
    }
  }

  /// Stop Athan playback
  Future<void> stopAthan() async {
    try {
      _previewStopTimer?.cancel();
      await _audioPlayer.stop();
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: Failure.audioPlaybackFailure(
          message: 'Failed to stop Athan: $e',
        ),
      );
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      state = state.copyWith(
        error: Failure.audioPlaybackFailure(
          message: 'Failed to set volume: $e',
        ),
      );
    }
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      state = state.copyWith(
        error: Failure.audioPlaybackFailure(
          message: 'Failed to seek: $e',
        ),
      );
    }
  }

  @override
  void dispose() {
    _previewStopTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Provider for Athan Audio
final athanAudioProvider =
    StateNotifierProvider<AthanAudioNotifier, AthanAudioState>(
  (ref) => AthanAudioNotifier(),
);

/// Provider for available Athan voices
final athanVoicesProvider = Provider<List<AthanVoice>>((ref) {
  return [
    const AthanVoice(
      id: 'abdulbasit',
      name: 'Abdul Basit Abdul Samad',
      description: 'Renowned Quranic reciter from Egypt',
      country: 'Egypt',
    ),
    const AthanVoice(
      id: 'mishary',
      name: 'Mishary Rashid Alafasy',
      description: 'Famous Imam and reciter from Kuwait',
      country: 'Kuwait',
    ),
    const AthanVoice(
      id: 'sudais',
      name: 'Sheikh Abdul Rahman Al-Sudais',
      description: 'Imam of Masjid al-Haram in Mecca',
      country: 'Saudi Arabia',
    ),
    const AthanVoice(
      id: 'shuraim',
      name: 'Sheikh Saud Al-Shuraim',
      description: 'Imam of Masjid al-Haram in Mecca',
      country: 'Saudi Arabia',
    ),
    const AthanVoice(
      id: 'maher',
      name: 'Maher Al-Muaiqly',
      description: 'Imam of Masjid al-Haram',
      country: 'Saudi Arabia',
    ),
  ];
});

/// Athan Voice model
class AthanVoice {
  const AthanVoice({
    required this.id,
    required this.name,
    required this.description,
    required this.country,
  });
  final String id;
  final String name;
  final String description;
  final String country;
}
