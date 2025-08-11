import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final List<Map<String, dynamic>> _prayerTimes = [
    {
      'name': 'Fajr',
      'arabicName': 'الفجر',
      'bengaliName': 'ফজর',
      'time': '5:15 AM',
      'isNext': false,
      'isCompleted': true,
      'remaining': '7h 45m',
      'icon': '🌅',
      'color': const Color(0xFF2E7D32),
      'bgColor': const Color(0xFFE8F5E8),
    },
    {
      'name': 'Dhuhr',
      'arabicName': 'الظهر',
      'bengaliName': 'যুহর',
      'time': '1:20 PM',
      'isNext': true,
      'isCompleted': false,
      'remaining': '6h 5m',
      'icon': '☀️',
      'color': const Color(0xFFFF8F00),
      'bgColor': const Color(0xFFFFF3E0),
    },
    {
      'name': 'Asr',
      'arabicName': 'العصر',
      'bengaliName': 'আসর',
      'time': '4:45 PM',
      'isNext': false,
      'isCompleted': false,
      'remaining': '9h 30m',
      'icon': '🌤',
      'color': const Color(0xFF7B1FA2),
      'bgColor': const Color(0xFFF3E5F5),
    },
    {
      'name': 'Maghrib',
      'arabicName': 'المغرب',
      'bengaliName': 'মাগরিব',
      'time': '6:30 PM',
      'isNext': false,
      'isCompleted': false,
      'remaining': '11h 15m',
      'icon': '🌆',
      'color': const Color(0xFFD84315),
      'bgColor': const Color(0xFFFFEBEE),
    },
    {
      'name': 'Isha',
      'arabicName': 'العشاء',
      'bengaliName': 'ইশা',
      'time': '8:00 PM',
      'isNext': false,
      'isCompleted': false,
      'remaining': '12h 45m',
      'icon': '🌙',
      'color': const Color(0xFF5D4037),
      'bgColor': const Color(0xFFEFEBE9),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prayer Times | নামাজের সময়',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // TODO: Open settings
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
              const Color(0xFF1565C0),
              const Color(0xFF1565C0).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Date Header
              Container(
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
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today | আজ',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          'Friday, 15 Ramadan 1445',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                        
                        const SizedBox(height: 2),
                        
                        Text(
                          'জুমা, ১৫ রমজান ১৪৪৫',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 12,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text(
                          '🌙',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Current Prayer Card (Fajr completed)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2E7D32), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '🌅',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fajr | ফজর',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            '5:15 AM',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          
                          const SizedBox(height: 2),
                          
                          Text(
                            '✓ Completed | সম্পন্ন',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Next in',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Text(
                          '7h 45m',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Prayer Cards List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _prayerTimes.length,
                  itemBuilder: (context, index) {
                    final prayer = _prayerTimes[index];
                    return _buildPrayerCard(prayer, index);
                  },
                ),
              ),
              
              // Quick Stats
              Container(
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
                    Text(
                      'Today\'s Progress | আজকের অগ্রগতি',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        // Prayers
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Prayers',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                  Text(
                                    '1/5',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Streak
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Streak',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFF8F00),
                                    ),
                                  ),
                                  Text(
                                    '7 days',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFFFF8F00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Month
                        Expanded(
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Month',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1565C0),
                                    ),
                                  ),
                                  Text(
                                    '85%',
                                    style: GoogleFonts.notoSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1565C0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Location Info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 Dhaka, Bangladesh',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    
                    const SizedBox(height: 2),
                    
                    Text(
                      'Calculation Method: Islamic Society of North America',
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerCard(Map<String, dynamic> prayer, int index) {
    final isCompleted = prayer['isCompleted'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prayer icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: prayer['bgColor'],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                prayer['icon'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Prayer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${prayer['name']} | ${prayer['bengaliName']}',
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  prayer['time'],
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: const Color(0xFF666666),
                  ),
                ),
                
                const SizedBox(height: 2),
                
                Text(
                  'in ${prayer['remaining']}',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: prayer['color'],
                  ),
                ),
              ],
            ),
          ),
          
          // Selection indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted 
                  ? const Color(0xFF4CAF50)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted 
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFDDDDDD),
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
