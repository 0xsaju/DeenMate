import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar:
            _shouldShowBottomNav() ? _buildBottomNavigation() : null,
      ),
    );
  }

  bool _shouldShowBottomNav() {
    // Don't show bottom nav on certain screens
    final hideOnRoutes = [
      '/athan-settings',
      '/calculation-method',
    ];

    return !hideOnRoutes.contains(widget.currentLocation);
  }

  Widget _buildBottomNavigation() {
    final theme = Theme.of(context);
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
              selectedColor: theme.colorScheme.primary,
              iconBuilder: (selected) => SvgPicture.asset(
                'assets/images/icons/home_app_logo.svg',
                width: 26,
                height: 26,
                colorFilter: ColorFilter.mode(
                  selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  BlendMode.srcIn,
                ),
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'quran', 'Quran'),
              selectedColor: theme.colorScheme.primary,
              iconBuilder: (selected) => Icon(
                selected
                    ? Icons.auto_stories_rounded
                    : Icons.auto_stories_outlined,
                size: 26,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'hadith', 'Hadith'),
              selectedColor: theme.colorScheme.primary,
              iconBuilder: (selected) => Icon(
                selected ? Icons.menu_book_rounded : Icons.menu_book_outlined,
                size: 26,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            BottomNavItem(
              label: S.t(context, 'more', 'More'),
              selectedColor: theme.colorScheme.primary,
              iconBuilder: (selected) => Icon(
                Icons.more_horiz,
                size: 26,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getSelectedIndex() {
    switch (widget.currentLocation) {
      case '/':
        return 0;
      case '/islamic-content':
        return 1;
      case '/quran':
        return 1;
      case '/prayer-times':
        // Treat prayer-times as Home for selection since it renders HomeScreen
        return 0;
      case '/qibla-finder':
        return 2;
      default:
        // Settings, profile, etc. go to "More" tab
        if (_isMoreTabRoute(widget.currentLocation)) {
          return 3;
        }
        // If any nested Quran route
        if (widget.currentLocation.startsWith('/quran')) {
          return 1;
        }
        // If any nested Hadith route
        if (widget.currentLocation.startsWith('/hadith')) {
          return 2;
        }
        return 0; // Default to home
    }
  }

  bool _isMoreTabRoute(String location) {
    final moreTabRoutes = [
      '/more',
      '/settings',
      '/profile',
      '/history',
      '/reports',
      '/sawm-tracker',
      '/islamic-will',
    ];
    return moreTabRoutes.contains(location);
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/quran');
        break;
      case 2:
        // Navigate to Hadith/Islamic content
        context.go('/islamic-content');
        break;
      case 3:
        // Navigate to the "More" screen
        context.go('/more');
        break;
    }
  }

  Future<bool> _onWillPop() async {
    try {
      final go = GoRouter.of(context);
      
      // Check if we can safely pop
      if (go.canPop()) {
        go.pop();
        return false;
      }

      // If not on Home tab, navigate to Home instead of exiting
      final isOnHome = widget.currentLocation == '/' ||
          widget.currentLocation == '/prayer-times';
      if (!isOnHome) {
        context.go('/');
        return false;
      }

      // We are on Home and cannot pop -> confirm exit
      if (!mounted) return true;
      
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit DeenMate'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: [
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    } catch (e) {
      // If there's any navigation error, allow the app to exit safely
      return true;
    }
  }
}
