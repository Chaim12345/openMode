import '../../domain/entities/agent.dart' as domain;

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

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    return AgentModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mode: json['mode'] ?? '',
      builtIn: json['builtIn'] ?? false,
      tools: (json['tools'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as bool),
      ) ?? {},
      model: json['model'] != null
          ? AgentModelConfig.fromJson(json['model'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'mode': mode,
      'builtIn': builtIn,
      'tools': tools,
      'model': model?.toJson(),
    };
  }

  domain.Agent toDomain() {
    return domain.Agent(
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

  domain.AgentModel toDomain() {
    return domain.AgentModel(
      provider: provider,
      model: model,
    );
  }
}
