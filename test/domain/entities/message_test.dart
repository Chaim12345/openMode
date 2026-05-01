import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/domain/entities/message.dart';

void main() {
  group('Message Entity', () {
    test('should create message from json', () {
      final json = {
        'id': 'msg-123',
        'content': 'Hello, world!',
        'role': 'user',
        'session_id': 'session-123',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final message = Message.fromJson(json);

      expect(message.id, 'msg-123');
      expect(message.content, 'Hello, world!');
      expect(message.role, 'user');
      expect(message.sessionId, 'session-123');
    });

    test('should handle assistant role', () {
      final json = {
        'id': 'msg-456',
        'content': 'Hi there!',
        'role': 'assistant',
      };

      final message = Message.fromJson(json);

      expect(message.role, 'assistant');
    });

    test('should handle null content', () {
      final json = {
        'id': 'msg-789',
        'content': null,
        'role': 'user',
      };

      final message = Message.fromJson(json);

      expect(message.content, '');
    });

    test('should compare messages by id', () {
      final message1 = Message(
        id: 'msg-123',
        content: 'Message 1',
        role: 'user',
      );
      final message2 = Message(
        id: 'msg-123',
        content: 'Message 2',
        role: 'assistant',
      );

      expect(message1, equals(message2));
    });

    test('should convert to json', () {
      final message = Message(
        id: 'msg-123',
        content: 'Test content',
        role: 'user',
      );

      final json = message.toJson();

      expect(json['id'], 'msg-123');
      expect(json['content'], 'Test content');
      expect(json['role'], 'user');
    });
  });
}
