import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../../domain/services/audio_service.dart' as audio_service;
import '../../../../core/theme/theme_helper.dart';

class AudioPlayerWidget extends ConsumerStatefulWidget {
  const AudioPlayerWidget({
    super.key,
    this.isMinimized = false,
    this.onMinimize,
    this.onExpand,
  });

  final bool isMinimized;
  final VoidCallback? onMinimize;
  final VoidCallback? onExpand;

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioStateProvider);
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeHelper.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(widget.isMinimized ? 12 : 20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.isMinimized 
          ? _buildMinimizedPlayer(context, audioState, position, duration)
          : _buildExpandedPlayer(context, audioState, position, duration),
      ),
    );
  }

  Widget _buildMinimizedPlayer(
    BuildContext context,
    AsyncValue<audio_service.AudioState> audioState,
    AsyncValue<Duration> position,
    AsyncValue<Duration> duration,
  ) {
    return InkWell(
      onTap: widget.onExpand,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Play/Pause button
            _buildPlayPauseButton(audioState, size: 32),
            
            const SizedBox(width: 12),
            
            // Current verse info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getCurrentVerseTitle(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeHelper.getTextPrimaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getCurrentReciterName(),
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemeHelper.getTextSecondaryColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Mini progress indicator
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: ThemeHelper.getDividerColor(context),
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _getProgressValue(position, duration),
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeHelper.getPrimaryColor(context),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Close button
            InkWell(
              onTap: _hidePlayer,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: ThemeHelper.getTextSecondaryColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(
    BuildContext context,
    AsyncValue<audio_service.AudioState> audioState,
    AsyncValue<Duration> position,
    AsyncValue<Duration> duration,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with minimize button
          Row(
            children: [
              Text(
                'Now Playing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeHelper.getTextPrimaryColor(context),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onMinimize,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: ThemeHelper.getTextSecondaryColor(context),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Verse info card
          _buildVerseInfoCard(context),
          
          const SizedBox(height: 32),
          
          // Progress slider
          _buildProgressSlider(context, position, duration),
          
          const SizedBox(height: 24),
          
          // Main controls
          _buildMainControls(context, audioState),
          
          const SizedBox(height: 24),
          
          // Additional controls
          _buildAdditionalControls(context),
        ],
      ),
    );
  }

  Widget _buildVerseInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeHelper.getPrimaryColor(context).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemeHelper.getPrimaryColor(context).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Arabic verse preview
          Text(
            _getCurrentVerseArabic(),
            style: TextStyle(
              fontSize: 20,
              height: 1.8,
              color: ThemeHelper.getTextPrimaryColor(context),
              fontFamily: 'Uthmani',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Verse reference
          Text(
            _getCurrentVerseTitle(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getPrimaryColor(context),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Reciter name
          Text(
            _getCurrentReciterName(),
            style: TextStyle(
              fontSize: 14,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSlider(
    BuildContext context,
    AsyncValue<Duration> position,
    AsyncValue<Duration> duration,
  ) {
    return Column(
      children: [
        // Time labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(position.value ?? Duration.zero),
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
            Text(
              _formatDuration(duration.value ?? Duration.zero),
              style: TextStyle(
                fontSize: 12,
                color: ThemeHelper.getTextSecondaryColor(context),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: ThemeHelper.getPrimaryColor(context),
            inactiveTrackColor: ThemeHelper.getDividerColor(context),
            thumbColor: ThemeHelper.getPrimaryColor(context),
            overlayColor: ThemeHelper.getPrimaryColor(context).withOpacity(0.2),
          ),
          child: Slider(
            value: _getProgressValue(position, duration),
            onChanged: _onSeek,
            min: 0.0,
            max: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildMainControls(
    BuildContext context,
    AsyncValue<audio_service.AudioState> audioState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        _buildControlButton(
          Icons.skip_previous,
          _onPrevious,
          size: 32,
        ),
        
        const SizedBox(width: 24),
        
        // Play/Pause button (large)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: ThemeHelper.getPrimaryColor(context),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ThemeHelper.getPrimaryColor(context).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildPlayPauseButton(audioState, size: 28, color: Theme.of(context).colorScheme.onPrimary),
        ),
        
        const SizedBox(width: 24),
        
        // Next button
        _buildControlButton(
          Icons.skip_next,
          _onNext,
          size: 32,
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          Icons.repeat,
          _onRepeatToggle,
          size: 24,
        ),
        _buildControlButton(
          Icons.speed,
          _onSpeedToggle,
          size: 24,
        ),
        _buildControlButton(
          Icons.playlist_play,
          _onShowPlaylist,
          size: 24,
        ),
        _buildControlButton(
          Icons.download,
          _onDownload,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildControlButton(
    IconData icon,
    VoidCallback? onPressed, {
    double size = 24,
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        child: Icon(
          icon,
          size: size,
          color: color ?? ThemeHelper.getTextSecondaryColor(context),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton(
    AsyncValue<audio_service.AudioState> audioState, {
    double size = 24,
    Color? color,
  }) {
    return audioState.when(
      data: (state) {
        IconData icon;
        VoidCallback? onPressed;
        
        switch (state) {
          case audio_service.AudioState.playing:
            icon = Icons.pause;
            onPressed = _onPause;
            break;
          case audio_service.AudioState.paused:
          case audio_service.AudioState.stopped:
            icon = Icons.play_arrow;
            onPressed = _onPlay;
            break;
          case audio_service.AudioState.buffering:
            return SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? ThemeHelper.getTextSecondaryColor(context),
                ),
              ),
            );
          case audio_service.AudioState.error:
            icon = Icons.error;
            onPressed = null;
            break;
        }
        
        return InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size),
          child: Icon(
            icon,
            size: size,
            color: color ?? ThemeHelper.getTextSecondaryColor(context),
          ),
        );
      },
      loading: () => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? ThemeHelper.getTextSecondaryColor(context),
          ),
        ),
      ),
      error: (_, __) => Icon(
        Icons.error,
        size: size,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // Helper methods

  String _getCurrentVerseTitle() {
    // TODO: Get from audio service
    return 'Surah Al-Fatiha (1:1)';
  }

  String _getCurrentReciterName() {
    // TODO: Get from audio service
    return 'Mishary Rashid Alafasy';
  }

  String _getCurrentVerseArabic() {
    // TODO: Get from audio service
    return 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
  }

  double _getProgressValue(AsyncValue<Duration> position, AsyncValue<Duration> duration) {
    final pos = position.value?.inMilliseconds ?? 0;
    final dur = duration.value?.inMilliseconds ?? 0;
    
    if (dur == 0) return 0.0;
    return (pos / dur).clamp(0.0, 1.0);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Action handlers

  void _onPlay() async {
    final audioService = ref.read(quranAudioServiceProvider);
    try {
      await audioService.play();
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _onPause() async {
    final audioService = ref.read(quranAudioServiceProvider);
    try {
      await audioService.pause();
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }

  void _onNext() async {
    final audioService = ref.read(quranAudioServiceProvider);
    try {
      await audioService.next();
    } catch (e) {
      print('Error skipping to next: $e');
    }
  }

  void _onPrevious() async {
    final audioService = ref.read(quranAudioServiceProvider);
    try {
      await audioService.previous();
    } catch (e) {
      print('Error skipping to previous: $e');
    }
  }

  void _onSeek(double value) async {
    final audioService = ref.read(quranAudioServiceProvider);
    try {
      final duration = Duration(milliseconds: (value * 100000).round());
      await audioService.seek(duration);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  void _onRepeatToggle() {
    // TODO: Implement repeat mode in audio service
    print('Repeat toggle - not yet implemented in service');
  }

  void _onSpeedToggle() {
    // TODO: Implement playback speed in audio service
    print('Speed toggle - not yet implemented in service');
  }

  void _onShowPlaylist() {
    // TODO: Implement playlist view
    print('Show playlist');
  }

  void _onDownload() {
    // TODO: Implement download functionality
    print('Download current verse');
  }

  void _hidePlayer() {
    _slideController.reverse().then((_) {
      // TODO: Hide player completely
      print('Hide player');
    });
  }
}
