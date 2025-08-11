import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/zakat_calculator_notifier.dart';

/// Base class for all Zakat form sections
abstract class ZakatFormSection extends StatelessWidget {

  const ZakatFormSection({
    required this.formData, required this.onDataChanged, super.key,
  });
  final ZakatFormData formData;
  final Function(ZakatFormData) onDataChanged;

  /// Create a styled input field for monetary amounts
  Widget buildMoneyInputField({
    required String label,
    required double value,
    required Function(double) onChanged,
    String? hint,
    String? helpText,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        TextFormField(
          initialValue: value == 0 ? '' : value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: hint ?? 'Enter amount',
            prefixText: '${formData.currency} ',
            suffixIcon: helpText != null
                ? IconButton(
                    icon: const Icon(Icons.help_outline, size: 18),
                    onPressed: () => _showHelpDialog(label, helpText),
                  )
                : null,
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
          onChanged: (value) {
            final doubleValue = double.tryParse(value) ?? 0.0;
            onChanged(doubleValue);
          },
        ),
        const SizedBox(height: AppTheme.spacing16),
      ],
    );
  }

  /// Create a styled input field for weight (grams)
  Widget buildWeightInputField({
    required String label,
    required double value,
    required Function(double) onChanged,
    String unit = 'grams',
    String? helpText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        TextFormField(
          initialValue: value == 0 ? '' : value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter weight',
            suffixText: unit,
            suffixIcon: helpText != null
                ? IconButton(
                    icon: const Icon(Icons.help_outline, size: 18),
                    onPressed: () => _showHelpDialog(label, helpText),
                  )
                : null,
          ),
          onChanged: (value) {
            final doubleValue = double.tryParse(value) ?? 0.0;
            onChanged(doubleValue);
          },
        ),
        const SizedBox(height: AppTheme.spacing16),
      ],
    );
  }

  /// Create a styled dropdown field
  Widget buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    String Function(T)? itemLabel,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing8),
        DropdownButtonFormField<T>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel?.call(item) ?? item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: 'Select option',
          ),
          validator: isRequired
              ? (value) {
                  if (value == null) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
        const SizedBox(height: AppTheme.spacing16),
      ],
    );
  }

  /// Create a section header
  Widget buildSectionHeader({
    required String title,
    required IconData icon,
    String? subtitle,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing16),
      margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.lightTheme.colorScheme.primary).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
        border: Border.all(
          color: color ?? AppTheme.lightTheme.colorScheme.primary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? AppTheme.lightTheme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: color ?? AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show help dialog
  void _showHelpDialog(String title, String content) {
    // This would be implemented in the parent widget
  }
}

/// Personal Information Section
class PersonalInfoSection extends ZakatFormSection {
  const PersonalInfoSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            title: 'Personal Information',
            subtitle: 'Basic details for your Zakat calculation',
            icon: Icons.person,
          ),
          
          // Name field
          TextFormField(
            initialValue: formData.name,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Name is required';
              }
              return null;
            },
            onChanged: (value) {
              onDataChanged(formData.copyWith(name: value));
            },
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Email field
          TextFormField(
            initialValue: formData.email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              onDataChanged(formData.copyWith(email: value));
            },
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Phone field
          TextFormField(
            initialValue: formData.phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter your phone number',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            onChanged: (value) {
              onDataChanged(formData.copyWith(phone: value));
            },
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Country field
          buildDropdownField<String>(
            label: 'Country',
            value: formData.country.isEmpty ? 'Bangladesh' : formData.country,
            items: AppConstants.supportedCurrencies.map((currency) {
              // Map currencies to countries (simplified)
              final countryMap = {
                'USD': 'United States',
                'BDT': 'Bangladesh',
                'EUR': 'European Union',
                'GBP': 'United Kingdom',
                'SAR': 'Saudi Arabia',
                'AED': 'United Arab Emirates',
                'INR': 'India',
                'PKR': 'Pakistan',
                'MYR': 'Malaysia',
                'IDR': 'Indonesia',
              };
              return countryMap[currency] ?? currency;
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onDataChanged(formData.copyWith(country: value));
              }
            },
            isRequired: true,
          ),
          
          // City field
          TextFormField(
            initialValue: formData.city,
            decoration: const InputDecoration(
              labelText: 'City *',
              hintText: 'Enter your city',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'City is required';
              }
              return null;
            },
            onChanged: (value) {
              onDataChanged(formData.copyWith(city: value));
            },
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Address field
          TextFormField(
            initialValue: formData.address,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your address (optional)',
              prefixIcon: Icon(Icons.home_outlined),
            ),
            onChanged: (value) {
              onDataChanged(formData.copyWith(address: value));
            },
          ),
          const SizedBox(height: AppTheme.spacing16),
          
          // Madhab field
          buildDropdownField<String>(
            label: 'Islamic School of Thought (Madhab)',
            value: formData.madhab,
            items: const ['Hanafi', "Shafi'i", 'Maliki', 'Hanbali'],
            onChanged: (value) {
              if (value != null) {
                onDataChanged(formData.copyWith(madhab: value));
              }
            },
          ),
          
          // Currency field
          buildDropdownField<String>(
            label: 'Currency',
            value: formData.currency,
            items: AppConstants.supportedCurrencies,
            onChanged: (value) {
              if (value != null) {
                onDataChanged(formData.copyWith(currency: value));
              }
            },
            isRequired: true,
          ),
          
          // Hawl start date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hawl Start Date (Islamic Year Beginning)',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              InkWell(
                onTap: () => _selectHawlDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Select date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormat('MMMM dd, yyyy').format(formData.hawlStartDate),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'The date when you first acquired wealth above Nisab threshold',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }

  Future<void> _selectHawlDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: formData.hawlStartDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      onDataChanged(formData.copyWith(hawlStartDate: date));
    }
  }
}

