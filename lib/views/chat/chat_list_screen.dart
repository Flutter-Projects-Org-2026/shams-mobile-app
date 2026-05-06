import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/shams_bottom_nav_bar.dart';
import 'chat_conversation_screen.dart'; // مسار شاشة الدردشة

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // البيانات الوهمية المطابقة لملف التكليف
  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'متجر التقنية الحديثة',
      'lastMessage': 'لقد تم تأكيد طلبك رقم 4321 بنجاح.',
      'time': 'منذ 2 د',
      'isOnline': true,
      'unreadCount': 2,
    },
    {
      'name': 'ورشة الأمل للصيانة',
      'lastMessage': 'هل يمكنك إرسال صورة للعطل؟',
      'time': '10:45 ص',
      'isOnline': true,
      'unreadCount': 0,
    },
    {
      'name': 'أحمد محمود',
      'lastMessage': 'تم الانتهاء من فحص المحرك، كل شيء يعمل.',
      'time': 'أمس',
      'isOnline': false,
      'unreadCount': 0,
    },
    {
      'name': 'شركة شمس للخدمات',
      'lastMessage': 'عروض حصرية لمتابعينا اليوم.',
      'time': 'أمس',
      'isOnline': false,
      'unreadCount': 1,
    },
    {
      'name': 'سارة خالد',
      'lastMessage': 'متى سيتوفر الشاحن القادم؟',
      'time': '15 مارس',
      'isOnline': false,
      'unreadCount': 0,
    },
  ];

  int _currentIndex = 2; // مؤشر شريط التنقل السفلي لقسم "المحادثات"

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ShamsColors.primaryBlue,
          elevation: 0,
          title: Text('المحادثات', style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 18)),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {
                // تفعيل شريط البحث الذي بنيته مسبقاً
                showSearch(
                  context: context,
                  delegate: ShamsSearchDelegate(
                    searchSuggestions: _chats.map((c) => c['name'] as String).toList(),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'المحادثات الأخيرة',
                style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: ShamsColors.textGray),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _chats.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100, height: 1),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return ChatTile(
                    name: chat['name'],
                    lastMessage: chat['lastMessage'],
                    time: chat['time'],
                    isOnline: chat['isOnline'],
                    unreadCount: chat['unreadCount'],
                    avatarPath: '', // المسار وهمي حالياً
                   onTap: () {
                      // 💡 الانتقال لشاشة المحادثة الفردية مع تمرير اسم الورشة
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatConversationScreen(
                            workshopName: chat['name'], // نرسل الاسم ليظهر في الـ AppBar
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: ShamsBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}