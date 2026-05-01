import '../../domain/entities/agent.dart';
import 'json_serializable/json_serializable.dart';

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

class AgentModelConfig {
  final String provider;
  final String model;

  AgentModelConfig({
    required this.provider,
    required this.model,
  });

  factory AgentModelConfig.fromJson(Map<String, dynamic> json) {
    return AgentModelConfig(
      provider: json['provider'] ?? '',
      model: json['model'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider,
      'model': model,
    };
  }

  AgentModel toDomain() {
    return AgentModel(
      provider: provider,
      model: model,
    );
  }
}
