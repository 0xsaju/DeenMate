import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive responsive design helper for DeenMate
/// Supports mobile, tablet, desktop, and web platforms with adaptive layouts
class ResponsiveHelper {
  // Breakpoints
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double desktopMinWidth = 1024;

  // Grid columns
  static const int mobileColumns = 1;
  static const int tabletColumns = 2;
  static const int desktopColumns = 3;

  /// Get current device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (kIsWeb) {
      if (width >= desktopMinWidth) return DeviceType.webDesktop;
      if (width >= mobileMaxWidth) return DeviceType.webTablet;
      return DeviceType.webMobile;
    }
    
    if (width >= desktopMinWidth) return DeviceType.desktop;
    if (width >= mobileMaxWidth) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  /// Check if current platform is mobile
  static bool isMobile(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.mobile || deviceType == DeviceType.webMobile;
  }

  /// Check if current platform is tablet
  static bool isTablet(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.tablet || deviceType == DeviceType.webTablet;
  }

  /// Check if current platform is desktop/web
  static bool isDesktop(BuildContext context) {
    final deviceType = getDeviceType(context);
    return deviceType == DeviceType.desktop || deviceType == DeviceType.webDesktop;
  }

  /// Check if running on web
  static bool isWeb() => kIsWeb;

  /// Get responsive grid column count
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return desktopColumns;
    if (isTablet(context)) return tabletColumns;
    return mobileColumns;
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile * 1.2;
    if (isTablet(context)) return tablet ?? mobile * 1.1;
    return mobile;
  }

  /// Get responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(context)) {
      return (screenWidth - 64) / 3 - 16; // 3 columns with spacing
    }
    if (isTablet(context)) {
      return (screenWidth - 48) / 2 - 12; // 2 columns with spacing
    }
    return screenWidth - 32; // Full width with padding
  }

  /// Get responsive max content width
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200;
    if (isTablet(context)) return 800;
    return double.infinity;
  }

  /// Get responsive app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isDesktop(context)) return 72;
    if (isTablet(context)) return 64;
    return 56;
  }

  /// Get responsive navigation rail width
  static double getNavigationRailWidth(BuildContext context) {
    if (isDesktop(context)) return 280;
    return 72;
  }

  /// Should use navigation rail instead of bottom navigation
  static bool shouldUseNavigationRail(BuildContext context) {
    return isTablet(context) || isDesktop(context);
  }

  /// Should use sidebar layout
  static bool shouldUseSidebarLayout(BuildContext context) {
    return isDesktop(context);
  }

  /// Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isDesktop(context)) {
      return (screenWidth * 0.4).clamp(400.0, 600.0);
    }
    if (isTablet(context)) {
      return (screenWidth * 0.6).clamp(300.0, 500.0);
    }
    return screenWidth - 32;
  }

  /// Get responsive sheet height
  static double getBottomSheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    if (isDesktop(context)) {
      return screenHeight * 0.6;
    }
    if (isTablet(context)) {
      return screenHeight * 0.7;
    }
    return screenHeight * 0.8;
  }

  /// Create responsive layout
  static Widget responsiveLayout({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Create responsive grid
  static Widget responsiveGrid({
    required BuildContext context,
    required List<Widget> children,
    double? spacing,
    double? runSpacing,
    double? childAspectRatio,
  }) {
    final columns = getGridColumns(context);
    final effectiveSpacing = spacing ?? 16.0;
    final effectiveRunSpacing = runSpacing ?? 16.0;
    final effectiveAspectRatio = childAspectRatio ?? 1.0;

    if (children.isEmpty) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: effectiveSpacing,
        mainAxisSpacing: effectiveRunSpacing,
        childAspectRatio: effectiveAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Create responsive wrap
  static Widget responsiveWrap({
    required BuildContext context,
    required List<Widget> children,
    double? spacing,
    double? runSpacing,
    WrapAlignment alignment = WrapAlignment.start,
  }) {
    final effectiveSpacing = spacing ?? 8.0;
    final effectiveRunSpacing = runSpacing ?? 8.0;

    return Wrap(
      spacing: effectiveSpacing,
      runSpacing: effectiveRunSpacing,
      alignment: alignment,
      children: children,
    );
  }

  /// Create responsive constrained box
  static Widget responsiveConstrainedBox({
    required BuildContext context,
    required Widget child,
    double? maxWidth,
  }) {
    final effectiveMaxWidth = maxWidth ?? getMaxContentWidth(context);
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
        child: child,
      ),
    );
  }

  /// Create responsive safe area
  static Widget responsiveSafeArea({
    required BuildContext context,
    required Widget child,
    bool enableForWeb = true,
  }) {
    if (isWeb() && !enableForWeb) return child;
    
    return SafeArea(child: child);
  }

  /// Get responsive list tile configuration
  static ListTileConfiguration getListTileConfiguration(BuildContext context) {
    if (isDesktop(context)) {
      return const ListTileConfiguration(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: 56,
        trailing: 48,
        dense: false,
      );
    }
    if (isTablet(context)) {
      return const ListTileConfiguration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: 48,
        trailing: 40,
        dense: false,
      );
    }
    return const ListTileConfiguration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: 40,
      trailing: 32,
      dense: true,
    );
  }

  /// Create adaptive app bar
  static PreferredSizeWidget adaptiveAppBar({
    required BuildContext context,
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
    double? elevation,
    bool? centerTitle,
  }) {
    final height = getAppBarHeight(context);
    final shouldCenter = centerTitle ?? !isDesktop(context);

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        elevation: elevation,
        centerTitle: shouldCenter,
        toolbarHeight: height,
      ),
    );
  }

  /// Create adaptive navigation
  static Widget adaptiveNavigation({
    required BuildContext context,
    required List<NavigationItem> items,
    required int currentIndex,
    required ValueChanged<int> onDestinationSelected,
    Widget? floatingActionButton,
  }) {
    if (shouldUseNavigationRail(context)) {
      return Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: isDesktop(context) 
              ? NavigationRailLabelType.all 
              : NavigationRailLabelType.selected,
            destinations: items.map((item) => NavigationRailDestination(
              icon: item.icon,
              selectedIcon: item.selectedIcon,
              label: Text(item.label),
            )).toList(),
            minWidth: getNavigationRailWidth(context),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(child: items[currentIndex].page),
                if (floatingActionButton != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: floatingActionButton,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: items[currentIndex].page,
      bottomNavigationBar: BottomNavigationBar(
        items: items.map((item) => BottomNavigationBarItem(
          icon: item.icon,
          activeIcon: item.selectedIcon,
          label: item.label,
        )).toList(),
        currentIndex: currentIndex,
        onTap: onDestinationSelected,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Create responsive card
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    double? elevation,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    final responsivePadding = padding ?? getResponsivePadding(context);
    final responsiveMargin = margin ?? getResponsiveMargin(context);
    final cardElevation = elevation ?? (isDesktop(context) ? 4.0 : 2.0);

    return Container(
      margin: responsiveMargin,
      child: Card(
        elevation: cardElevation,
        child: Padding(
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }

  /// Create responsive text
  static Widget responsiveText(
    String text, {
    required BuildContext context,
    TextStyle? style,
    double? mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final baseFontSize = mobileFontSize ?? style?.fontSize ?? 14;
    final responsiveFontSize = getResponsiveFontSize(
      context,
      mobile: baseFontSize,
      tablet: tabletFontSize,
      desktop: desktopFontSize,
    );

    final effectiveStyle = (style ?? const TextStyle()).copyWith(
      fontSize: responsiveFontSize,
    );

    return Text(
      text,
      style: effectiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Create responsive image
  static Widget responsiveImage({
    required BuildContext context,
    required ImageProvider image,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    final scaleFactor = isDesktop(context) ? 1.2 : isTablet(context) ? 1.1 : 1.0;
    
    return Image(
      image: image,
      width: width != null ? width * scaleFactor : null,
      height: height != null ? height * scaleFactor : null,
      fit: fit ?? BoxFit.cover,
    );
  }

  /// Get responsive button configuration
  static ButtonConfiguration getButtonConfiguration(BuildContext context) {
    if (isDesktop(context)) {
      return const ButtonConfiguration(
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: Size(120, 48),
        textStyle: TextStyle(fontSize: 16),
      );
    }
    if (isTablet(context)) {
      return const ButtonConfiguration(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: Size(100, 44),
        textStyle: TextStyle(fontSize: 15),
      );
    }
    return const ButtonConfiguration(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      minimumSize: Size(88, 40),
      textStyle: TextStyle(fontSize: 14),
    );
  }

  /// Handle web-specific keyboard shortcuts
  static Map<LogicalKeySet, Intent> getWebKeyboardShortcuts() {
    if (!isWeb()) return {};
    
    return {
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const SearchIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB): const BookmarksIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): const ReadingPlanIntent(),
      LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): const SettingsIntent(),
      LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousPageIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextPageIntent(),
      LogicalKeySet(LogicalKeyboardKey.space): const PlayPauseIntent(),
    };
  }

  /// Create responsive dialog
  static Widget responsiveDialog({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
  }) {
    final dialogWidth = getDialogWidth(context);
    
    if (isDesktop(context)) {
      return Dialog(
        child: Container(
          width: dialogWidth,
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              Flexible(child: child),
              if (actions != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: title != null ? Text(title) : null,
      content: child,
      actions: actions,
    );
  }
}

// Data classes and enums

enum DeviceType {
  mobile,
  tablet,
  desktop,
  webMobile,
  webTablet,
  webDesktop,
}

class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.page,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;
  final Widget page;
}

class ListTileConfiguration {
  const ListTileConfiguration({
    required this.contentPadding,
    required this.leading,
    required this.trailing,
    required this.dense,
  });

  final EdgeInsets contentPadding;
  final double leading;
  final double trailing;
  final bool dense;
}

class ButtonConfiguration {
  const ButtonConfiguration({
    required this.padding,
    required this.minimumSize,
    required this.textStyle,
  });

  final EdgeInsets padding;
  final Size minimumSize;
  final TextStyle textStyle;
}

// Intent classes for web keyboard shortcuts
class SearchIntent extends Intent {
  const SearchIntent();
}

class BookmarksIntent extends Intent {
  const BookmarksIntent();
}

class ReadingPlanIntent extends Intent {
  const ReadingPlanIntent();
}

class SettingsIntent extends Intent {
  const SettingsIntent();
}

class DismissIntent extends Intent {
  const DismissIntent();
}

class PreviousPageIntent extends Intent {
  const PreviousPageIntent();
}

class NextPageIntent extends Intent {
  const NextPageIntent();
}

class PlayPauseIntent extends Intent {
  const PlayPauseIntent();
}
