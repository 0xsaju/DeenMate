import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/islamic_utils.dart';

/// Enhanced multi-asset Zakat calculator with currency support
class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen>
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
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),
              
              // Tab Bar
              _buildTabBar(),
              
              // Tab Content
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
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Zakat Calculator | যাকাত ক্যালকুলেটর',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _resetCalculator,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedLabelColor: Colors.white,
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
          _buildSectionHeader('Cash & Savings | নগদ ও সঞ্চয়'),
          
          _buildCurrencySelector(),
          
          const SizedBox(height: 20),
          
          _buildInputField(
            controller: _cashController,
            label: 'Cash in Hand | হাতে নগদ',
            hint: 'Enter amount',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _savingsController,
            label: 'Bank Savings | ব্যাংক সঞ্চয়',
            hint: 'Enter amount',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _investmentController,
            label: 'Investments | বিনিয়োগ',
            hint: 'Enter amount',
            onChanged: _calculateZakat,
          ),
          
          const SizedBox(height: 20),
          
          _buildNisabInfo(),
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
          _buildSectionHeader('Gold & Silver | সোনা ও রূপা'),
          
          const SizedBox(height: 20),
          
          _buildInputField(
            controller: _goldGramsController,
            label: 'Gold (grams) | সোনা (গ্রাম)',
            hint: 'Enter weight in grams',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _silverGramsController,
            label: 'Silver (grams) | রূপা (গ্রাম)',
            hint: 'Enter weight in grams',
            onChanged: _calculateZakat,
          ),
          
          const SizedBox(height: 20),
          
          _buildMetalPricesInfo(),
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
          _buildSectionHeader('Business Assets | ব্যবসায়িক সম্পদ'),
          
          const SizedBox(height: 20),
          
          _buildInputField(
            controller: _businessCashController,
            label: 'Business Cash | ব্যবসায়িক নগদ',
            hint: 'Enter amount',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _businessInventoryController,
            label: 'Inventory | মালামাল',
            hint: 'Enter value',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _businessDebtsController,
            label: 'Business Debts | ব্যবসায়িক ঋণ',
            hint: 'Enter amount (will be deducted)',
            onChanged: _calculateZakat,
          ),
          
          const SizedBox(height: 20),
          
          _buildSectionHeader('Personal Debts | ব্যক্তিগত ঋণ'),
          
          _buildInputField(
            controller: _personalDebtsController,
            label: 'Personal Loans | ব্যক্তিগত ঋণ',
            hint: 'Enter amount (will be deducted)',
            onChanged: _calculateZakat,
          ),
          
          _buildInputField(
            controller: _loansController,
            label: 'Other Debts | অন্যান্য ঋণ',
            hint: 'Enter amount (will be deducted)',
            onChanged: _calculateZakat,
          ),
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
          _buildSectionHeader('Zakat Calculation Results | যাকাত গণনার ফলাফল'),
          
          const SizedBox(height: 20),
          
          _buildResultCard(),
          
          const SizedBox(height: 20),
          
          _buildZakatInfo(),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Currency | মুদ্রা নির্বাচন করুন',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCurrency,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
            items: _exchangeRates.keys.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(currency),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCurrency = value!;
                _updatePricesForCurrency();
                _calculateZakat();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required VoidCallback onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            onChanged: (_) => onChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nisab Threshold | নিসাব সীমা',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
                      Text(
              'Gold: 87.48g (7.5 tola)',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Silver: 612.36g (52.5 tola)',
              style: const TextStyle(color: Colors.white),
            ),
          Text(
            'Current Nisab Value: ${_formatCurrency(_nisabThreshold)}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalPricesInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Metal Prices | বর্তমান ধাতুর দাম',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gold: ${_formatCurrency(_goldPricePerGram)} per gram',
            style: const TextStyle(color: Colors.white),
          ),
          Text(
            'Silver: ${_formatCurrency(_silverPricePerGram)} per gram',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isZakatDue ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isZakatDue ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            _isZakatDue ? Icons.check_circle : Icons.info,
            color: _isZakatDue ? Colors.green : Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _isZakatDue ? 'Zakat is Due | যাকাত দেয়া আবশ্যক' : 'No Zakat Due | যাকাত দেয়া আবশ্যক নয়',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isZakatDue ? Colors.green : Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildResultRow('Total Assets', _totalZakatableAmount),
          _buildResultRow('Nisab Threshold', _nisabThreshold),
          if (_isZakatDue) ...[
            _buildResultRow('Zakat Amount (2.5%)', _totalZakat, isHighlighted: true),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double amount, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isHighlighted ? Colors.green : Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              color: isHighlighted ? Colors.green : Colors.white,
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZakatInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Zakat | যাকাত সম্পর্কে',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Zakat is an annual charitable payment of 2.5% on wealth above the Nisab threshold.',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nisab is the minimum amount of wealth a Muslim must possess before being obliged to pay Zakat.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _calculateZakat() {
    // Get values from controllers
    final cash = _getDoubleValue(_cashController);
    final savings = _getDoubleValue(_savingsController);
    final investments = _getDoubleValue(_investmentController);
    
    final goldGrams = _getDoubleValue(_goldGramsController);
    final silverGrams = _getDoubleValue(_silverGramsController);
    
    final businessCash = _getDoubleValue(_businessCashController);
    final businessInventory = _getDoubleValue(_businessInventoryController);
    final businessDebts = _getDoubleValue(_businessDebtsController);
    
    final personalDebts = _getDoubleValue(_personalDebtsController);
    final loans = _getDoubleValue(_loansController);
    
    // Calculate total assets
    final totalAssets = cash + savings + investments + 
                       (goldGrams * _goldPricePerGram) + 
                       (silverGrams * _silverPricePerGram) +
                       businessCash + businessInventory;
    
    // Calculate total liabilities
    final totalLiabilities = businessDebts + personalDebts + loans;
    
    // Calculate net wealth
    final netWealth = totalAssets - totalLiabilities;
    
    // Calculate Nisab threshold
    final goldNisabValue = 87.48 * _goldPricePerGram;
    final silverNisabValue = 612.36 * _silverPricePerGram;
    _nisabThreshold = math.min(goldNisabValue, silverNisabValue);
    
    // Check if Zakat is due
    _isZakatDue = netWealth >= _nisabThreshold;
    
    // Calculate Zakat amount (2.5%)
    _totalZakatableAmount = netWealth;
    _totalZakat = _isZakatDue ? netWealth * 0.025 : 0;
    
    setState(() {});
  }

  double _getDoubleValue(TextEditingController controller) {
    final text = controller.text;
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  void _updatePricesForCurrency() {
    // Update metal prices based on currency
    switch (_selectedCurrency) {
      case 'USD':
        _goldPricePerGram = 60.0;
        _silverPricePerGram = 0.75;
        break;
      case 'BDT':
        _goldPricePerGram = 7020.0; // 60 * 117
        _silverPricePerGram = 87.75; // 0.75 * 117
        break;
      case 'SAR':
        _goldPricePerGram = 225.0; // 60 * 3.75
        _silverPricePerGram = 2.81; // 0.75 * 3.75
        break;
      case 'AED':
        _goldPricePerGram = 220.2; // 60 * 3.67
        _silverPricePerGram = 2.75; // 0.75 * 3.67
        break;
      case 'GBP':
        _goldPricePerGram = 49.2; // 60 * 0.82
        _silverPricePerGram = 0.615; // 0.75 * 0.82
        break;
      case 'EUR':
        _goldPricePerGram = 57.0; // 60 * 0.95
        _silverPricePerGram = 0.7125; // 0.75 * 0.95
        break;
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} $_selectedCurrency';
  }

  void _loadZakatData() {
    // Load saved data from SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      _cashController.text = prefs.getString('zakat_cash') ?? '';
      _savingsController.text = prefs.getString('zakat_savings') ?? '';
      _investmentController.text = prefs.getString('zakat_investment') ?? '';
      _goldGramsController.text = prefs.getString('zakat_gold') ?? '';
      _silverGramsController.text = prefs.getString('zakat_silver') ?? '';
      _businessCashController.text = prefs.getString('zakat_business_cash') ?? '';
      _businessInventoryController.text = prefs.getString('zakat_business_inventory') ?? '';
      _businessDebtsController.text = prefs.getString('zakat_business_debts') ?? '';
      _personalDebtsController.text = prefs.getString('zakat_personal_debts') ?? '';
      _loansController.text = prefs.getString('zakat_loans') ?? '';
      _selectedCurrency = prefs.getString('zakat_currency') ?? 'USD';
      
      _updatePricesForCurrency();
      _calculateZakat();
    });
  }

  void _saveZakatData() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('zakat_cash', _cashController.text);
      prefs.setString('zakat_savings', _savingsController.text);
      prefs.setString('zakat_investment', _investmentController.text);
      prefs.setString('zakat_gold', _goldGramsController.text);
      prefs.setString('zakat_silver', _silverGramsController.text);
      prefs.setString('zakat_business_cash', _businessCashController.text);
      prefs.setString('zakat_business_inventory', _businessInventoryController.text);
      prefs.setString('zakat_business_debts', _businessDebtsController.text);
      prefs.setString('zakat_personal_debts', _personalDebtsController.text);
      prefs.setString('zakat_loans', _loansController.text);
      prefs.setString('zakat_currency', _selectedCurrency);
    });
  }

  void _resetCalculator() {
    setState(() {
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
      
      _totalZakatableAmount = 0;
      _totalZakat = 0;
      _nisabThreshold = 0;
      _isZakatDue = false;
    });
    
    _saveZakatData();
  }
}
