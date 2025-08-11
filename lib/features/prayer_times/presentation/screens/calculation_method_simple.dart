import 'package:flutter/material.dart';

import '../../data/services/calculation_method_service.dart';
import '../../domain/entities/calculation_method.dart';

/// Simplified calculation method screen for testing
class CalculationMethodSimpleScreen extends StatefulWidget {
  const CalculationMethodSimpleScreen({super.key});

  @override
  State<CalculationMethodSimpleScreen> createState() => _CalculationMethodSimpleScreenState();
}

class _CalculationMethodSimpleScreenState extends State<CalculationMethodSimpleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  CalculationMethod? _selectedMethod1;
  CalculationMethod? _selectedMethod2;
  String _selectedMethod = 'MWL';
  
  final _service = CalculationMethodService.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allMethods = _service.getAllMethods();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Calculation Methods'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Recommended'),
            Tab(icon: Icon(Icons.list), text: 'All Methods'),
            Tab(icon: Icon(Icons.compare), text: 'Compare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendedMethodsTab(allMethods),
          _buildAllMethodsTab(allMethods),
          _buildCompareMethodsTab(allMethods),
        ],
      ),
    );
  }

  Widget _buildRecommendedMethodsTab(List<CalculationMethod> allMethods) {
    // Simulate location-based recommendations
    final recommendedMethods = allMethods.take(5).toList();
    
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Location-Based Recommendations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These methods are recommended for your region. Location detection would normally determine this automatically.',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendedMethods.length,
            itemBuilder: (context, index) {
              final method = recommendedMethods[index];
              return _buildMethodCard(method, true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllMethodsTab(List<CalculationMethod> allMethods) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'All Available Methods',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${allMethods.length} calculation methods from Islamic organizations worldwide.',
                style: TextStyle(color: Colors.green[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: allMethods.length,
            itemBuilder: (context, index) {
              final method = allMethods[index];
              return _buildMethodCard(method, false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompareMethodsTab(List<CalculationMethod> allMethods) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.compare_arrows, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Method Comparison',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Select two methods to compare their angles and characteristics.',
                  style: TextStyle(color: Colors.orange[600]),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildMethodDropdown(
            label: 'Method 1',
            selectedValue: _selectedMethod1,
            methods: allMethods,
            onChanged: (method) {
              setState(() {
                _selectedMethod1 = method;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          _buildMethodDropdown(
            label: 'Method 2',
            selectedValue: _selectedMethod2,
            methods: allMethods,
            onChanged: (method) {
              setState(() {
                _selectedMethod2 = method;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          if (_selectedMethod1 != null && _selectedMethod2 != null)
            _buildComparisonResult(_selectedMethod1!, _selectedMethod2!),
        ],
      ),
    );
  }

  Widget _buildMethodCard(CalculationMethod method, bool showRecommendedBadge) {
                  final isSelected = method.name == _selectedMethod;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
                            _selectedMethod = method.name;
          });
          _showMethodSelected(method);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      method.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ),
                  if (showRecommendedBadge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Recommended',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Text(
                method.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _buildAngleChip('Fajr', method.fajrAngle),
                  const SizedBox(width: 8),
                  _buildAngleChip('Isha', method.ishaAngle),
                  const SizedBox(width: 8),
                  if (method.region != null) _buildRegionChip(method.region!),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(Icons.account_balance, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      method.organization ?? 'Unknown Organization',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
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

  Widget _buildAngleChip(String label, double angle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        '$label: $angle°',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildRegionChip(String region) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Text(
        region,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildMethodDropdown({
    required String label,
    required CalculationMethod? selectedValue,
    required List<CalculationMethod> methods,
    required ValueChanged<CalculationMethod?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CalculationMethod>(
          value: selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            hintText: 'Select a calculation method',
          ),
          items: methods.map((method) {
            return DropdownMenuItem(
              value: method,
              child: Text(method.name),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildComparisonResult(CalculationMethod method1, CalculationMethod method2) {
    final similarity = _service.compareMethods(method1, method2);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparison Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Similarity Score:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                '${(similarity * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Key Differences:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            _buildDifferenceRow('Fajr Angle', '${method1.fajrAngle}°', '${method2.fajrAngle}°'),
            _buildDifferenceRow('Isha Angle', '${method1.ishaAngle}°', '${method2.ishaAngle}°'),
            _buildDifferenceRow('Organization', method1.organization ?? 'N/A', method2.organization ?? 'N/A'),
            
            const SizedBox(height: 16),
            
            Text(
              'Impact Assessment:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Text(
                _getImpactAssessment(similarity),
                style: TextStyle(color: Colors.amber[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifferenceRow(String label, String value1, String value2) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value1,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value2,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  String _getImpactAssessment(double similarity) {
    if (similarity >= 0.8) {
      return 'These methods are very similar. The difference in prayer times will be minimal (usually less than 2-3 minutes).';
    } else if (similarity >= 0.6) {
      return 'These methods have moderate differences. You may notice 3-5 minute variations in prayer times.';
    } else {
      return 'These methods have significant differences. Prayer times may vary by 5-15 minutes, especially for Fajr and Isha.';
    }
  }

  void _showMethodSelected(CalculationMethod method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected: ${method.name}'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
