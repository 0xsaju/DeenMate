import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import '../../domain/entities/heir.dart';
// import '../../domain/entities/estate.dart';
// import '../../domain/entities/inheritance_result.dart';
// import '../../domain/usecases/calculate_inheritance_usecase.dart';
// import 'result_display_screen.dart';

/// Screen for selecting heirs for inheritance calculation
class HeirSelectionScreen extends StatefulWidget {
  final Estate estate;

  const HeirSelectionScreen({
    super.key,
    required this.estate,
  });

  @override
  State<HeirSelectionScreen> createState() => _HeirSelectionScreenState();
}

class _HeirSelectionScreenState extends State<HeirSelectionScreen> {
  final List<Heir> _selectedHeirs = [];
  final CalculateInheritanceUseCase _calculateUseCase =
      const CalculateInheritanceUseCase();

  // Predefined heirs for selection
  final List<Heir> _availableHeirs = [
    Heir(
      id: 'spouse',
      name: 'Spouse',
      arabicName: 'الزوج/الزوجة',
      bengaliName: 'স্বামী/স্ত্রী',
      heirType: HeirType.spouse,
      gender: Gender.male, // Will be set based on deceased
      category: HeirCategory.zabiulFuruj,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'with_children': '1/8', 'without_children': '1/4'},
    ),
    Heir(
      id: 'father',
      name: 'Father',
      arabicName: 'الأب',
      bengaliName: 'পিতা',
      heirType: HeirType.father,
      gender: Gender.male,
      category: HeirCategory.zabiulFuruj,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'with_children': '1/6', 'without_children': 'residue'},
    ),
    Heir(
      id: 'mother',
      name: 'Mother',
      arabicName: 'الأم',
      bengaliName: 'মাতা',
      heirType: HeirType.mother,
      gender: Gender.female,
      category: HeirCategory.zabiulFuruj,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {
        'with_children': '1/6',
        'with_siblings': '1/6',
        'alone': '1/3'
      },
    ),
    Heir(
      id: 'son',
      name: 'Son',
      arabicName: 'الابن',
      bengaliName: 'পুত্র',
      heirType: HeirType.son,
      gender: Gender.male,
      category: HeirCategory.asaba,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'always': 'residue'},
    ),
    Heir(
      id: 'daughter',
      name: 'Daughter',
      arabicName: 'الابنة',
      bengaliName: 'কন্যা',
      heirType: HeirType.daughter,
      gender: Gender.female,
      category: HeirCategory.zabiulFuruj,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'alone': '1/2', 'multiple': '2/3', 'with_sons': 'residue'},
    ),
    Heir(
      id: 'fullBrother',
      name: 'Full Brother',
      arabicName: 'الأخ الشقيق',
      bengaliName: 'সম্পূর্ণ ভাই',
      heirType: HeirType.fullBrother,
      gender: Gender.male,
      category: HeirCategory.asaba,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'always': 'residue'},
    ),
    Heir(
      id: 'fullSister',
      name: 'Full Sister',
      arabicName: 'الأخت الشقيقة',
      bengaliName: 'সম্পূর্ণ বোন',
      heirType: HeirType.fullSister,
      gender: Gender.female,
      category: HeirCategory.zabiulFuruj,
      quranicReferences: [],
      hadithReferences: [],
      blockingRules: [],
      shareRules: {'alone': '1/2', 'multiple': '2/3'},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Select Heirs',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Estate summary
          _buildEstateSummary(),

          // Heir selection
          Expanded(
            child: _buildHeirSelection(),
          ),

          // Calculate button
          _buildCalculateButton(),
        ],
      ),
    );
  }

  Widget _buildEstateSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
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
              Icon(Icons.account_balance, color: Colors.green[700], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Estate Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Deceased: ${widget.estate.deceasedName}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Value: ৳${widget.estate.totalValue.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selected Heirs: ${_selectedHeirs.length}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeirSelection() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _availableHeirs.length,
      itemBuilder: (context, index) {
        final heir = _availableHeirs[index];
        final isSelected = _selectedHeirs.any((h) => h.id == heir.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Colors.green[50] : Colors.white,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isSelected ? Colors.green[700] : Colors.grey[300],
              child: Icon(
                _getHeirIcon(heir.heirType),
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              heir.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green[700] : Colors.black87,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heir.arabicName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.green[600] : Colors.black54,
                    fontFamily: 'Amiri',
                  ),
                ),
                Text(
                  heir.bengaliName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.green[600] : Colors.black54,
                    fontFamily: 'NotoSansBengali',
                  ),
                ),
                Text(
                  _getShareRuleText(heir),
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.green[600] : Colors.black45,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedHeirs.add(heir);
                  } else {
                    _selectedHeirs.removeWhere((h) => h.id == heir.id);
                  }
                });
              },
              activeColor: Colors.green[700],
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedHeirs.removeWhere((h) => h.id == heir.id);
                } else {
                  _selectedHeirs.add(heir);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _selectedHeirs.isEmpty ? null : _calculateInheritance,
          icon: const Icon(Icons.calculate),
          label: const Text(
            'Calculate Inheritance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
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
    );
  }

  IconData _getHeirIcon(HeirType heirType) {
    switch (heirType) {
      case HeirType.spouse:
        return Icons.favorite;
      case HeirType.father:
        return Icons.person;
      case HeirType.mother:
        return Icons.person_outline;
      case HeirType.son:
        return Icons.boy;
      case HeirType.daughter:
        return Icons.girl;
      case HeirType.fullBrother:
        return Icons.people;
      case HeirType.fullSister:
        return Icons.people_outline;
      default:
        return Icons.person;
    }
  }

  String _getShareRuleText(Heir heir) {
    final rules = heir.shareRules;
    if (rules.containsKey('always')) {
      return 'Share: ${rules['always']}';
    } else if (rules.containsKey('with_children')) {
      return 'With children: ${rules['with_children']}, Without: ${rules['without_children']}';
    } else if (rules.containsKey('alone')) {
      return 'Alone: ${rules['alone']}, Multiple: ${rules['multiple']}';
    }
    return 'Fixed share heir';
  }

  void _calculateInheritance() async {
    if (_selectedHeirs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one heir'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      ),
    );

    try {
      // Calculate inheritance
      final result = _calculateUseCase(
        estate: widget.estate,
        heirs: _selectedHeirs,
        method: CalculationMethod.consensus,
      );

      // Hide loading dialog
      Navigator.pop(context);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calculation failed: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (inheritanceResult) {
          // Navigate to result screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultDisplayScreen(
                result: inheritanceResult,
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Hide loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
