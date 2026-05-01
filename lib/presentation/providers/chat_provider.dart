import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/datasources/app_local_datasource.dart';
import '../../data/models/chat_session_model.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/entities/provider.dart';
import '../../domain/usecases/send_chat_message.dart';
import '../../domain/usecases/get_chat_sessions.dart';
import '../../domain/usecases/create_chat_session.dart';
import '../../domain/usecases/get_chat_messages.dart';
import '../../domain/usecases/get_providers.dart';
import '../../domain/usecases/delete_chat_session.dart';
import '../../domain/usecases/update_chat_session.dart';
import '../../domain/usecases/share_chat_session.dart';
import '../../domain/usecases/unshare_chat_session.dart';
import '../../domain/usecases/abort_session.dart';
import '../../domain/usecases/revert_message.dart';
import '../../domain/usecases/unrevert_messages.dart';
import '../../domain/usecases/fork_session.dart';
import '../../core/errors/failures.dart';
import '../widgets/chat_input_widget.dart';
import 'project_provider.dart';

/// Chat state enum
enum ChatState { initial, loading, loaded, error, sending }

/// Chat provider
class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required this.sendChatMessage,
    required this.getChatSessions,
    required this.createChatSession,
    required this.getChatMessages,
    required this.getProviders,
    required this.deleteChatSession,
    required this.updateChatSession,
    required this.shareChatSession,
    required this.unshareChatSession,
    required this.abortSession,
    required this.revertMessage,
    required this.unrevertMessages,
    required this.forkSession,
    required this.projectProvider,
    required this.localDataSource,
  });

  // Scroll callback
  VoidCallback? _scrollToBottomCallback;

  final SendChatMessage sendChatMessage;
  final GetChatSessions getChatSessions;
  final CreateChatSession createChatSession;
  final GetChatMessages getChatMessages;
  final GetProviders getProviders;
  final DeleteChatSession deleteChatSession;
  final UpdateChatSession updateChatSession;
  final ShareChatSession shareChatSession;
  final UnshareChatSession unshareChatSession;
  final AbortSession abortSession;
  final RevertMessage revertMessage;
  final UnrevertMessages unrevertMessages;
  final ForkSession forkSession;
  final ProjectProvider projectProvider;
  final AppLocalDataSource localDataSource;

  ChatState _state = ChatState.initial;
  List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  String? _errorMessage;
  StreamSubscription<dynamic>? _messageSubscription;

  // Project and provider state
  String? _currentProjectId;
  List<Provider> _providers = [];
  Map<String, String> _defaultModels = {};
  String? _selectedProviderId;
  String? _selectedModelId;
  String _selectedAgent = 'general';

  // Getters
  ChatState get state => _state;
  List<ChatSession> get sessions => _sessions;
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  String? get errorMessage => _errorMessage;
  String? get currentProjectId => _currentProjectId;
  List<Provider> get providers => _providers;
  Map<String, String> get defaultModels => _defaultModels;
  String? get selectedProviderId => _selectedProviderId;
  String? get selectedModelId => _selectedModelId;
  bool get isSending => _state == ChatState.sending;

  /// Set scroll to bottom callback
  void setScrollToBottomCallback(VoidCallback? callback) {
    _scrollToBottomCallback = callback;
  }

  /// Set state
  void _setState(ChatState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Set error
  void _setError(String message) {
    _errorMessage = message;
    _setState(ChatState.error);
  }

  /// Initialize providers
  Future<void> initializeProviders() async {
    try {
      final result = await getProviders();
      result.fold(
        (failure) {
          debugPrint('Failed to get providers: ${failure.toString()}');
          // Use defaults as fallback
          _selectedProviderId = 'moonshotai-cn';
          _selectedModelId = 'kimi-k2-turbo-preview';
        },
        (providersResponse) {
          debugPrint('Got ${providersResponse.providers.length} providers');
          _providers = providersResponse.providers;
          _defaultModels = providersResponse.defaultModels;

          if (_providers.isNotEmpty) {
            Provider selectedProvider;
            final anthropicProvider = _providers
                .where((p) => p.id == 'anthropic')
                .firstOrNull;
            if (anthropicProvider != null) {
              selectedProvider = anthropicProvider;
            } else {
              selectedProvider = _providers.first;
            }

            _selectedProviderId = selectedProvider.id;

            if (_defaultModels.containsKey(selectedProvider.id)) {
              _selectedModelId = _defaultModels[selectedProvider.id];
            } else if (selectedProvider.models.isNotEmpty) {
              _selectedModelId = selectedProvider.models.keys.first;
            }

            debugPrint('Selected provider: $_selectedProviderId, model: $_selectedModelId');
          }
        },
      );
    } catch (e) {
      debugPrint('Error initializing providers: $e');
      _selectedProviderId = 'moonshotai-cn';
      _selectedModelId = 'kimi-k2-turbo-preview';
    }

    // Load saved provider/model selection (overrides defaults)
    await loadProviderModelSelection();

    notifyListeners();
  }

  /// 加载会话列表
  Future<void> loadSessions() async {
    if (_state == ChatState.loading) return;
    
    _setState(ChatState.loading);
    clearError();

    try {
      // 首先尝试从缓存加载
      await _loadCachedSessions();
      
      // 然后从服务器获取最新数据
      final result = await getChatSessions();
      
      result.fold(
        (failure) => _handleFailure(failure),
        (sessions) async {
          _sessions = sessions;
          _setState(ChatState.loaded);
          
          // 保存到缓存
          await _saveCachedSessions(sessions);
          
          // 恢复上次选择的会话
          await loadLastSession();
        },
      );
    } catch (e) {
      _setError('加载会话列表失败: ${e.toString()}');
    }
  }

  /// 从缓存加载会话列表
  Future<void> _loadCachedSessions() async {
    try {
      final cachedData = await localDataSource.getCachedSessions();
      if (cachedData != null) {
        final List<dynamic> jsonList = json.decode(cachedData);
        final cachedSessions = jsonList
            .map((json) => ChatSessionModel.fromJson(json).toDomain())
            .toList();
        
        if (cachedSessions.isNotEmpty) {
          _sessions = cachedSessions;
          _setState(ChatState.loaded);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('加载缓存会话失败: $e');
    }
  }

  /// 保存会话列表到缓存
  Future<void> _saveCachedSessions(List<ChatSession> sessions) async {
    try {
      final jsonList = sessions
          .map((session) => ChatSessionModel.fromDomain(session).toJson())
          .toList();
      final jsonString = json.encode(jsonList);
      await localDataSource.saveCachedSessions(jsonString);
    } catch (e) {
      debugPrint('保存会话缓存失败: $e');
    }
  }

  /// 保存当前会话ID
  Future<void> _saveCurrentSessionId(String sessionId) async {
    try {
      await localDataSource.saveCurrentSessionId(sessionId);
    } catch (e) {
      debugPrint('保存当前会话ID失败: $e');
    }
  }

  /// 加载上次选择的会话
  Future<void> loadLastSession() async {
    try {
      final sessionId = await localDataSource.getCurrentSessionId();
      if (sessionId != null) {
        final session = _sessions.where((s) => s.id == sessionId).firstOrNull;
        if (session != null) {
          await selectSession(session);
        }
      }
    } catch (e) {
      debugPrint('加载上次会话失败: $e');
    }
  }

  /// 创建新会话
  Future<void> createNewSession({String? parentId, String? title}) async {
    final projectId = projectProvider.currentProjectId;
    final directory = projectProvider.currentProject?.path;
    _setState(ChatState.loading);

    // 生成基于时间的标题
    final now = DateTime.now();
    final defaultTitle = title ?? _generateSessionTitle(now);

    final result = await createChatSession(
      CreateChatSessionParams(
        projectId: projectId,
        input: SessionCreateInput(
          parentId: parentId,
          title: defaultTitle,
        ),
        directory: directory,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (session) {
      _sessions.insert(0, session);
      _currentSession = session;
      _messages.clear(); // 确保新会话开始时消息列表为空
      _setState(ChatState.loaded);
    });
  }

  /// 生成基于时间的会话标题
  String _generateSessionTitle(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(time.year, time.month, time.day);

    if (sessionDate == today) {
      // 今天的对话显示时间
      return 'Today ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final difference = today.difference(sessionDate).inDays;
      if (difference == 1) {
        // 昨天的对话
        return 'Yesterday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else if (difference < 7) {
        // 一周内的对话显示星期几
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final weekday = weekdays[time.weekday - 1];
        return '$weekday ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      } else {
        // 更早的对话显示日期
        return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  /// 选择会话
  Future<void> selectSession(ChatSession session) async {
    if (_currentSession?.id == session.id) return;

    // 清空当前消息列表
    _messages.clear();
    _currentSession = session;
    notifyListeners();

    // 保存当前会话ID
    await _saveCurrentSessionId(session.id);

    // 加载新会话的消息
    await loadMessages(session.id);
  }

  /// 加载消息列表
  Future<void> loadMessages(String sessionId) async {
    // 同步项目ID（根据 ProjectProvider），新接口对 projectId 非必需
    _currentProjectId = projectProvider.currentProjectId;

    _setState(ChatState.loading);

    final result = await getChatMessages(
      GetChatMessagesParams(
        projectId: projectProvider.currentProjectId,
        sessionId: sessionId,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (messages) {
      _messages = messages;
      _setState(ChatState.loaded);
    });
  }

  /// 发送消息
  Future<void> sendMessage(String text, {List<FileAttachment>? attachments}) async {
    if (_currentSession == null) return;
    if (text.trim().isEmpty && (attachments == null || attachments.isEmpty)) return;

    _setState(ChatState.sending);

    // Sync project ID
    _currentProjectId = projectProvider.currentProjectId;

    // Generate message ID
    final messageId = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    // Build input parts from text and attachments
    final List<ChatInputPart> inputParts = [];

    if (text.trim().isNotEmpty) {
      inputParts.add(TextInputPart(text: text));
    }

    if (attachments != null) {
      for (final attachment in attachments) {
        inputParts.add(FileInputPart(
          source: FileInputSource(
            path: attachment.path,
            text: FileInputSourceText(
              value: attachment.content,
              start: 0,
              end: attachment.content.length,
            ),
            type: attachment.type,
          ),
          filename: attachment.name,
        ));
      }
    }

    // Add user message to UI
    final userMessage = UserMessage(
      id: messageId,
      sessionId: _currentSession!.id,
      time: DateTime.now(),
      parts: [
        TextPart(
          id: '${messageId}_text',
          messageId: messageId,
          sessionId: _currentSession!.id,
          text: text,
          time: DateTime.now(),
        ),
      ],
    );

    _messages.add(userMessage);
    notifyListeners();

    // Ensure providers are initialized
    if (_selectedProviderId == null || _selectedModelId == null) {
      await initializeProviders();
    }

    // Create chat input
    final input = ChatInput(
      messageId: messageId,
      providerId: _selectedProviderId ?? 'anthropic',
      modelId: _selectedModelId ?? 'claude-3-5-sonnet-20241022',
      agent: _selectedAgent,
      system: '',
      tools: const {},
      parts: inputParts,
    );

    // Cancel previous subscription
    _messageSubscription?.cancel();

    // Send message and listen to stream
    _messageSubscription =
        sendChatMessage(
      SendChatMessageParams(
        projectId: projectProvider.currentProjectId,
        sessionId: _currentSession!.id,
        input: input,
      ),
    ).listen(
      (result) {
        result.fold((failure) => _handleFailure(failure), (message) {
          _updateOrAddMessage(message);
        });
      },
      onError: (error) {
        _setError('Failed to send message: $error');
      },
      onDone: () {
        _setState(ChatState.loaded);
      },
    );
  }


  void _updateOrAddMessage(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      // 更新现有消息
      _messages[index] = message;
      debugPrint('🔄 更新消息: ${message.id}, 部件数量: ${message.parts.length}');
    } else {
      // 添加新消息
      _messages.add(message);
      debugPrint('➕ 添加新消息: ${message.id}, 角色: ${message.role}');
    }

    // 检查是否有未完成的助手消息
    if (message is AssistantMessage) {
      debugPrint('🤖 助手消息状态: ${message.isCompleted ? "已完成" : "进行中"}');
      if (message.isCompleted && _state == ChatState.sending) {
        debugPrint('✅ 消息完成，更新状态为已加载');
        _setState(ChatState.loaded);
      }
    }

    notifyListeners();

    // 触发自动滚动
    _scrollToBottomCallback?.call();
  }

  /// 处理失败
  void _handleFailure(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        _setError('网络连接失败，请检查网络设置');
        break;
      case ServerFailure:
        _setError('服务器错误，请稍后再试');
        break;
      case NotFoundFailure:
        _setError('资源不存在');
        break;
      case ValidationFailure:
        _setError('输入参数无效');
        break;
      default:
        _setError('未知错误，请稍后再试');
        break;
    }
  }

  /// 清除错误
  void clearError() {
    _errorMessage = null;
    if (_state == ChatState.error) {
      _setState(ChatState.loaded);
    }
  }

  /// 删除会话
  Future<void> deleteSession(String sessionId) async {
    // 同步项目ID（根据 ProjectProvider）
    _currentProjectId = projectProvider.currentProjectId;

    final result = await deleteChatSession(
      DeleteChatSessionParams(
        projectId: projectProvider.currentProjectId,
        sessionId: sessionId,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (_) {
      // 从本地列表中移除会话
      _sessions.removeWhere((session) => session.id == sessionId);

      // 如果删除的是当前会话，清空当前会话和消息
      if (_currentSession?.id == sessionId) {
        _currentSession = null;
        _messages.clear();

        // 如果还有其他会话，选择第一个
        if (_sessions.isNotEmpty) {
          selectSession(_sessions.first);
        }
      }

      notifyListeners();
    });
  }

  /// Refresh current session
  Future<void> refresh() async {
    if (_currentSession != null) {
      await loadMessages(_currentSession!.id);
    } else {
      if (_sessions.isNotEmpty) {
        _setState(ChatState.loaded);
      }
    }
  }

  /// Update session (e.g. rename)
  Future<void> updateSession(String sessionId, {String? title}) async {
    final projectId = projectProvider.currentProjectId;

    final result = await updateChatSession(
      UpdateChatSessionParams(
        projectId: projectId,
        sessionId: sessionId,
        input: SessionUpdateInput(title: title),
      ),
    );

    result.fold((failure) => _handleFailure(failure), (updatedSession) {
      // Update session in local list
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }
      // Update current session if it's the one being renamed
      if (_currentSession?.id == sessionId) {
        _currentSession = updatedSession;
      }
      notifyListeners();
    });
  }

  /// Share session
  Future<void> shareCurrentSession(String sessionId) async {
    final projectId = projectProvider.currentProjectId;

    final result = await shareChatSession(
      ShareChatSessionParams(
        projectId: projectId,
        sessionId: sessionId,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (updatedSession) {
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }
      if (_currentSession?.id == sessionId) {
        _currentSession = updatedSession;
      }
      notifyListeners();
    });
  }

  /// Unshare session
  Future<void> unshareCurrentSession(String sessionId) async {
    final projectId = projectProvider.currentProjectId;

    final result = await unshareChatSession(
      UnshareChatSessionParams(
        projectId: projectId,
        sessionId: sessionId,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (updatedSession) {
      final index = _sessions.indexWhere((s) => s.id == sessionId);
      if (index != -1) {
        _sessions[index] = updatedSession;
      }
      if (_currentSession?.id == sessionId) {
        _currentSession = updatedSession;
      }
      notifyListeners();
    });
  }

  /// Abort current generation
  Future<void> abortCurrentSession() async {
    if (_currentSession == null) return;

    final projectId = projectProvider.currentProjectId;

    _messageSubscription?.cancel();
    _messageSubscription = null;

    final result = await abortSession(
      AbortSessionParams(
        projectId: projectId,
        sessionId: _currentSession!.id,
      ),
    );

    result.fold((failure) {
      debugPrint('Abort failed: ${failure.message}');
    }, (_) {
      _setState(ChatState.loaded);
    });
  }

  /// Revert (undo) a specific message
  Future<void> revertMessageAction(String messageId) async {
    if (_currentSession == null) return;

    final projectId = projectProvider.currentProjectId;

    final result = await revertMessage(
      RevertMessageParams(
        projectId: projectId,
        sessionId: _currentSession!.id,
        messageId: messageId,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (_) {
      // Reload messages to reflect the revert
      loadMessages(_currentSession!.id);
    });
  }

  /// Unrevert (redo) previously reverted messages
  Future<void> unrevertMessagesAction() async {
    if (_currentSession == null) return;

    final projectId = projectProvider.currentProjectId;

    final result = await unrevertMessages(
      UnrevertMessagesParams(
        projectId: projectId,
        sessionId: _currentSession!.id,
      ),
    );

    result.fold((failure) => _handleFailure(failure), (_) {
      // Reload messages to reflect the unrevert
      loadMessages(_currentSession!.id);
    });
  }

  /// Select a specific provider and model
  void selectProviderModel(String providerId, String modelId) {
    _selectedProviderId = providerId;
    _selectedModelId = modelId;
    notifyListeners();

    // Persist selection
    _saveProviderModelSelection(providerId, modelId);
  }

  /// Select a specific agent
  void setSelectedAgent(String agent) {
    _selectedAgent = agent;
    notifyListeners();
  }

  /// Save provider/model selection to local storage
  Future<void> _saveProviderModelSelection(String providerId, String modelId) async {
    try {
      await localDataSource.saveSelectedProvider(providerId);
      await localDataSource.saveSelectedModel(modelId);
    } catch (e) {
      debugPrint('Failed to save provider/model selection: $e');
    }
  }

  /// Load saved provider/model selection from local storage
  Future<void> loadProviderModelSelection() async {
    try {
      final savedProvider = await localDataSource.getSelectedProvider();
      final savedModel = await localDataSource.getSelectedModel();
      if (savedProvider != null) _selectedProviderId = savedProvider;
      if (savedModel != null) _selectedModelId = savedModel;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load provider/model selection: $e');
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  /// Fork the current session into a new session
  Future<void> forkCurrentSession() async {
    if (_currentSession == null) return;

    final projectId = projectProvider.currentProjectId;

    final result = await forkSession(
      ForkSessionParams(
        projectId: projectId,
        sessionId: _currentSession!.id,
      ),
    );

    result.fold(
      (failure) => _handleFailure(failure),
      (forkedSession) {
        _sessions.insert(0, forkedSession);
        _currentSession = forkedSession;
        _messages = [];
        notifyListeners();
      },
    );
  }
}
