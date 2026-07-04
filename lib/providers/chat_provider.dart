import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/maintenance_service.dart';

/// كلاس إدارة حالة المحادثات في التطبيق باستخدام ChangeNotifier لتحديث واجهة المستخدم تلقائياً
class ChatProvider extends ChangeNotifier {
  // قائمة خاصة لتخزين كائنات المحادثات محلياً
  final List<ChatModel> _chats = [];
  
  // قناة الاتصال الفوري للاستماع لتحديثات المحادثات من Supabase
  RealtimeChannel? _chatListSubscription;

  // جلب المحادثات المخزنة محلياً لقراءتها من خارج الكلاس بشكل آمن
  List<ChatModel> get chats => _chats;

  // عند إنشاء كائن ChatProvider، يتم جلب المحادثات مباشرة
  ChatProvider() {
    fetchChats();
  }

  /// دالة جلب المحادثات من قاعدة بيانات Supabase ومعالجتها
  Future<void> fetchChats() async {
    try {
      // الحصول على بيانات المستخدم الحالي المسجل دخوله
      final user = Supabase.instance.client.auth.currentUser;
      // إذا لم يكن هناك مستخدم مسجل، يتم إيقاف العملية
      if (user == null) return;

      // جلب قائمة المحادثات من الخدمة المخصصة ChatService
      final data = await ChatService.fetchChats();
      // مسح قائمة المحادثات القديمة لتهيئة البيانات الجديدة
      _chats.clear();
      // الدوران على كل محادثة تم جلبها لمعالجتها
      for (final item in data) {
        // استخراج قائمة الرسائل الخام أو إرجاع قائمة فارغة إذا لم تكن موجودة
        final messagesData = item['messages'] as List<dynamic>? ?? [];
        // تحويل كل رسالة خام إلى كائن MessageModel
        final messages = messagesData.map((m) => MessageModel.fromSupabase(m)).toList();
        // ترتيب الرسائل تنازلياً حسب الوقت ليظهر الأحدث أولاً
        messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        // إضافة المحادثة بعد معالجتها وتحويلها إلى قائمة المحادثات المحلية
        _chats.add(ChatModel.fromSupabase(item, messages: messages));
      }
      // إرسال إشعار لواجهة المستخدم لإعادة رسم المكونات بالبيانات الجديدة
      notifyListeners();
      // بدء الاشتراك في الاستماع للتحديثات الفورية لهذه المحادثات
      subscribeToChats();
    } catch (e) {
      // طباعة الخطأ في وضع التطوير في حال فشل العملية
      debugPrint('Error fetching chats from Supabase: $e');
    }
  }

  /// دالة الاشتراك في قناة البث الفوري (Realtime) لتحديث قائمة المحادثات تلقائياً
  void subscribeToChats() {
    // إلغاء أي اشتراك نشط قديم لمنع تسرب الذاكرة والاشتراكات المتكررة
    _chatListSubscription?.unsubscribe();
    // استخراج معرفات المحادثات الحالية
    final chatIds = _chats.map((c) => c.chatId).toList();
    // إذا كانت قائمة المحادثات فارغة، لا داعي للاشتراك ويتم إيقاف الدالة
    if (chatIds.isEmpty) return;

    // بدء اشتراك جديد بالاعتماد على قائمة معرفات المحادثات
    _chatListSubscription = ChatService.subscribeToChatList(
      chatIds: chatIds,
      onUpdate: () {
        // عند حدوث أي تعديل في السيرفر، يتم إعادة جلب المحادثات تلقائياً
        fetchChats();
      },
    );
  }

