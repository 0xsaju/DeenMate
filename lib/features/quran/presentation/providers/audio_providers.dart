import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioState {
  const AudioState({this.isPlaying = false, this.currentUrl, this.repeatOne = false});
  final bool isPlaying;
  final String? currentUrl;
  final bool repeatOne;
}

class AudioNotifier extends Notifier<AudioState> {
  final AudioPlayer _player = AudioPlayer();

  @override
  AudioState build() {
    _player.onPlayerComplete.listen((_) {
      if (state.repeatOne && state.currentUrl != null) {
        play(state.currentUrl!);
      } else {
        state = const AudioState(isPlaying: false);
      }
    });
    return const AudioState();
  }

  Future<void> play(String url) async {
    await _player.stop();
    await _player.play(UrlSource(url));
    state = AudioState(isPlaying: true, currentUrl: url, repeatOne: state.repeatOne);
  }

  Future<void> pause() async {
    await _player.pause();
    state = AudioState(isPlaying: false, currentUrl: state.currentUrl, repeatOne: state.repeatOne);
  }

  Future<void> resume() async {
    final url = state.currentUrl;
    if (url != null) {
      await _player.resume();
      state = AudioState(isPlaying: true, currentUrl: url, repeatOne: state.repeatOne);
    }
  }

  void toggleRepeat() {
    state = AudioState(isPlaying: state.isPlaying, currentUrl: state.currentUrl, repeatOne: !state.repeatOne);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final audioStateProvider = NotifierProvider<AudioNotifier, AudioState>(AudioNotifier.new);


