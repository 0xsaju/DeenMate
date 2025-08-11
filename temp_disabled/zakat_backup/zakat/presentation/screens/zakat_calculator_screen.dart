import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/zakat_calculation.dart' as zakat_entities;
import '../../domain/repositories/zakat_repository.dart' as zakat_repo;
import '../providers/zakat_calculator_notifier.dart';
import '../providers/zakat_providers.dart';
import '../widgets/calculation_progress_indicator.dart';
import '../widgets/metal_prices_widget.dart';
import '../widgets/zakat_form_sections.dart';
import '../widgets/zakat_result_card.dart';

/// Comprehensive Zakat Calculator Screen with Islamic design
/// Implements step-by-step Zakat calculation following Islamic principles
class ZakatCalculatorScreen extends ConsumerStatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  ConsumerState<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends ConsumerState<ZakatCalculatorScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  late ZakatFormData _formData;
  
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form sections
  static const int _totalSections = 9;
  int _currentSection = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _totalSections, vsync: this);
    _pageController = PageController();
    _formData = ZakatFormData(
      hawlStartDate: DateTime.now().subtract(const Duration(days: 354)),
      currency: 'USD',
    );
    
    // Fetch initial metal prices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(zakatCalculatorNotifierProvider.notifier)
          .fetchMetalPrices(_formData.currency);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final calculatorState = ref.watch(zakatCalculatorNotifierProvider);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Islamic header with Bismillah
          _buildIslamicHeader(),
          
          // Progress indicator
          _buildProgressIndicator(),
          
          // Metal prices widget
          const MetalPricesWidget(),
          
          // Main content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _buildPersonalInfoSection(),
                  _buildCashAssetsSection(),
                  _buildPreciousMetalsSection(),
                  _buildBusinessAssetsSection(),
                  _buildInvestmentAssetsSection(),
                  _buildRealEstateSection(),
                  _buildAgriculturalSection(),
                  _buildLiabilitiesSection(),
                  _buildSummarySection(),
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          _buildBottomNavigation(),
        ],
      ),
      
      // Calculation result overlay
      body: calculatorState.when(
        initial: _buildMainContent,
        loading: () => _buildMainContent(showLoading: true),
        calculated: (result) => _buildMainContent(result: result),
        saved: (calculation) => _buildMainContent(showSaved: true),
        generatingReport: () => _buildMainContent(showGeneratingReport: true),
        reportGenerated: (filePath) => _buildMainContent(reportPath: filePath),
        metalPricesFetched: (prices) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMetalPrices(prices);
          });
          return _buildMainContent();
        },
        validationPassed: _buildMainContent,
        validationFailed: (errors) => _buildMainContent(validationErrors: errors),
        error: (failure) => _buildMainContent(error: failure),
      ),
    );
  }

  Widget _buildMainContent({
    bool showLoading = false,
    zakat_entities.ZakatResult? result,
    bool showSaved = false,
    bool showGeneratingReport = false,
    String? reportPath,
    List<zakat_repo.ValidationError>? validationErrors,
    Failure? error,
  }) {
    return Stack(
      children: [
        // Main form content
        Column(
          children: [
            _buildIslamicHeader(),
            _buildProgressIndicator(),
            const MetalPricesWidget(),
            Expanded(child: _buildFormContent()),
            _buildBottomNavigation(),
          ],
        ),
        
        // Loading overlay
        if (showLoading || showGeneratingReport)
          _buildLoadingOverlay(showGeneratingReport),
        
        // Result overlay
        if (result != null)
          _buildResultOverlay(result),
        
        // Error overlay
        if (error != null)
          _buildErrorOverlay(error),
        
        // Validation errors
        if (validationErrors != null && validationErrors.isNotEmpty)
          _buildValidationErrorsOverlay(validationErrors),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Zakat Calculator'),
      titleTextStyle: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _refreshMetalPrices,
          tooltip: 'Refresh Metal Prices',
        ),
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: _showHelpDialog,
          tooltip: 'Help & Guidance',
        ),
      ],
    );
  }

  Widget _buildIslamicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
        ),
      ),
      child: Column(
        children: [
          Text(
            AppConstants.bismillah,
            style: AppTheme.arabicHeadline.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            'In the name of Allah, the Most Gracious, the Most Merciful',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing12),
          Text(
            '"Take from their wealth a charity to purify and sanctify them" (Quran 9:103)',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return CalculationProgressIndicator(
      currentStep: _currentSection,
      totalSteps: _totalSections,
      completionPercentage: _formData.completionPercentage,
    );
  }

  Widget _buildFormContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      children: [
        PersonalInfoSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        CashAssetsSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        PreciousMetalsSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        BusinessAssetsSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        InvestmentAssetsSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        RealEstateSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        AgriculturalSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        LiabilitiesSection(
          formData: _formData,
          onDataChanged: _updateFormData,
        ),
        SummarySection(
          formData: _formData,
          onCalculate: _calculateZakat,
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          if (_currentSection > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousSection,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
          
          if (_currentSection > 0) const SizedBox(width: AppTheme.spacing16),
          
          // Next/Calculate button
          Expanded(
            flex: _currentSection == 0 ? 1 : 1,
            child: ElevatedButton.icon(
              onPressed: _currentSection == _totalSections - 1 
                  ? _calculateZakat 
                  : _nextSection,
              icon: Icon(_currentSection == _totalSections - 1 
                  ? Icons.calculate 
                  : Icons.arrow_forward,),
              label: Text(_currentSection == _totalSections - 1 
                  ? 'Calculate Zakat' 
                  : 'Next',),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(bool isGeneratingReport) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                isGeneratingReport 
                    ? 'Generating PDF Report...' 
                    : 'Calculating Zakat...',
                style: AppTheme.lightTheme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                isGeneratingReport
                    ? 'Please wait while we prepare your Islamic report'
                    : 'Please wait while we calculate your Zakat obligation',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultOverlay(zakat_entities.ZakatResult result) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacing16),
          child: ZakatResultCard(
            result: result,
            currency: _formData.currency,
            onSave: () => _saveCalculation(result),
            onGenerateReport: () => _generateReport(result),
            onClose: () => ref.read(zakatCalculatorNotifierProvider.notifier).reset(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(Failure failure) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacing16),
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Calculation Error',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                failure.userMessage,
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref.read(zakatCalculatorNotifierProvider.notifier).reset(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _retryCalculation,
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationErrorsOverlay(List<zakat_repo.ValidationError> errors) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(AppTheme.spacing16),
          padding: const EdgeInsets.all(AppTheme.spacing24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber,
                size: 48,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Validation Errors',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              ...errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error, size: 16, color: Colors.red),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        '${error.field}: ${error.message}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),),
              const SizedBox(height: AppTheme.spacing24),
              ElevatedButton(
                onPressed: () => ref.read(zakatCalculatorNotifierProvider.notifier).reset(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _onPageChanged(int index) {
    setState(() {
      _currentSection = index;
    });
    _tabController.animateTo(index);
  }

  void _nextSection() {
    if (_currentSection < _totalSections - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateFormData(ZakatFormData newData) {
    setState(() {
      _formData = newData;
    });
  }

  void _updateMetalPrices(Map<String, double> prices) {
    setState(() {
      _formData = _formData.copyWith(
        currentGoldPrice: prices['gold'] ?? 0.0,
        currentSilverPrice: prices['silver'] ?? 0.0,
        metalPricesUpdated: DateTime.now(),
      );
    });
  }

  void _refreshMetalPrices() {
    ref.read(zakatCalculatorNotifierProvider.notifier)
        .fetchMetalPrices(_formData.currency);
  }

  void _calculateZakat() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(zakatCalculatorNotifierProvider.notifier).calculateZakat(
        formData: _formData,
        currency: _formData.currency,
        userId: 'current_user', // This should come from auth service
      );
    }
  }

  void _retryCalculation() {
    ref.read(zakatCalculatorNotifierProvider.notifier).reset();
    _calculateZakat();
  }

  void _saveCalculation(zakat_entities.ZakatResult result) {
    ref.read(zakatCalculatorNotifierProvider.notifier).saveCalculation(
      formData: _formData,
      result: result,
      currency: _formData.currency,
      userId: 'current_user',
    );
  }

  void _generateReport(zakat_entities.ZakatResult result) {
    // Create a temporary calculation for report generation
          final calculation = zakat_entities.ZakatCalculation(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      calculationDate: DateTime.now(),
      hawlStartDate: _formData.hawlStartDate,
      userId: 'current_user',
      currency: _formData.currency,
      personalInfo: _formData.toPersonalInfo(),
      assets: _formData.toZakatableAssets(),
      liabilities: _formData.toLiabilities(),
      nisabInfo: _formData.toNisabInfo(),
      result: result,
      notes: _formData.notes,
    );

    ref.read(zakatCalculatorNotifierProvider.notifier).generateReport(calculation);
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zakat Calculator Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This calculator helps you determine your Zakat obligation according to Islamic principles.\n\n'
                'Key Points:\n'
                '• Zakat is due on wealth held for one Islamic year (Hawl)\n'
                '• The rate is generally 2.5% of qualifying wealth\n'
                '• Wealth must exceed the Nisab threshold\n'
                '• Debts are generally deductible\n\n'
                'For complex situations, please consult with qualified Islamic scholars.',
              ),
              const SizedBox(height: 16),
              Text(
                'Current Nisab Thresholds:',
                style: AppTheme.lightTheme.textTheme.titleSmall,
              ),
              Text('Gold: ${(87.48 * _formData.currentGoldPrice).toStringAsFixed(2)} ${_formData.currency}'),
              Text('Silver: ${(612.36 * _formData.currentSilverPrice).toStringAsFixed(2)} ${_formData.currency}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}