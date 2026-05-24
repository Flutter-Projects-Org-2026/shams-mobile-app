class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }

  factory MessageModel.fromSupabase(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['sender_id'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
    );
  }
}
