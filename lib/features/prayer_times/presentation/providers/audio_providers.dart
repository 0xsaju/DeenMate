import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

      // Robust asset load: resolve from manifest first
      final manifestJson = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = jsonDecode(manifestJson) as Map<String, dynamic>;
      final wantedSuffix = '/${muadhinVoice}_athan.mp3';
      final manifestMatches = manifest.keys.where((k) => k.endsWith(wantedSuffix)).toList();
      ByteData? bytes;
      if (manifestMatches.isNotEmpty) {
        for (final k in manifestMatches) {
          try {
            bytes = await rootBundle.load(k);
            break;
          } catch (_) {}
        }
      }
      // Fallback candidates
      if (bytes == null) {
        final candidates = <String>[
          'assets/audio/athan/${muadhinVoice}_athan.mp3',
          'audio/athan/${muadhinVoice}_athan.mp3',
        ];
        for (final path in candidates) {
          try {
            bytes = await rootBundle.load(path);
            break;
          } catch (_) {}
        }
      }
      if (bytes == null) {
        throw Failure.audioPlaybackFailure(
          message:
              'Athan asset not found for "$muadhinVoice". Expected at assets/audio/athan/${muadhinVoice}_athan.mp3',
        );
      }
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${muadhinVoice}_athan.mp3');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await _audioPlayer.play(DeviceFileSource(file.path));

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
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Provider for Athan Audio
final athanAudioProvider = StateNotifierProvider<AthanAudioNotifier, AthanAudioState>(
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
