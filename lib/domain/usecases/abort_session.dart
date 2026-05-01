import 'package:dartz/dartz.dart';
import '../repositories/chat_repository.dart';
import '../../core/errors/failures.dart';

/// Abort session use case
class AbortSession {
  const AbortSession(this.repository);

  final ChatRepository repository;

  Future<Either<Failure, void>> call(AbortSessionParams params) {
    return repository.abortSession(
      params.projectId,
      params.sessionId,
      directory: params.directory,
    );
  }
}

/// Abort session parameters
class AbortSessionParams {
  const AbortSessionParams({
    required this.projectId,
    required this.sessionId,
    this.directory,
  });

  final String projectId;
  final String sessionId;
  final String? directory;
}