import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/agent.dart';

part 'agent_model.g.dart';

@JsonSerializable()
class AgentModel {
  final String name;
  final String description;
  final String mode;
  final bool builtIn;
  final Map<String, bool> tools;
  final AgentModelConfig? model;

  AgentModel({
    required this.name,
    required this.description,
    required this.mode,
    required this.builtIn,
    required this.tools,
    this.model,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) =>
      _$AgentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgentModelToJson(this);

  Agent toDomain() {
    return Agent(
      name: name,
      description: description,
      mode: mode,
      builtIn: builtIn,
      tools: tools,
      model: model?.toDomain(),
    );
  }
}

@JsonSerializable()
class AgentModelConfig {
  final String provider;
  final String model;

  AgentModelConfig({
    required this.provider,
    required this.model,
  });

  factory AgentModelConfig.fromJson(Map<String, dynamic> json) =>
      _$AgentModelConfigFromJson(json);

  Map<String, dynamic> toJson() => _$AgentModelConfigToJson(this);

  domain.AgentModel toDomain() {
    return domain.AgentModel(
      provider: provider,
      model: model,
    );
  }
}
