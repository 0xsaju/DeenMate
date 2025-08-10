import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget to display current gold and silver prices with refresh capability
/// Shows live metal prices with Islamic context and Nisab calculations
class MetalPricesWidget extends ConsumerWidget {
  const MetalPricesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metalPricesAsync = ref.watch(metalPricesNotifierProvider('USD'));
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[50]!,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: Colors.amber[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: metalPricesAsync.when(
        data: (prices) => _buildPricesContent(context, ref, prices),
        loading: _buildLoadingContent,
        error: (error, stack) => _buildErrorContent(context, ref, error),
      ),
    );
  }

  Widget _buildPricesContent(BuildContext context, WidgetRef ref, Map<String, double> prices) {
    final goldPrice = prices['gold'] ?? 0.0;
    final silverPrice = prices['silver'] ?? 0.0;
    
    // Calculate Nisab values
    final goldNisab = 87.48 * goldPrice; // 7.5 tola
    final silverNisab = 612.36 * silverPrice; // 52.5 tola
    final applicableNisab = goldNisab < silverNisab ? goldNisab : silverNisab;
    
    return Column(
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(AppTheme.smallRadius),
              ),
              child: Icon(
                Icons.diamond,
                color: Colors.amber[700],
                size: 20,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Metal Prices',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  Text(
                    'Updated ${_getTimeAgo(DateTime.now())}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _refreshPrices(ref),
              icon: Icon(Icons.refresh, color: Colors.amber[700]),
              tooltip: 'Refresh Prices',
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacing16),
        
        // Prices grid
        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                'Gold',
                goldPrice,
                'USD/gram',
                Icons.circle,
                Colors.amber[700]!,
                goldNisab,
              ),
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: _buildPriceCard(
                'Silver',
                silverPrice,
                'USD/gram',
                Icons.circle,
                Colors.grey[600]!,
                silverNisab,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacing16),
        
        // Nisab information
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            border: Border.all(color: Colors.green[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green[700], size: 16),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Nisab Threshold',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Applicable Nisab:',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Text(
                    '${NumberFormat('#,##0.00').format(applicableNisab)} USD',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Based on:',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Text(
                    goldNisab < silverNisab ? 'Gold Standard' : 'Silver Standard',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: goldNisab < silverNisab ? Colors.amber[700] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppTheme.spacing12),
        
        // Islamic context
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Islamic Wisdom',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                '"There is no Zakat on gold less than twenty dinars, and there is no Zakat on silver less than five ounces." - Prophet Muhammad (ﷺ)',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard(
    String metal,
    double price,
    String unit,
    IconData icon,
    Color color,
    double nisabValue,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                metal,
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'per gram',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'Nisab: \$${NumberFormat('#,##0.00').format(nisabValue)}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Text(
          'Fetching current metal prices...',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(BuildContext context, WidgetRef ref, Object error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600], size: 20),
            const SizedBox(width: AppTheme.spacing8),
            Expanded(
              child: Text(
                'Unable to fetch metal prices',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () => _refreshPrices(ref),
              child: const Text('Retry'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(AppTheme.smallRadius),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offline Mode',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              const Text(
                'You can still calculate Zakat by entering metal prices manually in the precious metals section.',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _refreshPrices(WidgetRef ref) {
    ref.invalidate(metalPricesNotifierProvider('USD'));
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}