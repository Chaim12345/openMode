import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/agent.dart';

/// Agent repository interface
abstract class AgentRepository {
  /// Get all available agents
  Future<Either<Failure, List<Agent>>> getAgents();
}
