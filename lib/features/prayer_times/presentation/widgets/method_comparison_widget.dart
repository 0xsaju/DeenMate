import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/services/calculation_method_service.dart';
import '../../domain/entities/calculation_method.dart';

/// Widget for comparing two calculation methods
class MethodComparisonWidget extends StatelessWidget {

  const MethodComparisonWidget({
    required this.method1, required this.method2, super.key,
    this.onClose,
  });
  final CalculationMethod method1;
  final CalculationMethod method2;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final difference = CalculationMethodService.instance.getMethodDifference(method1, method2);

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

                // Comparison details
                _buildComparisonSection('Technical Differences', [
                  _buildComparisonRow(
                    'Fajr Angle',
                    '${method1.fajrAngle}°',
                    '${method2.fajrAngle}°',
                    difference.fajrAngleDifference,
                  ),
                  _buildComparisonRow(
                    'Isha Angle',
                    method1.ishaInterval ?? '${method1.ishaAngle}°',
                    method2.ishaInterval ?? '${method2.ishaAngle}°',
                    difference.ishaAngleDifference,
                  ),
                  _buildComparisonRow(
                    'Madhab',
                    method1.madhab,
                    method2.madhab,
                    null,
                  ),
                ]),

                const SizedBox(height: 16),

                _buildComparisonSection('Regional Usage', [
                  _buildRegionalRow('Primary Region', method1.region, method2.region),
                  _buildRegionalRow('Organization', method1.organization, method2.organization),
                ]),

                const SizedBox(height: 16),

                // Impact assessment
                _buildImpactAssessment(difference),

                const SizedBox(height: 16),

                // Time difference estimation
                _buildTimeDifferenceCard(difference),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSummary(CalculationMethod method, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: accentColor.shade700,
            ),
          ),
          const SizedBox(height: 4),
          if (method.organization != null)
            Text(
              method.organization!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSmallStat('Fajr', '${method.fajrAngle}°'),
              const SizedBox(width: 12),
              _buildSmallStat(
                'Isha',
                method.ishaInterval ?? '${method.ishaAngle}°',
              ),
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

  Widget _buildComparisonSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildComparisonRow(
    String parameter,
    String value1,
    String value2,
    double? difference,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              parameter,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value1,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          Expanded(
            child: Text(
              value2,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.green),
            ),
          ),
          if (difference != null)
            Expanded(
              child: Text(
                difference == 0 ? 'Same' : '±${difference.toStringAsFixed(1)}°',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: difference == 0 ? Colors.grey : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionalRow(String parameter, String? value1, String? value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              parameter,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value1 ?? 'N/A',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.blue),
            ),
          ),
          Expanded(
            child: Text(
              value2 ?? 'N/A',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
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
        color: impactColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: impactColor.withOpacity(0.3)),
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
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.1),
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
                const SizedBox(height: 8),
                Text(
                  'This is an approximate difference. Actual differences may vary based on your location and date.',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
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
