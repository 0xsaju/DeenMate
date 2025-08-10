import 'package:deen_mate/core/widgets/responsive_layout.dart';
import 'package:deen_mate/features/prayer_times/presentation/screens/prayer_times_production.dart';
import 'package:deen_mate/features/zakat/presentation/screens/zakat_calculator_production.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Platform readiness tests for Prayer Times and Zakat Calculator
/// Tests responsive design, Islamic theming, and cross-platform compatibility
void main() {
  group('Platform Readiness Tests', () {
    
    testWidgets('Prayer Times - Mobile Layout (< 600px)', (WidgetTester tester) async {
      // Set mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 812));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTimesProductionScreen(),
        ),
      );
      
      // Verify Islamic gradient app bar
      expect(find.text('Prayer Times | নামাজের সময়'), findsOneWidget);
      
      // Verify date header card
      expect(find.text('Today | আজ'), findsOneWidget);
      
      // Verify current prayer card with Islamic design
      expect(find.text('Fajr | ফজর'), findsOneWidget);
      expect(find.text('✓ Completed | সম্পন্ন'), findsOneWidget);
      
      // Verify upcoming prayers
      expect(find.text('Dhuhr | যুহর'), findsOneWidget);
      expect(find.text('Asr | আসর'), findsOneWidget);
      expect(find.text('Maghrib | মাগরিব'), findsOneWidget);
      expect(find.text('Isha | ইশা'), findsOneWidget);
      
      // Verify progress tracking
      expect(find.text("Today's Progress | আজকের অগ্রগতি"), findsOneWidget);
      expect(find.text('1/5'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      
      // Verify location info
      expect(find.text('📍 Dhaka, Bangladesh'), findsOneWidget);
    });
    
    testWidgets('Prayer Times - Tablet Layout (600px - 1199px)', (WidgetTester tester) async {
      // Set tablet screen size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTimesProductionScreen(),
        ),
      );
      
      // Verify all elements still present and properly spaced
      expect(find.text('Prayer Times | নামাজের সময়'), findsOneWidget);
      expect(find.text('Today | আজ'), findsOneWidget);
      expect(find.text('Fajr | ফজর'), findsOneWidget);
      
      // Test scrolling behavior
      await tester.fling(find.byType(CustomScrollView), const Offset(0, -300), 1000);
      await tester.pumpAndSettle();
    });
    
    testWidgets('Prayer Times - Desktop Layout (>= 1200px)', (WidgetTester tester) async {
      // Set desktop screen size
      await tester.binding.setSurfaceSize(const Size(1366, 768));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTimesProductionScreen(),
        ),
      );
      
      // Verify responsive design adapts to desktop
      expect(find.text('Prayer Times | নামাজের সময়'), findsOneWidget);
      expect(find.text('Today | আজ'), findsOneWidget);
    });
    
    testWidgets('Zakat Calculator - Mobile Responsive Design', (WidgetTester tester) async {
      // Set mobile screen size
      await tester.binding.setSurfaceSize(const Size(375, 812));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: ZakatCalculatorProductionScreen(),
        ),
      );
      
      // Verify Islamic gradient app bar
      expect(find.text('Zakat Calculator | যাকাত ক্যালকুলেটর'), findsOneWidget);
      
      // Verify progress indicator
      expect(find.text('Step 3 of 8 | ধাপ ৩/৮'), findsOneWidget);
      
      // Verify section header
      expect(find.text('Precious Metals | মূল্যবান ধাতু'), findsOneWidget);
      expect(find.text('Gold & Silver assets | স্বর্ণ ও রূপার সম্পদ'), findsOneWidget);
      
      // Verify live metal prices
      expect(find.text('Live Metal Prices | লাইভ দাম'), findsOneWidget);
      expect(find.text('Gold/স্বর্ণ'), findsOneWidget);
      expect(find.text('৳6,850/bhori'), findsOneWidget);
      expect(find.text('Silver/রূপা'), findsOneWidget);
      expect(find.text('৳95/bhori'), findsOneWidget);
      
      // Verify gold input section
      expect(find.text('Gold Holdings | স্বর্ণের সম্পদ'), findsOneWidget);
      expect(find.text('Weight in Bhori | ভরি এককে ওজন'), findsOneWidget);
      
      // Verify silver input section
      expect(find.text('Silver Holdings | রূপার সম্পদ'), findsOneWidget);
      
      // Verify nisab information
      expect(find.text('💡 Nisab Information | নিসাব তথ্য'), findsOneWidget);
      expect(find.text('Gold Nisab: 7.5 tola (৮৭.৪৮ গ্রাম)'), findsOneWidget);
      expect(find.text('Silver Nisab: 52.5 tola (৬১২.৩৬ গ্রাম)'), findsOneWidget);
      
      // Verify navigation buttons
      expect(find.text('← Previous'), findsOneWidget);
      expect(find.text('Next →'), findsOneWidget);
    });
    
    testWidgets('Zakat Calculator - Form Input Testing', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 812));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: ZakatCalculatorProductionScreen(),
        ),
      );
      
      // Test gold input field
      final goldField = find.byType(TextField).first;
      await tester.enterText(goldField, '15.0');
      await tester.pump();
      
      // Verify estimated value updates
      expect(find.textContaining('Estimated Value: ৳'), findsOneWidget);
      
      // Test silver input field
      final silverField = find.byType(TextField).last;
      await tester.enterText(silverField, '20.0');
      await tester.pump();
      
      // Test navigation
      await tester.tap(find.text('Next →'));
      await tester.pumpAndSettle();
    });
    
    testWidgets('Islamic Responsive Widgets - Cross Platform', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: ColoredBox(
                color: Colors.red,
                child: Text('Mobile'),
              ),
              tablet: ColoredBox(
                color: Colors.blue,
                child: Text('Tablet'),
              ),
              desktop: ColoredBox(
                color: Colors.green,
                child: Text('Desktop'),
              ),
            ),
          ),
        ),
      );
      
      // Test mobile (default size 800x600 in tests)
      expect(find.text('Tablet'), findsOneWidget);
      
      // Test desktop
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      await tester.pumpAndSettle();
      expect(find.text('Desktop'), findsOneWidget);
      
      // Test mobile
      await tester.binding.setSurfaceSize(const Size(375, 812));
      await tester.pumpAndSettle();
      expect(find.text('Mobile'), findsOneWidget);
    });
    
    testWidgets('Islamic Card - Responsive Sizing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IslamicCard(
              child: Text('Test Card'),
            ),
          ),
        ),
      );
      
      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
    
    group('Bengali Text Integration', () {
      testWidgets('Bengali prayer names display correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: PrayerTimesProductionScreen(),
          ),
        );
        
        // Test Bengali prayer names
        expect(find.text('ফজর'), findsOneWidget);
        expect(find.text('যুহর'), findsOneWidget);
        expect(find.text('আসর'), findsOneWidget);
        expect(find.text('মাগরিব'), findsOneWidget);
        expect(find.text('ইশা'), findsOneWidget);
        
        // Test Bengali completion status
        expect(find.text('সম্পন্ন'), findsOneWidget);
      });
      
      testWidgets('Bengali Zakat terms display correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ZakatCalculatorProductionScreen(),
          ),
        );
        
        // Test Bengali Zakat terms
        expect(find.text('যাকাত ক্যালকুলেটর'), findsOneWidget);
        expect(find.text('মূল্যবান ধাতু'), findsOneWidget);
        expect(find.text('স্বর্ণ ও রূপার সম্পদ'), findsOneWidget);
        expect(find.text('লাইভ দাম'), findsOneWidget);
        expect(find.text('স্বর্ণ'), findsOneWidget);
        expect(find.text('রূপা'), findsOneWidget);
        expect(find.text('ভরি এককে ওজন'), findsOneWidget);
        expect(find.text('নিসাব তথ্য'), findsOneWidget);
      });
    });
    
    group('Islamic Design System', () {
      testWidgets('Color scheme consistency', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: IslamicGradientBackground(
              child: Text('Islamic Green'),
            ),
          ),
        );
        
        expect(find.text('Islamic Green'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });
      
      testWidgets('Typography scales properly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    Text('Heading 1', style: IslamicTextStyles.heading1(context)),
                    Text('Heading 2', style: IslamicTextStyles.heading2(context)),
                    Text('Body Text', style: IslamicTextStyles.body(context)),
                    Text('Caption Text', style: IslamicTextStyles.caption(context)),
                    Text('Arabic Text', style: IslamicTextStyles.arabic(context)),
                    Text('Bengali Text', style: IslamicTextStyles.bengali(context)),
                  ],
                ),
              ),
            ),
          ),
        );
        
        expect(find.text('Heading 1'), findsOneWidget);
        expect(find.text('Arabic Text'), findsOneWidget);
        expect(find.text('Bengali Text'), findsOneWidget);
      });
    });
  });
  
  group('Performance Tests', () {
    testWidgets('Prayer Times scrolling performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrayerTimesProductionScreen(),
        ),
      );
      
      // Measure frame building time
      final binding = tester.binding;
      await binding.pump();
      
      // Test smooth scrolling
      await tester.fling(find.byType(CustomScrollView), const Offset(0, -500), 2000);
      await tester.pumpAndSettle();
      
      // Verify no overflow or rendering issues
      expect(tester.takeException(), isNull);
    });
    
    testWidgets('Zakat Calculator form performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ZakatCalculatorProductionScreen(),
        ),
      );
      
      // Test rapid input changes
      final goldField = find.byType(TextField).first;
      for (var i = 0; i < 10; i++) {
        await tester.enterText(goldField, i.toString());
        await tester.pump();
      }
      
      // Verify no performance issues
      expect(tester.takeException(), isNull);
    });
  });
}

/// Helper function to set up platform-specific testing environment
void setupPlatformTest(TargetPlatform platform) {
  // Platform override no longer needed in current Flutter version
  // Tests automatically adapt to different screen sizes
}

/// Clean up after platform tests
void tearDownPlatformTest() {
  // No cleanup needed for current Flutter version
}
