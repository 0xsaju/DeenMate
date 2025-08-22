import 'package:flutter/material.dart';
import '../../data/services/calculation_method_service.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/entities/location.dart';


/// Card widget displaying calculation method information
class CalculationMethodCard extends StatelessWidget {

  const CalculationMethodCard({
    required this.method, required this.location, required this.isSelected, required this.onSelected, super.key,
    this.onCompare,
    this.showCompareButton = false,
    this.isRecommended = false,
  });
  final CalculationMethod method;
  final Location location;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback? onCompare;
  final bool showCompareButton;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    final comparison = CalculationMethodService.instance.compareMethod(method, location);
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(
                color: Colors.green,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onSelected,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.green
                                : null,
                          ),
                        ),
                        if (method.organization != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            method.organization!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (isRecommended || comparison['isRecommended'] == true)
                        _buildBadge(
                          'RECOMMENDED',
                          Colors.green,
                          Colors.white,
                        ),
                      if (comparison['regionalMatch'] == true)
                        _buildBadge(
                          'REGIONAL',
                          Colors.green.shade100,
                          Colors.green.shade800,
                        ),
                      if (method.isCustom)
                        _buildBadge(
                          'CUSTOM',
                          Colors.orange.shade100,
                          Colors.orange.shade800,
                        ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                method.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 12),
              
              // Technical details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildAngleInfo('Fajr', '${method.fajrAngle}°'),
                        const SizedBox(width: 24),
                        _buildAngleInfo(
                          'Isha',
                          method.ishaInterval ?? '${method.ishaAngle}°',
                        ),
                      ],
                    ),
                    if (method.region != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDetailInfo('Region', method.region!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Suitability score
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Suitability: ${comparison['suitability']}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (comparison['suitability'] as int) / 100,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSuitabilityColor(comparison['suitability'] as int),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Action buttons
              if (showCompareButton || isSelected) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (isSelected)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Selected',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (showCompareButton && onCompare != null) ...[
                      if (isSelected) const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: onCompare,
                        icon: const Icon(Icons.compare_arrows, size: 16),
                        label: const Text('Compare'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAngleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getSuitabilityColor(int suitability) {
    if (suitability >= 80) return Colors.green;
    if (suitability >= 60) return Colors.orange;
    return Colors.red;
  }
}
