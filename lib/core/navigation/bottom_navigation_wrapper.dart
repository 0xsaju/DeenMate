import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';

/// Bottom Navigation Wrapper for DeenMate
/// Provides Islamic-themed bottom navigation without breaking existing routing
class BottomNavigationWrapper extends StatefulWidget {

  const BottomNavigationWrapper({
    required this.child, required this.currentLocation, super.key,
  });
  final Widget child;
  final String currentLocation;

  @override
  State<BottomNavigationWrapper> createState() => _BottomNavigationWrapperState();
}

class _BottomNavigationWrapperState extends State<BottomNavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _shouldShowBottomNav() ? _buildBottomNavigation() : null,
    );
  }

  bool _shouldShowBottomNav() {
    // Don't show bottom nav on certain screens
    final hideOnRoutes = [
      AppRouter.athanSettings,
      AppRouter.calculationMethod,
    ];
    
    return !hideOnRoutes.contains(widget.currentLocation);
  }

  Widget _buildBottomNavigation() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: NavigationBar(
          selectedIndex: _getSelectedIndex(),
          onDestinationSelected: _onDestinationSelected,
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.access_time_outlined),
              selectedIcon: Icon(
                Icons.access_time,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: 'Prayer',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calculate_outlined),
              selectedIcon: Icon(
                Icons.calculate,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: 'Zakat',
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: Icon(
                Icons.explore,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: 'Qibla',
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon: Icon(
                Icons.menu,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex() {
    switch (widget.currentLocation) {
      case AppRouter.home:
        return 0;
      case AppRouter.prayerTimes:
        return 1;
      case AppRouter.zakatCalculator:
        return 2;
      case AppRouter.qiblaFinder:
        return 3;
      default:
        // Settings, profile, etc. go to "More" tab
        if (_isMoreTabRoute(widget.currentLocation)) {
          return 4;
        }
        return 0; // Default to home
    }
  }

  bool _isMoreTabRoute(String location) {
    final moreTabRoutes = [
      AppRouter.settings,
      AppRouter.profile,
      AppRouter.history,
      AppRouter.reports,
      AppRouter.sawmTracker,
      AppRouter.islamicWill,
    ];
    return moreTabRoutes.contains(location);
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppRouter.home);
        break;
      case 1:
        context.go(AppRouter.prayerTimes);
        break;
      case 2:
        context.go(AppRouter.zakatCalculator);
        break;
      case 3:
        context.go(AppRouter.qiblaFinder);
        break;
      case 4:
        // Navigate to the "More" screen
        context.go('/more');
        break;
    }
  }
}
