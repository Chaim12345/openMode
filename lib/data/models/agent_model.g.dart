// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentModel _$AgentModelFromJson(Map<String, dynamic> json) => AgentModel(
      name: json['name'] as String,
      description: json['description'] as String,
      mode: json['mode'] as String,
      builtIn: json['builtIn'] as bool,
      tools: (json['tools'] as Map).cast<String, bool>(),
      model: json['model'] == null
          ? null
          : AgentModelConfig.fromJson(json['model'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AgentModelToJson(AgentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'mode': instance.mode,
      'builtIn': instance.builtIn,
      'tools': instance.tools,
      'model': instance.model?.toJson(),
    };

AgentModelConfig _$AgentModelConfigFromJson(Map<String, dynamic> json) =>
    AgentModelConfig(
      provider: json['provider'] as String,
      model: json['model'] as String,
    );

Map<String, dynamic> _$AgentModelConfigToJson(AgentModelConfig instance) =>
    <String, dynamic>{
      'provider': instance.provider,
      'model': instance.model,
    };
