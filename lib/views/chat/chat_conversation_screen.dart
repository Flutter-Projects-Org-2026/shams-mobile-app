import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_field.dart';
import '../../widgets/inline_search_bar.dart';
import '../../utils/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatConversationScreen extends StatefulWidget {
  final String chatId;

  const ChatConversationScreen({super.key, required this.chatId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  bool _isSearching = false;
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.watch<UserProvider>().currentUser;
    final chat = chatProvider.chats.firstWhere(
      (c) => c.chatId == widget.chatId,
      orElse: () => chatProvider.chats.first,
    );
    final otherParticipant = chat.participants.firstWhere(
      (p) => p.id != currentUser.id,
      orElse: () => chat.participants.first,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(
                  otherParticipant.profileImageUrl ??
                      'assets/images/logo/shams logo.png',
                ),
              ),
              const SizedBox(width: 10),
              Text(
                otherParticipant.name,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() {
                    _isSearching = true;
                  });
                } else if (value == 'clear') {
                  // TODO: Implement clear chat in ChatProvider
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
                      const Icon(Icons.notifications_off_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('كتم الإشعارات', style: GoogleFonts.tajawal()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: ShamsColors.dangerRed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'مسح المحادثة',
                        style: GoogleFonts.tajawal(
                          color: ShamsColors.dangerRed,
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
                  setState(() {
                    _searchQuery = val;
                  });
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
                          return msg.text.toLowerCase().contains(
                            _searchQuery.toLowerCase(),
                          );
                        }).toList();

                  if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج لـ "$_searchQuery"',
                        style: GoogleFonts.tajawal(
                          color: ShamsColors.textHint,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true, // قلب القائمة لتبدأ من الأسفل
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final msg = filteredMessages[index];
                      // TODO: Add date divider logic for models
                      return MessageBubble(
                        message: msg.text,
                        time: timeago.format(
                          msg.timestamp,
                          locale: 'ar',
                        ), // Or format to time only
                        isMe: msg.senderId == currentUser.id,
                        isRead: msg.isRead,
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

  }


