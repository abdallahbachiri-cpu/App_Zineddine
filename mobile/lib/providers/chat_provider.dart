import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/api_client_service.dart';

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
  final ApiClientService _api = sl<ApiClientService>();

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

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
      final response = await _api.post('/chat/$orderId', data: {'message': text});
      final msg = ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
      _messages = [..._messages, msg];
      notifyListeners();
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

  void clear() {
    _messages = [];
    _error = null;
    _unreadCount = 0;
    notifyListeners();
  }
}
