import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatModel> _chats = [];

  List<ChatModel> get chats => _chats;

  void sendMessage(String chatId, MessageModel msg) {
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
  }

  void markAsRead(String chatId) {
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
  }

  /// Get an existing chat conversation between currentUser and otherUser, or create a new one.
  String getOrCreateChat(UserModel currentUser, UserModel otherUser) {
    final existingIndex = _chats.indexWhere(
      (c) =>
          c.participants.any((p) => p.id == currentUser.id) &&
          c.participants.any((p) => p.id == otherUser.id),
    );

    if (existingIndex != -1) {
      return _chats[existingIndex].chatId;
    } else {
      final newChatId = 'ch_${DateTime.now().millisecondsSinceEpoch}';
      final newChat = ChatModel(
        chatId: newChatId,
        participants: [currentUser, otherUser],
        messages: [],
        lastMessageTime: DateTime.now(),
      );
      _chats.add(newChat);
      notifyListeners();
      return newChatId;
    }
  }

  /// Create or reuse a chat session for a maintenance request.
  ///
  /// If a chat with [targetWorkshop] already exists, the new request message
  /// is appended to it and the chat is moved to the top of the inbox.
  /// Otherwise a brand-new chat is created at index 0.
  String createMaintenanceChat(
    UserModel currentUser,
    UserModel targetWorkshop,
    String requestDetails,
  ) {
    final now = DateTime.now();
    final messageId = 'msg_${now.millisecondsSinceEpoch}';

    final initialMessage = MessageModel(
      id: messageId,
      senderId: currentUser.id,
      text: 'طلب صيانة جديد: $requestDetails',
      timestamp: now,
      isRead: false,
    );

    // ── Check for an existing chat with this workshop ──────────────────────
    final existingIndex = _chats.indexWhere(
      (c) => c.participants.any((p) => p.id == targetWorkshop.id),
    );

    if (existingIndex != -1) {
      // Append message to the existing chat
      final existingChat = _chats[existingIndex];
      final updatedMessages = List<MessageModel>.from(existingChat.messages)
        ..insert(0, initialMessage);

      final updatedChat = existingChat.copyWith(
        messages: updatedMessages,
        lastMessageTime: now,
      );

      // Move to the top of the inbox
      _chats.removeAt(existingIndex);
      _chats.insert(0, updatedChat);
      notifyListeners();
      return updatedChat.chatId;
    }

    // ── No existing chat — create a new one ────────────────────────────────
    final chatId =
        'ch_${now.millisecondsSinceEpoch}_${requestDetails.hashCode.abs()}';

    final newChat = ChatModel(
      chatId: chatId,
      participants: [currentUser, targetWorkshop],
      messages: [initialMessage],
      lastMessageTime: now,
    );

    _chats.insert(0, newChat);
    notifyListeners();
    return chatId;
  }
}
