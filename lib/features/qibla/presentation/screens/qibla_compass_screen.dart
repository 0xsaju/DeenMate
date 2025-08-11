import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/localization/strings.dart';
import '../../domain/entities/qibla_direction.dart';
import '../providers/qibla_providers.dart';
import '../widgets/qibla_compass_widget.dart';
import '../widgets/qibla_calibration_widget.dart';
import '../widgets/qibla_error_widget.dart';

/// Beautiful Islamic Qibla Compass Screen with Clean Architecture
class QiblaCompassScreen extends ConsumerStatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  ConsumerState<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends ConsumerState<QiblaCompassScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQibla();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ),);
    
    _pulseController.repeat(reverse: true);
  }

  Future<void> _initializeQibla() async {
    final qiblaState = ref.read(qiblaStateProvider.notifier);
    await qiblaState.initializeSensors();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaState = ref.watch(qiblaStateProvider);
    final sensorsAvailableAsync = ref.watch(sensorsAvailableProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status indicator
              _buildStatusIndicator(qiblaState, sensorsAvailableAsync),
              
              // Main content
              Expanded(
                child: _buildMainContent(qiblaState, sensorsAvailableAsync),
              ),
              
              // Action buttons
              _buildActionButtons(qiblaState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(QiblaState qiblaState, AsyncValue<bool> sensorsAvailableAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            _getStatusIcon(qiblaState),
            color: _getStatusColor(qiblaState),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getStatusText(qiblaState, sensorsAvailableAsync),
              style: TextStyle(
                color: _getStatusColor(qiblaState),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(QiblaState qiblaState, AsyncValue<bool> sensorsAvailableAsync) {
    return sensorsAvailableAsync.when(
      data: (sensorsAvailable) {
        if (!sensorsAvailable) {
          return _buildSensorUnavailableState();
        }

        return _buildQiblaContent(qiblaState);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildQiblaContent(QiblaState qiblaState) {
    switch (qiblaState.runtimeType) {
      case QiblaInitial:
        return _buildInitialState();
      case QiblaLoading:
        return _buildLoadingState();
      case QiblaCalibrating:
        return _buildCalibratingState();
      case QiblaReady:
        return _buildReadyState();
      case QiblaLoaded:
        final loadedState = qiblaState as QiblaLoaded;
        return _buildLoadedState(loadedState.qiblaDirection);
      case QiblaError:
        final errorState = qiblaState as QiblaError;
        return _buildErrorState(errorState.message);
      default:
        return _buildInitialState();
    }
  }

  Widget _buildActionButtons(QiblaState qiblaState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _refreshQibla,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _calibrateCompass,
            icon: const Icon(Icons.compass_calibration),
            label: const Text('Calibrate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _clearCache,
            icon: const Icon(Icons.clear_all),
            label: const Text('Clear Cache'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(QiblaState state) {
    switch (state.runtimeType) {
      case QiblaInitial:
        return Icons.compass_calibration;
      case QiblaLoading:
        return Icons.hourglass_empty;
      case QiblaCalibrating:
        return Icons.compass_calibration;
      case QiblaReady:
        return Icons.check_circle;
      case QiblaLoaded:
        return Icons.location_on;
      case QiblaError:
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(QiblaState state) {
    switch (state.runtimeType) {
      case QiblaInitial:
        return Colors.blue;
      case QiblaLoading:
        return Colors.orange;
      case QiblaCalibrating:
        return Colors.purple;
      case QiblaReady:
        return Colors.green;
      case QiblaLoaded:
        return Colors.green;
      case QiblaError:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(QiblaState state, AsyncValue<bool> sensorsAvailableAsync) {
    if (sensorsAvailableAsync.isLoading) {
      return 'Checking sensors...';
    }
    
    if (sensorsAvailableAsync.hasError) {
      return 'Sensor error: ${sensorsAvailableAsync.error}';
    }

    final sensorsAvailable = sensorsAvailableAsync.value ?? false;
    if (!sensorsAvailable) {
      return 'Sensors unavailable';
    }

    switch (state.runtimeType) {
      case QiblaInitial:
        return 'Initializing...';
      case QiblaLoading:
        return 'Loading...';
      case QiblaCalibrating:
        return 'Calibrating compass...';
      case QiblaReady:
        return 'Ready';
      case QiblaLoaded:
        return 'Qibla direction loaded';
      case QiblaError:
        final errorState = state as QiblaError;
        return 'Error: ${errorState.message}';
      default:
        return 'Unknown state';
    }
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return Text(
                    S.t(context, 'qibla_compass', 'Qibla Compass'),
                    style: IslamicTheme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                Builder(builder: (context) {
                  return Text(
                    S.t(context, 'qibla_direction', 'কিবলার দিক | اتجاه القبلة'),
                    style: IslamicTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  );
                }),
              ],
            ),
          ),
          IconButton(
            onPressed: _refreshQibla,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'initializing_qibla', 'Initializing Qibla Compass...'),
              style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'getting_location', 'Getting your location...'),
              style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalibratingState() {
    return const QiblaCalibrationWidget();
  }

  Widget _buildReadyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.compass_calibration,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'compass_ready', 'Compass is ready'),
              style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'tap_to_start', 'Tap to start Qibla direction'),
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            );
          }),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _getCurrentQiblaDirection,
            icon: const Icon(Icons.compass_calibration),
            label: Builder(builder: (context) {
              return Text(S.t(context, 'start_qibla', 'Start Qibla'));
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: IslamicTheme.islamicGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(QiblaDirection qiblaDirection) {
    return Column(
      children: [
        _buildLocationInfo(qiblaDirection),
        const SizedBox(height: 24),
        Expanded(
          child: Center(
            child: QiblaCompassWidget(
              qiblaDirection: qiblaDirection,
              pulseAnimation: _pulseAnimation,
            ),
          ),
        ),
        _buildDistanceInfo(qiblaDirection),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return QiblaErrorWidget(
      message: message,
      onRetry: _getCurrentQiblaDirection,
      onCalibrate: _calibrateCompass,
    );
  }

  Widget _buildSensorUnavailableState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 24),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'sensors_unavailable', 'Sensors Unavailable'),
              style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          const SizedBox(height: 16),
          Builder(builder: (context) {
            return Text(
              S.t(context, 'enable_location_compass', 'Please enable location services and ensure your device has a compass sensor.'),
              style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            );
          }),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            label: Builder(builder: (context) {
              return Text(S.t(context, 'open_settings', 'Open Settings'));
            }),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: IslamicTheme.islamicGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(QiblaDirection qiblaDirection) {
    if (qiblaDirection.locationName == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(builder: (context) {
                  return Text(
                    S.t(context, 'your_location', 'Your Location'),
                    style: IslamicTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  );
                }),
                Text(
                  qiblaDirection.locationName!,
                  style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceInfo(QiblaDirection qiblaDirection) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            S.t(context, 'distance_to_mecca', 'Distance to Mecca'),
            qiblaDirection.formattedDistance,
          ),
          _buildInfoItem(
            S.t(context, 'qibla_direction', 'Qibla Direction'),
            qiblaDirection.formattedBearing,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: IslamicTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Action methods

  void _refreshQibla() {
    final qiblaState = ref.read(qiblaStateProvider.notifier);
    qiblaState.getCurrentQiblaDirection();
  }

  void _getCurrentQiblaDirection() {
    final qiblaState = ref.read(qiblaStateProvider.notifier);
    qiblaState.getCurrentQiblaDirection();
  }

  void _calibrateCompass() {
    final qiblaState = ref.read(qiblaStateProvider.notifier);
    qiblaState.calibrateCompass();
  }

  void _showSettings() {
    // Show Qibla settings dialog
    showDialog(
      context: context,
      builder: (context) => _buildSettingsDialog(),
    );
  }

  void _openSettings() {
    // Open device settings
    // This would typically use a package like app_settings
  }

  Widget _buildSettingsDialog() {
    return AlertDialog(
      title: Builder(builder: (context) {
        return Text(S.t(context, 'qibla_settings', 'Qibla Settings'));
      }),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.compass_calibration),
            title: Builder(builder: (context) {
              return Text(S.t(context, 'calibrate_compass', 'Calibrate Compass'));
            }),
            onTap: () {
              Navigator.pop(context);
              _calibrateCompass();
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: Builder(builder: (context) {
              return Text(S.t(context, 'refresh_location', 'Refresh Location'));
            }),
            onTap: () {
              Navigator.pop(context);
              _refreshQibla();
            },
          ),
          ListTile(
            leading: const Icon(Icons.clear),
            title: Builder(builder: (context) {
              return Text(S.t(context, 'clear_cache', 'Clear Cache'));
            }),
            onTap: () {
              Navigator.pop(context);
              _clearCache();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Builder(builder: (context) {
            return Text(S.t(context, 'cancel', 'Cancel'));
          }),
        ),
      ],
    );
  }

  void _clearCache() {
    final qiblaState = ref.read(qiblaStateProvider.notifier);
    qiblaState.clearCache();
  }
}
