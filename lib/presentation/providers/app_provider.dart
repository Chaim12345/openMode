import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/health_status.dart';
import '../../domain/entities/provider.dart';
import '../../domain/usecases/get_app_info.dart';
import '../../domain/usecases/get_providers.dart';
import '../../domain/usecases/check_connection.dart';
import '../../domain/usecases/update_server_config.dart';
import '../../domain/usecases/get_health_status.dart';
import '../../core/constants/api_constants.dart';

/// 应用状态枚举
enum AppStatus { initial, loading, loaded, error, disconnected }

/// 应用状态提供者
class AppProvider extends ChangeNotifier {
  final GetAppInfo _getAppInfo;
  final CheckConnection _checkConnection;
  final UpdateServerConfig _updateServerConfig;
  final GetProviders _getProviders;
  final GetHealthStatus _getHealthStatus;

  AppProvider({
    required GetAppInfo getAppInfo,
    required CheckConnection checkConnection,
    required UpdateServerConfig updateServerConfig,
    required GetProviders getProviders,
    required GetHealthStatus getHealthStatus,
  }) : _getAppInfo = getAppInfo,
       _checkConnection = checkConnection,
       _updateServerConfig = updateServerConfig,
       _getProviders = getProviders,
       _getHealthStatus = getHealthStatus;

  // 状态
  AppStatus _status = AppStatus.initial;
  AppInfo? _appInfo;
  String _errorMessage = '';
  String _serverHost = ApiConstants.defaultHost;
  int _serverPort = ApiConstants.defaultPort;
  bool _isConnected = false;
  ThemeMode _themeMode = ThemeMode.dark;
  
  // Selected model/provider state
  String? _selectedProviderId;
  String? _selectedModelId;
  String? _serverVersion;
  ProvidersResponse? _providersResponse;
  HealthStatus? _healthStatus;

  // Getters
  AppStatus get status => _status;
  AppInfo? get appInfo => _appInfo;
  String get errorMessage => _errorMessage;
  String get serverHost => _serverHost;
  int get serverPort => _serverPort;
  bool get isConnected => _isConnected;
  ThemeMode get themeMode => _themeMode;
  String get serverUrl => 'http://$_serverHost:$_serverPort';
  String? get selectedProviderId => _selectedProviderId;
  String? get selectedModelId => _selectedModelId;
  ProvidersResponse? get providersResponse => _providersResponse;
  String? get serverVersion => _serverVersion;
  HealthStatus? get healthStatus => _healthStatus;

  /// 获取应用信息
  Future<void> getAppInfo() async {
    _setStatus(AppStatus.loading);

    final result = await _getAppInfo();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _setStatus(AppStatus.error);
        _isConnected = false;
      },
      (appInfo) {
        _appInfo = appInfo;
        _setStatus(AppStatus.loaded);
        _isConnected = true;
      },
    );

    notifyListeners();
  }

  /// 检查服务器连接
  Future<void> checkConnection() async {
    // Fetch health status for version info
    await fetchHealthStatus();

    final result = await _checkConnection();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isConnected = false;
      },
      (connected) {
        _isConnected = connected;
        if (connected) {
          _errorMessage = '';
        }
      },
    );

    notifyListeners();
  }

  /// Fetch server health status
  Future<void> fetchHealthStatus() async {
    final result = await _getHealthStatus();
    result.fold(
      (failure) {
              },
      (healthStatus) {
        _healthStatus = healthStatus;
        _serverVersion = healthStatus.version;
      },
    );
    notifyListeners();
  }

  /// 更新服务器配置
  Future<bool> updateServerConfig(String host, int port) async {
    final params = UpdateServerConfigParams(host: host, port: port);
    final result = await _updateServerConfig(params);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _serverHost = host;
        _serverPort = port;
        _errorMessage = '';
        notifyListeners();
        return true;
      },
    );
  }

  /// 设置服务器配置（从本地存储加载）
  void setServerConfig(String host, int port) {
    _serverHost = host;
    _serverPort = port;
    notifyListeners();
  }

  /// 清除错误消息
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _status = AppStatus.initial;
    _appInfo = null;
    _errorMessage = '';
    _isConnected = false;
    notifyListeners();
  }

  void _setStatus(AppStatus status) {
    _status = status;
  }

  /// 获取提供商列表
  Future<ProvidersResponse?> getProviders() async {
    try {
      final result = await _getProviders();
      return result.fold(
        (failure) {
                    return null;
        },
        (response) {
          _providersResponse = response;
          // Set default selection if not already set
          if (_selectedProviderId == null && response.providers.isNotEmpty) {
            final firstProvider = response.providers.first;
            _selectedProviderId = firstProvider.id;
            _selectedModelId = firstProvider.models.keys.first;
          }
          notifyListeners();
          return response;
        },
      );
    } catch (e) {
            return null;
    }
  }

  /// 更新选中的模型
  void updateSelectedModel(String providerId, String modelId) {
    _selectedProviderId = providerId;
    _selectedModelId = modelId;
    notifyListeners();
  }

  /// Load theme mode from SharedPreferences
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode');
    if (saved != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == saved,
        orElse: () => ThemeMode.dark,
      );
      notifyListeners();
    }
  }

  /// Set and persist theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
  }
}
