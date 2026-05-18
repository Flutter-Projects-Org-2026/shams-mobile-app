import 'user_model.dart';
import 'message_model.dart';

class ChatModel {
  final String chatId;
  final List<UserModel> participants;
  final List<MessageModel> messages;
  final DateTime lastMessageTime;

  const ChatModel({
    required this.chatId,
    this.participants = const [],
    this.messages = const [],
    required this.lastMessageTime,
  });

  ChatModel copyWith({
    String? chatId,
    List<UserModel>? participants,
    List<MessageModel>? messages,
    DateTime? lastMessageTime,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants.map((e) => e.toMap()).toList(),
      'messages': messages.map((e) => e.toMap()).toList(),
      'lastMessageTime': lastMessageTime.toIso8601String(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatId: map['chatId'] ?? '',
      participants: (map['participants'] as List<dynamic>?)
              ?.map((e) => UserModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      messages: (map['messages'] as List<dynamic>?)
              ?.map((e) => MessageModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          const [],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : DateTime.now(),
    );
  }
}
