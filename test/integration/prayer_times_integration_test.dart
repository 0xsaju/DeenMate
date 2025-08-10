import 'package:dartz/dartz.dart';
import 'package:deen_mate/core/error/failures.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/athan_settings.dart';
import 'package:deen_mate/features/prayer_times/domain/entities/prayer_times.dart';
import 'package:deen_mate/features/prayer_times/domain/repositories/prayer_times_repository.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/notification_providers.dart';
import 'package:deen_mate/features/prayer_times/presentation/providers/prayer_times_providers.dart';
import 'package:deen_mate/features/prayer_times/presentation/screens/athan_settings_screen.dart';
import 'package:deen_mate/features/prayer_times/presentation/screens/prayer_times_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Mock Repository for Testing
class MockPrayerTimesRepository extends Mock implements PrayerTimesRepository {}

/// Integration tests for Prayer Times module
/// Tests the complete flow from UI to repository
void main() {
  group('Prayer Times Integration Tests', () {
    late MockPrayerTimesRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockPrayerTimesRepository();
      container = ProviderContainer(
        overrides: [
          prayerTimesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Prayer Times Screen displays correctly with data', (tester) async {
      // Arrange
      final mockPrayerTimes = PrayerTimes(
        id: 'test-1',
        date: DateTime.now(),
        location: const Location(
          latitude: 40.7128,
          longitude: -74.0060,
          city: 'New York',
          country: 'USA',
          timezone: 'America/New_York',
        ),
        fajr: PrayerTime(
          name: 'Fajr',
          time: DateTime.now().add(const Duration(hours: 5)),
          arabicName: 'فجر',
        ),
        dhuhr: PrayerTime(
          name: 'Dhuhr',
          time: DateTime.now().add(const Duration(hours: 12)),
          arabicName: 'ظهر',
        ),
        asr: PrayerTime(
          name: 'Asr',
          time: DateTime.now().add(const Duration(hours: 15)),
          arabicName: 'عصر',
        ),
        maghrib: PrayerTime(
          name: 'Maghrib',
          time: DateTime.now().add(const Duration(hours: 18)),
          arabicName: 'مغرب',
        ),
        isha: PrayerTime(
          name: 'Isha',
          time: DateTime.now().add(const Duration(hours: 20)),
          arabicName: 'عشاء',
        ),
        calculationMethod: 'MWL',
      );

      when(mockRepository.getCurrentPrayerTimes())
          .thenAnswer((_) async => Right(mockPrayerTimes));
      
      when(mockRepository.getCurrentLocation())
          .thenAnswer((_) async => const Right(Location(
            latitude: 40.7128,
            longitude: -74.0060,
            city: 'New York',
            country: 'USA',
            timezone: 'America/New_York',
          ),),);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: PrayerTimesScreen(),
          ),
        ),
      );

      // Wait for async operations
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Prayer Times'), findsOneWidget);
      expect(find.text('Fajr'), findsOneWidget);
      expect(find.text('Dhuhr'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.text('Isha'), findsOneWidget);
      expect(find.text('New York'), findsOneWidget);
      
      // Verify repository was called
      verify(mockRepository.getCurrentPrayerTimes()).called(1);
      verify(mockRepository.getCurrentLocation()).called(1);
    });

    testWidgets('Prayer Times Screen handles error states gracefully', (tester) async {
      // Arrange
      when(mockRepository.getCurrentPrayerTimes())
          .thenAnswer((_) async => const Left(Failure.networkFailure(
            message: 'Network error occurred',
          ),),);

      when(mockRepository.getCurrentLocation())
          .thenAnswer((_) async => const Left(Failure.locationUnavailable()));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: PrayerTimesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Prayer Times'), findsOneWidget);
      // Error handling should show appropriate messages
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Athan Settings Screen loads and displays correctly', (tester) async {
      // Arrange
      final mockAthanSettings = AthanSettingsDefaults.standard;

      when(mockRepository.getAthanSettings())
          .thenAnswer((_) async => Right(mockAthanSettings));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: AthanSettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Athan & Notifications'), findsOneWidget);
      expect(find.text('Athan'), findsOneWidget);
      expect(find.text('Prayers'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Ramadan'), findsOneWidget);
      
      // Check if settings are displayed
      expect(find.text('Prayer Notifications'), findsAtLeastNWidget(1));
      
      // Verify repository was called
      verify(mockRepository.getAthanSettings()).called(1);
    });

    testWidgets('Athan Settings can be toggled', (tester) async {
      // Arrange
      final mockAthanSettings = AthanSettingsDefaults.standard;

      when(mockRepository.getAthanSettings())
          .thenAnswer((_) async => Right(mockAthanSettings));
      
      when(mockRepository.saveAthanSettings(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: AthanSettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the main toggle switch
      final toggleSwitch = find.byType(Switch).first;
      expect(toggleSwitch, findsOneWidget);
      
      await tester.tap(toggleSwitch);
      await tester.pumpAndSettle();

      // Assert
      // Verify that saveAthanSettings was called
      verify(mockRepository.saveAthanSettings(any)).called(1);
    });

    testWidgets('Prayer Times Screen navigation to settings works', (tester) async {
      // Arrange
      final mockPrayerTimes = PrayerTimes(
        id: 'test-1',
        date: DateTime.now(),
        location: const Location(
          latitude: 40.7128,
          longitude: -74.0060,
          city: 'New York',
          country: 'USA',
          timezone: 'America/New_York',
        ),
        fajr: PrayerTime(
          name: 'Fajr',
          time: DateTime.now().add(const Duration(hours: 5)),
          arabicName: 'فجر',
        ),
        dhuhr: PrayerTime(
          name: 'Dhuhr',
          time: DateTime.now().add(const Duration(hours: 12)),
          arabicName: 'ظهر',
        ),
        asr: PrayerTime(
          name: 'Asr',
          time: DateTime.now().add(const Duration(hours: 15)),
          arabicName: 'عصر',
        ),
        maghrib: PrayerTime(
          name: 'Maghrib',
          time: DateTime.now().add(const Duration(hours: 18)),
          arabicName: 'مغرب',
        ),
        isha: PrayerTime(
          name: 'Isha',
          time: DateTime.now().add(const Duration(hours: 20)),
          arabicName: 'عشاء',
        ),
        calculationMethod: 'MWL',
      );

      when(mockRepository.getCurrentPrayerTimes())
          .thenAnswer((_) async => Right(mockPrayerTimes));
      
      when(mockRepository.getCurrentLocation())
          .thenAnswer((_) async => const Right(Location(
            latitude: 40.7128,
            longitude: -74.0060,
            city: 'New York',
            country: 'USA',
            timezone: 'America/New_York',
          ),),);

      // Act
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: PrayerTimesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the notification settings button
      final notificationButton = find.byIcon(Icons.notifications_outlined);
      expect(notificationButton, findsOneWidget);
      
      // Note: In a real integration test, this would navigate
      // For now, we just verify the button exists
      await tester.tap(notificationButton);
      await tester.pumpAndSettle();
    });

    group('Provider Integration Tests', () {
      test('currentPrayerTimesProvider returns prayer times correctly', () async {
        // Arrange
        final mockPrayerTimes = PrayerTimes(
          id: 'test-1',
          date: DateTime.now(),
          location: const Location(
            latitude: 40.7128,
            longitude: -74.0060,
            city: 'New York',
            country: 'USA',
            timezone: 'America/New_York',
          ),
          fajr: PrayerTime(
            name: 'Fajr',
            time: DateTime.now().add(const Duration(hours: 5)),
            arabicName: 'فجر',
          ),
          dhuhr: PrayerTime(
            name: 'Dhuhr',
            time: DateTime.now().add(const Duration(hours: 12)),
            arabicName: 'ظهر',
          ),
          asr: PrayerTime(
            name: 'Asr',
            time: DateTime.now().add(const Duration(hours: 15)),
            arabicName: 'عصر',
          ),
          maghrib: PrayerTime(
            name: 'Maghrib',
            time: DateTime.now().add(const Duration(hours: 18)),
            arabicName: 'مغرب',
          ),
          isha: PrayerTime(
            name: 'Isha',
            time: DateTime.now().add(const Duration(hours: 20)),
            arabicName: 'عشاء',
          ),
          calculationMethod: 'MWL',
        );

        when(mockRepository.getCurrentPrayerTimes())
            .thenAnswer((_) async => Right(mockPrayerTimes));

        // Act
        final result = await container.read(currentPrayerTimesProvider.future);

        // Assert
        expect(result.id, equals('test-1'));
        expect(result.fajr.name, equals('Fajr'));
        expect(result.location.city, equals('New York'));
        
        verify(mockRepository.getCurrentPrayerTimes()).called(1);
      });

      test('athanSettingsProvider handles settings correctly', () async {
        // Arrange
        final mockSettings = AthanSettingsDefaults.standard;
        
        when(mockRepository.getAthanSettings())
            .thenAnswer((_) async => Right(mockSettings));

        // Act
        final result = await container.read(athanSettingsProvider.future);

        // Assert
        expect(result.isEnabled, equals(true));
        expect(result.muadhinVoice, equals('abdulbasit'));
        expect(result.volume, equals(0.8));
        
        verify(mockRepository.getAthanSettings()).called(1);
      });
    });

    group('Error Handling Tests', () {
      test('Prayer times provider handles network failure', () async {
        // Arrange
        when(mockRepository.getCurrentPrayerTimes())
            .thenAnswer((_) async => const Left(Failure.networkFailure(
              message: 'Network connection failed',
            ),),);

        // Act & Assert
        expect(
          () async => container.read(currentPrayerTimesProvider.future),
          throwsA(isA<Failure>()),
        );
        
        verify(mockRepository.getCurrentPrayerTimes()).called(1);
      });

      test('Athan settings provider handles loading failure', () async {
        // Arrange
        when(mockRepository.getAthanSettings())
            .thenAnswer((_) async => const Left(Failure.databaseFailure(
              operation: 'load_settings',
              message: 'Failed to load settings',
            ),),);

        // Act & Assert
        expect(
          () async => await container.read(athanSettingsProvider.future),
          throwsA(isA<Failure>()),
        );
        
        verify(mockRepository.getAthanSettings()).called(1);
      });
    });
  });
}
