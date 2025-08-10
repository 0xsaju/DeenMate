import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/services/calculation_method_service.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/entities/prayer_times.dart';
import '../providers/prayer_times_providers.dart';
import '../widgets/calculation_method_card.dart';
import '../widgets/method_comparison_widget.dart';

/// Calculation Method Selection Screen
/// Allows users to choose and compare different prayer time calculation methods
class CalculationMethodScreen extends ConsumerStatefulWidget {
  const CalculationMethodScreen({super.key});

  @override
  ConsumerState<CalculationMethodScreen> createState() => _CalculationMethodScreenState();
}

class _CalculationMethodScreenState extends ConsumerState<CalculationMethodScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedMethodId = 'MWL';
  bool _showComparison = false;
  String? _comparisonMethodId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentMethod();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentMethod() async {
    final settingsAsync = ref.read(prayerSettingsProvider);
    settingsAsync.whenData((settings) {
      setState(() {
        _selectedMethodId = settings.calculationMethod;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(currentLocationProvider);
    final settingsAsync = ref.watch(prayerSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Calculation Methods'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_showComparison && _comparisonMethodId != null)
            IconButton(
              onPressed: _hideComparison,
              icon: const Icon(Icons.close),
              tooltip: 'Hide Comparison',
            ),
          IconButton(
            onPressed: _showInfoDialog,
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Calculation Methods',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Recommended', icon: Icon(Icons.star_outline)),
            Tab(text: 'All Methods', icon: Icon(Icons.list)),
            Tab(text: 'Custom', icon: Icon(Icons.tune)),
          ],
        ),
      ),
      body: locationAsync.when(
        data: (location) => TabBarView(
          controller: _tabController,
          children: [
            _buildRecommendedTab(location),
            _buildAllMethodsTab(location),
            _buildCustomTab(location),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load location',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Location is needed to show recommended methods',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentLocationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _showComparison && _comparisonMethodId != null
          ? null
          : FloatingActionButton.extended(
              onPressed: _applySelectedMethod,
              icon: const Icon(Icons.check),
              label: const Text('Apply Method'),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            ),
    );
  }

  Widget _buildRecommendedTab(Location location) {
    final recommendedMethods = CalculationMethodService.instance.getRecommendedMethods(location);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Location',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${location.city}, ${location.country}'),
                  Text('${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Recommended Methods',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These methods are specifically recommended for your location based on regional preferences and accuracy.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ...recommendedMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CalculationMethodCard(
              method: method,
              location: location,
              isSelected: method.id == _selectedMethodId,
              onSelected: () => _selectMethod(method.id),
              onCompare: () => _showComparison
                  ? _hideComparison()
                  : _startComparison(method.id),
              showCompareButton: true,
              isRecommended: true,
            ),
          ),),
        ],
      ),
    );
  }

  Widget _buildAllMethodsTab(Location location) {
    const allMethods = CalculationMethods.allMethods;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Available Methods',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from all ${allMethods.length} available calculation methods used worldwide.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ...allMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CalculationMethodCard(
              method: method,
              location: location,
              isSelected: method.id == _selectedMethodId,
              onSelected: () => _selectMethod(method.id),
              onCompare: () => _showComparison
                  ? _hideComparison()
                  : _startComparison(method.id),
              showCompareButton: true,
            ),
          ),),
        ],
      ),
    );
  }

  Widget _buildCustomTab(Location location) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your own calculation method with custom angles.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.construction,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Custom Method Creator',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This feature will allow you to create custom calculation methods with your preferred Fajr and Isha angles.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showCustomMethodDialog,
                    child: const Text('Create Custom Method'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectMethod(String methodId) {
    setState(() {
      _selectedMethodId = methodId;
    });
  }

  void _startComparison(String methodId) {
    setState(() {
      _showComparison = true;
      _comparisonMethodId = methodId;
    });
  }

  void _hideComparison() {
    setState(() {
      _showComparison = false;
      _comparisonMethodId = null;
    });
  }

  Future<void> _applySelectedMethod() async {
    try {
      final method = CalculationMethods.getMethodById(_selectedMethodId);
      if (method == null) return;

      // Update prayer settings
      final currentSettings = await ref.read(prayerSettingsProvider.future);
      final updatedSettings = currentSettings.copyWith(
        calculationMethod: method.id,
        madhab: method.madhab,
      );

      // Save settings (implement this in your repository)
      // await ref.read(prayerTimesRepositoryProvider).savePrayerSettings(updatedSettings);

      // Invalidate prayer times to trigger recalculation
      ref.invalidate(currentPrayerTimesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied "${method.name}" calculation method'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => context.pop(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply method: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Calculation Methods'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Prayer time calculation methods use different angles for Fajr and Isha prayers, resulting in slight variations in prayer times.',
              ),
              SizedBox(height: 16),
              Text(
                'Key Differences:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Fajr Angle: Determines morning prayer time'),
              Text('• Isha Angle: Determines night prayer time'),
              Text('• Regional Preferences: Based on local scholarly consensus'),
              Text('• Madhab Differences: Mainly affect Asr calculation'),
              SizedBox(height: 16),
              Text(
                'We recommend using the method preferred in your region for consistency with your local Muslim community.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showCustomMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Method'),
        content: const Text(
          'Custom method creation will be available in a future update. '
          'For now, please choose from the available methods which cover '
          'most regional preferences worldwide.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
