import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/maintenance_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatModel> _chats = [];
  RealtimeChannel? _chatListSubscription;

  List<ChatModel> get chats => _chats;

  ChatProvider() {
    fetchChats();
  }

  Future<void> fetchChats() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await ChatService.fetchChats();
      _chats.clear();
      for (final item in data) {
        final messagesData = item['messages'] as List<dynamic>? ?? [];
        final messages = messagesData.map((m) => MessageModel.fromSupabase(m)).toList();
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        _chats.add(ChatModel.fromSupabase(item, messages: messages));
      }
      notifyListeners();
      subscribeToChats();
    } catch (e) {
      debugPrint('Error fetching chats from Supabase: $e');
    }
  }

  void subscribeToChats() {
    _chatListSubscription?.unsubscribe();
    final chatIds = _chats.map((c) => c.chatId).toList();
    if (chatIds.isEmpty) return;

    _chatListSubscription = ChatService.subscribeToChatList(
      chatIds: chatIds,
      onUpdate: () {
        fetchChats();
      },
    );
  }

  Future<void> sendMessage(String chatId, MessageModel msg) async {
    // 1. Optimistic local UI update
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final updatedMessages = List<MessageModel>.from(chat.messages)
        ..insert(0, msg);

      _chats[index] = chat.copyWith(
        messages: updatedMessages,
        lastMessageTime: msg.timestamp,
      );
      notifyListeners();
    }

    // 2. Persist to Supabase
    try {
      await ChatService.sendMessage(chatId: chatId, text: msg.text);
    } catch (e) {
      debugPrint('Error sending message to Supabase: $e');
      // On failure, reload list to revert local state
      fetchChats();
    }
  }

  Future<void> markAsRead(String chatId) async {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final updatedMessages = chat.messages.map((msg) {
        if (!msg.isRead) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      _chats[index] = chat.copyWith(messages: updatedMessages);
      notifyListeners();
    }

    try {
      await ChatService.markChatAsRead(chatId);
    } catch (e) {
      debugPrint('Error marking chat as read in Supabase: $e');
    }
  }

  /// Get an existing chat conversation between currentUser and otherUser, or create a new one.
  Future<String> getOrCreateChat(UserModel currentUser, UserModel otherUser) async {
    try {
      final chatId = await ChatService.getOrCreateChat(otherUserId: otherUser.id);
      await fetchChats();
      return chatId;
    } catch (e) {
      debugPrint('Error getOrCreateChat: $e');
      return '';
    }
  }

  /// Create or reuse a chat session for a maintenance request.
  /// Fully persists the request to MaintenanceService and the chat to ChatService on Supabase.
  Future<String> createMaintenanceChat({
    required UserModel currentUser,
    required String workshopId,
    required UserModel targetWorkshop,
    required String serviceType,
    required String problemDescription,
    double? systemCapacityKw,
    String? inverterBrand,
    String? batteryType,
  }) async {
    try {
      // 1. Create maintenance request in database
      final request = await MaintenanceService.createRequest(
        workshopId: workshopId,
        serviceType: serviceType,
        problemDescription: problemDescription,
        systemCapacityKw: systemCapacityKw,
        inverterBrand: inverterBrand,
        batteryType: batteryType,
      );

      final requestId = request['id'] as String;

      // 2. Get or create chat between these users linked to this request
      final chatId = await ChatService.getOrCreateChat(
        otherUserId: targetWorkshop.id,
        maintenanceRequestId: requestId,
      );

      // 3. Send initial request summary message in the chat
      final summaryText = '📋 طلب خدمة جديد:\n'
          'نوع الخدمة: $serviceType\n'
          '${systemCapacityKw != null ? 'قدرة المنظومة: $systemCapacityKw كيلوواط\n' : ''}'
          '${inverterBrand != null && inverterBrand.isNotEmpty ? 'نوع العاكس: $inverterBrand\n' : ''}'
          '${batteryType != null && batteryType.isNotEmpty ? 'نوع البطارية: $batteryType\n' : ''}'
          'تفاصيل المشكلة: $problemDescription';

      await ChatService.sendMessage(chatId: chatId, text: summaryText);

      await fetchChats();

      return chatId;
    } catch (e) {
      debugPrint('Error creating maintenance request chat: $e');
      rethrow;
    }
  }

  /// Clears all messages in [chatId] while keeping the chat visible in the list.
  void clearChat(String chatId) {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      _chats[index] = _chats[index].copyWith(messages: []);
      notifyListeners();
    }
  }

  /// Permanently removes the chat with [chatId] from the inbox.
  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((c) => c.chatId == chatId);
    notifyListeners();

    try {
      await ChatService.deleteChat(chatId);
    } catch (e) {
      debugPrint('Error deleting chat from Supabase: $e');
      await fetchChats();
    }
  }

  /// Permanently removes multiple chats from the inbox.
  Future<void> deleteMultipleChats(List<String> chatIds) async {
    _chats.removeWhere((c) => chatIds.contains(c.chatId));
    notifyListeners();

    try {
      await ChatService.deleteChats(chatIds);
    } catch (e) {
      debugPrint('Error deleting multiple chats from Supabase: $e');
      await fetchChats();
    }
  }

  void clearChats() {
    _chats.clear();
    _chatListSubscription?.unsubscribe();
    _chatListSubscription = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatListSubscription?.unsubscribe();
    super.dispose();
  }
}
