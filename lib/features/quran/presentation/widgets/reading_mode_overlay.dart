import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/providers.dart';
import '../../../../core/theme/theme_helper.dart';

class ReadingModeOverlay extends ConsumerStatefulWidget {
  const ReadingModeOverlay({
    super.key,
    required this.child,
    required this.onExitReadingMode,
  });

  final Widget child;
  final VoidCallback onExitReadingMode;

  @override
  ConsumerState<ReadingModeOverlay> createState() => _ReadingModeOverlayState();
}

class _ReadingModeOverlayState extends ConsumerState<ReadingModeOverlay>
    with TickerProviderStateMixin {
  late AnimationController _overlayController;
  late Animation<double> _overlayAnimation;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    // Auto-hide controls after 3 seconds
    _showControlsTemporarily();
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    _overlayController.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  void _hideControls() {
    _overlayController.reverse().then((_) {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getReadingModeBackground(context),
      body: Stack(
        children: [
          // Main content
          GestureDetector(
            onTap: _toggleControls,
            child: Container(
              color: Colors.transparent,
              child: widget.child,
            ),
          ),
          
          // Top overlay with controls
          if (_showControls)
            AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, -80 * (1 - _overlayAnimation.value)),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Exit reading mode
                              IconButton(
                                onPressed: widget.onExitReadingMode,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const Spacer(),
                              
                              // Reading mode title
                              Text(
                                'Reading Mode',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              
                              // Settings
                              IconButton(
                                onPressed: _showReadingSettings,
                                icon: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          
          // Bottom overlay with progress and controls
          if (_showControls)
            AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, 80 * (1 - _overlayAnimation.value)),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            children: [
                              // Progress indicator
                              _buildProgressIndicator(),
                              const SizedBox(height: 12),
                              
                              // Control buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildControlButton(
                                    Icons.brightness_6,
                                    'Theme',
                                    _showThemeOptions,
                                  ),
                                  _buildControlButton(
                                    Icons.text_fields,
                                    'Font',
                                    _showFontOptions,
                                  ),
                                  _buildControlButton(
                                    Icons.translate,
                                    'Translation',
                                    _showTranslationOptions,
                                  ),
                                  _buildControlButton(
                                    Icons.bookmark_outline,
                                    'Bookmark',
                                    _addBookmark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // This would be connected to actual reading progress
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: 0.35, // Example progress
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getReadingModeBackground(BuildContext context) {
    final prefs = ref.watch(prefsProvider);
    
    // You can add theme-based backgrounds here
    switch (prefs.arabicFontFamily) {
      case 'sepia':
        return const Color(0xFFF5F1E8); // Sepia background
      case 'dark':
        return const Color(0xFF1A1A1A); // Dark background
      case 'green':
        return const Color(0xFFE8F5E8); // Green background
      default:
        return ThemeHelper.getBackgroundColor(context);
    }
  }

  void _showReadingSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReadingSettingsSheet(),
    );
  }

  void _showThemeOptions() {
    // Implement theme selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Theme options coming soon')),
    );
  }

  void _showFontOptions() {
    // Implement font options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Font options coming soon')),
    );
  }

  void _showTranslationOptions() {
    // Implement translation selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Translation options coming soon')),
    );
  }

  void _addBookmark() {
    // Implement bookmark functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bookmark added')),
    );
  }
}

class _ReadingSettingsSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ThemeHelper.getDividerColor(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Reading Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
            ),
          ),
          
          // Settings options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  'Text Size',
                  Icons.text_fields,
                  () {},
                ),
                _buildSettingTile(
                  context,
                  'Line Height',
                  Icons.format_line_spacing,
                  () {},
                ),
                _buildSettingTile(
                  context,
                  'Reading Theme',
                  Icons.palette,
                  () {},
                ),
                _buildSettingTile(
                  context,
                  'Auto-scroll',
                  Icons.play_arrow,
                  () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: ThemeHelper.getPrimaryColor(context),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: ThemeHelper.getTextPrimaryColor(context),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ],
        ),
      ),
    );
  }
}
