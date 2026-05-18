import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/inline_search_bar.dart';
import 'chat_conversation_screen.dart'; // مسار شاشة الدردشة
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // البيانات ستأتي من ChatProvider

  // int _currentIndex = 2; // مؤشر شريط التنقل السفلي لقسم "المحادثات"

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = context.watch<UserProvider>().currentUser;
    final allChats = chatProvider.chats;

    final filteredChats = _searchQuery.isEmpty 
        ? allChats 
        : allChats.where((c) {
            final otherParticipant = c.participants.firstWhere((p) => p.id != currentUser.id, orElse: () => c.participants.first);
            return otherParticipant.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ShamsColors.primaryBlue,
          elevation: 0,
          title: Text(
            'المحادثات',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: const [],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InlineSearchBar(
              hintText: 'ابحث في المحادثات...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Text(
                'المحادثات الأخيرة',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.textGray,
                ),
              ),
            ),
            Expanded(
              child: filteredChats.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد محادثات تطابق "$_searchQuery"',
                        style: GoogleFonts.tajawal(color: ShamsColors.textHint, fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherParticipant = chat.participants.firstWhere(
                          (p) => p.id != currentUser.id, 
                          orElse: () => chat.participants.first
                        );
                        final lastMessage = chat.messages.isNotEmpty ? chat.messages.first.text : 'لا توجد رسائل';
                        final unreadCount = chat.messages.where((m) => !m.isRead && m.senderId != currentUser.id).length;

                        return ChatTile(
                          name: otherParticipant.name,
                          lastMessage: lastMessage,
                          time: timeago.format(chat.lastMessageTime, locale: 'ar'),
                          isOnline: false, // Dummy online status
                          unreadCount: unreadCount,
                          avatarPath: otherParticipant.profileImageUrl ?? 'assets/images/logo/shams logo.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatConversationScreen(
                                  chatId: chat.chatId,
                                ),
                              ),
                            ).then((_) {
                              // Mark messages as read when returning
                              context.read<ChatProvider>().markAsRead(chat.chatId);
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
