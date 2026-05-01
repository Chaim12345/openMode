import 'package:dartz/dartz.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Unshare chat session use case
class UnshareChatSession {
  const UnshareChatSession(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, ChatSession>> call(UnshareChatSessionParams params) {
    return repository.unshareSession(
      params.projectId,
      params.sessionId,
      directory: params.directory,
    );
  }
}

/// Unshare chat session parameters
class UnshareChatSessionParams {
  const UnshareChatSessionParams({
    required this.projectId,
    required this.sessionId,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final String? directory;
}