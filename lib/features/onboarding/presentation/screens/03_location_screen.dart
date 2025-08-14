import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../prayer_times/presentation/providers/prayer_times_providers.dart';

import '../../../../core/theme/islamic_theme.dart';
import '../widgets/islamic_decorative_elements.dart';
import '../widgets/islamic_gradient_background.dart';

/// Location selection screen for DeenMate onboarding
class LocationScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const LocationScreen({super.key, this.onNext, this.onPrevious});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  bool _isLoading = false;
  bool _locationPermissionGranted = false;
  String _selectedCity = 'Dhaka';
  String _selectedCountry = 'Bangladesh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IslamicGradientBackground(
        primaryColor: const Color(0xFFF0F4FF),
        secondaryColor: const Color(0xFFFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar area
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withOpacity(0.05),
                ),
              ),

              // Progress indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: OnboardingProgressIndicator(
                  currentStep: 3,
                  totalSteps: 8,
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Header icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: const Color(0xFF42A5F5).withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF42A5F5).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '📍',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      Text(
                        'Set Location for Salah Time',
                        style: IslamicTheme.textTheme.headlineSmall?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E2E2E),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Choose your country and city for',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      Text(
                        'accurate prayer time calculations',
                        style: IslamicTheme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Location options
                      Expanded(
                        child: ListView(
                          children: [
                            _buildLocationOption(
                              title: 'Use GPS Location',
                              subtitle: 'Automatically detect your location',
                              icon: '🛰️',
                              isSelected: _locationPermissionGranted,
                              onTap: _requestLocationPermission,
                            ),
                            const SizedBox(height: 16),
                            _buildLocationOption(
                              title: 'Manual Selection',
                              subtitle: 'Choose your city manually',
                              icon: '🏙️',
                              isSelected: !_locationPermissionGranted,
                              onTap: _showManualLocationDialog,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Continue button
                      _buildContinueButton(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationOption({
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE3F2FD).withOpacity(0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF1565C0) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
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
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1565C0).withOpacity(0.1)
                    : const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: IslamicTheme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : const Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: IslamicTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: const Color(0xFF666666),
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
                color:
                    isSelected ? const Color(0xFF1565C0) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1565C0)
                      : const Color(0xFFE0E0E0),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Request location permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDeniedDialog();
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationPermissionGranted = true;
        _isLoading = false;
      });

      // Persist preferred location for app usage
      try {
        final locService = ref.read(locationServiceProvider);
        final repo = ref.read(prayerTimesRepositoryProvider);
        final loc = await locService.getLocationFromCoordinates(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        await repo.savePreferredLocation(loc);
      } catch (_) {}
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to get location: $e');
    }
  }

  void _showManualLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Country dropdown
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                labelText: 'Country',
                border: OutlineInputBorder(),
              ),
              items: [
                'Bangladesh',
                'Pakistan',
                'Saudi Arabia',
                'Turkey',
                'Malaysia'
              ]
                  .map(
                    (country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // City dropdown
            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              items: _getCitiesForCountry(_selectedCountry)
                  .map(
                    (city) => DropdownMenuItem(
                      value: city,
                      child: Text(city),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value!;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _locationPermissionGranted = false;
                _isLoading = true;
              });
              try {
                final query = '$_selectedCity, $_selectedCountry';
                final locService = ref.read(locationServiceProvider);
                final repo = ref.read(prayerTimesRepositoryProvider);
                final results = await locService.searchLocations(query);
                if (results.isNotEmpty) {
                  await repo.savePreferredLocation(results.first);
                }
                if (mounted) Navigator.pop(context);
                widget.onNext?.call();
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  _showErrorDialog('Failed to set location: $e');
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  List<String> _getCitiesForCountry(String country) {
    switch (country) {
      case 'Bangladesh':
        return ['Dhaka', 'Chittagong', 'Sylhet', 'Rajshahi', 'Khulna'];
      case 'Pakistan':
        return ['Karachi', 'Lahore', 'Islamabad', 'Peshawar', 'Quetta'];
      case 'Saudi Arabia':
        return ['Mecca', 'Medina', 'Riyadh', 'Jeddah', 'Dammam'];
      case 'Turkey':
        return ['Istanbul', 'Ankara', 'Izmir', 'Bursa', 'Antalya'];
      case 'Malaysia':
        return ['Kuala Lumpur', 'Penang', 'Johor Bahru', 'Malacca', 'Ipoh'];
      default:
        return ['Dhaka'];
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Please enable location services in your device settings to use GPS location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Denied'),
        content: const Text(
          'Location permission is required for accurate prayer times. You can select your location manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading ? null : () => _navigateToNext(context),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isLoading
                ? [Colors.grey, Colors.grey.shade400]
                : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
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
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
        ),
      ),
    );
  }

  void _navigateToNext(BuildContext context) {
    // Navigate to next onboarding screen
    widget.onNext?.call();
  }
}
