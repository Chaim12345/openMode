import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/provider.dart';

part 'provider_model.g.dart';

/// 提供商响应模型
@JsonSerializable()
class ProvidersResponseModel {
  const ProvidersResponseModel({
    required this.providers,
    required this.defaultModels,
  });

  final List<ProviderModel> providers;
  @JsonKey(name: 'default')
  final Map<String, String> defaultModels;

  factory ProvidersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProvidersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProvidersResponseModelToJson(this);

  /// 从OpenCode API响应创建
  factory ProvidersResponseModel.fromOpenCodeApi(Map<String, dynamic> json) {
    final allProviders = json['all'] as List<dynamic>? ?? [];
    final defaultMap = (json['default'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, v.toString()),
    );

    final providers = allProviders.map((p) {
      final providerMap = p as Map<String, dynamic>;
      final modelsMap = providerMap['models'] as Map<String, dynamic>? ?? {};
      
      final models = modelsMap.map((key, value) {
        final modelMap = value as Map<String, dynamic>;
        return MapEntry(key, ModelModel(
          id: modelMap['id'] as String? ?? key,
          name: modelMap['name'] as String? ?? key,
          // Parse capabilities from OpenCode format
          capabilities: _parseCapabilities(modelMap['capabilities']),
          options: modelMap['options'] as Map<String, dynamic>? ?? {},
          cost: modelMap['cost'] != null 
            ? ModelCostModel.fromOpenCode(modelMap['cost'])
            : const ModelCostModel(input: 0, output: 0),
          limit: modelMap['limit'] != null
            ? ModelLimitModel.fromOpenCode(modelMap['limit'])
            : const ModelLimitModel(context: 0, output: 0),
          family: modelMap['family'] as String?,
          status: modelMap['status'] as String?,
          variants: modelMap['variants'] as List<dynamic>?,
        ));
      });

      return ProviderModel(
        id: providerMap['id'] as String? ?? 'unknown',
        name: providerMap['name'] as String? ?? 'Unknown',
        env: (providerMap['env'] as List<dynamic>?)?.cast<String>() ?? [],
        source: providerMap['source'] as String?,
        npm: providerMap['npm'] as String?,
        models: models,
      );
    }).toList();

    return ProvidersResponseModel(
      providers: providers,
      defaultModels: defaultMap,
    );
  }

  static ModelCapabilities _parseCapabilities(dynamic caps) {
    if (caps == null) return const ModelCapabilities();
    if (caps is Map<String, dynamic>) {
      return ModelCapabilities(
        attachment: caps['attachment'] as bool? ?? false,
        reasoning: caps['reasoning'] as bool? ?? false,
        temperature: caps['temperature'] as bool? ?? true,
        toolCall: caps['tool_call'] as bool? ?? false,
      );
    }
    return const ModelCapabilities();
  }

  /// 转换为领域实体
  ProvidersResponse toDomain() {
    return ProvidersResponse(
      providers: providers.map((p) => p.toDomain()).toList(),
      defaultModels: defaultModels,
    );
  }
}

/// 模型能力
@JsonSerializable()
class ModelCapabilities {
  final bool attachment;
  final bool reasoning;
  final bool temperature;
  final bool toolCall;

  const ModelCapabilities({
    this.attachment = false,
    this.reasoning = false,
    this.temperature = true,
    this.toolCall = false,
  });

  factory ModelCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ModelCapabilitiesFromJson(json);
  Map<String, dynamic> toJson() => _$ModelCapabilitiesToJson(this);
}

/// 提供商模型
@JsonSerializable()
class ProviderModel {
  const ProviderModel({
    required this.id,
    required this.name,
    required this.env,
    this.api,
    this.npm,
    this.source,
    required this.models,
  });

  final String id;
  final String name;
  final List<String> env;
  final String? api;
  final String? npm;
  final String? source;
  final Map<String, ModelModel> models;

  factory ProviderModel.fromJson(Map<String, dynamic> json) =>
      _$ProviderModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderModelToJson(this);

  /// 转换为领域实体
  Provider toDomain() {
    return Provider(
      id: id,
      name: name,
      env: env,
      api: api,
      npm: npm,
      source: source,
      models: models.map((key, value) => MapEntry(key, value.toDomain())),
    );
  }
}

