import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatModel> _chats = [
    ChatModel(
      chatId: 'ch1',
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      participants: const [
        UserModel(
          id: 'u1',
          name: 'مستخدم تجريبي',
          email: 'test@shams.com',
        ),
        UserModel(
          id: 'w1',
          name: 'كراج المجد التقني',
          email: 'almajd@shams.com',
          profileImageUrl: 'assets/images/logo/shams logo.png',
        ),
      ],
      messages: [
        MessageModel(
          id: 'm1',
          senderId: 'w1',
          text: 'تم استلام طلبك بنجاح! فريقنا بانتظارك في المركز.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
          isRead: false,
        ),
      ],
    ),
  ];

  List<ChatModel> get chats => _chats;

  void sendMessage(String chatId, MessageModel msg) {
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      final chat = _chats[index];
      final updatedMessages = List<MessageModel>.from(chat.messages)..insert(0, msg);
      
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
      
      _chats[index] = chat.copyWith(
        messages: updatedMessages,
      );
      notifyListeners();
    }
  }
}
