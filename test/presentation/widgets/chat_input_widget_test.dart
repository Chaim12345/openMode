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
              enabled: true,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('should enable send button when text entered', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {},
              enabled: true,
            ),
          ),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'Hello');
      await tester.pump();

      // Send button should be enabled
      final sendButton = tester.widget<IconButton>(find.byIcon(Icons.send));
      expect(sendButton.enabled, isTrue);
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
              enabled: true,
            ),
          ),
        ),
      );

      // Enter and send
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(capturedMessage, 'Test message');
    });

    testWidgets('should show attachment button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ChatInputWidget(
              onSendMessage: (text, {attachments}) {},
              enabled: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });
  });
}
