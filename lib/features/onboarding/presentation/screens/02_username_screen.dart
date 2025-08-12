import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Username input screen for the onboarding flow
class UsernameScreen extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const UsernameScreen({super.key, this.onNext, this.onPrevious});

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _validateUsername() {
    setState(() {
      _isValid = _usernameController.text.trim().length >= 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom - 48,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  
                  // Decorative elements
                  IslamicDecorativeElements.buildGeometricPattern(
                    size: 60,
                    color: const Color(0xFF4CAF50),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Title
                  Text(
                    'What should we call you?',
                    style: GoogleFonts.notoSans(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E2E2E),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    'Enter your name to personalize your experience',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: const Color(0xFF666666),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Username input field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.notoSans(
                          color: Colors.grey[400],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.grey[400],
                        ),
                      ),
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: const Color(0xFF2E2E2E),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Validation message
                  if (_usernameController.text.isNotEmpty && !_isValid)
                    Text(
                      'Name must be at least 2 characters long',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: Colors.red[600],
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // Continue button
                  if (widget.onNext != null)
                    Column(
                      children: [
                        _buildContinueButton(),
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
                  
                  const SizedBox(height: 20),
                  
                  // Bottom decoration
                  _buildBottomDecoration(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: _isValid ? widget.onNext : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isValid 
                ? const [Color(0xFF2E7D32), Color(0xFF4CAF50)]
                : [Colors.grey[400]!, Colors.grey[500]!],
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
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDecoration() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF4CAF50).withOpacity(0.1),
          ],
        ),
      ),
      child: Center(
        child: IslamicDecorativeElements.buildGeometricPattern(
          size: 40,
          color: const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
    );
  }
}
