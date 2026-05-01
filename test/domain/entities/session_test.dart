import 'package:flutter_test/flutter_test.dart';
import 'package:open_mode/domain/entities/session.dart';

void main() {
  group('SessionTime', () {
    test('should create SessionTime', () {
      final time = SessionTime(created: 1234567890, updated: 1234567890);
      expect(time.created, 1234567890);
      expect(time.updated, 1234567890);
    });
  });

  group('Session', () {
    test('should create Session', () {
      final time = SessionTime(created: 1234567890, updated: 1234567890);
      final session = Session(
        id: 'session-123',
        title: 'Test Session',
        version: '1.0',
        time: time,
      );
      expect(session.id, 'session-123');
      expect(session.title, 'Test Session');
      expect(session.version, '1.0');
    });

    test('should compare sessions by props', () {
      final time = SessionTime(created: 1234567890, updated: 1234567890);
      final session1 = Session(
        id: 'session-123',
        title: 'Test',
        version: '1.0',
        time: time,
      );
      final session2 = Session(
        id: 'session-123',
        title: 'Test',
        version: '1.0',
        time: time,
      );
      expect(session1, equals(session2));
    });
  });
}
