import 'package:dartz/dartz.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Unrevert messages use case
class UnrevertMessages {
  const UnrevertMessages(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, void>> call(UnrevertMessagesParams params) {
    return repository.unrevertMessages(
      params.projectId,
      params.sessionId,
      directory: params.directory,
    );
  }
}

/// Unrevert messages parameters
class UnrevertMessagesParams {
  const UnrevertMessagesParams({
    required this.projectId,
    required this.sessionId,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final String? directory;
}