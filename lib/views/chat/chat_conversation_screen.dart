import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/message_bubble.dart'; 
import '../../widgets/chat_input_field.dart';
import '../../widgets/inline_search_bar.dart';
import '../../utils/constants.dart';

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
  bool _isSearching = false;
  String _searchQuery = '';

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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.black87),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() {
                    _isSearching = true;
                  });
                } else if (value == 'clear') {
                  setState(() {
                    _messages.clear();
                  });
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
                      const Icon(Icons.delete_outline_rounded, size: 20, color: ShamsColors.dangerRed),
                      const SizedBox(width: 8),
                      Text('مسح المحادثة', style: GoogleFonts.tajawal(color: ShamsColors.dangerRed)),
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
                  final filteredMessages = _searchQuery.isEmpty
                      ? _messages
                      : _messages.where((msg) {
                          if (msg['isDivider'] == true) return false;
                          final text = msg['text'] as String;
                          return text.toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();

                  if (filteredMessages.isEmpty && _searchQuery.isNotEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد نتائج لـ "$_searchQuery"',
                        style: GoogleFonts.tajawal(color: ShamsColors.textHint, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true, // قلب القائمة لتبدأ من الأسفل
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: filteredMessages.length,
                    itemBuilder: (context, index) {
                      final msg = filteredMessages[index];
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
                  );
                }
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