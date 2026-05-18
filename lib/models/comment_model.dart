import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final UserModel user;
  final String text;
  final int likesCount;
  final DateTime timestamp;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.text,
    this.likesCount = 0,
    required this.timestamp,
  });

  CommentModel copyWith({
    String? id,
    String? postId,
    UserModel? user,
    String? text,
    int? likesCount,
    DateTime? timestamp,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      user: user ?? this.user,
      text: text ?? this.text,
      likesCount: likesCount ?? this.likesCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'user': user.toMap(),
      'text': text,
      'likesCount': likesCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      user: UserModel.fromMap(map['user'] ?? {}),
      text: map['text'] ?? '',
      likesCount: map['likesCount']?.toInt() ?? 0,
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }
}
