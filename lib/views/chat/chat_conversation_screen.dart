import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/models/chat_model.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_field.dart';
import '../../widgets/inline_search_bar.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workshop_provider.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/chat_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChatConversationScreen — شاشة المحادثة الفردية
//
// • context.watch<T>() for reactive reads.
// • context.read<T>() strictly inside callbacks.
// • Date dividers are inserted automatically between messages on different days.
// ─────────────────────────────────────────────────────────────────────────────

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({super.key, required this.chatId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isMuted = false;
  RealtimeChannel? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _messageSubscription = ChatService.subscribeToMessages(
      chatId: widget.chatId,
      onNewMessage: (payload) {
        if (mounted) {
          context.read<ChatProvider>().fetchChats();
        }
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.unsubscribe();
    super.dispose();
  }

  Widget _buildChatAvatar(String? path, String name) {
    if (path == null || path.isEmpty) {
      return _buildFallbackAvatar(name);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
        );
      } else {
        return _buildFallbackAvatar(name);
      }
    }
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      color: Theme.of(context).extension<ShamsExtendedColors>()!.avatarFallbackBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _addNewMessage(String text) {
    if (text.trim().isEmpty) return;
    final currentUser = context.read<UserProvider>().currentUser;
    final newMsg = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUser.id,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );
    context.read<ChatProvider>().sendMessage(widget.chatId, newMsg);
  }

  /// Returns a human-readable date label for a given [date].
  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return 'اليوم';
    if (msgDay == yesterday) return 'أمس';

    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${date.day} ${arabicMonths[date.month - 1]} ${date.year}';
  }

  /// Returns true if [a] and [b] are on different calendar days.
  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.watch<UserProvider>().currentUser;
    final chat = chatProvider.chats.firstWhere(
      (c) => c.chatId == widget.chatId,
      orElse: () => ChatModel(
        chatId: widget.chatId,
        participants: const [],
        messages: const [],
        lastMessageTime: DateTime.now(),
      ),
    );
    final otherParticipant = chat.participants.isEmpty
        ? const UserModel(id: '', name: 'محادثة', email: '')
        : chat.participants.firstWhere(
            (p) => p.id != currentUser.id,
            orElse: () => chat.participants.first,
          );

    String displayName = otherParticipant.name;
    String? displayAvatar = otherParticipant.profileImageUrl;

    final workshopProvider = context.watch<WorkshopProvider>();
    final workshopMatch = workshopProvider.getWorkshopByOwnerId(otherParticipant.id);
    if (workshopMatch != null) {
      displayName = workshopMatch.name;
      displayAvatar = workshopMatch.logoPath;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF0F2F5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildChatAvatar(displayAvatar, displayName),
              ),
              const SizedBox(width: 10),
              Text(
                displayName,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() => _isSearching = true);
                } else if (value == 'mute') {
                  setState(() => _isMuted = !_isMuted);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isMuted ? 'تم كتم إشعارات هذه المحادثة' : 'تم تفعيل إشعارات هذه المحادثة',
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inverseSurface,
                        behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (value == 'clear') {
                  // Show confirmation dialog before clearing
                  _showClearChatDialog();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('بحث', style: GoogleFonts.tajawal()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(
                        _isMuted ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isMuted ? 'تفعيل الإشعارات' : 'كتم الإشعارات',
                        style: GoogleFonts.tajawal(),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مسح المحادثة',
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isSearching)
              InlineSearchBar(
                hintText: 'ابحث في المحادثة...',
                onChanged: (val) {
                  setState(() => _searchQuery = val);
                },
                onClose: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = '';
                  });
                },
              ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final allMessages = chat.messages;
                  final filteredMessages = _searchQuery.isEmpty
                      ? allMessages
                      : allMessages.where((msg) {
                          return msg.text
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                        }).toList();

                  // ── Empty chat state ──────────────────────────────────────
                  if (allMessages.isEmpty && _searchQuery.isEmpty) {
                    return _buildEmptyChatState();
                  }

                  // ── No search results ─────────────────────────────────────
                  if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج لـ "$_searchQuery"',
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context)
                              .extension<ShamsExtendedColors>()!
                              .textHint,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // ── Build list items with date dividers ───────────────────
                  // Because the list is reversed, index 0 is the newest message.
                  // We insert a date divider when adjacent messages (i) and (i+1)
                  // are on different calendar days — i+1 is older in reversed order.
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final msg = filteredMessages[index];
                      final isMe = msg.senderId == currentUser.id;

                      // Check if we need a date divider above this message.
                      // In a reversed list, index+1 is the message *before* this one.
                      final bool showDivider = index == filteredMessages.length - 1 ||
                          _isDifferentDay(
                            msg.timestamp,
                            filteredMessages[index + 1].timestamp,
                          );

                      return Column(
                        children: [
                          MessageBubble(
                            message: msg.text,
                            time: _formatTime(msg.timestamp),
                            isMe: isMe,
                            isRead: msg.isRead,
                          ),
                          if (showDivider)
                            _DateDivider(label: _formatDateLabel(msg.timestamp)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // ربط حقل الإدخال بدالة الإضافة
            ChatInputField(onSendMessage: _addNewMessage),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  /// Formats a [DateTime] as HH:mm (24-hour) for the message timestamp.
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Confirmation dialog before wiping all messages.
  void _showClearChatDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'مسح المحادثة',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Text(
            'هل أنت متأكد أنك تريد مسح جميع الرسائل في هذه المحادثة؟',
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إلغاء', style: GoogleFonts.tajawal(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // context.read() inside a callback — correct usage.
                context.read<ChatProvider>().clearChat(widget.chatId);
              },
              child: Text(
                'مسح',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 60,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل بعد',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ابدأ المحادثة الآن!',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Theme.of(context)
                  .extension<ShamsExtendedColors>()!
                  .textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DateDivider — فاصل التاريخ بين الرسائل
// ─────────────────────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final String label;

  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).extension<ShamsExtendedColors>()!.dividerLight,
              endIndent: 12,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 11.5,
                color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).extension<ShamsExtendedColors>()!.dividerLight,
              indent: 12,
            ),
          ),
        ],
      ),
    );
  }
}
