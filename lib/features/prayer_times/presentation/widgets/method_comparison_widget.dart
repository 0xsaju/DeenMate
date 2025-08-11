import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/calculation_method.dart';

/// Simple class to represent method differences
class MethodDifference {
  const MethodDifference({
    required this.impact,
    required this.estimatedTimeDifference,
  });

  final String impact;
  final int estimatedTimeDifference;
}

/// Widget for comparing two calculation methods
class MethodComparisonWidget extends StatelessWidget {
  const MethodComparisonWidget({
    required this.method1,
    required this.method2,
    super.key,
    this.onClose,
  });

  final CalculationMethod method1;
  final CalculationMethod method2;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final difference = const MethodDifference(
      impact: 'Moderate',
      estimatedTimeDifference: 5,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Method Comparison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Methods being compared
                Row(
                  children: [
                    Expanded(
                      child: _buildMethodSummary(method1, Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMethodSummary(method2, Colors.green),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Impact assessment
                _buildImpactAssessment(difference),

                const SizedBox(height: 16),

                // Time difference card
                _buildTimeDifferenceCard(difference),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSummary(CalculationMethod method, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method.displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSmallStat('Fajr', '18°'),
              const SizedBox(width: 12),
              _buildSmallStat('Isha', '17°'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImpactAssessment(MethodDifference difference) {
    Color impactColor;
    IconData impactIcon;
    String impactDescription;

    switch (difference.impact) {
      case 'Minimal':
        impactColor = Colors.green;
        impactIcon = Icons.check_circle_outline;
        impactDescription = 'Very small differences in prayer times (usually less than 5 minutes)';
        break;
      case 'Moderate':
        impactColor = Colors.orange;
        impactIcon = Icons.warning_amber_outlined;
        impactDescription = 'Noticeable differences in prayer times (5-15 minutes)';
        break;
      case 'Significant':
        impactColor = Colors.red;
        impactIcon = Icons.error_outline;
        impactDescription = 'Substantial differences in prayer times (15+ minutes)';
        break;
      default:
        impactColor = Colors.grey;
        impactIcon = Icons.help_outline;
        impactDescription = 'Impact assessment unavailable';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: impactColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: impactColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(impactIcon, color: impactColor, size: 20),
              const SizedBox(width: 8),
              Text(
                '${difference.impact} Impact',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: impactColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            impactDescription,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDifferenceCard(MethodDifference difference) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Time Difference',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${difference.estimatedTimeDifference} minutes average difference',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
