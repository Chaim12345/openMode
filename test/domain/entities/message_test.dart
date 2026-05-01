import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/domain/entities/message.dart';

void main() {
  group('MessageRole Enum', () {
    test('should have correct roles', () {
      expect(MessageRole.values.length, 2);
      expect(MessageRole.user, isNotNull);
      expect(MessageRole.assistant, isNotNull);
    });
  });

  group('MessageTime', () {
    test('should create MessageTime', () {
      final time = MessageTime(
        created: 1234567890,
        updated: 1234567890,
      );
      expect(time.created, 1234567890);
      expect(time.updated, 1234567890);
    });
  });

  group('UserMessage', () {
    test('should create UserMessage', () {
      final time = MessageTime(
        created: 1234567890,
        updated: 1234567890,
      );
      final message = UserMessage(
        id: 'msg-123',
        sessionId: 'session-123',
        time: time,
      );
      expect(message.id, 'msg-123');
      expect(message.sessionId, 'session-123');
      expect(message.role, MessageRole.user);
    });
  });
}
