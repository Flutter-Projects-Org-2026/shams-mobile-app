import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  RealtimeChannel? _subscription;

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await NotificationService.fetchNotifications();
      _notifications.clear();
      for (final item in data) {
        _notifications.add(NotificationModel.fromSupabase(item));
      }
      notifyListeners();
      subscribeToNotifications();
    } catch (e) {
      debugPrint('Error fetching notifications from Supabase: $e');
    }
  }

  void subscribeToNotifications() {
    _subscription?.unsubscribe();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _subscription = NotificationService.subscribeToNotifications(
      onNew: (payload) {
        // Optimistic refresh
        fetchNotifications();
      },
    );
  }

  Future<void> markAllAsRead() async {
    bool changed = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }

    try {
      await NotificationService.markAllAsRead();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }

    try {
      await NotificationService.markAsRead(id);
    } catch (e) {
      debugPrint('Error marking single notification as read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications.removeAt(index);
      notifyListeners();
    }

    try {
      await NotificationService.deleteNotification(id);
    } catch (e) {
      debugPrint('Error deleting notification from database: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
