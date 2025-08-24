import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'responsive_helper.dart' hide DismissIntent;
import '../theme/theme_helper.dart';

/// Web-optimized app wrapper with responsive design and keyboard shortcuts
class WebAppWrapper extends ConsumerWidget {
  const WebAppWrapper({
    super.key,
    required this.child,
    this.enableKeyboardShortcuts = true,
    this.showUrlInTitle = true,
  });

  final Widget child;
  final bool enableKeyboardShortcuts;
  final bool showUrlInTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ResponsiveHelper.isWeb()) {
      return child;
    }

    Widget wrappedChild = child;

    // Add keyboard shortcuts for web
    if (enableKeyboardShortcuts) {
      wrappedChild = _buildKeyboardShortcuts(context, wrappedChild);
    }

    // Add responsive constraints for web
    wrappedChild = _buildResponsiveWrapper(context, wrappedChild);

    // Add web-specific features
    wrappedChild = _buildWebFeatures(context, wrappedChild);

    return wrappedChild;
  }

  Widget _buildKeyboardShortcuts(BuildContext context, Widget child) {
    return Shortcuts(
      shortcuts: ResponsiveHelper.getWebKeyboardShortcuts(),
      child: Actions(
        actions: {
          SearchIntent: CallbackAction<SearchIntent>(
            onInvoke: (intent) => _handleSearchShortcut(context),
          ),
          BookmarksIntent: CallbackAction<BookmarksIntent>(
            onInvoke: (intent) => _handleBookmarksShortcut(context),
          ),
          ReadingPlanIntent: CallbackAction<ReadingPlanIntent>(
            onInvoke: (intent) => _handleReadingPlanShortcut(context),
          ),
          SettingsIntent: CallbackAction<SettingsIntent>(
            onInvoke: (intent) => _handleSettingsShortcut(context),
          ),
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (intent) => _handleDismissShortcut(context),
          ),
          PreviousPageIntent: CallbackAction<PreviousPageIntent>(
            onInvoke: (intent) => _handlePreviousPageShortcut(context),
          ),
          NextPageIntent: CallbackAction<NextPageIntent>(
            onInvoke: (intent) => _handleNextPageShortcut(context),
          ),
          PlayPauseIntent: CallbackAction<PlayPauseIntent>(
            onInvoke: (intent) => _handlePlayPauseShortcut(context),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  Widget _buildResponsiveWrapper(BuildContext context, Widget child) {
    return ResponsiveHelper.responsiveConstrainedBox(
      context: context,
      child: child,
      maxWidth: ResponsiveHelper.getMaxContentWidth(context),
    );
  }

  Widget _buildWebFeatures(BuildContext context, Widget child) {
    return Scaffold(
      body: Column(
        children: [
          // Web-specific header (optional)
          if (ResponsiveHelper.isDesktop(context) && showUrlInTitle)
            _buildWebHeader(context),
          
          // Main content
          Expanded(child: child),
          
          // Web-specific footer (optional)
          if (ResponsiveHelper.isDesktop(context))
            _buildWebFooter(context),
        ],
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // App logo/title
          Text(
            'DeenMate - Quran App',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ThemeHelper.getTextPrimaryColor(context),
            ),
          ),
          
          const Spacer(),
          
          // Keyboard shortcuts hint
          _buildKeyboardShortcutsHint(context),
        ],
      ),
    );
  }

  Widget _buildKeyboardShortcutsHint(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.keyboard,
        size: 20,
        color: ThemeHelper.getTextSecondaryColor(context),
      ),
      tooltip: 'Keyboard Shortcuts',
      itemBuilder: (context) => [
        const PopupMenuItem(
          enabled: false,
          child: Text(
            'Keyboard Shortcuts',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Ctrl + F'),
              Spacer(),
              Text('Search'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Ctrl + B'),
              Spacer(),
              Text('Bookmarks'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Ctrl + R'),
              Spacer(),
              Text('Reading Plans'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Ctrl + S'),
              Spacer(),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Space'),
              Spacer(),
              Text('Play/Pause'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('← →'),
              Spacer(),
              Text('Navigate'),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          child: Row(
            children: [
              Text('Esc'),
              Spacer(),
              Text('Dismiss'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWebFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeHelper.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: ThemeHelper.getDividerColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '© 2024 DeenMate. Made with ❤️ for the Ummah.',
            style: TextStyle(
              fontSize: 12,
              color: ThemeHelper.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    );
  }

  // Keyboard shortcut handlers

  void _handleSearchShortcut(BuildContext context) {
    // Navigate to search screen or open search dialog
    showSearch(
      context: context,
      delegate: QuranSearchDelegate(),
    );
  }

  void _handleBookmarksShortcut(BuildContext context) {
    // Navigate to bookmarks screen
    Navigator.of(context).pushNamed('/bookmarks');
  }

  void _handleReadingPlanShortcut(BuildContext context) {
    // Navigate to reading plans screen
    Navigator.of(context).pushNamed('/reading-plans');
  }

  void _handleSettingsShortcut(BuildContext context) {
    // Navigate to settings screen
    Navigator.of(context).pushNamed('/settings');
  }

  void _handleDismissShortcut(BuildContext context) {
    // Close current dialog or go back
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _handlePreviousPageShortcut(BuildContext context) {
    // Handle previous page navigation (context-dependent)
    _triggerPageNavigation(context, -1);
  }

  void _handleNextPageShortcut(BuildContext context) {
    // Handle next page navigation (context-dependent)
    _triggerPageNavigation(context, 1);
  }

  void _handlePlayPauseShortcut(BuildContext context) {
    // Handle audio play/pause (if audio is available)
    _triggerAudioControl(context);
  }

  void _triggerPageNavigation(BuildContext context, int direction) {
    // This would need to be implemented based on current screen context
    // For now, just show a message
    if (kDebugMode) {
      print('Page navigation: ${direction > 0 ? 'Next' : 'Previous'}');
    }
  }

  void _triggerAudioControl(BuildContext context) {
    // This would need to be implemented based on current audio state
    // For now, just show a message
    if (kDebugMode) {
      print('Audio control: Play/Pause');
    }
  }
}

/// Search delegate for web keyboard shortcut
class QuranSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Implement search results
    return Center(
      child: Text('Search results for "$query"'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Implement search suggestions
    return Center(
      child: Text('Search suggestions for "$query"'),
    );
  }
}

/// Web-optimized responsive scaffold
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveLayout(
      context: context,
      mobile: _buildMobileScaffold(context),
      tablet: _buildTabletScaffold(context),
      desktop: _buildDesktopScaffold(context),
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ResponsiveHelper.responsiveSafeArea(
        context: context,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildTabletScaffold(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          if (drawer != null)
            SizedBox(
              width: 280,
              child: drawer!,
            ),
          Expanded(
            child: ResponsiveHelper.responsiveSafeArea(
              context: context,
              child: body,
            ),
          ),
          if (endDrawer != null)
            SizedBox(
              width: 280,
              child: endDrawer!,
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: ResponsiveHelper.responsiveConstrainedBox(
        context: context,
        child: Column(
          children: [
            if (appBar != null) appBar!,
            Expanded(
              child: Row(
                children: [
                  if (drawer != null)
                    SizedBox(
                      width: 320,
                      child: Material(
                        elevation: 1,
                        child: drawer!,
                      ),
                    ),
                  Expanded(
                    child: ResponsiveHelper.responsiveSafeArea(
                      context: context,
                      child: body,
                      enableForWeb: false,
                    ),
                  ),
                  if (endDrawer != null)
                    SizedBox(
                      width: 320,
                      child: Material(
                        elevation: 1,
                        child: endDrawer!,
                      ),
                    ),
                ],
              ),
            ),
            if (bottomNavigationBar != null) bottomNavigationBar!,
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Responsive container for content areas
class ResponsiveContentArea extends StatelessWidget {
  const ResponsiveContentArea({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveConstrainedBox(
      context: context,
      maxWidth: maxWidth,
      child: Container(
        padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
        margin: margin ?? ResponsiveHelper.getResponsiveMargin(context),
        child: child,
      ),
    );
  }
}

/// Responsive grid for content
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
    this.shrinkWrap = true,
    this.physics,
  });

  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.responsiveGrid(
      context: context,
      children: children,
      spacing: spacing,
      runSpacing: runSpacing,
      childAspectRatio: childAspectRatio,
    );
  }
}
