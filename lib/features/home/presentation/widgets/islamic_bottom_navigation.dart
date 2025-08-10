import 'package:flutter/material.dart';
import '../../../../core/theme/islamic_theme.dart';

/// Islamic bottom navigation bar matching the design
class IslamicBottomNavigation extends StatelessWidget {
  
  const IslamicBottomNavigation({
    required this.currentIndex, required this.onTap, super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, '🏠', 'Home', isActive: currentIndex == 0),
            _buildNavItem(1, '🕌', 'Prayer', isActive: currentIndex == 1),
            _buildNavItem(2, '🧮', 'Zakat', isActive: currentIndex == 2),
            _buildNavItem(3, '🧭', 'Qibla', isActive: currentIndex == 3),
            _buildNavItem(4, '⋯', 'More', isActive: currentIndex == 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label, {required bool isActive}) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 60,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? IslamicTheme.islamicGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 20,
                color: isActive ? IslamicTheme.islamicGreen : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? IslamicTheme.islamicGreen : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSelectedColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFE8F5E8); // Home - Islamic green
      case 1: return const Color(0xFFE3F2FD); // Prayer - Blue
      case 2: return const Color(0xFFE8F5E8); // Zakat - Islamic green
      case 3: return const Color(0xFFFFF3E0); // Qibla - Orange
      case 4: return const Color(0xFFEFEBE9); // More - Brown
      default: return const Color(0xFFE8F5E8);
    }
  }

  Color _getSelectedTextColor(int index) {
    switch (index) {
      case 0: return IslamicTheme.islamicGreen; // Home
      case 1: return IslamicTheme.prayerBlue; // Prayer
      case 2: return IslamicTheme.islamicGreen; // Zakat
      case 3: return IslamicTheme.hadithOrange; // Qibla
      case 4: return IslamicTheme.duaBrown; // More
      default: return IslamicTheme.islamicGreen;
    }
  }

  bool _shouldShowBengali() {
    // TODO: Get from app settings
    return true;
  }
}

/// Enhanced bottom navigation with more detailed design
class EnhancedBottomNavigation extends StatelessWidget {
  
  const EnhancedBottomNavigation({
    required this.currentIndex, required this.onTap, required this.items, super.key,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;
              
              return _buildEnhancedNavItem(
                index: index,
                item: item,
                isSelected: isSelected,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNavItem({
    required int index,
    required BottomNavItem item,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        decoration: BoxDecoration(
          color: isSelected ? item.selectedColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: SizedBox(
                width: 24,
                height: 24,
                child: item.iconBuilder(isSelected),
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: IslamicTheme.textTheme.labelSmall?.copyWith(
                color: isSelected ? item.selectedColor : IslamicTheme.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ) ?? const TextStyle(),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom navigation item model
class BottomNavItem {
  
  const BottomNavItem({
    required this.label,
    required this.iconBuilder,
    required this.selectedColor,
  });
  final String label;
  final Widget Function(bool isSelected) iconBuilder;
  final Color selectedColor;
}
