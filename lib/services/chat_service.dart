import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService {
  static final _db = Supabase.instance.client;

  // ── CREATE CHAT ─────────────────────────────────────────────────────────

  /// Creates a new 1-to-1 chat and returns the chat ID.
  /// If a chat already exists between these users, returns existing ID.
  static Future<String> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  }) async {
    final userId = _db.auth.currentUser!.id;

    // Check for existing chat
    final myChats = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    final otherChats = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', otherUserId);

    final myIds = myChats.map((r) => r['chat_id']).toSet();
    final otherIds = otherChats.map((r) => r['chat_id']).toSet();
    final commonIds = myIds.intersection(otherIds);

    if (commonIds.isNotEmpty) {
      final chatId = commonIds.first as String;
      if (maintenanceRequestId != null) {
        try {
          await _db.from('chats').update({
            'maintenance_req_id': maintenanceRequestId,
          }).eq('id', chatId);
        } catch (e) {
          print('Error updating chat maintenance request id: $e');
        }
      }
      return chatId;
    }

    // Create new chat using RPC function to create the chat and add participants atomically.
    // This completely bypasses the select policy failure during direct insertion.
    final dynamic resultId = await _db.rpc('create_new_chat', params: {
      'other_user_uuid': otherUserId,
      'maintenance_req_uuid': maintenanceRequestId,
    });

    return resultId as String;
  }

  // ── READ (User's chat list) ─────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchChats() async {
    final userId = _db.auth.currentUser!.id;

    // Get chat IDs for this user
    final participantRows = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    final chatIds = participantRows.map((r) => r['chat_id'] as String).toList();

    if (chatIds.isEmpty) return [];

    // Fetch chats with participants' profiles
    return await _db
        .from('chats')
        .select('''
          *,
          chat_participants(
            profiles!chat_participants_user_id_fkey(id, name, username, profile_image_url)
          ),
          messages(id, text, sender_id, is_read, created_at)
        ''')
        .inFilter('id', chatIds)
        .order('last_message_at', ascending: false);
  }

  // ── READ (Messages in a chat — paginated) ───────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _db
        .from('messages')
        .select('''
          *,
          profiles!messages_sender_id_fkey(id, name, profile_image_url)
        ''')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  // ── SEND MESSAGE ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final userId = _db.auth.currentUser!.id;
    final message = await _db.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'text': text,
    }).select().single();

    // Trigger notification asynchronously
    _createMessageNotification(chatId: chatId, senderId: userId, text: text);

    return message;
  }

  static void _createMessageNotification({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      // Find the other participant in the chat
      final participants = await _db
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', chatId)
          .neq('user_id', senderId);

      if (participants.isNotEmpty) {
        final recipientId = participants.first['user_id'] as String;

        // Fetch sender's name
        final senderProfile = await _db
            .from('profiles')
            .select('name')
            .eq('id', senderId)
            .maybeSingle();
        final senderName = senderProfile?['name'] ?? 'مستخدم شمس';

        await _db.from('notifications').insert({
          'user_id': recipientId,
          'title': 'رسالة جديدة',
          'message': 'أرسل $senderName: $text',
          'type': 'message',
          'target_id': chatId,
        });
      }
    } catch (e) {
      print('Error creating message notification: $e');
    }
  }

  // ── MARK AS READ ────────────────────────────────────────────────────────

  static Future<void> markChatAsRead(String chatId) async {
    final userId = _db.auth.currentUser!.id;
    await _db
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }

  // ── DELETE CHAT ─────────────────────────────────────────────────────────

  static Future<void> deleteChat(String chatId) async {
    await _db.from('chats').delete().eq('id', chatId);
  }

  static Future<void> deleteChats(List<String> chatIds) async {
    await _db.from('chats').delete().inFilter('id', chatIds);
  }

  // ── REAL-TIME STREAM ──────────────────────────────────────────────────

  /// Subscribe to new messages in a specific chat.
  /// Returns a RealtimeChannel that should be disposed when leaving the screen.
  static RealtimeChannel subscribeToMessages({
    required String chatId,
    required void Function(Map<String, dynamic> newMessage) onNewMessage,
  }) {
    return _db
        .channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Subscribe to chat list updates (new messages across all user's chats).
  static RealtimeChannel subscribeToChatList({
    required List<String> chatIds,
    required void Function() onUpdate,
  }) {
    return _db
        .channel('chat-list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter,
            column: 'chat_id',
            value: chatIds,
          ),
          callback: (_) => onUpdate(),
        )
        .subscribe();
  }
}
