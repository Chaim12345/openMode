import 'package:equatable/equatable.dart';

/// AI Agent entity
class Agent extends Equatable {
  final String name;
  final String description;
  final String mode;
  final bool builtIn;
  final Map<String, bool> tools;
  final AgentModel? model;

  const Agent({
    required this.name,
    required this.description,
    required this.mode,
    required this.builtIn,
    required this.tools,
    this.model,
  });

  @override
  List<Object?> get props => [name, description, mode, builtIn, tools, model];
}

/// Agent model configuration
class AgentModel extends Equatable {
  final String provider;
  final String model;

  const AgentModel({
    required this.provider,
    required this.model,
  });

  @override
  List<Object?> get props => [provider, model];
}
