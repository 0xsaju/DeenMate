import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/zakat_calculation.dart';

/// Comprehensive Zakat Result Display Card
/// Shows calculation results with Islamic formatting and guidance
class ZakatResultCard extends StatelessWidget {

  const ZakatResultCard({
    required this.result, required this.currency, super.key,
    this.onSave,
    this.onGenerateReport,
    this.onClose,
  });
  final ZakatResult result;
  final String currency;
  final VoidCallback? onSave;
  final VoidCallback? onGenerateReport;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildMainResult(),
          _buildDetailedBreakdown(),
          _buildIslamicGuidance(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: result.isZakatRequired
              ? [const Color(0xFF2E7D32), const Color(0xFF4CAF50)]
              : [const Color(0xFF757575), const Color(0xFF9E9E9E)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.largeRadius),
          topRight: Radius.circular(AppTheme.largeRadius),
        ),
      ),
      child: Column(
        children: [
          Icon(
            result.isZakatRequired ? Icons.check_circle : Icons.info,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            result.isZakatRequired ? 'Zakat is Due' : 'No Zakat Due',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          if (result.isZakatRequired)
            Text(
              'الحمد لله - May Allah accept your Zakat',
              style: AppTheme.arabicBody.copyWith(
                color: Colors.white70,
                fontSize: 16,
              ),
              textDirection: TextDirection.rtl,
            )
          else
            Text(
              'Your wealth is below the Nisab threshold',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainResult() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        children: [
          // Zakat amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: result.isZakatRequired 
                  ? const Color(0xFF2E7D32).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(
                color: result.isZakatRequired 
                    ? const Color(0xFF2E7D32)
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Zakat Amount',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  '${NumberFormat('#,##0.00').format(result.zakatDue)} $currency',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: result.isZakatRequired 
                        ? const Color(0xFF2E7D32)
                        : Colors.grey[600],
                  ),
                ),
                if (result.isZakatRequired) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    '${(result.zakatRate * 100).toStringAsFixed(1)}% of zakatable wealth',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Key metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Total Wealth',
                  result.zakatableWealth,
                  currency,
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: _buildMetricCard(
                  'Nisab Threshold',
                  result.nisabThreshold,
                  currency,
                  Icons.trending_up,
                ),
              ),
            ],
          ),
          
          if (result.isZakatRequired) ...[
            const SizedBox(height: AppTheme.spacing12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Excess over Nisab',
                    result.excessOverNisab,
                    currency,
                    Icons.add_circle_outline,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: _buildMetricCard(
                    'Net Worth',
                    result.netWorth,
                    currency,
                    Icons.assessment,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    if (result.categoryBreakdown == null || result.categoryBreakdown!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wealth Breakdown',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
            ),
            child: Column(
              children: result.categoryBreakdown!.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing12,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${NumberFormat('#,##0.00').format(entry.value)} $currency',
                        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
        ],
      ),
    );
  }

  Widget _buildIslamicGuidance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.isZakatRequired) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Distribution Guidance',
                        style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  const Text(
                    'Distribute your Zakat among the eight categories mentioned in the Quran (9:60):',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  _buildDistributionCategories(),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
          ],
          
          // Islamic reminders
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange[700]),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Important Reminders',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                if (result.notes != null) ...[
                  ...result.notes!.take(3).map((note) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(note, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCategories() {
    final categories = [
      'The Poor (Al-Fuqara)',
      'The Needy (Al-Masakin)',
      'Zakat Administrators',
      'New Muslims',
      'Freeing Captives',
      'Those in Debt',
      "In Allah's Cause",
      'Travelers in Need',
    ];

    return Column(
      children: categories.take(4).map((category) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            const Text('• ', style: TextStyle(fontSize: 11)),
            Expanded(
              child: Text(category, style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        children: [
          if (result.isZakatRequired) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Calculation'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onGenerateReport,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate Report'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
          ],
          
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double value, String currency, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: AppTheme.spacing4),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            NumberFormat('#,##0.00').format(value),
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currency,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}