import 'package:flutter/material.dart';
import '../../../../core/theme/islamic_theme.dart';

/// More Features Screen following app-screens design
class MoreFeaturesScreen extends StatefulWidget {
  const MoreFeaturesScreen({super.key});

  @override
  State<MoreFeaturesScreen> createState() => _MoreFeaturesScreenState();
}

class _MoreFeaturesScreenState extends State<MoreFeaturesScreen> {
  bool _isBengaliEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IslamicTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar following app-screens design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    IslamicTheme.duaBrown,
                    IslamicTheme.duaBrownLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'More Features | আরও ফিচার',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Islamic Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    IslamicTheme.duaBrown,
                    IslamicTheme.duaBrownLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'جزاك الله خيراً',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'May Allah reward you with goodness',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'আল্লাহ আপনাকে কল্যাণ দান করুন',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Features Grid
                    _buildFeaturesGrid(),
                    
                    const SizedBox(height: 20),
                    
                    // Language Settings
                    _buildLanguageSettings(),
                    
                    const SizedBox(height: 20),
                    
                    // App Info
                    _buildAppInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'title': 'Sawm Tracker',
        'subtitle': 'সিয়াম ট্র্যাকার',
        'description': 'Track your fasting',
        'subDescription': 'Monitor Ramadan fasting progress',
        'status': 'Coming Soon | শীঘ্রই আসছে',
        'icon': '🌙',
        'color': IslamicTheme.quranPurple,
        'backgroundColor': IslamicTheme.quranPurple.withOpacity(0.1),
      },
      {
        'title': 'Islamic Will',
        'subtitle': 'ইসলামিক উইল',
        'description': 'Generate Islamic will',
        'subDescription': 'According to Shariah law',
        'status': 'Coming Soon | শীঘ্রই আসছে',
        'icon': '📜',
        'color': IslamicTheme.duaBrown,
        'backgroundColor': IslamicTheme.duaBrown.withOpacity(0.1),
      },
      {
        'title': 'History',
        'subtitle': 'ইতিহাস',
        'description': 'View calculations',
        'subDescription': 'Past Zakat calculations',
        'status': 'Available | উপলব্ধ',
        'icon': '📊',
        'color': IslamicTheme.prayerBlue,
        'backgroundColor': IslamicTheme.prayerBlue.withOpacity(0.1),
      },
      {
        'title': 'Reports',
        'subtitle': 'রিপোর্ট',
        'description': 'Generate reports',
        'subDescription': 'PDF Zakat statements',
        'status': 'Available | উপলব্ধ',
        'icon': '📈',
        'color': IslamicTheme.hadithOrange,
        'backgroundColor': IslamicTheme.hadithOrange.withOpacity(0.1),
      },
      {
        'title': 'Profile',
        'subtitle': 'প্রোফাইল',
        'description': 'Manage profile',
        'subDescription': 'Personal information',
        'status': 'Available | উপলব্ধ',
        'icon': '👤',
        'color': IslamicTheme.islamicGreen,
        'backgroundColor': IslamicTheme.islamicGreen.withOpacity(0.1),
      },
      {
        'title': 'Settings',
        'subtitle': 'সেটিংস',
        'description': 'App preferences',
        'subDescription': 'Language, notifications',
        'status': 'Available | উপলব্ধ',
        'icon': '⚙️',
        'color': const Color(0xFF009688),
        'backgroundColor': const Color(0xFF009688).withOpacity(0.1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: feature['backgroundColor']! as Color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: feature['color']! as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          feature['icon']! as String,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title']! as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: feature['color']! as Color,
                            ),
                          ),
                          Text(
                            feature['subtitle']! as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature['description']! as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature['subDescription']! as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        feature['status']! as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: feature['color']! as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: IslamicTheme.prayerBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🌐', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Language Settings | ভাষা সেটিংস',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: IslamicTheme.prayerBlue,
                  ),
                ),
                Text(
                  'Switch between English, Bengali & Arabic',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'ইংরেজি, বাংলা ও আরবির মধ্যে পরিবর্তন করুন',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isBengaliEnabled,
            onChanged: (value) {
              setState(() {
                _isBengaliEnabled = value;
              });
            },
            activeColor: IslamicTheme.islamicGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Column(
      children: [
        Text(
          'ToolsForUmmah v2.0 Enhanced UI',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'بارك الله فيكم - May Allah bless you',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
