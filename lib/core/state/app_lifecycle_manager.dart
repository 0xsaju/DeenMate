import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/prayer_times/presentation/providers/prayer_times_providers.dart';

/// Manages app lifecycle events and triggers data synchronization
/// when the app is minimized and then maximized again
class AppLifecycleManager extends ConsumerStatefulWidget {
  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppLifecycleManager> createState() =>
      _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends ConsumerState<AppLifecycleManager>
    with WidgetsBindingObserver {
  AppLifecycleState? _lastAppState;
  DateTime? _lastMinimizeTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    print(
        'AppLifecycleManager: App state changed from $_lastAppState to $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // App is being minimized/backgrounded
        _handleAppMinimize();
        break;

      case AppLifecycleState.resumed:
        // App is being maximized/foregrounded
        _handleAppMaximize();
        break;

      case AppLifecycleState.detached:
        // App is being terminated
        _handleAppDetach();
        break;
    }

    _lastAppState = state;
  }

  void _handleAppMinimize() {
    _lastMinimizeTime = DateTime.now();
    print('AppLifecycleManager: App minimized at $_lastMinimizeTime');
  }

  void _handleAppMaximize() async {
    final now = DateTime.now();
    final timeSinceMinimize = _lastMinimizeTime != null
        ? now.difference(_lastMinimizeTime!).inMinutes
        : 0;

    print(
        'AppLifecycleManager: App maximized. Time since minimize: ${timeSinceMinimize} minutes');

    // Always sync when app becomes active, but with different strategies based on time
    await _syncAppData(timeSinceMinimize);
  }

  void _handleAppDetach() {
    print('AppLifecycleManager: App detached');
    // Clean up any resources if needed
  }

  Future<void> _syncAppData(int minutesSinceMinimize) async {
    try {
      // Check network connectivity
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasNetwork = connectivityResults.any((result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet);

      print('AppLifecycleManager: Network available: $hasNetwork');

      // Always ensure live providers are updated for real-time prayer time switching
      ref.invalidate(currentAndNextPrayerLiveProvider);
      ref.invalidate(timeTickerProvider);

      if (hasNetwork) {
        // Refresh prayer times on minimize/maximize for accurate data
        print('AppLifecycleManager: Refreshing prayer times from API');

        try {
          // Force fresh API call
          ref.invalidate(currentPrayerTimesProvider);
          ref.invalidate(currentAndNextPrayerProvider);
          ref.invalidate(cachedCurrentPrayerTimesProvider);

          // Wait for the refresh to complete
          await ref.read(currentPrayerTimesProvider.future);
          print(
              'AppLifecycleManager: Successfully refreshed prayer times from API');
        } catch (e) {
          print('AppLifecycleManager: Error refreshing prayer times: $e');
          // Fallback: just update timestamp
          try {
            await ref.read(updateLastUpdatedProvider.future);
            print(
                'AppLifecycleManager: Updated last updated timestamp as fallback');
          } catch (e2) {
            print('AppLifecycleManager: Error updating timestamp: $e2');
          }
        }
      } else {
        print('AppLifecycleManager: No network available, using cached data');
      }
    } catch (e) {
      print('AppLifecycleManager: Error syncing app data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
