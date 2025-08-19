import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/isha_time_widget.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/isha_time_providers.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/isha_time_data.dart';

class IshaTimeDemoScreen extends ConsumerWidget {
  const IshaTimeDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isha Prayer Times'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header information
            _buildHeader(),
            const SizedBox(height: 16),

            // Isha time widget
            const IshaTimeWidget(),
            const SizedBox(height: 16),

            // Scholarly view selector
            _buildScholarlyViewSelector(ref),
            const SizedBox(height: 16),

            // Educational information
            _buildEducationalSection(ref),
            const SizedBox(height: 16),

            // Current status
            _buildCurrentStatus(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.nightlight_round, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Authentic Isha Prayer Times',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Based on Sahih Hadiths with Islamic Midnight Calculation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarlyViewSelector(WidgetRef ref) {
    final currentView = ref.watch(scholarlyViewProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scholarly View',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildScholarlyOption(
                    ref,
                    ScholarlyView.majority,
                    'Majority View',
                    'Preferred until midnight, permissible until Fajr (Jumhur)',
                    currentView == ScholarlyView.majority,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildScholarlyOption(
                    ref,
                    ScholarlyView.strict,
                    'Strict View',
                    'Hard deadline at Islamic midnight (Ibn Hazm, Al-Albani)',
                    currentView == ScholarlyView.strict,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScholarlyOption(
    WidgetRef ref,
    ScholarlyView view,
    String title,
    String description,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => ref.read(scholarlyViewProvider.notifier).state = view,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue : Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationalSection(WidgetRef ref) {
    final educationalInfo = ref.watch(ishaEducationalInfoProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Educational Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
                'Hadith Source', educationalInfo['hadith_source'] ?? ''),
            _buildInfoRow('Hadith Text', educationalInfo['hadith_text'] ?? ''),
            _buildInfoRow('Explanation', educationalInfo['explanation'] ?? ''),
            _buildInfoRow('Scholarly Differences',
                educationalInfo['scholarly_differences'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(WidgetRef ref) {
    final urgencyLevel = ref.watch(ishaUrgencyLevelProvider);
    final statusMessage = ref.watch(ishaStatusMessageProvider);
    final isCurrentTimeIsha = ref.watch(isCurrentTimeIshaProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow('Urgency Level', urgencyLevel.toUpperCase()),
            _buildStatusRow('Status Message', statusMessage),
            _buildStatusRow('Is Isha Time', isCurrentTimeIsha ? 'YES' : 'NO'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
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
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
