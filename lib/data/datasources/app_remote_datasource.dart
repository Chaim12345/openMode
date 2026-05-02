import '../models/provider_model.dart';
import 'package:flutter/foundation.dart';
import '../models/app_info_model.dart';

/// 应用远程数据源接口
abstract class AppRemoteDataSource {
  /// 获取应用信息
  Future<AppInfoModel> getAppInfo({String? directory});

  /// 初始化应用
  Future<bool> initializeApp({String? directory});

  /// 获取提供商信息
  Future<ProvidersResponseModel> getProviders({String? directory});

  /// 获取配置信息
  Future<Map<String, dynamic>> getConfig({String? directory});
}

/// 应用远程数据源实现
class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  final dynamic dio;

  AppRemoteDataSourceImpl({required this.dio});

  @override
  Future<AppInfoModel> getAppInfo({String? directory}) async {
    // Do NOT swallow network errors here.
    // Align to OpenAPI: use /path and /config instead of /app/info.
    // Let Dio throw exceptions so upper layers can handle connection status correctly.
    final queryParams = directory != null
        ? {'directory': directory}
        : <String, dynamic>{};

    // Fetch path info
    final pathResp = await dio.get('/path', queryParameters: queryParams);

    // Fetch config info (optional for future use) - ignore response for now
    await dio.get('/config', queryParameters: queryParams);

    final Map<String, dynamic> pathJson = pathResp.data as Map<String, dynamic>;

    // Map OpenAPI Path schema to AppInfoModel expected structure.
    // Where exact fields don't exist, provide sensible defaults.
    final mapped = <String, dynamic>{
      'hostname': 'OpenCode',
      'git': false,
      'path': {
        'config': pathJson['config'] ?? '',
        // There is no 'data' in Path schema; use worktree as a reasonable default.
        'data': pathJson['worktree'] ?? '',
        // Root is not explicitly defined; use worktree as root.
        'root': pathJson['worktree'] ?? '',
        // Use directory as current working directory.
        'cwd': pathJson['directory'] ?? '',
        'state': pathJson['state'] ?? '',
      },
      'time': null,
    };

    return AppInfoModel.fromJson(mapped);
  }

  @override
  Future<bool> initializeApp({String? directory}) async {
    try {
      final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
      final response = await dio.post('/app/init', queryParameters: queryParams);
      return response.data['success'] ?? true;
    } catch (e) {
      debugPrint('初始化应用时出错: $e');
      return false;
    }
  }

  @override
  Future<ProvidersResponseModel> getProviders({String? directory}) async {
    try {
      final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
      final response = await dio.get('/provider', queryParameters: queryParams);
      debugPrint('Providers API 响应: ${response.data}');
      // Use OpenCode API format
      return ProvidersResponseModel.fromOpenCodeApi(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('解析提供商响应时出错: $e');
      // Return empty response on error
      return const ProvidersResponseModel(
        providers: [],
        defaultModels: {},
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getConfig({String? directory}) async {
    final queryParams = directory != null ? {'directory': directory} : <String, dynamic>{};
    final response = await dio.get('/config', queryParameters: queryParams);
    return response.data as Map<String, dynamic>;
  }
}
