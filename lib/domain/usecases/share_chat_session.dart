import 'package:dartz/dartz.dart';
import '../entities/chat_session.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Share chat session use case
class ShareChatSession {
  const ShareChatSession(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, ChatSession>> call(ShareChatSessionParams params) {
    return repository.shareSession(
      params.projectId,
      params.sessionId,
      directory: params.directory,
    );
  }
}

/// Share chat session parameters
class ShareChatSessionParams {
  const ShareChatSessionParams({
    required this.projectId,
    required this.sessionId,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final String? directory;
}