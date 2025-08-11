import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class QiblaFinderScreen extends StatefulWidget {
  const QiblaFinderScreen({super.key});

  @override
  State<QiblaFinderScreen> createState() => _QiblaFinderScreenState();
}

class _QiblaFinderScreenState extends State<QiblaFinderScreen> {
  double _qiblaDirection = 0.0; // Degrees from North
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeQibla();
  }

  void _initializeQibla() {
    // Simulate loading and getting qibla direction
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _qiblaDirection = 292.5; // Example: Direction to Kaaba from Dhaka
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qibla Finder | কিবলা ফাইন্ডার',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF8F00),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF8F00),
              const Color(0xFFFF8F00).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Location info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Dhaka, Bangladesh',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Qibla direction info
                    Text(
                      'Direction to Kaaba | কাবা শরীফের দিক',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Compass section
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading) ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8F00)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Finding Qibla Direction...',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: const Color(0xFFFF8F00),
                          ),
                        ),
                      ] else ...[
                        // Compass
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer circle
                              Container(
                                width: 250,
                                height: 250,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFF8F00),
                                    width: 3,
                                  ),
                                ),
                              ),
                              
                              // Direction markers
                              ...List.generate(8, (index) {
                                final angle = index * 45.0;
                                final isNorth = index == 0;
                                final isQibla = (angle - _qiblaDirection).abs() < 22.5;
                                
                                return Transform.rotate(
                                  angle: angle * 3.14159 / 180,
                                  child: Container(
                                    width: 2,
                                    height: isNorth ? 30 : 15,
                                    color: isQibla 
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFFF8F00),
                                    margin: EdgeInsets.only(
                                      top: isNorth ? 10 : 20,
                                    ),
                                  ),
                                );
                              }),
                              
                              // Center Kaaba icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              
                              // Direction arrow
                              Transform.rotate(
                                angle: (_qiblaDirection - 90) * 3.14159 / 180,
                                child: Container(
                                  width: 4,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF2E7D32),
                                        const Color(0xFF2E7D32).withOpacity(0.5),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Direction text
                        Text(
                          '${_qiblaDirection.toStringAsFixed(1)}° from North',
                          style: GoogleFonts.notoSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'কিবলা দিক: উত্তর থেকে ${_qiblaDirection.toStringAsFixed(1)}°',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 14,
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Instructions
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFFFF8F00),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instructions | নির্দেশনা',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFF8F00),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      '1. Hold your phone flat and level\n'
                      '2. Point the arrow towards the direction shown\n'
                      '3. The green arrow points to the Kaaba in Mecca',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: const Color(0xFF666666),
                        height: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      '১. ফোনটি সমতল করে ধরে রাখুন\n'
                      '২. তীরটি দেখানো দিকে নির্দেশ করুন\n'
                      '৩. সবুজ তীর মক্কার কাবা শরীফের দিকে নির্দেশ করে',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 12,
                        color: const Color(0xFF999999),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
