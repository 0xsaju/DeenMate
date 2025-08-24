import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'simple_inheritance_calculator.dart';

/// Main inheritance calculator screen
class InheritanceCalculatorScreen extends StatefulWidget {
  const InheritanceCalculatorScreen({super.key});

  @override
  State<InheritanceCalculatorScreen> createState() =>
      _InheritanceCalculatorScreenState();
}

class _InheritanceCalculatorScreenState
    extends State<InheritanceCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Islamic Inheritance Calculator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => context.go('/shariah-clarification'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Islamic header
            _buildIslamicHeader(),
            const SizedBox(height: 24),

            // Quick start section
            _buildQuickStartSection(),
            const SizedBox(height: 24),

            // Features section
            _buildFeaturesSection(),
            const SizedBox(height: 24),

            // Disclaimer
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[700]!, Colors.green[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'فَرِيضَةً مِّنَ اللَّهِ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Amiri',
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Text(
            'An obligation from Allah',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'আল্লাহর পক্ষ থেকে নির্ধারিত বিধান',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontFamily: 'NotoSansBengali',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Quick Start',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuickStartStep(
              1,
              'Enter Estate Details',
              'Add total assets, debts, and expenses',
              Icons.account_balance,
            ),
            _buildQuickStartStep(
              2,
              'Select Heirs',
              'Choose family members from the list',
              Icons.family_restroom,
            ),
            _buildQuickStartStep(
              3,
              'Calculate Inheritance',
              'Get accurate Islamic distribution',
              Icons.calculate,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startCalculation(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Calculation'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartStep(
      int step, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$step',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.green[700], size: 24),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              '100% Shariah Compliant',
              'Based on Quran and authentic Hadith',
              Icons.verified,
            ),
            _buildFeatureItem(
              'Step-by-Step Calculation',
              'Detailed breakdown of inheritance distribution',
              Icons.list_alt,
            ),
            _buildFeatureItem(
              'Aul & Radd Support',
              'Handles complex inheritance scenarios',
              Icons.trending_up,
            ),
            _buildFeatureItem(
              'Quranic References',
              'Direct links to relevant verses',
              Icons.book,
            ),
            _buildFeatureItem(
              'Bengali Language',
              'Full support for Bengali users',
              Icons.language,
            ),
            _buildFeatureItem(
              'Offline Calculation',
              'Works without internet connection',
              Icons.offline_bolt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.green[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Important Notice',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This calculator provides Islamic inheritance calculations based on established Shariah principles. While designed for educational purposes, users should:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Consult qualified Islamic scholars for religious guidance\n'
              '• Seek legal professionals for court proceedings\n'
              '• Verify calculations independently\n'
              '• Understand that religious and legal requirements may differ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startCalculation(BuildContext context) {
    // Navigate to simplified inheritance calculator
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleInheritanceCalculator(),
      ),
    );
  }
}
