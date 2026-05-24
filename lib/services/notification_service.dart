import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final _db = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchNotifications() async {
    final userId = _db.auth.currentUser!.id;
    return await _db
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);
  }

  static Future<void> markAsRead(String notificationId) async {
    await _db
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  static Future<void> markAllAsRead() async {
    final userId = _db.auth.currentUser!.id;
    await _db
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  static Future<void> deleteNotification(String notificationId) async {
    await _db.from('notifications').delete().eq('id', notificationId);
  }

  /// Real-time listener for new notifications.
  /// Returns a RealtimeChannel that should be disposed when leaving the screen.
  static RealtimeChannel subscribeToNotifications({
    required void Function(Map<String, dynamic> notification) onNew,
  }) {
    final userId = _db.auth.currentUser!.id;
    return _db
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNew(payload.newRecord);
          },
        )
        .subscribe();
  }
}
