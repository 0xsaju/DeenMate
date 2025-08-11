import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart'; // Added for context.go
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/islamic_theme.dart';

/// Enhanced multi-asset Zakat calculator
class EnhancedZakatCalculatorScreen extends StatefulWidget {
  const EnhancedZakatCalculatorScreen({super.key});

  @override
  State<EnhancedZakatCalculatorScreen> createState() => _EnhancedZakatCalculatorScreenState();
}

class _EnhancedZakatCalculatorScreenState extends State<EnhancedZakatCalculatorScreen>
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  
  // Cash & Savings
  final _cashController = TextEditingController();
  final _savingsController = TextEditingController();
  final _investmentController = TextEditingController();
  
  // Gold & Silver
  final _goldGramsController = TextEditingController();
  final _silverGramsController = TextEditingController();
  double _goldPricePerGram = 60; // USD - more realistic default
  double _silverPricePerGram = 0.75; // USD - more realistic default
  
  // Business Assets
  final _businessCashController = TextEditingController();
  final _businessInventoryController = TextEditingController();
  final _businessDebtsController = TextEditingController();
  
  // Debts & Liabilities
  final _personalDebtsController = TextEditingController();
  final _loansController = TextEditingController();
  
  // Results
  double _totalZakatableAmount = 0;
  double _totalZakat = 0;
  double _nisabThreshold = 0;
  bool _isZakatDue = false;
  
  // Currency
  String _selectedCurrency = 'USD';
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'BDT': 117.0,  // Updated to more recent exchange rate
    'SAR': 3.75,
    'AED': 3.67,
    'GBP': 0.82,   // Updated to more recent exchange rate
    'EUR': 0.95,  // Updated to more recent exchange rate
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadZakatData();
    _calculateZakat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashController.dispose();
    _savingsController.dispose();
    _investmentController.dispose();
    _goldGramsController.dispose();
    _silverGramsController.dispose();
    _businessCashController.dispose();
    _businessInventoryController.dispose();
    _businessDebtsController.dispose();
    _personalDebtsController.dispose();
    _loansController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              IslamicTheme.islamicGreen,
              IslamicTheme.islamicGreen.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildCurrencySelector(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCashTab(),
                    _buildGoldSilverTab(),
                    _buildBusinessTab(),
                    _buildResultsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            IslamicTheme.islamicGreen,
            IslamicTheme.islamicGreen.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Zakat Calculator | যাকাত ক্যালকুলেটর',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _saveCalculation,
            icon: const Icon(Icons.save, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Currency:',
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedCurrency,
            dropdownColor: IslamicTheme.islamicGreen,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            underline: Container(),
            items: _exchangeRates.keys.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
                _calculateZakat();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.6),
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: IslamicTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Cash'),
          Tab(text: 'Gold/Silver'),
          Tab(text: 'Business'),
          Tab(text: 'Results'),
        ],
      ),
    );
  }

  Widget _buildCashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('💰 Cash & Savings', 'নগদ অর্থ ও সঞ্চয়'),
          const SizedBox(height: 16),
          
          _buildInputCard(
            title: 'Cash in Hand',
            subtitle: 'নগদ টাকা',
            controller: _cashController,
            icon: '💵',
          ),
          
          _buildInputCard(
            title: 'Bank Savings',
            subtitle: 'ব্যাংক সঞ্চয়',
            controller: _savingsController,
            icon: '🏦',
          ),
          
          _buildInputCard(
            title: 'Investments',
            subtitle: 'বিনিয়োগ',
            controller: _investmentController,
            icon: '📈',
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('📉 Debts & Liabilities', 'ঋণ ও দায়'),
          const SizedBox(height: 16),
          
          _buildInputCard(
            title: 'Personal Debts',
            subtitle: 'ব্যক্তিগত ঋণ',
            controller: _personalDebtsController,
            icon: '💳',
          ),
          
          _buildInputCard(
            title: 'Loans',
            subtitle: 'লোন',
            controller: _loansController,
            icon: '🏠',
          ),
        ],
      ),
    );
  }

  Widget _buildGoldSilverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🥇 Gold & Silver', 'স্বর্ণ ও রৌপ্য'),
          const SizedBox(height: 16),
          
          _buildPriceUpdateCard(),
          const SizedBox(height: 16),
          
          _buildInputCard(
            title: 'Gold (grams)',
            subtitle: 'স্বর্ণ (গ্রাম)',
            controller: _goldGramsController,
            icon: '🥇',
            suffix: 'g',
          ),
          
          _buildValueDisplay(
            'Gold Value',
            _getGoldTotal(),
            '≈ ${_formatCurrency(_getGoldTotal())}',
          ),
          
          _buildInputCard(
            title: 'Silver (grams)',
            subtitle: 'রৌপ্য (গ্রাম)',
            controller: _silverGramsController,
            icon: '🥈',
            suffix: 'g',
          ),
          
          _buildValueDisplay(
            'Silver Value',
            _getSilverTotal(),
            '≈ ${_formatCurrency(_getSilverTotal())}',
          ),
          
          const SizedBox(height: 16),
          _buildNisabInfo(),
        ],
      ),
    );
  }

  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('🏢 Business Assets', 'ব্যবসায়িক সম্পদ'),
          const SizedBox(height: 16),
          
          _buildInputCard(
            title: 'Business Cash',
            subtitle: 'ব্যবসায়িক নগদ',
            controller: _businessCashController,
            icon: '💼',
          ),
          
          _buildInputCard(
            title: 'Inventory Value',
            subtitle: 'মালামালের মূল্য',
            controller: _businessInventoryController,
            icon: '📦',
          ),
          
          _buildInputCard(
            title: 'Business Debts',
            subtitle: 'ব্যবসায়িক ঋণ',
            controller: _businessDebtsController,
            icon: '📋',
          ),
          
          const SizedBox(height: 24),
          _buildBusinessNote(),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResultCard(),
          const SizedBox(height: 24),
          _buildBreakdownCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildIslamicReminder(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: IslamicTheme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String icon,
    String? suffix,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: IslamicTheme.textTheme.bodySmall?.copyWith(
                        color: IslamicTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              prefixText: _getCurrencySymbol(),
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: IslamicTheme.islamicGreen),
              ),
            ),
            onChanged: (_) {
              _calculateZakat();
              _saveZakatData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceUpdateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: IslamicTheme.islamicGreen),
              const SizedBox(width: 8),
              Text(
                'Current Prices (USD)',
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceField('Gold/gram', _goldPricePerGram, (value) {
                  _goldPricePerGram = value;
                  _saveZakatData();
                  _calculateZakat();
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceField('Silver/gram', _silverPricePerGram, (value) {
                  _silverPricePerGram = value;
                  _saveZakatData();
                  _calculateZakat();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(String label, double value, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: IslamicTheme.textTheme.bodySmall?.copyWith(
            color: IslamicTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixText: r'$',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) {
            final newValue = double.tryParse(val) ?? value;
            onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildValueDisplay(String title, double value, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IslamicTheme.islamicGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IslamicTheme.islamicGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              color: IslamicTheme.islamicGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabInfo() {
    const goldNisab = 85.0; // grams
    const silverNisab = 595.0; // grams
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Nisab Thresholds (Standard Values)',
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Gold: ${goldNisab}g (≈${_formatCurrency(goldNisab * _goldPricePerGram)})',
            style: IslamicTheme.textTheme.bodySmall,
          ),
          Text(
            '• Silver: ${silverNisab}g (≈${_formatCurrency(silverNisab * _silverPricePerGram)})',
            style: IslamicTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Business Zakat Note',
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Business zakat is calculated on liquid assets and inventory intended for sale, minus business debts. Fixed assets like machinery are not included.',
            style: IslamicTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isZakatDue ? Icons.check_circle : Icons.info,
            size: 48,
            color: _isZakatDue ? IslamicTheme.islamicGreen : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            _isZakatDue ? 'Zakat is Due' : 'Below Nisab Threshold',
            style: IslamicTheme.textTheme.headlineSmall?.copyWith(
              color: _isZakatDue ? IslamicTheme.islamicGreen : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isZakatDue 
                ? 'যাকাত প্রদান করুন | أدِ الزكاة'
                : 'নিসাবের নিচে | أقل من النصاب',
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              color: IslamicTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isZakatDue) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: IslamicTheme.islamicGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Zakat Amount',
                    style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                      color: IslamicTheme.islamicGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatCurrency(_totalZakat),
                    style: IslamicTheme.textTheme.headlineLarge?.copyWith(
                      color: IslamicTheme.islamicGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calculation Breakdown',
            style: IslamicTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildBreakdownItem('Cash & Savings', _getCashTotal()),
          _buildBreakdownItem('Gold & Silver', _getGoldSilverTotal()),
          _buildBreakdownItem('Business Assets (Net)', _getBusinessTotal()),
          _buildBreakdownItem('Less: Personal Debts', -_getDebtsTotal(), isNegative: true),
          
          const Divider(height: 24),
          
          _buildBreakdownItem('Total Zakatable', _totalZakatableAmount, isBold: true),
          _buildBreakdownItem('Nisab Threshold', _nisabThreshold),
          
          const Divider(height: 24),
          
          _buildBreakdownItem('Zakat Rate', null, rightText: '2.5%'),
          _buildBreakdownItem('Zakat Amount', _totalZakat, isBold: true, isResult: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(
    String label, 
    double? amount, {
    bool isBold = false,
    bool isNegative = false,
    bool isResult = false,
    String? rightText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isResult ? IslamicTheme.islamicGreen : null,
            ),
          ),
          Text(
            rightText ?? (amount != null ? _formatCurrency(amount) : ''),
            style: IslamicTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isNegative 
                  ? Colors.red 
                  : isResult 
                      ? IslamicTheme.islamicGreen 
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (!_isZakatDue) return const SizedBox();
    
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _shareZakatCalculation,
          icon: const Icon(Icons.share),
          label: const Text('Share Calculation'),
          style: ElevatedButton.styleFrom(
            backgroundColor: IslamicTheme.islamicGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _saveCalculation,
          icon: const Icon(Icons.save),
          label: const Text('Save for Later'),
          style: OutlinedButton.styleFrom(
            foregroundColor: IslamicTheme.islamicGreen,
            side: const BorderSide(color: IslamicTheme.islamicGreen),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicReminder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IslamicTheme.quranPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IslamicTheme.quranPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mosque, color: IslamicTheme.quranPurple),
              const SizedBox(width: 8),
              Text(
                'Islamic Reminder',
                style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: IslamicTheme.quranPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"And establish prayer and give zakat, and whatever good you put forward for yourselves - you will find it with Allah." (Quran 2:110)',
            style: IslamicTheme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Zakat purifies wealth and brings Allah's blessings. Pay it with a sincere heart.",
            style: IslamicTheme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Calculation methods
  void _calculateZakat() {
    // Calculate totals
    final cashTotal = _getCashTotal();
    final businessTotal = _getBusinessTotal();
    final debtsTotal = _getDebtsTotal();
    final goldTotal = _getGoldTotal();
    final silverTotal = _getSilverTotal();
    
    // Total zakatable amount
    _totalZakatableAmount = cashTotal + businessTotal + _getGoldSilverTotal() - debtsTotal;
    
    // Nisab threshold (85 grams of gold or 595 grams of silver) - use the lower value
    final goldNisab = 85.0 * _goldPricePerGram;  // 85g is the standard gold nisab
    final silverNisab = 595.0 * _silverPricePerGram;  // 595g is the standard silver nisab
    _nisabThreshold = math.min(goldNisab, silverNisab); // Use the lower of gold or silver nisab
    
    // Check if zakat is due
    _isZakatDue = _totalZakatableAmount >= _nisabThreshold;
    
    // Calculate zakat (2.5% of zakatable amount)
    _totalZakat = _isZakatDue ? _totalZakatableAmount * 0.025 : 0.0;
    
    setState(() {});
  }

  double _getCashTotal() {
    final cash = double.tryParse(_cashController.text) ?? 0.0;
    final savings = double.tryParse(_savingsController.text) ?? 0.0;
    final investment = double.tryParse(_investmentController.text) ?? 0.0;
    
    return cash + savings + investment;
  }

  double _getGoldSilverTotal() {
    // Return the total value of gold and silver in USD
    return _getGoldTotal() + _getSilverTotal();
  }

  double _calculateGoldValue() {
    final grams = double.tryParse(_goldGramsController.text) ?? 0.0;
    // Gold price is in USD, return value in USD
    return grams * _goldPricePerGram;
  }

  double _calculateSilverValue() {
    final grams = double.tryParse(_silverGramsController.text) ?? 0.0;
    // Silver price is in USD, return value in USD
    return grams * _silverPricePerGram;
  }

  double _getBusinessTotal() {
    final cash = double.tryParse(_businessCashController.text) ?? 0.0;
    final inventory = double.tryParse(_businessInventoryController.text) ?? 0.0;
    final debts = double.tryParse(_businessDebtsController.text) ?? 0.0;
    
    // Business debts are subtracted from business assets
    return cash + inventory - debts;
  }

  double _getDebtsTotal() {
    final personalDebts = double.tryParse(_personalDebtsController.text) ?? 0.0;
    final loans = double.tryParse(_loansController.text) ?? 0.0;
    
    return personalDebts + loans;
  }

  double _getGoldTotal() {
    final grams = double.tryParse(_goldGramsController.text) ?? 0.0;
    return grams * _goldPricePerGram;
  }

  double _getSilverTotal() {
    final grams = double.tryParse(_silverGramsController.text) ?? 0.0;
    return grams * _silverPricePerGram;
  }

  String _getCurrencySymbol() {
    switch (_selectedCurrency) {
      case 'USD': return r'$';
      case 'BDT': return '৳';
      case 'SAR': return 'ر.س';
      case 'AED': return 'د.إ';
      case 'GBP': return '£';
      case 'EUR': return '€';
      default: return r'$';
    }
  }

  String _formatCurrency(double amount) {
    // Convert amount to selected currency for display
    var convertedAmount = amount;
    if (_selectedCurrency != 'USD') {
      convertedAmount = amount * _exchangeRates[_selectedCurrency]!;
    }
    
    final formatter = NumberFormat.currency(
      symbol: _getCurrencySymbol(),
      decimalDigits: 2,
    );
    return formatter.format(convertedAmount);
  }

  // Data persistence
  Future<void> _saveZakatData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('zakat_cash', double.tryParse(_cashController.text) ?? 0.0);
      await prefs.setDouble('zakat_savings', double.tryParse(_savingsController.text) ?? 0.0);
      await prefs.setDouble('zakat_investment', double.tryParse(_investmentController.text) ?? 0.0);
      await prefs.setDouble('zakat_gold_grams', double.tryParse(_goldGramsController.text) ?? 0.0);
      await prefs.setDouble('zakat_silver_grams', double.tryParse(_silverGramsController.text) ?? 0.0);
      await prefs.setDouble('zakat_business_cash', double.tryParse(_businessCashController.text) ?? 0.0);
      await prefs.setDouble('zakat_business_inventory', double.tryParse(_businessInventoryController.text) ?? 0.0);
      await prefs.setDouble('zakat_business_debts', double.tryParse(_businessDebtsController.text) ?? 0.0);
      await prefs.setDouble('zakat_personal_debts', double.tryParse(_personalDebtsController.text) ?? 0.0);
      await prefs.setDouble('zakat_loans', double.tryParse(_loansController.text) ?? 0.0);
      
      
      // Save calculation results
      await prefs.setDouble('zakat_total_amount', _totalZakatableAmount);
      await prefs.setDouble('zakat_total_zakat', _totalZakat);
      await prefs.setDouble('zakat_nisab_threshold', _nisabThreshold);
      await prefs.setBool('zakat_is_due', _isZakatDue);
      
      // Save gold and silver prices
      await prefs.setDouble('zakat_gold_price', _goldPricePerGram);
      await prefs.setDouble('zakat_silver_price', _silverPricePerGram);
      // Save timestamp
      await prefs.setString('zakat_last_calculation', DateTime.now().toIso8601String());

      print('Zakat data saved successfully');
    } catch (e) {
      print('Error saving zakat data: $e');
    }
  }

  Future<void> _loadZakatData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load with proper type conversion and error handling
      _cashController.text = _safeGetDouble(prefs, 'zakat_cash').toString();
      _savingsController.text = _safeGetDouble(prefs, 'zakat_savings').toString();
      _investmentController.text = _safeGetDouble(prefs, 'zakat_investment').toString();
      _goldGramsController.text = _safeGetDouble(prefs, 'zakat_gold_grams').toString();
      _silverGramsController.text = _safeGetDouble(prefs, 'zakat_silver_grams').toString();
      _businessCashController.text = _safeGetDouble(prefs, 'zakat_business_cash').toString();
      _businessInventoryController.text = _safeGetDouble(prefs, 'zakat_business_inventory').toString();
      _businessDebtsController.text = _safeGetDouble(prefs, 'zakat_business_debts').toString();
      _personalDebtsController.text = _safeGetDouble(prefs, 'zakat_personal_debts').toString();
      _loansController.text = _safeGetDouble(prefs, 'zakat_loans').toString();
      
      // Load selected currency
      final savedCurrency = prefs.getString('zakat_selected_currency');
      if (savedCurrency != null && _exchangeRates.containsKey(savedCurrency)) {
        setState(() {
          _selectedCurrency = savedCurrency;
        });
      }
      
      _goldPricePerGram = prefs.getDouble('zakat_gold_price') ?? 65.0;
      _silverPricePerGram = prefs.getDouble('zakat_silver_price') ?? 0.85;

      // Load calculation results
      _totalZakatableAmount = prefs.getDouble('zakat_total_amount') ?? 0.0;
      _totalZakat = prefs.getDouble('zakat_total_zakat') ?? 0.0;
      _nisabThreshold = prefs.getDouble('zakat_nisab_threshold') ?? 0.0;
      _isZakatDue = prefs.getBool('zakat_is_due') ?? false;

      print('Zakat data loaded successfully');
      _calculateZakat(); // Recalculate after loading
    } catch (e) {
      print('Error loading zakat data: $e');
      // Continue with default values if loading fails
    }
  }

  double _safeGetDouble(SharedPreferences prefs, String key) {
    try {
      // Try to get as double first
      final doubleValue = prefs.getDouble(key);
      if (doubleValue != null) return doubleValue;
      
      // If not found as double, try as string and convert
      final stringValue = prefs.getString(key);
      if (stringValue != null && stringValue.isNotEmpty) {
        return double.tryParse(stringValue) ?? 0.0;
      }
      
      return 0;
    } catch (e) {
      print('Error loading $key: $e');
      return 0;
    }
  }

  void _resetAll() {
    _cashController.clear();
    _savingsController.clear();
    _investmentController.clear();
    _goldGramsController.clear();
    _silverGramsController.clear();
    _businessCashController.clear();
    _businessInventoryController.clear();
    _businessDebtsController.clear();
    _personalDebtsController.clear();
    _loansController.clear();
    _calculateZakat();
    _saveZakatData();
  }

  void _shareZakatCalculation() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing feature coming soon!'),
        backgroundColor: IslamicTheme.islamicGreen,
      ),
    );
  }

  void _saveCalculation() {
    _saveZakatData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calculation saved successfully!'),
        backgroundColor: IslamicTheme.islamicGreen,
      ),
    );
  }
}