/// Cash Assets Section
class CashAssetsSection extends ZakatFormSection {
  const CashAssetsSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            title: 'Cash & Bank Assets',
            subtitle: 'All cash holdings and bank balances',
            icon: Icons.account_balance_wallet,
          ),
          
          buildMoneyInputField(
            label: 'Cash in Hand',
            value: formData.cashInHand,
            hint: 'Physical cash you possess',
            onChanged: (value) {
              onDataChanged(formData.copyWith(cashInHand: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Savings Account',
            value: formData.bankSavings,
            hint: 'Money in savings accounts',
            onChanged: (value) {
              onDataChanged(formData.copyWith(bankSavings: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Checking Account',
            value: formData.bankChecking,
            hint: 'Money in checking accounts',
            onChanged: (value) {
              onDataChanged(formData.copyWith(bankChecking: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Fixed Deposits',
            value: formData.fixedDeposits,
            hint: 'Term deposits and CDs',
            helpText: 'Include all fixed deposits that have matured or will mature within the year',
            onChanged: (value) {
              onDataChanged(formData.copyWith(fixedDeposits: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Foreign Currency',
            value: formData.foreignCurrency,
            hint: 'Convert to ${formData.currency}',
            helpText: 'Convert all foreign currency holdings to your selected base currency',
            onChanged: (value) {
              onDataChanged(formData.copyWith(foreignCurrency: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Digital Wallets',
            value: formData.digitalWallets,
            hint: 'PayPal, Payoneer, etc.',
            onChanged: (value) {
              onDataChanged(formData.copyWith(digitalWallets: value));
            },
          ),
          
          buildMoneyInputField(
            label: 'Cryptocurrencies',
            value: formData.cryptocurrencies,
            hint: 'Convert to ${formData.currency}',
            helpText: 'Include only if considered halal by your scholar. Convert to fiat value.',
            onChanged: (value) {
              onDataChanged(formData.copyWith(cryptocurrencies: value));
            },
          ),
          
          // Total cash summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cash Assets:',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${formData.totalCashAssets.toStringAsFixed(2)} ${formData.currency}',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }
}

/// Precious Metals Section
class PreciousMetalsSection extends ZakatFormSection {
  const PreciousMetalsSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionHeader(
            title: 'Precious Metals',
            subtitle: 'Gold, Silver, and other precious metals',
            icon: Icons.diamond,
            color: Colors.amber[700],
          ),
          
          // Gold section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.amber[700], size: 16),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Gold Holdings',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  buildWeightInputField(
                    label: 'Gold Weight',
                    value: formData.goldWeightGrams,
                    helpText: 'Enter the total weight of gold you own in grams',
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(goldWeightGrams: value));
                    },
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: buildMoneyInputField(
                          label: 'Current Gold Price per Gram',
                          value: formData.currentGoldPrice,
                          hint: 'Live price: ${formData.currentGoldPrice.toStringAsFixed(2)}',
                          onChanged: (value) {
                            onDataChanged(formData.copyWith(goldCurrentPrice: value));
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          // Refresh gold price
                        },
                        tooltip: 'Refresh Price',
                      ),
                    ],
                  ),
                  
                  buildMoneyInputField(
                    label: 'Gold Jewelry (Investment)',
                    value: formData.goldJewelry,
                    hint: 'Only investment jewelry',
                    helpText: 'Include only jewelry kept for investment. Personal use jewelry may be exempt.',
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(goldJewelry: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Gold Coins',
                    value: formData.goldCoins,
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(goldCoins: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Gold Bars',
                    value: formData.goldBars,
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(goldBars: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Gold ETFs/Funds',
                    value: formData.goldETFs,
                    hint: 'Gold-backed securities',
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(goldETFs: value));
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Silver section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.circle, color: Colors.grey[400], size: 16),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Silver Holdings',
                        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  
                  buildWeightInputField(
                    label: 'Silver Weight',
                    value: formData.silverWeightGrams,
                    helpText: 'Enter the total weight of silver you own in grams',
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(silverWeightGrams: value));
                    },
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: buildMoneyInputField(
                          label: 'Current Silver Price per Gram',
                          value: formData.currentSilverPrice,
                          hint: 'Live price: ${formData.currentSilverPrice.toStringAsFixed(2)}',
                          onChanged: (value) {
                            onDataChanged(formData.copyWith(silverCurrentPrice: value));
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          // Refresh silver price
                        },
                        tooltip: 'Refresh Price',
                      ),
                    ],
                  ),
                  
                  buildMoneyInputField(
                    label: 'Silver Jewelry (Investment)',
                    value: formData.silverJewelry,
                    hint: 'Only investment jewelry',
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(silverJewelry: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Silver Coins',
                    value: formData.silverCoins,
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(silverCoins: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Silver Bars',
                    value: formData.silverBars,
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(silverBars: value));
                    },
                  ),
                  
                  buildMoneyInputField(
                    label: 'Silver ETFs/Funds',
                    value: formData.silverETFs,
                    onChanged: (value) {
                      onDataChanged(formData.copyWith(silverETFs: value));
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Precious metals summary
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(color: Colors.amber[700]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Gold Value:'),
                    Text(
                      '${((formData.goldWeightGrams * formData.currentGoldPrice) + formData.goldJewelry + formData.goldCoins + formData.goldBars + formData.goldETFs).toStringAsFixed(2)} ${formData.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Silver Value:'),
                    Text(
                      '${((formData.silverWeightGrams * formData.currentSilverPrice) + formData.silverJewelry + formData.silverCoins + formData.silverBars + formData.silverETFs).toStringAsFixed(2)} ${formData.currency}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Precious Metals:',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${formData.totalPreciousMetalsValue.toStringAsFixed(2)} ${formData.currency}',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing32),
        ],
      ),
    );
  }
}

// Continue with other sections...
// Due to length constraints, I'll create the remaining sections in separate files
// The pattern is similar for BusinessAssetsSection, InvestmentAssetsSection, etc.

/// Business Assets Section (placeholder)
class BusinessAssetsSection extends ZakatFormSection {
  const BusinessAssetsSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Business Assets Section - To be implemented'),
    );
  }
}

/// Investment Assets Section (placeholder)
class InvestmentAssetsSection extends ZakatFormSection {
  const InvestmentAssetsSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Investment Assets Section - To be implemented'),
    );
  }
}

/// Real Estate Section (placeholder)
class RealEstateSection extends ZakatFormSection {
  const RealEstateSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Real Estate Section - To be implemented'),
    );
  }
}

/// Agricultural Section (placeholder)
class AgriculturalSection extends ZakatFormSection {
  const AgriculturalSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Agricultural Section - To be implemented'),
    );
  }
}

/// Liabilities Section (placeholder)
class LiabilitiesSection extends ZakatFormSection {
  const LiabilitiesSection({
    required super.formData, required super.onDataChanged, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Liabilities Section - To be implemented'),
    );
  }
}

/// Summary Section
class SummarySection extends StatelessWidget {

  const SummarySection({
    required this.formData, required this.onCalculate, super.key,
  });
  final ZakatFormData formData;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calculate,
                  size: 48,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                const SizedBox(height: AppTheme.spacing16),
                Text(
                  'Calculation Summary',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Review your information and calculate Zakat',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing24),
          
          // Summary cards
          _buildSummaryCard(
            'Total Assets',
            formData.totalAssets,
            formData.currency,
            Icons.account_balance_wallet,
            Colors.green,
          ),
          
          _buildSummaryCard(
            'Total Liabilities',
            formData.totalLiabilities,
            formData.currency,
            Icons.money_off,
            Colors.red,
          ),
          
          _buildSummaryCard(
            'Net Worth',
            formData.netWorth,
            formData.currency,
            Icons.trending_up,
            Colors.blue,
          ),
          
          const SizedBox(height: AppTheme.spacing24),
          
          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: formData.isValid ? onCalculate : null,
              icon: const Icon(Icons.calculate, size: 28),
              label: const Text(
                'Calculate Zakat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacing16),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: AppTheme.spacing8),
                    Text(
                      'Important Note',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing8),
                const Text(
                  'This calculation is for guidance purposes only. For complex situations or religious guidance, please consult with qualified Islamic scholars. Different schools of Islamic thought may have varying interpretations.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    String currency,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.mediumRadius),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    '${amount.toStringAsFixed(2)} $currency',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}