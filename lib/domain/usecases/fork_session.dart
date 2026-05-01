import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';

/// Fork a chat session
class ForkSession {
  final ChatRepository repository;

  ForkSession(this.repository);

  Future<Either<Failure, ChatSession>> call({
    required String projectId,
    required String sessionId,
    String? directory,
  }) async {
    return await repository.forkSession(projectId, sessionId, directory: directory);
  }
}

class ForkSessionParams {
  final String projectId;
  final String sessionId;
  final String? directory;

  const ForkSessionParams({
    required this.projectId,
    required this.sessionId,
    this.directory,
  });
}
