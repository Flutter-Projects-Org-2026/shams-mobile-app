import 'package:flutter/material.dart';

/// Notification type — determines where tapping a notification navigates.
enum NotificationType {
  /// Someone liked the user's post → navigate to post
  like,

  /// Someone commented on the user's post → navigate to post
  comment,

  /// Someone replied to the user's comment → navigate to post
  reply,

  /// A followed workshop published a new post → navigate to workshop profile
  workshopUpdate,

  /// Maintenance request status changed → navigate to chat
  maintenanceStatus,

  /// New message received → navigate to chat
  message,

  /// Generic / system notification
  system,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final IconData? icon;
  final Color? color;

  /// Determines the navigation destination on tap.
  final NotificationType type;

  /// The ID of the target resource (postId, workshopId, chatId, etc.).
  /// May be null for generic system notifications.
  final String? targetId;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.icon,
    this.color,
    this.type = NotificationType.system,
    this.targetId,
  });

  IconData get resolvedIcon => icon ?? _resolvedIcon(type);
  Color get resolvedColor => color ?? _resolvedColor(type);

  static IconData _resolvedIcon(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return Icons.favorite_rounded;
      case NotificationType.comment:
        return Icons.comment_rounded;
      case NotificationType.reply:
        return Icons.reply_rounded;
      case NotificationType.workshopUpdate:
        return Icons.local_offer_rounded;
      case NotificationType.maintenanceStatus:
        return Icons.build_circle_rounded;
      case NotificationType.message:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  static Color _resolvedColor(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return const Color(0xFFD32F2F);
      case NotificationType.comment:
        return const Color(0xFF2CC069);
      case NotificationType.reply:
        return const Color(0xFF0056C6);
      case NotificationType.workshopUpdate:
        return const Color(0xFF2CC069);
      case NotificationType.maintenanceStatus:
        return const Color(0xFFFFD600);
      case NotificationType.message:
        return const Color(0xFF0056C6);
      case NotificationType.system:
        return const Color(0xFF9EA3B0);
    }
  }

  factory NotificationModel.fromSupabase(Map<String, dynamic> map) {
    final typeStr = map['type'] ?? 'system';
    final parsedType = _parseType(typeStr);
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      isRead: map['is_read'] ?? false,
      type: parsedType,
      targetId: map['target_id'],
    );
  }

  static NotificationType _parseType(String typeStr) {
    switch (typeStr) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'reply':
        return NotificationType.reply;
      case 'workshop_update':
        return NotificationType.workshopUpdate;
      case 'maintenance_status':
        return NotificationType.maintenanceStatus;
      case 'message':
        return NotificationType.message;
      default:
        return NotificationType.system;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    IconData? icon,
    Color? color,
    NotificationType? type,
    String? targetId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      targetId: targetId ?? this.targetId,
    );
  }
}
