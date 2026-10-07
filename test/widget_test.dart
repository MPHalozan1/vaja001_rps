// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vaja001_rps/main.dart';

void main() {
  testWidgets('Sign in screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we are on the Sign In screen.
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Login as:'), findsOneWidget);

    // Verify buttons are present.
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Employee'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
  });
}