  /// دالة إرسال رسالة جديدة مع تطبيق نمط التحديث المتفائل (Optimistic Update)
  Future<void> sendMessage(String chatId, MessageModel msg) async {
    // 1. التحديث المحلي المتفائل: تحديث واجهة المستخدم فوراً قبل استجابة السيرفر
    // البحث عن موقع المحادثة الحالية في القائمة المحلية
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      final chat = _chats[index];
      // إنشاء قائمة رسائل جديدة وإدراج الرسالة الجديدة في أولها
      final updatedMessages = List<MessageModel>.from(chat.messages)
        ..insert(0, msg);

      // تحديث كائن المحادثة محلياً بالرسائل الجديدة وتعديل وقت آخر رسالة
      _chats[index] = chat.copyWith(
        messages: updatedMessages,
        lastMessageTime: msg.timestamp,
      );
      // إشعار الواجهات بالتعديل الفوري لتبدو عملية الإرسال لحظية للمستخدم
      notifyListeners();
    }

    // 2. إرسال الرسالة وحفظها في قاعدة بيانات Supabase
    try {
      await ChatService.sendMessage(chatId: chatId, text: msg.text);
    } catch (e) {
      // طباعة الخطأ في حال فشل الإرسال
      debugPrint('Error sending message to Supabase: $e');
      // التراجع عن التعديل المتفائل محلياً وإعادة جلب البيانات الفعلية من السيرفر
      fetchChats();
    }
  }

  /// دالة لتحديد كافة رسائل محادثة معينة كرسائل مقروءة
  Future<void> markAsRead(String chatId) async {
    // البحث عن المحادثة لتحديث حالتها محلياً بشكل سريع
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      final chat = _chats[index];
      // تحويل الرسائل غير المقروءة محلياً لتصبح مقروءة
      final updatedMessages = chat.messages.map((msg) {
        if (!msg.isRead) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      // حفظ التعديل المحلي على كائن المحادثة
      _chats[index] = chat.copyWith(messages: updatedMessages);
      // إشعار واجهة المستخدم لتحديث العدادات أو الأيقونات
      notifyListeners();
    }

    try {
      // تحديث حالة القراءة للمحادثة في قاعدة بيانات Supabase
      await ChatService.markChatAsRead(chatId);
    } catch (e) {
      // طباعة الخطأ في حال فشل تحديث السيرفر
      debugPrint('Error marking chat as read in Supabase: $e');
    }
  }

  /// الحصول على محادثة قائمة بين المستخدم الحالي ومستخدم آخر أو إنشاء محادثة جديدة
  Future<String> getOrCreateChat(UserModel currentUser, UserModel otherUser) async {
    try {
      // استدعاء خدمة الشات لجلب المحادثة أو إنشائها بالاعتماد على معرف المستخدم الآخر
      final chatId = await ChatService.getOrCreateChat(otherUserId: otherUser.id);
      // تحديث قائمة المحادثات محلياً
      await fetchChats();
      // إرجاع معرف المحادثة
      return chatId;
    } catch (e) {
      // طباعة الخطأ وإرجاع نص فارغ في حال الفشل
      debugPrint('Error getOrCreateChat: $e');
      return '';
    }
  }

  /// إنشاء محادثة جديدة مخصصة لطلب صيانة وربطها بالطلب بشكل كامل
  Future<String> createMaintenanceChat({
    required UserModel currentUser,
    required String workshopId,
    required UserModel targetWorkshop,
    required String serviceType,
    required String problemDescription,
    double? systemCapacityKw,
    String? inverterBrand,
    String? batteryType,
  }) async {
    try {
      // 1. إنشاء طلب الصيانة أولاً في قاعدة البيانات والحصول على بياناته
      final request = await MaintenanceService.createRequest(
        workshopId: workshopId,
        serviceType: serviceType,
        problemDescription: problemDescription,
        systemCapacityKw: systemCapacityKw,
        inverterBrand: inverterBrand,
        batteryType: batteryType,
      );

      // استخراج معرف طلب الصيانة الجديد
      final requestId = request['id'] as String;

      // 2. إنشاء أو جلب محادثة بين الطرفين مع ربطها بمعرّف طلب الصيانة
      final chatId = await ChatService.getOrCreateChat(
        otherUserId: targetWorkshop.id,
        maintenanceRequestId: requestId,
      );

      // 3. صياغة نص رسالة آلية تحتوي على ملخص تفاصيل طلب الخدمة
      final summaryText = '📋 طلب خدمة جديد:\n'
          'نوع الخدمة: $serviceType\n'
          '${systemCapacityKw != null ? 'قدرة المنظومة: $systemCapacityKw كيلوواط\n' : ''}'
          '${inverterBrand != null && inverterBrand.isNotEmpty ? 'نوع العاكس: $inverterBrand\n' : ''}'
          '${batteryType != null && batteryType.isNotEmpty ? 'نوع البطارية: $batteryType\n' : ''}'
          'تفاصيل المشكلة: $problemDescription';

      // إرسال رسالة التلخيص تلقائياً داخل المحادثة المنشأة حديثاً
      await ChatService.sendMessage(chatId: chatId, text: summaryText);

      // تحديث قائمة المحادثات المحلية
      await fetchChats();

      // إرجاع معرف المحادثة التي تم إنشاؤها
      return chatId;
    } catch (e) {
      // طباعة الخطأ وإعادة توجيهه للتعامل معه في واجهات المستخدم
      debugPrint('Error creating maintenance request chat: $e');
      rethrow;
    }
  }

  /// مسح كافة الرسائل محلياً من محادثة معينة مع إبقائها ظاهرة في القائمة
  void clearChat(String chatId) {
    // البحث عن موقع المحادثة
    final index = _chats.indexWhere((c) => c.chatId == chatId);
    if (index != -1) {
      // تفريغ الرسائل من كائن المحادثة
      _chats[index] = _chats[index].copyWith(messages: []);
      // تحديث الشاشة فوراً
      notifyListeners();
    }
  }

  /// حذف محادثة معينة نهائياً من صندوق الوارد
  Future<void> deleteChat(String chatId) async {
    // إزالة المحادثة محلياً فوراً
    _chats.removeWhere((c) => c.chatId == chatId);
    // تحديث الشاشة
    notifyListeners();

    try {
      // طلب حذف المحادثة من قاعدة البيانات
      await ChatService.deleteChat(chatId);
    } catch (e) {
      // طباعة الخطأ وإعادة جلب البيانات لإعادة المحادثة محلياً في حال فشل الحذف بالسيرفر
      debugPrint('Error deleting chat from Supabase: $e');
      await fetchChats();
    }
  }

  /// حذف محادثات متعددة دفعة واحدة من صندوق الوارد
  Future<void> deleteMultipleChats(List<String> chatIds) async {
    // إزالة قائمة المحادثات المحددة محلياً فوراً
    _chats.removeWhere((c) => chatIds.contains(c.chatId));
    // تحديث واجهة المستخدم
    notifyListeners();

    try {
      // حذف قائمة المحادثات المحددة من قاعدة البيانات
      await ChatService.deleteChats(chatIds);
    } catch (e) {
      // طباعة الخطأ وتحديث البيانات في حال فشل العملية لاسترجاع ما لم يتم حذفه
      debugPrint('Error deleting multiple chats from Supabase: $e');
      await fetchChats();
    }
  }

  /// تفريغ وإلغاء تهيئة كائن المحادثات بالكامل (مثال: عند تسجيل الخروج)
  void clearChats() {
    // تفريغ القائمة المحلية
    _chats.clear();
    // إلغاء اشتراك القناة الفورية لمنع تسرب البيانات
    _chatListSubscription?.unsubscribe();
    // تعيين الاشتراك إلى null
    _chatListSubscription = null;
    // تنبيه واجهة المستخدم بالتغييرات
    notifyListeners();
  }

  @override
  void dispose() {
    // التأكد من إغلاق القناة الفورية وإلغاء الاشتراك عند تدمير الكائن لمنع تسرب الذاكرة
    _chatListSubscription?.unsubscribe();
    super.dispose();
  }
}
