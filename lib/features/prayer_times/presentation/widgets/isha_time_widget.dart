import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/isha_time_data.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/isha_time_providers.dart';

class IshaTimeWidget extends ConsumerWidget {
  const IshaTimeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ishaDataAsync = ref.watch(ishaTimeDataProvider);
    final urgencyLevel = ref.watch(ishaUrgencyLevelProvider);
    final statusMessage = ref.watch(ishaStatusMessageProvider);

    return ishaDataAsync.when(
      data: (ishaData) =>
          _buildIshaTimeCard(context, ishaData, urgencyLevel, statusMessage),
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(error.toString()),
    );
  }

  Widget _buildIshaTimeCard(
    BuildContext context,
    IshaTimeData ishaData,
    String urgencyLevel,
    String statusMessage,
  ) {
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.nightlight_round,
                  color: _getStatusColor(ishaData.status),
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Isha Prayer Times',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildStatusChip(ishaData.status),
              ],
            ),
            const SizedBox(height: 16),

            // Time windows
            _buildTimeRow('Start Time', timeFormat.format(ishaData.startTime),
                Colors.green),
            _buildTimeRow('Optimal End',
                timeFormat.format(ishaData.optimalEndTime), Colors.blue),
            _buildTimeRow('Islamic Midnight',
                timeFormat.format(ishaData.islamicMidnight), Colors.orange),
            _buildTimeRow('Absolute End',
                timeFormat.format(ishaData.absoluteEndTime), Colors.red),

            const SizedBox(height: 12),

            // Status message
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getStatusColor(ishaData.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(ishaData.status),
                    color: _getStatusColor(ishaData.status),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: TextStyle(
                        color: _getStatusColor(ishaData.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Educational info
            _buildEducationalInfo(ishaData),

            const SizedBox(height: 12),

            // Scholarly view indicator
            _buildScholarlyViewIndicator(ishaData.scholarlyView),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(IshaStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEducationalInfo(IshaTimeData ishaData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 16),
              SizedBox(width: 8),
              Text(
                'Islamic Midnight Calculation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Based on Sahih Muslim (612): "The time of Isha is until the middle of the night"',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Islamic Midnight = (Maghrib + Fajr) ÷ 2 = ${_formatDuration(ishaData.nightDuration)} night duration',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarlyViewIndicator(ScholarlyView scholarlyView) {
    final isStrict = scholarlyView == ScholarlyView.strict;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isStrict
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isStrict
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isStrict ? Icons.warning : Icons.check_circle,
            color: isStrict ? Colors.red : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isStrict
                  ? 'Strict View: Hard deadline at Islamic midnight (Ibn Hazm, Al-Albani)'
                  : 'Majority View: Preferred until midnight, permissible until Fajr (Jumhur)',
              style: TextStyle(
                fontSize: 12,
                color: isStrict ? Colors.red[700] : Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return const Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error loading Isha times',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(IshaStatus status) {
    switch (status) {
      case IshaStatus.optimal:
        return Colors.green;
      case IshaStatus.permissible:
        return Colors.blue;
      case IshaStatus.ending:
        return Colors.orange;
      case IshaStatus.ended:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(IshaStatus status) {
    switch (status) {
      case IshaStatus.optimal:
        return Icons.check_circle;
      case IshaStatus.permissible:
        return Icons.info;
      case IshaStatus.ending:
        return Icons.warning;
      case IshaStatus.ended:
        return Icons.error;
    }
  }

  String _getStatusText(IshaStatus status) {
    switch (status) {
      case IshaStatus.optimal:
        return 'OPTIMAL';
      case IshaStatus.permissible:
        return 'PERMISSIBLE';
      case IshaStatus.ending:
        return 'ENDING SOON';
      case IshaStatus.ended:
        return 'ENDED';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
