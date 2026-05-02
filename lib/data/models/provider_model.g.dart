// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvidersResponseModel _$ProvidersResponseModelFromJson(
  Map<String, dynamic> json,
) => ProvidersResponseModel(
  providers: (json['providers'] as List<dynamic>)
      .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  defaultModels: Map<String, String>.from(json['default'] as Map),
);

Map<String, dynamic> _$ProvidersResponseModelToJson(
  ProvidersResponseModel instance,
) => <String, dynamic>{
  'providers': instance.providers,
  'default': instance.defaultModels,
};

ModelCapabilities _$ModelCapabilitiesFromJson(Map<String, dynamic> json) =>
    ModelCapabilities(
      attachment: json['attachment'] as bool? ?? false,
      reasoning: json['reasoning'] as bool? ?? false,
      temperature: json['temperature'] as bool? ?? true,
      toolCall: json['toolCall'] as bool? ?? false,
    );

Map<String, dynamic> _$ModelCapabilitiesToJson(ModelCapabilities instance) =>
    <String, dynamic>{
      'attachment': instance.attachment,
      'reasoning': instance.reasoning,
      'temperature': instance.temperature,
      'toolCall': instance.toolCall,
    };

ProviderModel _$ProviderModelFromJson(Map<String, dynamic> json) =>
    ProviderModel(
      id: json['id'] as String,
      name: json['name'] as String,
      env: (json['env'] as List<dynamic>).map((e) => e as String).toList(),
      api: json['api'] as String?,
      npm: json['npm'] as String?,
      source: json['source'] as String?,
      models: (json['models'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, ModelModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$ProviderModelToJson(ProviderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'env': instance.env,
      'api': instance.api,
      'npm': instance.npm,
      'source': instance.source,
      'models': instance.models,
    };

ModelModel _$ModelModelFromJson(Map<String, dynamic> json) => ModelModel(
  id: json['id'] as String,
  name: json['name'] as String,
  releaseDate: json['release_date'] as String?,
  attachment: json['attachment'] as bool?,
  reasoning: json['reasoning'] as bool?,
  temperature: json['temperature'] as bool?,
  toolCall: json['tool_call'] as bool?,
  capabilities: json['capabilities'] == null
      ? null
      : ModelCapabilities.fromJson(
          json['capabilities'] as Map<String, dynamic>,
        ),
  cost: ModelCostModel.fromJson(json['cost'] as Map<String, dynamic>),
  limit: ModelLimitModel.fromJson(json['limit'] as Map<String, dynamic>),
  options: json['options'] as Map<String, dynamic>?,
  knowledge: json['knowledge'] as String?,
  lastUpdated: json['last_updated'] as String?,
  modalities: json['modalities'] as Map<String, dynamic>?,
  openWeights: json['open_weights'] as bool?,
  family: json['family'] as String?,
  status: json['status'] as String?,
  variants: json['variants'] as List<dynamic>?,
);

Map<String, dynamic> _$ModelModelToJson(ModelModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'release_date': instance.releaseDate,
      'attachment': instance.attachment,
      'reasoning': instance.reasoning,
      'temperature': instance.temperature,
      'tool_call': instance.toolCall,
      'capabilities': instance.capabilities,
      'cost': instance.cost,
      'limit': instance.limit,
      'options': instance.options,
      'knowledge': instance.knowledge,
      'last_updated': instance.lastUpdated,
      'modalities': instance.modalities,
      'open_weights': instance.openWeights,
      'family': instance.family,
      'status': instance.status,
      'variants': instance.variants,
    };

ModelCostModel _$ModelCostModelFromJson(Map<String, dynamic> json) =>
    ModelCostModel(
      input: ModelCostModel._doubleFromJson(json['input']),
      output: ModelCostModel._doubleFromJson(json['output']),
      cacheRead: ModelCostModel._nullableDoubleFromJson(json['cache_read']),
      cacheWrite: ModelCostModel._nullableDoubleFromJson(json['cache_write']),
    );

Map<String, dynamic> _$ModelCostModelToJson(ModelCostModel instance) =>
    <String, dynamic>{
      'input': instance.input,
      'output': instance.output,
      'cache_read': instance.cacheRead,
      'cache_write': instance.cacheWrite,
    };

ModelLimitModel _$ModelLimitModelFromJson(Map<String, dynamic> json) =>
    ModelLimitModel(
      context: (json['context'] as num).toInt(),
      output: (json['output'] as num).toInt(),
    );

Map<String, dynamic> _$ModelLimitModelToJson(ModelLimitModel instance) =>
    <String, dynamic>{'context': instance.context, 'output': instance.output};
