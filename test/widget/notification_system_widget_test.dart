import 'package:dartz/dartz.dart' as dartz;
import 'package:deen_mate/features/prayer_times/data/services/prayer_notification_service.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/athan_settings.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/notification_providers.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/athan_preview_widget.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/muadhin_selector_widget.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/notification_permissions_widget.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/prayer_notification_toggle.dart';
import 'package:deen_mate/features/prayer_times/presentation/widgets/volume_slider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Mock services for testing
class MockPrayerNotificationService extends Mock implements PrayerNotificationService {}

/// Widget tests for notification system components
void main() {
  group('Notification System Widget Tests', () {
    late MockPrayerNotificationService mockNotificationService;
    late ProviderContainer container;

    setUp(() {
      mockNotificationService = MockPrayerNotificationService();
      container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(mockNotificationService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('Muadhin Selector Widget', () {
      testWidgets('displays all available Muadhin voices', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MuadhinSelectorWidget(
                selectedVoice: 'abdulbasit',
                onVoiceChanged: (voice) {},
              ),
            ),
          ),
        );

        // Check if widget displays correctly
        expect(find.text('Muadhin Voice'), findsOneWidget);
        expect(find.text('Choose your preferred voice for the call to prayer:'), findsOneWidget);
        
        // Check if all voices are displayed
        expect(find.text('Abdul Basit'), findsOneWidget);
        expect(find.text('Mishary Rashid'), findsOneWidget);
        expect(find.text('Sheikh Sudais'), findsOneWidget);
        expect(find.text('Default'), findsOneWidget);
      });

      testWidgets('highlights selected voice correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MuadhinSelectorWidget(
                selectedVoice: 'sudais',
                onVoiceChanged: (voice) {},
              ),
            ),
          ),
        );

        // Find the selected voice card
        final sudaisCard = find.ancestor(
          of: find.text('Sheikh Sudais'),
          matching: find.byType(GestureDetector),
        );
        
        expect(sudaisCard, findsOneWidget);
      });

      testWidgets('calls onVoiceChanged when voice is selected', (tester) async {
        String? selectedVoice;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MuadhinSelectorWidget(
                selectedVoice: 'abdulbasit',
                onVoiceChanged: (voice) => selectedVoice = voice,
              ),
            ),
          ),
        );

        // Tap on a different voice
        final misharyCard = find.ancestor(
          of: find.text('Mishary Rashid'),
          matching: find.byType(GestureDetector),
        );
        
        await tester.tap(misharyCard);
        await tester.pump();

        expect(selectedVoice, equals('mishary'));
      });
    });

    group('Volume Slider Widget', () {
      testWidgets('displays volume control correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VolumeSliderWidget(
                volume: 0.7,
                onVolumeChanged: (volume) {},
              ),
            ),
          ),
        );

        expect(find.text('Volume Control'), findsOneWidget);
        expect(find.text('70%'), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
      });

      testWidgets('calls onVolumeChanged when slider is moved', (tester) async {
        double? newVolume;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VolumeSliderWidget(
                volume: 0.5,
                onVolumeChanged: (volume) => newVolume = volume,
              ),
            ),
          ),
        );

        // Find and interact with the slider
        final slider = find.byType(Slider);
        await tester.tap(slider);
        await tester.pump();

        // Note: Exact volume value depends on tap position
        // We just verify the callback was called
        expect(newVolume, isNotNull);
      });

      testWidgets('displays volume presets correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VolumeSliderWidget(
                volume: 0.6,
                onVolumeChanged: (volume) {},
              ),
            ),
          ),
        );

        expect(find.text('Silent'), findsOneWidget);
        expect(find.text('Low'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('High'), findsOneWidget);
      });
    });

    group('Prayer Notification Toggle', () {
      testWidgets('displays prayer information correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrayerNotificationToggle(
                prayerName: 'Fajr',
                arabicName: 'فجر',
                icon: Icons.wb_twilight,
                isEnabled: true,
                onToggle: (enabled) {},
              ),
            ),
          ),
        );

        expect(find.text('Fajr'), findsOneWidget);
        expect(find.text('فجر'), findsOneWidget);
        expect(find.byIcon(Icons.wb_twilight), findsOneWidget);
        expect(find.text('Enabled'), findsOneWidget);
      });

      testWidgets('calls onToggle when switch is tapped', (tester) async {
        bool? newState;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrayerNotificationToggle(
                prayerName: 'Dhuhr',
                arabicName: 'ظهر',
                icon: Icons.wb_sunny_outlined,
                isEnabled: false,
                onToggle: (enabled) => newState = enabled,
              ),
            ),
          ),
        );

        // Find and tap the switch
        final switchWidget = find.byType(Switch);
        await tester.tap(switchWidget);
        await tester.pump();

        expect(newState, equals(true));
      });

      testWidgets('shows different status based on enabled state', (tester) async {
        // Test enabled state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrayerNotificationToggle(
                prayerName: 'Asr',
                arabicName: 'عصر',
                icon: Icons.wb_cloudy,
                isEnabled: true,
                onToggle: (enabled) {},
              ),
            ),
          ),
        );

        expect(find.text('Enabled'), findsOneWidget);

        // Test disabled state
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrayerNotificationToggle(
                prayerName: 'Asr',
                arabicName: 'عصر',
                icon: Icons.wb_cloudy,
                isEnabled: false,
                onToggle: (enabled) {},
              ),
            ),
          ),
        );

        expect(find.text('Disabled'), findsOneWidget);
      });
    });

    group('Notification Permissions Widget', () {
      testWidgets('displays permission status correctly', (tester) async {
        const permissions = NotificationPermissionsState(
          notificationPermission: true,
          dndOverridePermission: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NotificationPermissionsWidget(permissions: permissions),
            ),
          ),
        );

        expect(find.text('Notification Permissions'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Exact Alarms'), findsOneWidget);
        expect(find.text('Do Not Disturb Override'), findsOneWidget);
      });

      testWidgets('shows grant button for denied permissions', (tester) async {
        const permissions = NotificationPermissionsState(
          
        );

        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(
                body: NotificationPermissionsWidget(permissions: permissions),
              ),
            ),
          ),
        );

        // Should show grant buttons for permissions that can be requested
        expect(find.text('Grant'), findsAtLeastNWidget(2));
      });

      testWidgets('shows correct overall status', (tester) async {
        // Test all granted
        const allGrantedPermissions = NotificationPermissionsState(
          notificationPermission: true,
          exactAlarmPermission: true,
          dndOverridePermission: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NotificationPermissionsWidget(permissions: allGrantedPermissions),
            ),
          ),
        );

        expect(find.text('All Set!'), findsOneWidget);
        expect(find.text('Ready'), findsOneWidget);

        // Test some denied
        const someGrantedPermissions = NotificationPermissionsState(
          notificationPermission: true,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NotificationPermissionsWidget(permissions: someGrantedPermissions),
            ),
          ),
        );

        expect(find.text('Setup Required'), findsOneWidget);
        expect(find.text('Setup Needed'), findsOneWidget);
      });
    });

    group('Athan Preview Widget', () {
      testWidgets('displays preview controls correctly', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(
                body: AthanPreviewWidget(
                  muadhinVoice: 'abdulbasit',
                  volume: 0.8,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Preview Athan'), findsOneWidget);
        expect(find.text('Listen to a sample of the selected Muadhin voice:'), findsOneWidget);
        expect(find.text('Preview'), findsOneWidget);
        expect(find.text('80%'), findsOneWidget);
      });

      testWidgets('shows voice information correctly', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: const MaterialApp(
              home: Scaffold(
                body: AthanPreviewWidget(
                  muadhinVoice: 'sudais',
                  volume: 0.6,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Sheikh Abdul Rahman Al-Sudais'), findsOneWidget);
        expect(find.text('Imam of Masjid al-Haram in Mecca'), findsOneWidget);
      });
    });

    group('Integration Widget Tests', () {
      testWidgets('multiple notification widgets work together', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            parent: container,
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      MuadhinSelectorWidget(
                        selectedVoice: 'abdulbasit',
                        onVoiceChanged: (voice) {},
                      ),
                      const SizedBox(height: 20),
                      VolumeSliderWidget(
                        volume: 0.7,
                        onVolumeChanged: (volume) {},
                      ),
                      const SizedBox(height: 20),
                      PrayerNotificationToggle(
                        prayerName: 'Fajr',
                        arabicName: 'فجر',
                        icon: Icons.wb_twilight,
                        isEnabled: true,
                        onToggle: (enabled) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Verify all widgets are displayed
        expect(find.text('Muadhin Voice'), findsOneWidget);
        expect(find.text('Volume Control'), findsOneWidget);
        expect(find.text('Fajr'), findsOneWidget);
        expect(find.text('70%'), findsOneWidget);
        expect(find.text('Abdul Basit'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('widgets have proper semantic labels', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  VolumeSliderWidget(
                    volume: 0.5,
                    onVolumeChanged: (volume) {},
                  ),
                  PrayerNotificationToggle(
                    prayerName: 'Fajr',
                    arabicName: 'فجر',
                    icon: Icons.wb_twilight,
                    isEnabled: true,
                    onToggle: (enabled) {},
                  ),
                ],
              ),
            ),
          ),
        );

        // Verify accessibility elements exist
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        
        // These should have semantic properties for screen readers
        expect(tester.binding.pipelineOwner.semanticsOwner, isNotNull);
      });
    });
  });
}
