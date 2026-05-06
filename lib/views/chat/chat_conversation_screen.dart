import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/message_bubble.dart'; 
import '../../widgets/chat_input_field.dart';

class ChatConversationScreen extends StatefulWidget {
  final String workshopName;
  final String workshopAvatar;

  const ChatConversationScreen({
    super.key,
    this.workshopName = 'كراج المجد التقني',
    this.workshopAvatar = 'assets/images/logo/shams logo.png',
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  // قائمة الرسائل (الموقع 0 هو الأحدث ويظهر بالأسفل)
  final List<Map<String, dynamic>> _messages = [
    {
      'isDivider': false,
      'text': 'تم استلام طلبك بنجاح! فريقنا بانتظارك في المركز.',
      'time': 'ص 10:40',
      'isMe': false,
    },
    {
      'isDivider': false,
      'text': 'ممتاز. قمت بتجهيز قائمة بالقطع المطلوبة بناءً على موديل سيارتك.',
      'time': 'ص 10:25',
      'isMe': false,
    },
    {
      'isDivider': true,
      'text': 'اليوم',
    },
  ];

  // دالة توليد التوقيت الحالي بتنسيق (ص/م)
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'م' : 'ص';
    return '$period $hour:$minute';
  }

  void _addNewMessage(String text) {
    setState(() {
      // إدراج الرسالة في الموقع 0 لتظهر في الأسفل فوراً
      _messages.insert(0, {
        'isDivider': false,
        'text': text,
        'time': _getCurrentTime(),
        'isMe': true,
        'isRead': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage(widget.workshopAvatar),
              ),
              const SizedBox(width: 10),
              Text(
                widget.workshopName,
                style: GoogleFonts.tajawal(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.black87), onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true, // قلب القائمة لتبدأ من الأسفل
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  if (msg['isDivider'] == true) {
                    return _buildDateDivider(msg['text']);
                  }
                  return MessageBubble(
                    message: msg['text'],
                    time: msg['time'],
                    isMe: msg['isMe'],
                    isRead: msg['isRead'] ?? false,
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

  Widget _buildDateDivider(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(16)),
        child: Text(
          label,
          style: GoogleFonts.tajawal(fontSize: 11, color: const Color(0xFF9EA3B0), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}