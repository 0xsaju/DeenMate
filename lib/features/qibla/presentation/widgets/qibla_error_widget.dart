import 'package:flutter/material.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../../../../core/localization/strings.dart';

/// Qibla error widget with recovery options
class QiblaErrorWidget extends StatelessWidget {
  const QiblaErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onCalibrate,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCalibrate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildErrorIcon(),
            const SizedBox(height: 24),
            _buildErrorTitle(context),
            const SizedBox(height: 16),
            _buildErrorMessage(context),
            const SizedBox(height: 32),
            _buildErrorActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.error_outline,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorTitle(BuildContext context) {
    return Text(
      S.t(context, 'qibla_error', 'Qibla Error'),
      style: IslamicTheme.textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            S.t(context, 'error_help_text', 'Please check your device settings and try again.'),
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(S.t(context, 'retry', 'Retry')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: IslamicTheme.islamicGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onCalibrate,
          icon: const Icon(Icons.compass_calibration),
          label: Text(S.t(context, 'calibrate_compass', 'Calibrate Compass')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            foregroundColor: IslamicTheme.islamicGreen,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            // Show help dialog
            showDialog(
              context: context,
              builder: (context) => _buildHelpDialog(context),
            );
          },
          icon: const Icon(Icons.help_outline, color: Colors.white),
          label: Text(
            S.t(context, 'help', 'Help'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpDialog(BuildContext context) {
    return AlertDialog(
      title: Text(S.t(context, 'qibla_help', 'Qibla Help')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.t(context, 'help_title', 'Common Issues:'),
            style: IslamicTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildHelpItem(
            context,
            S.t(context, 'location_permission', 'Location Permission'),
            S.t(context, 'location_permission_help', 'Make sure location services are enabled and permission is granted.'),
          ),
          _buildHelpItem(
            context,
            S.t(context, 'compass_sensor', 'Compass Sensor'),
            S.t(context, 'compass_sensor_help', 'Ensure your device has a compass sensor and it\'s working properly.'),
          ),
          _buildHelpItem(
            context,
            S.t(context, 'calibration', 'Calibration'),
            S.t(context, 'calibration_help', 'Move your device in a figure-8 pattern to calibrate the compass.'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(S.t(context, 'close', 'Close')),
        ),
      ],
    );
  }

  Widget _buildHelpItem(BuildContext context, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
