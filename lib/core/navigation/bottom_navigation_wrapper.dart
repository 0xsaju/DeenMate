import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_router.dart';
import '../theme/app_theme.dart';
import '../localization/strings.dart';
import '../../features/home/presentation/widgets/islamic_bottom_navigation.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bottom Navigation Wrapper for DeenMate
/// Provides Islamic-themed bottom navigation without breaking existing routing
class BottomNavigationWrapper extends StatefulWidget {
  const BottomNavigationWrapper({
    required this.child,
    required this.currentLocation,
    super.key,
  });
  final Widget child;
  final String currentLocation;

  @override
  State<BottomNavigationWrapper> createState() =>
      _BottomNavigationWrapperState();
}

class _BottomNavigationWrapperState extends State<BottomNavigationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar:
          _shouldShowBottomNav() ? _buildBottomNavigation() : null,
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
    // Custom bottom nav to match the reference exactly (UI only)
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 10),
        child: EnhancedBottomNavigation(
          currentIndex: _getSelectedIndex(),
          onTap: _onDestinationSelected,
          items: [
            BottomNavItem(
              label: S.t(context, 'home', 'Home'),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              iconBuilder: (selected) => SvgPicture.asset(
                'assets/images/icons/home_app_logo.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  selected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : const Color(0xFF5D4037),
                  BlendMode.srcIn,
                ),
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'quran', 'Quran'),
              selectedColor: const Color(0xFF5D4037),
              iconBuilder: (selected) => Icon(
                selected
                    ? Icons.auto_stories_rounded
                    : Icons.auto_stories_outlined,
                size: 26,
                color: const Color(0xFF5D4037),
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'hadith', 'Hadith'),
              selectedColor: const Color(0xFF5D4037),
              iconBuilder: (selected) => Icon(
                selected ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                size: 26,
                color: const Color(0xFF5D4037),
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'more', 'More'),
              selectedColor: AppTheme.lightTheme.colorScheme.primary,
              iconBuilder: (selected) => Icon(
                Icons.more_horiz,
                size: 26,
                color: selected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : const Color(0xFF5D4037),
              ),
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
      case AppRouter.qiblaFinder:
        return 2;
      default:
        // Settings, profile, etc. go to "More" tab
        if (_isMoreTabRoute(widget.currentLocation)) {
          return 3;
        }
        return 0; // Default to home
    }
  }

  bool _isMoreTabRoute(String location) {
    final moreTabRoutes = [
      '/more',
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
        context.go(AppRouter.qiblaFinder);
        break;
      case 3:
        // Navigate to the "More" screen
        context.go('/more');
        break;
    }
  }
}
