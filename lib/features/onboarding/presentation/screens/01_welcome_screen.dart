import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Welcome screen for the onboarding flow
/// Displays Islamic greeting and app introduction
class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const WelcomeScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decorative elements
                    IslamicDecorativeElements.buildGeometricPattern(
                      size: 120,
                      color: const Color(0xFF4CAF50),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Arabic greeting
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'السلام عليكم ورحمة الله وبركاته',
                        style: GoogleFonts.amiri(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B4513),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // English welcome message
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Welcome to your new\nspiritual companion',
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF4A4A4A),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Bottom decoration
                    _buildBottomDecoration(),
                  ],
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    _buildContinueButton(context),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to continue',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: const Color(0xFF8B4513).withOpacity(0.7),
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

  Widget _buildDecorativeDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 1,
          color: const Color(0xFFC19A6B).withOpacity(0.4),
        ),
        const SizedBox(width: 16),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF8B4513).withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 50,
          height: 1,
          color: const Color(0xFFC19A6B).withOpacity(0.4),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: () => onNext?.call(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDecoration() {
    return Column(
      children: [
        // Curved line
        CustomPaint(
          size: const Size(100, 20),
          painter: CurvedLinePainter(),
        ),
        const SizedBox(height: 8),
        // Decorative dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecorativeDot(const Color(0xFFC19A6B)),
            const SizedBox(width: 20),
            _buildDecorativeDot(const Color(0xFF2E7D32), size: 6),
            const SizedBox(width: 20),
            _buildDecorativeDot(const Color(0xFFC19A6B)),
          ],
        ),
      ],
    );
  }

  Widget _buildDecorativeDot(Color color, {double size = 4}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Custom painter for curved line decoration
class CurvedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4B996).withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 4,
      size.height / 2 - 10,
      size.width / 2,
      size.height / 2,
    );
    path.quadraticBezierTo(
      size.width * 3 / 4,
      size.height / 2 + 10,
      size.width,
      size.height / 2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
