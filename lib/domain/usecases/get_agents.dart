import 'package:dartz/dartz.dart';
import '../repositories/agent_repository.dart';
import '../entities/agent.dart';
import '../../core/errors/failures.dart';

/// Get all available agents use case
class GetAgents {
  final AgentRepository repository;

  GetAgents(this.repository);

  Future<Either<Failure, List<Agent>>> call() async {
    return await repository.getAgents();
  }
}
