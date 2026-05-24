import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';
import '../../models/notification_model.dart';
import '../../providers/notification_provider.dart';
import '../posts/post_detail_screen.dart';
import '../workshops/workshop_profile_screen.dart';
import '../chat/chat_conversation_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NotificationsScreen — شاشة الإشعارات
//
// • StatelessWidget — reads live data from NotificationProvider.
// • context.watch<NotificationProvider>() drives the list reactively.
// • Dismissible.onDismissed calls context.read().deleteNotification() —
//   updates the provider so the AppBar badge count is also correct.
// • Unread items are visually distinguished from read ones.
// ─────────────────────────────────────────────────────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'الإشعارات',
            style: GoogleFonts.tajawal(
              color: ShamsColors.textGray,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ShamsColors.textGray,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (provider.unreadCount > 0)
              TextButton(
                onPressed: () =>
                    context.read<NotificationProvider>().markAllAsRead(),
                child: Text(
                  'قراءة الكل',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: ShamsColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: notifications.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(
                  color: ShamsColors.dividerLight,
                  height: 1,
                  indent: 70,
                ),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Dismissible(
                    key: Key(notif.id),
                    // RTL: startToEnd = right-to-left swipe
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: ShamsColors.dangerRed,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) {
                      // context.read() inside callback — correct usage.
                      context
                          .read<NotificationProvider>()
                          .deleteNotification(notif.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حذف الإشعار',
                            style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: ShamsColors.textGray,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    child: _NotificationTile(
                      notif: notif,
                      onTap: () => _handleNotifTap(context, notif),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ── Navigation dispatcher ────────────────────────────────────────────────

  void _handleNotifTap(BuildContext context, NotificationModel notif) async {
    // Mark as read on tap
    if (!notif.isRead) {
      context.read<NotificationProvider>().markAsRead(notif.id);
    }

    // Navigate based on notification type
    switch (notif.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.reply:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.workshopUpdate:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkshopProfile(workshopId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.maintenanceStatus:
        if (notif.targetId != null) {
          // Show progress indicator while loading
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            final chatRes = await Supabase.instance.client
                .from('chats')
                .select('id')
                .eq('maintenance_req_id', notif.targetId!)
                .maybeSingle();

            if (context.mounted) {
              Navigator.pop(context); // Dismiss progress dialog
              if (chatRes != null) {
                final chatId = chatRes['id'] as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatConversationScreen(chatId: chatId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  _infoSnack('لم يتم العثور على محادثة لطلب الصيانة هذا'),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Dismiss progress dialog
              ScaffoldMessenger.of(context).showSnackBar(
                _infoSnack('حدث خطأ أثناء تحميل المحادثة: $e'),
              );
            }
          }
        }
        break;
      case NotificationType.message:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatConversationScreen(chatId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.system:
        break;
    }
  }

  SnackBar _infoSnack(String text) => SnackBar(
        content: Text(text, style: GoogleFonts.tajawal(color: Colors.white)),
        backgroundColor: ShamsColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      );

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: ShamsColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات حالياً',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ShamsColors.textGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ستظهر إشعاراتك هنا عند وصولها',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: ShamsColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NotificationTile — بطاقة الإشعار الواحد
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notif,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notif.isRead;
    final String timeLabel = _formatTime(notif.timestamp);

    return InkWell(
      onTap: onTap,
      child: Container(
        // Unread items get a subtle blue tint
        color: isUnread
            ? ShamsColors.primaryBlue.withValues(alpha: 0.04)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread indicator dot
            if (isUnread)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: ShamsColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              const SizedBox(width: 15),

            // Icon badge
            CircleAvatar(
              backgroundColor: notif.resolvedColor.withValues(alpha: 0.12),
              radius: 22,
              child: Icon(
                notif.resolvedIcon,
                color: notif.resolvedColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.title,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.w500,
                      color: ShamsColors.textGray,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.message,
                    style: GoogleFonts.tajawal(
                      fontSize: 12.5,
                      color: ShamsColors.textHint,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: ShamsColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
