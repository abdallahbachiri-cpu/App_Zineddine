import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:cuisinous/core/config/environment_config.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'dart:developer' as devtools;

class ChatMessageModel {
  final String id;
  final String orderId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String? ?? '',
      receiverId: json['receiverId'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiClient _api = getIt<ApiClient>();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  // SSE state
  StreamSubscription<String>? _sseSubscription;
  String _sseBuffer = '';
  String? _subscribedOrderId;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadMessages(String orderId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.get('/chat/$orderId');
      final List<dynamic> data = response.data as List<dynamic>? ?? [];
      _messages = data
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _unreadCount = 0;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ChatMessageModel?> sendMessage(String orderId, String text) async {
    try {
      final response = await _api.post('/chat/$orderId', body: {'message': text});
      final msg = ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
      // Don't add locally — the SSE event will deliver it back so we avoid duplicates.
      // If SSE is not connected, fall back to adding it immediately.
      if (_sseSubscription == null) {
        _messages = [..._messages, msg];
        notifyListeners();
      }
      return msg;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> markAsRead(String orderId) async {
    try {
      await _api.put('/chat/$orderId/read');
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  /// Adds a message received via SSE/Mercure without a round-trip.
  void addIncomingMessage(ChatMessageModel msg) {
    if (_messages.any((m) => m.id == msg.id)) return;
    _messages = [..._messages, msg];
    _unreadCount++;
    notifyListeners();
  }

  // ── Mercure SSE ────────────────────────────────────────────────────────────

  /// Opens a persistent SSE connection to the Mercure hub for [orderId].
  /// Automatically reuses an existing connection for the same order.
  Future<void> subscribeToMercure(String orderId) async {
    if (_subscribedOrderId == orderId && _sseSubscription != null) return;

    unsubscribeFromMercure();
    _subscribedOrderId = orderId;

    final token = await getIt<SecureStorageService>().getAccessToken();
    final mercureUrl = _buildMercureUrl(orderId);

    devtools.log('[Chat SSE] Connecting to $mercureUrl');

    try {
      final dio = Dio();
      final response = await dio.get<ResponseBody>(
        mercureUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          sendTimeout: null,
          receiveTimeout: null,
        ),
      );

      _sseSubscription = response.data!.stream
          .cast<Uint8List>()
          .transform(utf8.decoder as StreamTransformer<Uint8List, dynamic>)
          .transform(const LineSplitter())
          .listen(
            _processSseLine,
            onError: (Object e) => devtools.log('[Chat SSE] Stream error: $e'),
            onDone: () => devtools.log('[Chat SSE] Connection closed'),
            cancelOnError: false,
          );

      devtools.log('[Chat SSE] Connected for order $orderId');
    } catch (e) {
      devtools.log('[Chat SSE] Failed to connect: $e');
    }
  }

  /// Closes the SSE connection.
  void unsubscribeFromMercure() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
    _subscribedOrderId = null;
    _sseBuffer = '';
    devtools.log('[Chat SSE] Disconnected');
  }

  void _processSseLine(String line) {
    if (line.startsWith('data: ')) {
      _sseBuffer += line.substring(6);
    } else if (line.isEmpty && _sseBuffer.isNotEmpty) {
      _handleSseData(_sseBuffer);
      _sseBuffer = '';
    }
  }

  void _handleSseData(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final msg = ChatMessageModel.fromJson(json);
      addIncomingMessage(msg);
    } catch (e) {
      devtools.log('[Chat SSE] Failed to parse event: $e');
    }
  }

  String _buildMercureUrl(String orderId) {
    final base = EnvironmentConfig.apiBaseUrl.replaceAll(RegExp(r'/$'), '');
    final topic = Uri.encodeComponent('/chat/$orderId');
    return '$base/.well-known/mercure?topic=$topic';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  void clear() {
    unsubscribeFromMercure();
    _messages = [];
    _error = null;
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromMercure();
    super.dispose();
  }
}
