import 'package:dartz/dartz.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Update chat session use case
class UpdateChatSession {
  const UpdateChatSession(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, ChatSession>> call(UpdateChatSessionParams params) {
    return repository.updateSession(
      params.projectId,
      params.sessionId,
      params.input,
      directory: params.directory,
    );
  }
}

/// Update chat session parameters
class UpdateChatSessionParams {
  const UpdateChatSessionParams({
    required this.projectId,
    required this.sessionId,
    required this.input,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final SessionUpdateInput input;
  final String? directory;
}