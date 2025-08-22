import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Islamic Inheritance Calculator based on authentic Shariah rules
class SimpleInheritanceCalculator extends StatefulWidget {
  const SimpleInheritanceCalculator({super.key});

  @override
  State<SimpleInheritanceCalculator> createState() =>
      _SimpleInheritanceCalculatorState();
}

class _SimpleInheritanceCalculatorState
    extends State<SimpleInheritanceCalculator> {
  String _deceasedGender = 'male'; // Default to male
  final Map<String, int> _heirCounts = {};

  // Available heirs with proper Islamic inheritance rules
  final List<Map<String, dynamic>> _availableHeirs = [
    {
      'id': 'husband',
      'name': 'Husband',
      'arabic': 'الزوج',
      'bengali': 'স্বামী',
      'english': 'Husband',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
      'multiple': false,
    },
    {
      'id': 'wife',
      'name': 'Wife(s)',
      'arabic': 'الزوجة',
      'bengali': 'স্ত্রী',
      'english': 'Wife(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
      'multiple': true,
    },
    {
      'id': 'father',
      'name': 'Father',
      'arabic': 'الأب',
      'bengali': 'পিতা',
      'english': 'Father',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
    },
    {
      'id': 'mother',
      'name': 'Mother',
      'arabic': 'الأم',
      'bengali': 'মাতা',
      'english': 'Mother',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
    },
    {
      'id': 'son',
      'name': 'Son(s)',
      'arabic': 'الابن',
      'bengali': 'পুত্র',
      'english': 'Son(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'daughter',
      'name': 'Daughter(s)',
      'arabic': 'الابنة',
      'bengali': 'কন্যা',
      'english': 'Daughter(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'grandson',
      'name': 'Grandson(s)',
      'arabic': 'ابن الابن',
      'bengali': 'নাতি',
      'english': 'Grandson(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'granddaughter',
      'name': 'Granddaughter(s)',
      'arabic': 'ابنة الابن',
      'bengali': 'নাতনি',
      'english': 'Granddaughter(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalGrandfather',
      'name': 'Paternal Grandfather',
      'arabic': 'أب الأب',
      'bengali': 'দাদা',
      'english': 'Paternal Grandfather',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
    },
    {
      'id': 'paternalGrandmother',
      'name': 'Paternal Grandmother',
      'arabic': 'أم الأب',
      'bengali': 'দাদী',
      'english': 'Paternal Grandmother',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
    },
    {
      'id': 'maternalGrandmother',
      'name': 'Maternal Grandmother',
      'arabic': 'أم الأم',
      'bengali': 'নানী',
      'english': 'Maternal Grandmother',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': true,
    },
    {
      'id': 'fullBrother',
      'name': 'Full Brother(s)',
      'arabic': 'الأخ الشقيق',
      'bengali': 'সম্পূর্ণ ভাই',
      'english': 'Full Brother(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'fullSister',
      'name': 'Full Sister(s)',
      'arabic': 'الأخت الشقيقة',
      'bengali': 'সম্পূর্ণ বোন',
      'english': 'Full Sister(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalBrother',
      'name': 'Paternal Brother(s)',
      'arabic': 'الأخ لأب',
      'bengali': 'সৎ ভাই',
      'english': 'Paternal Brother(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalSister',
      'name': 'Paternal Sister(s)',
      'arabic': 'الأخت لأب',
      'bengali': 'সৎ বোন',
      'english': 'Paternal Sister(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'maternalSibling',
      'name': 'Maternal Sibling(s)',
      'arabic': 'الأخ لأم',
      'bengali': 'মাতুল ভাইবোন',
      'english': 'Maternal Sibling(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'fullNephew',
      'name': 'Full Nephew(s)',
      'arabic': 'ابن الأخ الشقيق',
      'bengali': 'ভাইপো',
      'english': 'Full Nephew(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalNephew',
      'name': 'Paternal Nephew(s)',
      'arabic': 'ابن الأخ لأب',
      'bengali': 'সৎ ভাইপো',
      'english': 'Paternal Nephew(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'fullUncle',
      'name': 'Full Uncle(s)',
      'arabic': 'الأخ الشقيق للأب',
      'bengali': 'চাচা',
      'english': 'Full Uncle(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalUncle',
      'name': 'Paternal Uncle(s)',
      'arabic': 'الأخ لأب للأب',
      'bengali': 'সৎ চাচা',
      'english': 'Paternal Uncle(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'fullCousin',
      'name': 'Full Cousin(s)',
      'arabic': 'ابن الأخ الشقيق للأب',
      'bengali': 'চাচাতো ভাই',
      'english': 'Full Cousin(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
    {
      'id': 'paternalCousin',
      'name': 'Paternal Cousin(s)',
      'arabic': 'ابن الأخ لأب للأب',
      'bengali': 'সৎ চাচাতো ভাই',
      'english': 'Paternal Cousin(s)',
      'hasChildren': false,
      'noChildren': false,
      'fixedShare': false,
      'multiple': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize all heir counts to 0
    for (final heir in _availableHeirs) {
      _heirCounts[heir['id']] = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.calculate_outlined,
              color: colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Islamic Inheritance Calculator',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            onPressed: _showHelp,
            icon: Icon(Icons.help_outline, color: colorScheme.onSurface),
            tooltip: 'Help',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Gender Selection Section
            _buildGenderSelection(theme),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Islamic Header
                    _buildIslamicHeader(theme),
                    const SizedBox(height: 24),

                    // Heir Selection
                    _buildHeirSelection(theme),
                    const SizedBox(height: 24),

                    // Calculate Button
                    _buildCalculateButton(theme),
                    const SizedBox(height: 16),

                    // Disclaimer
                    _buildDisclaimer(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Deceased Person Gender',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGenderOption(
                  theme,
                  'male',
                  'Male',
                  'পুরুষ',
                  Icons.male,
                  _deceasedGender == 'male',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderOption(
                  theme,
                  'female',
                  'Female',
                  'মহিলা',
                  Icons.female,
                  _deceasedGender == 'female',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(
    ThemeData theme,
    String value,
    String englishLabel,
    String bengaliLabel,
    IconData icon,
    bool isSelected,
  ) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _deceasedGender = value;
          // Reset spouse counts when gender changes
          _heirCounts['husband'] = 0;
          _heirCounts['wife'] = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              englishLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
            Text(
              bengaliLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontFamily: 'NotoSansBengali',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIslamicHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'فَرِيضَةً مِّنَ اللَّهِ',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Amiri',
              height: 1.5,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'An obligation from Allah',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'আল্লাহর পক্ষ থেকে নির্ধারিত বিধান',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontFamily: 'NotoSansBengali',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Enter the number of each family member to calculate their Islamic inheritance shares',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'প্রতিটি পরিবারের সদস্যের সংখ্যা লিখুন ইসলামিক উত্তরাধিকার শেয়ার গণনা করার জন্য',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontFamily: 'NotoSansBengali',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeirSelection(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.people_outline,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Family Members',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select family members and their counts',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ..._availableHeirs.map((heir) => _buildHeirCard(heir, theme)),
      ],
    );
  }

  Widget _buildHeirCard(Map<String, dynamic> heir, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final heirId = heir['id'] as String;
    final count = _heirCounts[heirId] ?? 0;
    final isMultiple = heir['multiple'] == true;
    final bool isDisabled = _isHeirDisabled(heirId);
    final isSelected = count > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primaryContainer.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getHeirIcon(heirId),
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heir['english'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        heir['arabic'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      Text(
                        heir['bengali'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontFamily: 'NotoSansBengali',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (isMultiple) ...[
                  _buildCounterControls(heirId, count, isDisabled, theme),
                ] else ...[
                  _buildToggleSwitch(heirId, count, isDisabled, theme),
                ],
              ],
            ),
            if (isDisabled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _disabledReason(heirId),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterControls(
      String heirId, int count, bool isDisabled, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      setState(() {
                        if (count > 0) {
                          _heirCounts[heirId] = count - 1;
                        }
                      });
                    },
              icon: Icon(
                Icons.remove_circle_outline,
                color: isDisabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.error,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
            ),
            Container(
              width: 40,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: count > 0
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: count > 0
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: count > 0
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      setState(() {
                        if (heirId == 'wife' && count >= 4)
                          return; // cap at 4 wives
                        _heirCounts[heirId] = count + 1;
                      });
                    },
              icon: Icon(
                Icons.add_circle_outline,
                color: isDisabled
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.primary,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(36, 36),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        if (heirId == 'wife' && count >= 4)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Max 4 wives',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.secondary,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleSwitch(
      String heirId, int count, bool isDisabled, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Switch(
      value: count > 0,
      onChanged: isDisabled
          ? null
          : (value) {
              setState(() {
                _heirCounts[heirId] = value ? 1 : 0;
              });
            },
      activeColor: colorScheme.primary,
      activeTrackColor: colorScheme.primaryContainer,
      inactiveThumbColor: colorScheme.onSurfaceVariant,
      inactiveTrackColor: colorScheme.surfaceVariant,
    );
  }

  Widget _buildCalculateButton(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _canCalculate() ? _calculateInheritance : null,
        icon: const Icon(Icons.calculate_outlined),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text(
                'Calculate Inheritance',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'উত্তরাধিকার গণনা করুন',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'NotoSansBengali',
                ),
              ),
            ],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: colorScheme.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Important Notice',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This calculator follows Islamic inheritance rules. For legal proceedings, consult qualified Islamic scholars and legal professionals.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'এই ক্যালকুলেটর ইসলামিক উত্তরাধিকার নিয়ম অনুসরণ করে। আইনি কার্যক্রমের জন্য, যোগ্য ইসলামিক পণ্ডিত এবং আইনজীবীদের সাথে পরামর্শ করুন।',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontFamily: 'NotoSansBengali',
            ),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('How to use this calculator:'),
              SizedBox(height: 8),
              Text('1. Select the gender of the deceased person'),
              Text('2. Add family members and their counts'),
              Text(
                  '3. The calculator will automatically disable incompatible heirs'),
              Text('4. Click "Calculate Inheritance" to see results'),
              SizedBox(height: 16),
              Text('Note: This follows authentic Islamic inheritance rules.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getHeirIcon(String heirId) {
    switch (heirId) {
      case 'husband':
        return Icons.male;
      case 'wife':
        return Icons.female;
      case 'father':
        return Icons.person;
      case 'mother':
        return Icons.person_outline;
      case 'son':
        return Icons.boy;
      case 'daughter':
        return Icons.girl;
      case 'grandson':
        return Icons.child_care;
      case 'granddaughter':
        return Icons.child_friendly;
      case 'paternalGrandfather':
        return Icons.elderly;
      case 'paternalGrandmother':
        return Icons.elderly_woman;
      case 'maternalGrandmother':
        return Icons.elderly_woman;
      case 'fullBrother':
        return Icons.people;
      case 'fullSister':
        return Icons.people_outline;
      case 'paternalBrother':
        return Icons.people_alt;
      case 'paternalSister':
        return Icons.people_alt_outlined;
      case 'maternalSibling':
        return Icons.family_restroom;
      case 'fullNephew':
        return Icons.child_care;
      case 'paternalNephew':
        return Icons.child_friendly;
      case 'fullUncle':
        return Icons.person_4;
      case 'paternalUncle':
        return Icons.person_4_outlined;
      case 'fullCousin':
        return Icons.person_3;
      case 'paternalCousin':
        return Icons.person_3_outlined;
      default:
        return Icons.person;
    }
  }

  bool _canCalculate() {
    // Check if at least one heir is selected
    return _heirCounts.values.any((count) => count > 0);
  }

  void _calculateInheritance() {
    final results = _calculateIslamicShares();
    _showResults(results);
  }

  Map<String, Map<String, dynamic>> _calculateIslamicShares() {
    final results = <String, Map<String, dynamic>>{};
    final totalShares = 24.0; // Using 24 as base for easier calculations
    double remainingShares = totalShares;

    // Get counts for all heir types
    final husbandCount = _heirCounts['husband'] ?? 0;
    final wifeCount = _heirCounts['wife'] ?? 0;
    final fatherCount = _heirCounts['father'] ?? 0;
    final motherCount = _heirCounts['mother'] ?? 0;
    final sonCount = _heirCounts['son'] ?? 0;
    final daughterCount = _heirCounts['daughter'] ?? 0;
    final grandsonCount = _heirCounts['grandson'] ?? 0;
    final granddaughterCount = _heirCounts['granddaughter'] ?? 0;
    final paternalGrandfatherCount = _heirCounts['paternalGrandfather'] ?? 0;
    final paternalGrandmotherCount = _heirCounts['paternalGrandmother'] ?? 0;
    final maternalGrandmotherCount = _heirCounts['maternalGrandmother'] ?? 0;
    final fullBrotherCount = _heirCounts['fullBrother'] ?? 0;
    final fullSisterCount = _heirCounts['fullSister'] ?? 0;
    final paternalBrotherCount = _heirCounts['paternalBrother'] ?? 0;
    final paternalSisterCount = _heirCounts['paternalSister'] ?? 0;
    final maternalSiblingCount = _heirCounts['maternalSibling'] ?? 0;
    final fullNephewCount = _heirCounts['fullNephew'] ?? 0;
    final paternalNephewCount = _heirCounts['paternalNephew'] ?? 0;
    final fullUncleCount = _heirCounts['fullUncle'] ?? 0;
    final paternalUncleCount = _heirCounts['paternalUncle'] ?? 0;
    final fullCousinCount = _heirCounts['fullCousin'] ?? 0;
    final paternalCousinCount = _heirCounts['paternalCousin'] ?? 0;

    // Check if there are children (sons, daughters, grandsons, granddaughters)
    final hasChildren = sonCount > 0 ||
        daughterCount > 0 ||
        grandsonCount > 0 ||
        granddaughterCount > 0;
    final hasDirectChildren = sonCount > 0 || daughterCount > 0;
    final hasGrandchildren = grandsonCount > 0 || granddaughterCount > 0;

    // 1. HUSBAND/WIFE SHARES (Fixed shares)
    if (husbandCount > 0) {
      double husbandShare;
      if (hasChildren) {
        husbandShare = 6.0; // 1/4 = 6/24
      } else {
        husbandShare = 12.0; // 1/2 = 12/24
      }
      results['husband'] = {
        'count': husbandCount,
        'shares': husbandShare,
        'percentage': (husbandShare / totalShares * 100),
        'rule': hasChildren
            ? '1/4 (when children exist)'
            : '1/2 (when no children)',
      };
      remainingShares -= husbandShare;
    }

    if (wifeCount > 0) {
      double wivesCollectiveShare;
      if (hasChildren) {
        wivesCollectiveShare = 3.0; // 1/8 = 3/24
      } else {
        wivesCollectiveShare = 6.0; // 1/4 = 6/24
      }
      results['wife'] = {
        'count': wifeCount,
        'shares': wivesCollectiveShare,
        'percentage': (wivesCollectiveShare / totalShares * 100),
        'rule': hasChildren
            ? '1/8 (when children exist, shared equally)'
            : '1/4 (when no children, shared equally)',
      };
      remainingShares -= wivesCollectiveShare;
    }

    // 2. FATHER SHARES (Fixed share or residue)
    if (fatherCount > 0) {
      double fatherShare;
      if (hasChildren) {
        fatherShare = 4.0; // 1/6 = 4/24
      } else {
        fatherShare = remainingShares; // Residue
      }
      results['father'] = {
        'count': fatherCount,
        'shares': fatherShare,
        'percentage': (fatherShare / totalShares * 100),
        'rule': hasChildren
            ? '1/6 (when children exist)'
            : 'Residue (when no children)',
      };
      remainingShares -= fatherShare;
    }

    // 3. MOTHER SHARES (Fixed share)
    if (motherCount > 0) {
      double motherShare;
      if (hasChildren) {
        motherShare = 4.0; // 1/6 = 4/24
      } else if (fullBrotherCount > 0 ||
          fullSisterCount > 0 ||
          paternalBrotherCount > 0 ||
          paternalSisterCount > 0) {
        motherShare = 4.0; // 1/6 = 4/24
      } else {
        motherShare = 8.0; // 1/3 = 8/24
      }
      results['mother'] = {
        'count': motherCount,
        'shares': motherShare,
        'percentage': (motherShare / totalShares * 100),
        'rule': hasChildren
            ? '1/6 (when children exist)'
            : (fullBrotherCount > 0 ||
                    fullSisterCount > 0 ||
                    paternalBrotherCount > 0 ||
                    paternalSisterCount > 0)
                ? '1/6 (when siblings exist)'
                : '1/3 (when no children or siblings)',
      };
      remainingShares -= motherShare;
    }

    // 4. CHILDREN SHARES (Sons and Daughters - Residue with 2:1 ratio)
    if (sonCount > 0 || daughterCount > 0) {
      if (sonCount > 0 && daughterCount > 0) {
        // Both sons and daughters exist - sons get twice daughters' share
        final totalChildrenShares = remainingShares;
        final daughterShare =
            totalChildrenShares / (sonCount * 2 + daughterCount);
        final sonShare = daughterShare * 2;

        if (daughterCount > 0) {
          results['daughter'] = {
            'count': daughterCount,
            'shares': daughterShare * daughterCount,
            'percentage': (daughterShare * daughterCount / totalShares * 100),
            'rule': 'Sons get twice daughters\' share',
          };
        }

        if (sonCount > 0) {
          results['son'] = {
            'count': sonCount,
            'shares': sonShare * sonCount,
            'percentage': (sonShare * sonCount / totalShares * 100),
            'rule': 'Sons get twice daughters\' share',
          };
        }
      } else if (daughterCount > 0) {
        // Only daughters
        results['daughter'] = {
          'count': daughterCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': '1/2 (when only daughters, no sons)',
        };
      } else if (sonCount > 0) {
        // Only sons
        results['son'] = {
          'count': sonCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (when only sons)',
        };
      }
      remainingShares = 0;
    }

    // 5. GRANDCHILDREN (only if no direct children)
    if (remainingShares > 0 && !hasDirectChildren && hasGrandchildren) {
      if (grandsonCount > 0 && granddaughterCount > 0) {
        // Both grandsons and granddaughters exist - grandsons get twice granddaughters' share
        final totalGrandchildrenShares = remainingShares;
        final granddaughterShare =
            totalGrandchildrenShares / (grandsonCount * 2 + granddaughterCount);
        final grandsonShare = granddaughterShare * 2;

        if (granddaughterCount > 0) {
          results['granddaughter'] = {
            'count': granddaughterCount,
            'shares': granddaughterShare * granddaughterCount,
            'percentage':
                (granddaughterShare * granddaughterCount / totalShares * 100),
            'rule': 'Grandsons get twice granddaughters\' share',
          };
        }

        if (grandsonCount > 0) {
          results['grandson'] = {
            'count': grandsonCount,
            'shares': grandsonShare * grandsonCount,
            'percentage': (grandsonShare * grandsonCount / totalShares * 100),
            'rule': 'Grandsons get twice granddaughters\' share',
          };
        }
      } else if (granddaughterCount > 0) {
        // Only granddaughters
        results['granddaughter'] = {
          'count': granddaughterCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': '1/2 (when only granddaughters, no grandsons)',
        };
      } else if (grandsonCount > 0) {
        // Only grandsons
        results['grandson'] = {
          'count': grandsonCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (when only grandsons)',
        };
      }
      remainingShares = 0;
    }

    // 6. GRANDPARENTS (only if no children and no father)
    if (remainingShares > 0 && !hasChildren && fatherCount == 0) {
      // Paternal Grandfather
      if (paternalGrandfatherCount > 0) {
        results['paternalGrandfather'] = {
          'count': paternalGrandfatherCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (when no children or father)',
        };
        remainingShares = 0;
      }

      // Grandmothers (if no paternal grandfather)
      if (remainingShares > 0 && paternalGrandfatherCount == 0) {
        if (paternalGrandmotherCount > 0 && maternalGrandmotherCount > 0) {
          // Both grandmothers share 1/6 equally
          final grandmotherShare = 4.0; // 1/6 = 4/24
          results['paternalGrandmother'] = {
            'count': paternalGrandmotherCount,
            'shares': grandmotherShare / 2,
            'percentage': (grandmotherShare / 2 / totalShares * 100),
            'rule': '1/12 (shared with maternal grandmother)',
          };
          results['maternalGrandmother'] = {
            'count': maternalGrandmotherCount,
            'shares': grandmotherShare / 2,
            'percentage': (grandmotherShare / 2 / totalShares * 100),
            'rule': '1/12 (shared with maternal grandmother)',
          };
          remainingShares -= grandmotherShare;
        } else if (paternalGrandmotherCount > 0) {
          results['paternalGrandmother'] = {
            'count': paternalGrandmotherCount,
            'shares': 4.0, // 1/6 = 4/24
            'percentage': (4.0 / totalShares * 100),
            'rule': '1/6 (when no maternal grandmother)',
          };
          remainingShares -= 4.0;
        } else if (maternalGrandmotherCount > 0) {
          results['maternalGrandmother'] = {
            'count': maternalGrandmotherCount,
            'shares': 4.0, // 1/6 = 4/24
            'percentage': (4.0 / totalShares * 100),
            'rule': '1/6 (when no paternal grandmother)',
          };
          remainingShares -= 4.0;
        }
      }
    }

    // 7. SIBLINGS (only if no children, no father, no grandparents)
    if (remainingShares > 0 &&
        !hasChildren &&
        fatherCount == 0 &&
        paternalGrandfatherCount == 0 &&
        paternalGrandmotherCount == 0 &&
        maternalGrandmotherCount == 0) {
      // Full siblings first
      if (fullSisterCount > 0 && fullBrotherCount == 0) {
        // Only full sisters
        results['fullSister'] = {
          'count': fullSisterCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': '1/2 (when only sisters, no brothers)',
        };
      } else if (fullBrotherCount > 0) {
        // Full brothers (with or without sisters)
        if (fullSisterCount > 0) {
          // Both brothers and sisters - brothers get twice sisters' share
          final totalSiblingShares = remainingShares;
          final sisterShare =
              totalSiblingShares / (fullBrotherCount * 2 + fullSisterCount);
          final brotherShare = sisterShare * 2;

          results['fullSister'] = {
            'count': fullSisterCount,
            'shares': sisterShare * fullSisterCount,
            'percentage': (sisterShare * fullSisterCount / totalShares * 100),
            'rule': 'Brothers get twice sisters\' share',
          };

          results['fullBrother'] = {
            'count': fullBrotherCount,
            'shares': brotherShare * fullBrotherCount,
            'percentage': (brotherShare * fullBrotherCount / totalShares * 100),
            'rule': 'Brothers get twice sisters\' share',
          };
        } else {
          // Only brothers
          results['fullBrother'] = {
            'count': fullBrotherCount,
            'shares': remainingShares,
            'percentage': (remainingShares / totalShares * 100),
            'rule': 'Residue (when only brothers)',
          };
        }
      }

      // Paternal siblings (if no full siblings)
      if (remainingShares > 0 &&
          fullBrotherCount == 0 &&
          fullSisterCount == 0) {
        if (paternalSisterCount > 0 && paternalBrotherCount == 0) {
          // Only paternal sisters
          results['paternalSister'] = {
            'count': paternalSisterCount,
            'shares': remainingShares,
            'percentage': (remainingShares / totalShares * 100),
            'rule': '1/2 (when only paternal sisters, no brothers)',
          };
        } else if (paternalBrotherCount > 0) {
          // Paternal brothers (with or without sisters)
          if (paternalSisterCount > 0) {
            // Both brothers and sisters - brothers get twice sisters' share
            final totalSiblingShares = remainingShares;
            final sisterShare = totalSiblingShares /
                (paternalBrotherCount * 2 + paternalSisterCount);
            final brotherShare = sisterShare * 2;

            results['paternalSister'] = {
              'count': paternalSisterCount,
              'shares': sisterShare * paternalSisterCount,
              'percentage':
                  (sisterShare * paternalSisterCount / totalShares * 100),
              'rule': 'Paternal brothers get twice sisters\' share',
            };

            results['paternalBrother'] = {
              'count': paternalBrotherCount,
              'shares': brotherShare * paternalBrotherCount,
              'percentage':
                  (brotherShare * paternalBrotherCount / totalShares * 100),
              'rule': 'Paternal brothers get twice sisters\' share',
            };
          } else {
            // Only paternal brothers
            results['paternalBrother'] = {
              'count': paternalBrotherCount,
              'shares': remainingShares,
              'percentage': (remainingShares / totalShares * 100),
              'rule': 'Residue (when only paternal brothers)',
            };
          }
        }
      }

      // Maternal siblings (if no other siblings)
      if (remainingShares > 0 &&
          fullBrotherCount == 0 &&
          fullSisterCount == 0 &&
          paternalBrotherCount == 0 &&
          paternalSisterCount == 0 &&
          maternalSiblingCount > 0) {
        results['maternalSibling'] = {
          'count': maternalSiblingCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': '1/6 (maternal siblings share equally)',
        };
      }
    }

    // 8. NEPHEWS (only if no siblings)
    if (remainingShares > 0 &&
        fullBrotherCount == 0 &&
        fullSisterCount == 0 &&
        paternalBrotherCount == 0 &&
        paternalSisterCount == 0 &&
        maternalSiblingCount == 0) {
      if (fullNephewCount > 0) {
        results['fullNephew'] = {
          'count': fullNephewCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (full nephews)',
        };
      } else if (paternalNephewCount > 0) {
        results['paternalNephew'] = {
          'count': paternalNephewCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (paternal nephews)',
        };
      }
    }

    // 9. UNCLES (only if no nephews)
    if (remainingShares > 0 &&
        fullNephewCount == 0 &&
        paternalNephewCount == 0) {
      if (fullUncleCount > 0) {
        results['fullUncle'] = {
          'count': fullUncleCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (full uncles)',
        };
      } else if (paternalUncleCount > 0) {
        results['paternalUncle'] = {
          'count': paternalUncleCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (paternal uncles)',
        };
      }
    }

    // 10. COUSINS (only if no uncles)
    if (remainingShares > 0 && fullUncleCount == 0 && paternalUncleCount == 0) {
      if (fullCousinCount > 0) {
        results['fullCousin'] = {
          'count': fullCousinCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (full cousins)',
        };
      } else if (paternalCousinCount > 0) {
        results['paternalCousin'] = {
          'count': paternalCousinCount,
          'shares': remainingShares,
          'percentage': (remainingShares / totalShares * 100),
          'rule': 'Residue (paternal cousins)',
        };
      }
    }

    return results;
  }

  void _showResults(Map<String, Map<String, dynamic>> results) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Inheritance Results',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Distribution based on Islamic inheritance rules (24-share system)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ইসলামিক উত্তরাধিকার নিয়ম অনুসারে বণ্টন (২৪-শেয়ার সিস্টেম)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontFamily: 'NotoSansBengali',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Inheritance Distribution:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              ...results.entries.map((entry) {
                final heir =
                    _availableHeirs.firstWhere((h) => h['id'] == entry.key);
                final data = entry.value;
                final count = data['count'] as int;
                final shares = data['shares'] as double;
                final percentage = data['percentage'] as double;
                final rule = data['rule'] as String;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getHeirIcon(entry.key),
                              color: colorScheme.onPrimaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${heir['english']} (${count > 1 ? '$count persons' : '1 person'})',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${heir['arabic']} - ${heir['bengali']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: 'Amiri',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shares: ${shares.toStringAsFixed(1)}/24',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rule: $rule',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.secondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_outlined,
                          color: colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Important Notice',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This calculation follows Islamic inheritance rules. For legal proceedings, consult qualified Islamic scholars and legal professionals.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'এই গণনা ইসলামিক উত্তরাধিকার নিয়ম অনুসরণ করে। আইনি কার্যক্রমের জন্য, যোগ্য ইসলামিক পণ্ডিত এবং আইনজীবীদের সাথে পরামর্শ করুন।',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'NotoSansBengali',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _copyResults(results);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.copy_outlined),
            label: Text(
              'Copy Results',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _copyResults(Map<String, Map<String, dynamic>> results) {
    final buffer = StringBuffer();
    buffer.writeln('Islamic Inheritance Calculation Results');
    buffer.writeln('=====================================');
    buffer.writeln('Based on Islamic inheritance rules (24 shares system)');
    buffer.writeln('');
    buffer.writeln('Family Members:');

    for (final entry in _heirCounts.entries) {
      if (entry.value > 0) {
        final heir = _availableHeirs.firstWhere((h) => h['id'] == entry.key);
        buffer.writeln('• ${heir['english']}: ${entry.value}');
      }
    }

    buffer.writeln('');
    buffer.writeln('Inheritance Distribution:');

    for (final entry in results.entries) {
      final heir = _availableHeirs.firstWhere((h) => h['id'] == entry.key);
      final data = entry.value;
      final count = data['count'] as int;
      final shares = data['shares'] as double;
      final percentage = data['percentage'] as double;
      final rule = data['rule'] as String;

      buffer.writeln(
          '• ${heir['english']} (${count > 1 ? '$count persons' : '1 person'}): ${shares.toStringAsFixed(1)}/24 shares (${percentage.toStringAsFixed(1)}%)');
      buffer.writeln('  Rule: $rule');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Results copied to clipboard',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'ফলাফল ক্লিপবোর্ডে কপি করা হয়েছে',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: 'NotoSansBengali',
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  bool _hasDirectChildren() {
    return (_heirCounts['son'] ?? 0) > 0 || (_heirCounts['daughter'] ?? 0) > 0;
  }

  bool _isHeirDisabled(String heirId) {
    // Gender-based spouse eligibility
    if (_deceasedGender == 'male' && heirId == 'husband') return true;
    if (_deceasedGender == 'female' && heirId == 'wife') return true;

    final bool hasChildren = _hasDirectChildren();
    final bool fatherPresent = (_heirCounts['father'] ?? 0) > 0;

    // Children block grandchildren
    if (hasChildren && (heirId == 'grandson' || heirId == 'granddaughter'))
      return true;

    // Father blocks paternal grandfather
    if (fatherPresent && heirId == 'paternalGrandfather') return true;

    // Sons or father block full/paternal siblings
    if (((_heirCounts['son'] ?? 0) > 0 || fatherPresent) &&
        (heirId == 'fullBrother' ||
            heirId == 'fullSister' ||
            heirId == 'paternalBrother' ||
            heirId == 'paternalSister')) return true;

    // Descendants or father block maternal siblings
    if ((hasChildren || fatherPresent) && heirId == 'maternalSibling')
      return true;

    return false;
  }

  String _disabledReason(String heirId) {
    if (_deceasedGender == 'male' && heirId == 'husband')
      return 'Husband not applicable when deceased is male';
    if (_deceasedGender == 'female' && heirId == 'wife')
      return 'Wives not applicable when deceased is female';
    if (_hasDirectChildren() &&
        (heirId == 'grandson' || heirId == 'granddaughter'))
      return 'Blocked: direct children exist';
    if ((_heirCounts['father'] ?? 0) > 0 && heirId == 'paternalGrandfather')
      return 'Blocked: father present';
    if (((_heirCounts['son'] ?? 0) > 0 || (_heirCounts['father'] ?? 0) > 0) &&
        (heirId == 'fullBrother' ||
            heirId == 'fullSister' ||
            heirId == 'paternalBrother' ||
            heirId == 'paternalSister'))
      return 'Blocked: son or father present';
    if (((_heirCounts['son'] ?? 0) > 0 ||
            (_heirCounts['daughter'] ?? 0) > 0 ||
            (_heirCounts['father'] ?? 0) > 0) &&
        heirId == 'maternalSibling')
      return 'Blocked: descendants or father present';
    return 'Not eligible in current scenario';
  }
}
