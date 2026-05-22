import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/inline_search_bar.dart';
import 'chat_conversation_screen.dart'; // مسار شاشة الدردشة
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workshop_provider.dart';
import '../../models/user_model.dart';
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
    final workshopProvider = context.watch<WorkshopProvider>();
    final allChats = chatProvider.chats;

    final filteredChats = _searchQuery.isEmpty 
        ? allChats 
        : allChats.where((c) {
            if (c.participants.isEmpty) return false;
            final otherParticipant = c.participants.firstWhere((p) => p.id != currentUser.id, orElse: () => c.participants.first);
            final workshopMatch = workshopProvider.getWorkshopById(otherParticipant.id);
            final displayName = workshopMatch != null ? workshopMatch.name : otherParticipant.name;
            return displayName.toLowerCase().contains(_searchQuery.toLowerCase());
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
            if (_searchQuery.isEmpty)
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
                      child: _searchQuery.isEmpty
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 56,
                                  color: ShamsColors.textHint.withValues(alpha: 0.35),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'لا توجد محادثات بعد',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: ShamsColors.textGray,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ابدأ محادثة من صفحة ورشة لطلب الصيانة',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: ShamsColors.textHint,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'لا توجد محادثات تطابق "$_searchQuery"',
                              style: GoogleFonts.tajawal(
                                color: ShamsColors.textHint,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    )
                  : ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) =>
                          Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherParticipant = chat.participants.isEmpty
                            ? const UserModel(id: '', name: 'محادثة', email: '')
                            : chat.participants.firstWhere(
                                (p) => p.id != currentUser.id, 
                                orElse: () => chat.participants.first
                              );
                        
                        final workshopMatch = workshopProvider.getWorkshopById(otherParticipant.id);
                        final displayName = workshopMatch != null ? workshopMatch.name : otherParticipant.name;
                        final displayAvatar = workshopMatch != null ? workshopMatch.logoPath : (otherParticipant.profileImageUrl ?? 'assets/images/logo/shams logo.png');

                        final lastMessage = chat.messages.isNotEmpty ? chat.messages.first.text : 'لا توجد رسائل';
                        final unreadCount = chat.messages.where((m) => !m.isRead && m.senderId != currentUser.id).length;

                        return ChatTile(
                          name: displayName,
                          lastMessage: lastMessage,
                          time: timeago.format(chat.lastMessageTime, locale: 'ar'),
                          isOnline: false, // Dummy online status
                          unreadCount: unreadCount,
                          avatarPath: displayAvatar,
                          onTap: () {
                            final chatProvider = context.read<ChatProvider>();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatConversationScreen(
                                  chatId: chat.chatId,
                                ),
                              ),
                            ).then((_) {
                              chatProvider.markAsRead(chat.chatId);
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
