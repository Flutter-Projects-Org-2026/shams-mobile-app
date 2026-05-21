import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 1. Dummy Data List
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'قام أحمد خالد بالإعجاب بمنشورك',
      'time': 'منذ ساعتين',
      'icon': Icons.favorite_rounded,
      'color': ShamsColors.dangerRed,
    },
    {
      'id': '2',
      'title': 'ورشة المجد أضافت عرضاً جديداً في منظومات الطاقة',
      'time': 'منذ يوم',
      'icon': Icons.local_offer_rounded,
      'color': ShamsColors.verifiedGreen,
    },
    {
      'id': '3',
      'title': 'رد جديد على تعليقك من محمد النور',
      'time': 'منذ 3 أيام',
      'icon': Icons.reply_rounded,
      'color': ShamsColors.primaryBlue,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
        ),
        body: _notifications.isEmpty
            ? Center(
                child: Text(
                  'لا توجد إشعارات حالياً',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: ShamsColors.textHint,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _notifications.length,
                separatorBuilder: (context, index) => const Divider(
                  color: ShamsColors.dividerLight,
                  height: 1,
                  indent: 70,
                ),
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  // 2. Swipe-to-Dismiss Widget
                  return Dismissible(
                    key: Key(notif['id']),
                    // RTL direction: startToEnd is right to left
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
                    onDismissed: (direction) {
                      setState(() {
                        _notifications.removeAt(index);
                      });
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
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: notif['color'].withOpacity(0.1),
                        child: Icon(
                          notif['icon'],
                          color: notif['color'],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        notif['title'],
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ShamsColors.textGray,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          notif['time'],
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: ShamsColors.textHint,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
    );
  }
}
