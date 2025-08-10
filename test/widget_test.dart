// This is a basic Flutter widget test for DeenMate app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:deen_mate/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DeenMate app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DeenMateApp());

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    
    // The app should show either onboarding or home screen
    // We can't predict which one due to async onboarding state
    await tester.pumpAndSettle();
    
    // Verify no exceptions occurred
    expect(tester.takeException(), isNull);
  });
}
