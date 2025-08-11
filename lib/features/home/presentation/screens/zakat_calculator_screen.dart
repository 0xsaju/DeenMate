import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  int _currentStep = 3;
  final int _totalSteps = 8;
  
  final _goldController = TextEditingController(text: '12.5');
  final _silverController = TextEditingController(text: '0');
  
  double _goldPrice = 6850.0; // ৳ per bhori
  double _silverPrice = 95.0; // ৳ per bhori
  
  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Zakat Calculator | যাকাত ক্যালকুলেটর',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              // TODO: Save calculation
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2E7D32),
              const Color(0xFF2E7D32).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Indicator
                _buildProgressIndicator(),
                
                const SizedBox(height: 16),
                
                // Current Section Header
                _buildSectionHeader(),
                
                const SizedBox(height: 16),
                
                // Live Metal Prices Card
                _buildMetalPricesCard(),
                
                const SizedBox(height: 16),
                
                // Gold Input Section
                _buildGoldInputSection(),
                
                const SizedBox(height: 16),
                
                // Silver Input Section
                _buildSilverInputSection(),
                
                const SizedBox(height: 16),
                
                // Nisab Information
                _buildNisabInformation(),
                
                const SizedBox(height: 20),
                
                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _currentStep / _totalSteps,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Step $_currentStep of $_totalSteps | ধাপ $_currentStep/$_totalSteps',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '🏆',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Precious Metals | মূল্যবান ধাতু',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  'Gold & Silver assets | স্বর্ণ ও রূপার সম্পদ',
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: const Color(0xFF666666),
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  'Enter your gold and silver holdings',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetalPricesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFA000)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live Metal Prices | লাইভ দাম',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Updated 2 minutes ago',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              // Gold price
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Gold/স্বর্ণ',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      Text(
                        '৳${_goldPrice.toStringAsFixed(0)}/bhori',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Silver price
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Silver/রূপা',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 2),
                      
                      Text(
                        '৳${_silverPrice.toStringAsFixed(0)}/bhori',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoldInputSection() {
    final goldWeight = double.tryParse(_goldController.text) ?? 0.0;
    final goldValue = goldWeight * _goldPrice;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gold Holdings | স্বর্ণের সম্পদ',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Weight in Bhori | ভরি এককে ওজন',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goldController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                
                Text(
                  'bhori | ভরি',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Estimated Value: ৳${goldValue.toStringAsFixed(0)}',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4CAF50),
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            'Zakatable amount (if held for 1 year)',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSilverInputSection() {
    final silverWeight = double.tryParse(_silverController.text) ?? 0.0;
    final silverValue = silverWeight * _silverPrice;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Silver Holdings | রূপার সম্পদ',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Weight in Bhori | ভরি এককে ওজন',
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: const Color(0xFF666666),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _silverController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      color: const Color(0xFF333333),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                
                Text(
                  'bhori | ভরি',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            silverValue > 0 
                ? 'Estimated Value: ৳${silverValue.toStringAsFixed(0)}'
                : 'Estimated Value: ৳0',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: silverValue > 0 ? const Color(0xFF4CAF50) : const Color(0xFF999999),
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            'Add silver jewelry, coins, or bullion',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabInformation() {
    final goldWeight = double.tryParse(_goldController.text) ?? 0.0;
    final silverWeight = double.tryParse(_silverController.text) ?? 0.0;
    final exceedsNisab = goldWeight >= 7.5 || silverWeight >= 52.5;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
              
              const SizedBox(width: 8),
              
              Text(
                'Nisab Information | নিসাব তথ্য',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Gold Nisab: 7.5 tola (৮৭.৪৮ গ্রাম)',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: const Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 2),
          
          Text(
            'Silver Nisab: 52.5 tola (৬১২.৩৬ গ্রাম)',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: const Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            exceedsNisab 
                ? '✓ Your gold exceeds nisab threshold'
                : '⚠ You need more assets to reach nisab',
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: exceedsNisab ? const Color(0xFF4CAF50) : const Color(0xFFFF8F00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Previous button
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Center(
              child: Text(
                '← Previous',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Next button
        Expanded(
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                'Next →',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
