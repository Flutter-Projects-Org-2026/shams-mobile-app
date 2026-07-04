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
  String _searchQuery = '';
  final Set<String> _selectedChatIds = {};

  void _toggleSelection(String chatId) {
    setState(() {
      if (_selectedChatIds.contains(chatId)) {
        _selectedChatIds.remove(chatId);
      } else {
        _selectedChatIds.add(chatId);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedChatIds.clear();
    });
  }

  void _selectAll(List<dynamic> visibleChats) {
    setState(() {
      final visibleIds = visibleChats.map((c) => c.chatId as String).toList();
      final allSelected = visibleIds.isNotEmpty && visibleIds.every((id) => _selectedChatIds.contains(id));
      if (allSelected) {
        for (final id in visibleIds) {
          _selectedChatIds.remove(id);
        }
      } else {
        _selectedChatIds.addAll(visibleIds);
      }
    });
  }

  Widget _buildSelectionBar(List<dynamic> visibleChats) {
    final allSelected = visibleChats.isNotEmpty && visibleChats.every((c) => _selectedChatIds.contains(c.chatId));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                onPressed: _clearSelection,
              ),
              const SizedBox(width: 8),
              Text(
                'تم تحديد ${_selectedChatIds.length}',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => _selectAll(visibleChats),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  allSelected ? Icons.deselect : Icons.select_all,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  allSelected ? 'إلغاء تحديد الكل' : 'تحديد الكل',
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showDeleteConfirmationDialog(context, _selectedChatIds.toList()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(
                  'حذف',
                  style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            final workshopMatch = workshopProvider.getWorkshopByOwnerId(otherParticipant.id);
            final displayName = workshopMatch != null ? workshopMatch.name : otherParticipant.name;
            return displayName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
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
            if (_selectedChatIds.isNotEmpty)
              _buildSelectionBar(filteredChats)
            else if (_searchQuery.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Text(
                  'المحادثات الأخيرة',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context)
                                      .extension<ShamsExtendedColors>()!
                                      .textHint
                                      .withValues(alpha: 0.35),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'لا توجد محادثات بعد',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ابدأ محادثة من صفحة ورشة لطلب الصيانة',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .extension<ShamsExtendedColors>()!
                                        .textHint,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'لا توجد محادثات تطابق "$_searchQuery"',
                              style: GoogleFonts.tajawal(
                                color: Theme.of(context)
                                    .extension<ShamsExtendedColors>()!
                                    .textHint,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                    )
                  : ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Theme.of(context)
                            .extension<ShamsExtendedColors>()!
                            .dividerLight,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final otherParticipant = chat.participants.isEmpty
                            ? const UserModel(id: '', name: 'محادثة', email: '')
                            : chat.participants.firstWhere(
                                (p) => p.id != currentUser.id, 
                                orElse: () => chat.participants.first
                              );
                        
                        final workshopMatch = workshopProvider.getWorkshopByOwnerId(otherParticipant.id);
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
                          isSelected: _selectedChatIds.contains(chat.chatId),
                          onTap: () {
                            if (_selectedChatIds.isNotEmpty) {
                              _toggleSelection(chat.chatId);
                            } else {
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
                            }
                          },
                          onLongPress: () {
                            _toggleSelection(chat.chatId);
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

  void _showDeleteConfirmationDialog(BuildContext context, List<String> chatIds) {
    final count = chatIds.length;
    if (count == 0) return;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            count == 1 ? 'حذف المحادثة' : 'حذف المحادثات المحددة',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Text(
            count == 1
                ? 'هل أنت متأكد أنك تريد حذف هذه المحادثة نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'
                : 'هل أنت متأكد أنك تريد حذف المحادثات المحددة (عددها: $count) نهائياً؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.tajawal(
              fontSize: 14.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(
                  color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                    builder: (context) => Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                );

                try {
                  await context.read<ChatProvider>().deleteMultipleChats(chatIds);
                  _clearSelection();
                  
                  // Hide loading indicator
                  if (context.mounted) Navigator.pop(context);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          count == 1 ? 'تم حذف المحادثة بنجاح' : 'تم حذف المحادثات بنجاح',
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  // Hide loading indicator
                  if (context.mounted) Navigator.pop(context);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'حدث خطأ أثناء الحذف: $e',
                          style: GoogleFonts.tajawal(),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
