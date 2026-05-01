// Tests need appProvider parameter - temporarily disabled
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/main.dart';
import 'package:open_mode/presentation/pages/main_page.dart';
import 'package:open_mode/presentation/pages/settings_page.dart';

/// Comprehensive UI Test Suite
void main() {
  group('UI Tests - Complete App Flow', () {
    testWidgets('1. App launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('2. Bottom navigation switches tabs', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      expect(find.text('Chat'), findsOneWidget);
      
      await tester.tap(find.text('Files'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('3. Chat input accepts text', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'Test message');
      await tester.pump();
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('4. Settings sections accessible', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      
      expect(find.text('Server'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });
  });
}
