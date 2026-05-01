import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/presentation/widgets/chat_input_widget.dart';

void main() {
  group('ChatInputWidget', () {
    testWidgets('should display empty input field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      // The widget uses send_rounded when composing and mic_rounded when idle
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    });

    testWidgets('should enable send button when text entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {},
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Send button (send_rounded) should appear when composing
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    });

    testWidgets('should call onSendMessage when send tapped', (WidgetTester tester) async {
      String? capturedMessage;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {
                capturedMessage = text;
              },
            ),
          ),
        ),
      );

      // Enter and send
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();

      expect(capturedMessage, 'Test message');
    });

    testWidgets('should show attachment button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {},
            ),
          ),
        ),
      );

      // The widget uses add_rounded for attachments
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });
  });
}
