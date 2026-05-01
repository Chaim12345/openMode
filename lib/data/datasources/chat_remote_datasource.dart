import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/chat_message_model.dart';
import '../models/chat_session_model.dart';
import '../../core/errors/exceptions.dart';

/// Chat remote data source
abstract class ChatRemoteDataSource {
  /// Get session list
  Future<List<ChatSessionModel>> getSessions({String? directory});

  /// Get session details
  Future<ChatSessionModel> getSession(String projectId, String sessionId, {String? directory});

  /// Create session
  Future<ChatSessionModel> createSession(String projectId, SessionCreateInputModel input, {String? directory});

  /// 更新会话
  Future<ChatSessionModel> updateSession(
    String projectId,
    String sessionId,
    SessionUpdateInputModel input, {
    String? directory,
  });

  /// 删除会话
  Future<void> deleteSession(String projectId, String sessionId, {String? directory});

  /// 分享会话
  Future<ChatSessionModel> shareSession(String projectId, String sessionId, {String? directory});

  /// 取消分享会话
  Future<ChatSessionModel> unshareSession(String projectId, String sessionId, {String? directory});

  /// 获取会话消息列表
  Future<List<ChatMessageModel>> getMessages(String projectId, String sessionId, {String? directory});

  /// 获取消息详情
  Future<ChatMessageModel> getMessage(String projectId, String sessionId, String messageId, {String? directory});

  /// 发送聊天消息（流式）
  Stream<ChatMessageModel> sendMessage(String projectId, String sessionId, ChatInputModel input, {String? directory});

  /// 中止会话
  Future<void> abortSession(String projectId, String sessionId, {String? directory});

  /// 撤销消息
  Future<void> revertMessage(String projectId, String sessionId, String messageId, {String? directory});

  /// 恢复撤销的消息
  Future<void> unrevertMessages(String projectId, String sessionId, {String? directory});

  /// 初始化会话
  Future<void> initSession(
    String projectId,
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
    String? directory,
  });

  /// 总结会话
  Future<void> summarizeSession(String projectId, String sessionId, {String? directory});
}

