import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Progress indicator for Zakat calculation process
/// Shows current step and overall completion progress
class CalculationProgressIndicator extends StatelessWidget {

  const CalculationProgressIndicator({
    required this.currentStep, required this.totalSteps, required this.completionPercentage, super.key,
  });
  final int currentStep;
  final int totalSteps;
  final double completionPercentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              Text(
                _getStepName(currentStep),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Progress bar
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 8,
                width: MediaQuery.of(context).size.width * 
                       ((currentStep + 1) / totalSteps) * 0.9, // Adjust for padding
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacing8),
          
          // Completion percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Form Completion: ${(completionPercentage * 100).toStringAsFixed(0)}%',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${((currentStep + 1) / totalSteps * 100).toStringAsFixed(0)}% Complete',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, _buildStepDot),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDot(int index) {
    final isCompleted = index < currentStep;
    final isCurrent = index == currentStep;
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted 
            ? AppTheme.lightTheme.colorScheme.primary
            : isCurrent
                ? AppTheme.lightTheme.colorScheme.primary.withOpacity(0.7)
                : Colors.grey[300],
        border: isCurrent
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
            : Text(
                '${index + 1}',
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  String _getStepName(int step) {
    const stepNames = [
      'Personal Info',
      'Cash Assets',
      'Precious Metals',
      'Business Assets',
      'Investments',
      'Real Estate',
      'Agricultural',
      'Liabilities',
      'Summary',
    ];
    
    return step < stepNames.length ? stepNames[step] : 'Step ${step + 1}';
  }
}