/// AI模型模型
@JsonSerializable()
class ModelModel {
  const ModelModel({
    required this.id,
    required this.name,
    this.releaseDate,
    this.attachment,
    this.reasoning,
    this.temperature,
    this.toolCall,
    this.capabilities,
    required this.cost,
    required this.limit,
    this.options,
    this.knowledge,
    this.lastUpdated,
    this.modalities,
    this.openWeights,
    this.family,
    this.status,
    this.variants,
  });

  final String id;
  final String name;
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  final bool? attachment;
  final bool? reasoning;
  final bool? temperature;
  @JsonKey(name: 'tool_call')
  final bool? toolCall;
  final ModelCapabilities? capabilities;
  final ModelCostModel cost;
  final ModelLimitModel limit;
  final Map<String, dynamic>? options;
  final String? knowledge;
  @JsonKey(name: 'last_updated')
  final String? lastUpdated;
  final Map<String, dynamic>? modalities;
  @JsonKey(name: 'open_weights')
  final bool? openWeights;
  final String? family;
  final String? status;
  final List<dynamic>? variants;

  factory ModelModel.fromJson(Map<String, dynamic> json) =>
      _$ModelModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelModelToJson(this);

  /// 转换为领域实体
  Model toDomain() {
    final caps = capabilities;
    final bool attachment = caps?.attachment ?? this.attachment ?? false;
    final bool reasoning = caps?.reasoning ?? this.reasoning ?? false;
    final bool temperature = caps?.temperature ?? this.temperature ?? true;
    final bool toolCall = caps?.toolCall ?? this.toolCall ?? false;
    
    return Model(
      id: id,
      name: name,
      releaseDate: releaseDate ?? 'unknown',
      attachment: attachment,
      reasoning: reasoning,
      temperature: temperature,
      toolCall: toolCall,
      cost: cost.toDomain(),
      limit: limit.toDomain(),
      options: options ?? {},
      knowledge: knowledge,
      lastUpdated: lastUpdated,
      modalities: modalities,
      openWeights: openWeights,
      family: family,
      status: status,
      variants: variants?.cast<String>(),
    );
  }
}

/// 模型费用模型
@JsonSerializable()
class ModelCostModel {
  const ModelCostModel({
    required this.input,
    required this.output,
    this.cacheRead,
    this.cacheWrite,
  });

  @JsonKey(fromJson: _doubleFromJson)
  final double input;
  @JsonKey(fromJson: _doubleFromJson)
  final double output;
  @JsonKey(name: 'cache_read', fromJson: _nullableDoubleFromJson)
  final double? cacheRead;
  @JsonKey(name: 'cache_write', fromJson: _nullableDoubleFromJson)
  final double? cacheWrite;

  factory ModelCostModel.fromOpenCode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ModelCostModel(
        input: _doubleFromJson(json['input']),
        output: _doubleFromJson(json['output']),
        cacheRead: _nullableDoubleFromJson(json['cache_read']),
        cacheWrite: _nullableDoubleFromJson(json['cache_write']),
      );
    }
    return const ModelCostModel(input: 0, output: 0);
  }

  static double _doubleFromJson(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static double? _nullableDoubleFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory ModelCostModel.fromJson(Map<String, dynamic> json) =>
      _$ModelCostModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelCostModelToJson(this);

  /// 转换为领域实体
  ModelCost toDomain() {
    return ModelCost(
      input: input,
      output: output,
      cacheRead: cacheRead,
      cacheWrite: cacheWrite,
    );
  }
}

/// 模型限制模型
@JsonSerializable()
class ModelLimitModel {
  const ModelLimitModel({required this.context, required this.output});

  final int context;
  final int output;

  factory ModelLimitModel.fromOpenCode(dynamic json) {
    if (json is Map<String, dynamic>) {
      return ModelLimitModel(
        context: (json['context'] as num?)?.toInt() ?? 0,
        output: (json['output'] as num?)?.toInt() ?? 0,
      );
    }
    return const ModelLimitModel(context: 0, output: 0);
  }

  factory ModelLimitModel.fromJson(Map<String, dynamic> json) =>
      _$ModelLimitModelFromJson(json);

  Map<String, dynamic> toJson() => _$ModelLimitModelToJson(this);

  /// 转换为领域实体
  ModelLimit toDomain() {
    return ModelLimit(context: context, output: output);
  }
}