/// Chat remote data source实现
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  const ChatRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<ChatSessionModel>> getSessions({String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，会话列表端点是 /session，不需要 projectId 路径参数
      final response = await dio.get(
        '/session',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ChatSessionModel.fromJson(json)).toList();
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> getSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，获取单个会话端点是 /session/{id}，不需要 projectId 路径参数
      final response = await dio.get(
        '/session/$sessionId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> createSession(String projectId, SessionCreateInputModel input, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，会话创建端点是 /session，不需要 projectId 路径参数
      final response = await dio.post(
        '/session',
        data: input.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> updateSession(
    String projectId,
    String sessionId,
    SessionUpdateInputModel input, {
    String? directory,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，更新会话端点是 /session/{id}，不需要 projectId 路径参数
      final response = await dio.patch(
        '/session/$sessionId',
        data: input.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> deleteSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，删除会话端点是 /session/{id}，不需要 projectId 路径参数
      final response = await dio.delete(
        '/session/$sessionId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> shareSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，分享会话端点是 /session/{id}/share，不需要 projectId 路径参数
      final response = await dio.post(
        '/session/$sessionId/share',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatSessionModel> unshareSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      // 根据新的 API 规范，取消分享会话端点是 /session/{id}/share，不需要 projectId 路径参数
      final response = await dio.delete(
        '/session/$sessionId/share',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        return ChatSessionModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.get(
        '/session/$sessionId/message',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          // 会话历史可能较大，提升接收超时以避免 60 秒中断
          receiveTimeout: const Duration(minutes: 3),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Each item follows { info: MessageObject, parts: Part[] }
        // Flatten to a single map compatible with ChatMessageModel.fromJson
        return data.map((item) {
          final map = item as Map<String, dynamic>;
          final info = (map['info'] as Map<String, dynamic>?) ?? <String, dynamic>{};
          final parts = (map['parts'] as List<dynamic>?) ?? <dynamic>[];
          return ChatMessageModel.fromJson({
            ...info,
            'parts': parts,
          });
        }).toList();
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<ChatMessageModel> getMessage(String projectId, String sessionId, String messageId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.get(
        '/session/$sessionId/message/$messageId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          // 单条消息也可能较慢，统一提升接收超时
          receiveTimeout: const Duration(minutes: 3),
        ),
      );

      if (response.statusCode == 200) {
        return ChatMessageModel.fromJson(response.data);
      } else {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Stream<ChatMessageModel> sendMessage(String projectId, String sessionId, ChatInputModel input, {String? directory}) async* {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      debugPrint('=== 开始发送消息 ===');
      debugPrint('会话ID: $sessionId');
      debugPrint('消息ID: ${input.messageId}');
      debugPrint('==================');

      // 启动 SSE 监听器，监听消息更新事件
      final eventController = StreamController<ChatMessageModel>();
      late StreamSubscription eventSubscription;
      bool messageCompleted = false;

      // 创建 SSE 监听器
      try {
        final eventResponse = await dio.get(
          '/event',
          options: Options(
            headers: {
              'Accept': 'text/event-stream',
              'Cache-Control': 'no-cache',
            },
            responseType: ResponseType.stream,
          ),
        );

        if (eventResponse.statusCode == 200) {
      debugPrint('✅ 成功连接到事件流');

          eventSubscription = (eventResponse.data as ResponseBody).stream
              .transform(
                StreamTransformer.fromHandlers(
                  handleData: (Uint8List data, EventSink<String> sink) {
                    sink.add(utf8.decode(data));
                  },
                ),
              )
              .transform(const LineSplitter())
              .where((line) => line.startsWith('data: '))
              .map((line) => line.substring(6)) // 移除 "data: " 前缀
              .where((data) => data.isNotEmpty && data != '[DONE]')
              .listen(
                (eventData) {
                  try {
                    final event = jsonDecode(eventData) as Map<String, dynamic>;
                    final eventType = event['type'] as String?;

      debugPrint('📨 收到事件: $eventType');

                    if (eventType == 'message.updated') {
                      final properties =
                          event['properties'] as Map<String, dynamic>?;
                      final info = properties?['info'] as Map<String, dynamic>?;

                      if (info != null && info['sessionID'] == sessionId) {
      debugPrint('🔄 消息更新事件: ${info['id']}');
                        // 获取完整的消息信息（包括 parts）
                         _getCompleteMessage(projectId, sessionId, info['id'] as String)
                             .then((message) {
                              if (message != null) {
                                eventController.add(message);

                                // 检查消息是否完成
                                if (message.completedTime != null &&
                                    !messageCompleted) {
                                  messageCompleted = true;
      debugPrint('🎉 消息完成，准备关闭事件流');
                                  // 延迟关闭，确保最后的更新被处理
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      eventSubscription.cancel();
                                      eventController.close();
                                    },
                                  );
                                }
                              }
                            })
                            .catchError((error) {
      debugPrint('获取完整消息失败: $error');
                            });
                      }
                    } else if (eventType == 'message.part.updated') {
                      final properties =
                          event['properties'] as Map<String, dynamic>?;
                      final part = properties?['part'] as Map<String, dynamic>?;

                      if (part != null && part['sessionID'] == sessionId) {
                        debugPrint(
                          '🔄 消息部件更新: ${part['messageID']} - ${part['id']}',
                        );
                        // 获取完整的消息信息
                         _getCompleteMessage(projectId, sessionId, part['messageID'] as String)
                             .then((message) {
                              if (message != null) {
                                eventController.add(message);

                                // 检查消息是否完成
                                if (message.completedTime != null &&
                                    !messageCompleted) {
                                  messageCompleted = true;
      debugPrint('🎉 消息完成，准备关闭事件流');
                                  // 延迟关闭，确保最后的更新被处理
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      eventSubscription.cancel();
                                      eventController.close();
                                    },
                                  );
                                }
                              }
                            })
                            .catchError((error) {
      debugPrint('获取完整消息失败: $error');
                            });
                      }
                    }
                  } catch (e) {
      debugPrint('解析事件失败: $e');
      debugPrint('事件数据: $eventData');
                  }
                },
                onError: (error) {
      debugPrint('事件流错误: $error');
                  eventController.addError(error);
                },
                onDone: () {
      debugPrint('事件流结束');
                  eventController.close();
                },
              );
        }
      } catch (e) {
      debugPrint('连接事件流失败: $e');
      }

      // 发送消息请求
      final response = await dio.post(
        '/session/$sessionId/message',
        data: input.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
      debugPrint('✅ 消息发送成功');

        // 获取初始消息状态
        if (input.messageId != null) {
          final initialMessage = await _getCompleteMessage(projectId, sessionId, input.messageId!);
          if (initialMessage != null) {
            yield initialMessage;
          }
        }

        // 监听后续的消息更新
        await for (final message in eventController.stream) {
          yield message;
        }
      } else {
        throw const ServerException('发送消息失败');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('会话不存在');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('消息格式错误');
      }
      throw const ServerException('发送消息失败');
    } catch (e) {
      debugPrint('发送消息异常: $e');
      throw const ServerException('发送消息失败');
    }
  }

  /// 获取完整的消息信息（包括 parts）
  Future<ChatMessageModel?> _getCompleteMessage(String projectId, String sessionId, String messageId) async {
    try {
      final response = await dio.get('/session/$sessionId/message/$messageId');

      if (response.statusCode == 200) {
        final info = response.data['info'] as Map<String, dynamic>;
        final parts = response.data['parts'] as List<dynamic>;

        return ChatMessageModel.fromJson({...info, 'parts': parts});
      }
    } catch (e) {
      debugPrint('获取完整消息失败: $e');
    }
    return null;
  }

  @override
  Future<void> abortSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.post(
        '/session/$sessionId/abort',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> revertMessage(String projectId, String sessionId, String messageId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.post(
        '/session/$sessionId/revert',
        data: {'messageID': messageId},
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> unrevertMessages(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.post(
        '/session/$sessionId/unrevert',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> initSession(
    String projectId,
    String sessionId, {
    required String messageId,
    required String providerId,
    required String modelId,
    String? directory,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.post(
        '/session/$sessionId/init',
        data: {
          'messageID': messageId,
          'providerID': providerId,
          'modelID': modelId,
        },
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      if (e.response?.statusCode == 400) {
        throw const ValidationException('参数验证失败');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }

  @override
  Future<void> summarizeSession(String projectId, String sessionId, {String? directory}) async {
    try {
      final queryParams = <String, String>{};
      if (directory != null) {
        queryParams['directory'] = directory;
      }
      
      final response = await dio.post(
        '/session/$sessionId/summarize',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode != 200) {
        throw const ServerException('服务器错误');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('资源未找到');
      }
      throw const ServerException('服务器错误');
    } catch (e) {
      throw const ServerException('服务器错误');
    }
  }
}
