import 'package:dartz/dartz.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Revert message use case
class RevertMessage {
  const RevertMessage(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, void>> call(RevertMessageParams params) {
    return repository.revertMessage(
      params.projectId,
      params.sessionId,
      params.messageId,
      directory: params.directory,
    );
  }
}

/// Revert message parameters
class RevertMessageParams {
  const RevertMessageParams({
    required this.projectId,
    required this.sessionId,
    required this.messageId,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final String messageId;
  final String? directory;
}