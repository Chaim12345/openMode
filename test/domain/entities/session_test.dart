import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/domain/entities/session.dart';

void main() {
  group('Session Entity', () {
    test('should create session from json', () {
      final json = {
        'id': 'session-123',
        'title': 'Test Session',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final session = Session.fromJson(json);

      expect(session.id, 'session-123');
      expect(session.title, 'Test Session');
      expect(session.createdAt, isNotNull);
      expect(session.updatedAt, isNotNull);
    });

    test('should convert session to json', () {
      final session = Session(
        id: 'session-123',
        title: 'Test Session',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = session.toJson();

      expect(json['id'], 'session-123');
      expect(json['title'], 'Test Session');
    });

    test('should handle null values in fromJson', () {
      final json = {
        'id': 'session-123',
        'title': null,
      };

      final session = Session.fromJson(json);

      expect(session.id, 'session-123');
      expect(session.title, '');
    });

    test('should compare sessions by id', () {
      final session1 = Session(
        id: 'session-123',
        title: 'Session 1',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );
      final session2 = Session(
        id: 'session-123',
        title: 'Session 2',
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      );

      expect(session1, equals(session2));
    });
  });
}
