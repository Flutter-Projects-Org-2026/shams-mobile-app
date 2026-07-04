# شرح مفصل لملف `chat_provider.dart`

يعتبر هذا الملف جزءاً أساسياً من نظام إدارة الحالة (State Management) في تطبيق Flutter الخاص بك. يعتمد على مكتبة **Provider** (`ChangeNotifier`) لإدارة حالة المحادثات (Chats) والرسائل بين المستخدمين والورش، والربط مع قاعدة بيانات **Supabase** لتحقيق التحديث الفوري (Realtime) للبيانات.

---

## الهيكل العام للملف (Class Structure)

يرث الكلاس `ChatProvider` من `ChangeNotifier` لتنبيه واجهات المستخدم (UI) عند حدوث أي تعديل في البيانات باستخدام `notifyListeners()`.

### 1. المتغيرات والممتلكات (State Variables)
```dart
final List<ChatModel> _chats = [];
RealtimeChannel? _chatListSubscription;

List<ChatModel> get chats => _chats;
```
*   `_chats`: قائمة خاصة (private) تحتوي على جميع المحادثات الحالية للمستخدم.
*   `_chatListSubscription`: قناة اتصال فوري (Realtime Channel) من Supabase للاستماع للتحديثات المباشرة.
*   `chats`: حقل عام (getter) للوصول إلى المحادثات من خارج الكلاس بشكل آمن دون إمكانية تعديل القائمة مباشرة.

---

## شرح الدوال والعمليات (Methods Explanation)

### 1. المشيد (Constructor)
```dart
ChatProvider() {
  fetchChats();
}
```
عند إنشاء كائن من `ChatProvider`، يتم استدعاء دالة `fetchChats()` مباشرة لجلب المحادثات من قاعدة البيانات.

### 2. جلب المحادثات `fetchChats()`
```dart
Future<void> fetchChats() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final data = await ChatService.fetchChats();
    _chats.clear();
    for (final item in data) {
      final messagesData = item['messages'] as List<dynamic>? ?? [];
      final messages = messagesData.map((m) => MessageModel.fromSupabase(m)).toList();
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _chats.add(ChatModel.fromSupabase(item, messages: messages));
    }
    notifyListeners();
    subscribeToChats();
  } catch (e) {
    debugPrint('Error fetching chats from Supabase: $e');
  }
}
```
*   **التحقق من المستخدم:** يتأكد من أن المستخدم مسجل دخوله حالياً.
*   **جلب البيانات:** يستدعي `ChatService.fetchChats()` للحصول على المحادثات من Supabase.
*   **معالجة الرسائل:** لكل محادثة، يقوم بتحويل الرسائل الخام إلى كائنات `MessageModel` ويرتبها تنازلياً حسب الوقت (الأحدث أولاً).
*   **تحديث الواجهة:** يستدعي `notifyListeners()` لتحديث الشاشات.
*   **الاشتراك الفوري:** يستدعي `subscribeToChats()` لتفعيل التحديث التلقائي.

### 3. الاشتراك الفوري `subscribeToChats()`
```dart
void subscribeToChats() {
  _chatListSubscription?.unsubscribe();
  final chatIds = _chats.map((c) => c.chatId).toList();
  if (chatIds.isEmpty) return;

  _chatListSubscription = ChatService.subscribeToChatList(
    chatIds: chatIds,
    onUpdate: () {
      fetchChats();
    },
  );
}
```
*   تقوم بإلغاء الاشتراك القديم أولاً (لتجنب تسريب الذاكرة أو الاشتراكات المتكررة).
*   تستمع لأي تحديث يطرأ على قائمة المحادثات (مثل وصول رسالة جديدة في أي محادثة).
*   عند حدوث أي تحديث، يتم إعادة استدعاء `fetchChats()` لجلب البيانات الجديدة.

### 4. إرسال رسالة `sendMessage()`
```dart
Future<void> sendMessage(String chatId, MessageModel msg) async {
  // 1. التحديث المحلي المتفائل (Optimistic local UI update)
  final index = _chats.indexWhere((c) => c.chatId == chatId);
  if (index != -1) {
    final chat = _chats[index];
    final updatedMessages = List<MessageModel>.from(chat.messages)
      ..insert(0, msg);

    _chats[index] = chat.copyWith(
      messages: updatedMessages,
      lastMessageTime: msg.timestamp,
    );
    notifyListeners();
  }

  // 2. الحفظ في Supabase
  try {
    await ChatService.sendMessage(chatId: chatId, text: msg.text);
  } catch (e) {
    debugPrint('Error sending message to Supabase: $e');
    // في حال الفشل، يتم إعادة جلب البيانات لإلغاء التغيير المحلي المؤقت
    fetchChats();
  }
}
```
تستخدم هذه الدالة نمط **Optimistic UI Update** (التحديث المتفائل للواجهة):
1.  تضيف الرسالة إلى قائمة الرسائل محلياً وتحدث الواجهة فوراً ليشعر المستخدم بالسرعة والاستجابة الفورية.
2.  ترسل الرسالة إلى السيرفر (Supabase) بالخلفية.
3.  إذا فشلت العملية، تتراجع عن الإضافة المحلية عن طريق استدعاء `fetchChats()` للتزامن الفعلي مع السيرفر.

### 5. تحديد الرسائل كمقروءة `markAsRead()`
```dart
Future<void> markAsRead(String chatId) async {
  final index = _chats.indexWhere((c) => c.chatId == chatId);
  if (index != -1) {
    final chat = _chats[index];
    final updatedMessages = chat.messages.map((msg) {
      if (!msg.isRead) {
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();

    _chats[index] = chat.copyWith(messages: updatedMessages);
    notifyListeners();
  }

  try {
    await ChatService.markChatAsRead(chatId);
  } catch (e) {
    debugPrint('Error marking chat as read in Supabase: $e');
  }
}
```
*   تعديل حالة الرسائل غير المقروءة محلياً إلى مقروءة (`isRead = true`) لسرعة استجابة التطبيق.
*   تحديث الحالة في قاعدة بيانات Supabase.

### 6. الحصول على محادثة أو إنشائها `getOrCreateChat()`
```dart
Future<String> getOrCreateChat(UserModel currentUser, UserModel otherUser) async {
  try {
    final chatId = await ChatService.getOrCreateChat(otherUserId: otherUser.id);
    await fetchChats();
    return chatId;
  } catch (e) {
    debugPrint('Error getOrCreateChat: $e');
    return '';
  }
}
```
تُستخدم لفتح محادثة ثنائية بين مستخدمين. تتحقق إن كانت هناك محادثة سابقة؛ إن لم توجد تقوم بإنشاء واحدة جديدة وتحديث القائمة.

### 7. إنشاء محادثة طلب صيانة `createMaintenanceChat()`
```dart
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
    // 1. إنشاء طلب الصيانة في قاعدة البيانات
    final request = await MaintenanceService.createRequest(
      workshopId: workshopId,
      serviceType: serviceType,
      problemDescription: problemDescription,
      systemCapacityKw: systemCapacityKw,
      inverterBrand: inverterBrand,
      batteryType: batteryType,
    );

    final requestId = request['id'] as String;

    // 2. إنشاء أو جلب المحادثة وربطها برقم الطلب (Maintenance Request ID)
    final chatId = await ChatService.getOrCreateChat(
      otherUserId: targetWorkshop.id,
      maintenanceRequestId: requestId,
    );

    // 3. إرسال رسالة آلية تلخص تفاصيل طلب الصيانة
    final summaryText = '📋 طلب خدمة جديد:\n'
        'نوع الخدمة: $serviceType\n'
        '${systemCapacityKw != null ? \'قدرة المنظومة: $systemCapacityKw كيلوواط\n\' : \'\'}'
        '${inverterBrand != null && inverterBrand.isNotEmpty ? \'نوع العاكس: $inverterBrand\n\' : \'\'}'
        '${batteryType != null && batteryType.isNotEmpty ? \'نوع البطارية: $batteryType\n\' : \'\'}'
        'تفاصيل المشكلة: $problemDescription';

    await ChatService.sendMessage(chatId: chatId, text: summaryText);
    await fetchChats();
    return chatId;
  } catch (e) {
    debugPrint('Error creating maintenance request chat: $e');
    rethrow;
  }
}
```
هذه الدالة تقوم بسلسلة خطوات متكاملة لربط محادثة الشات بطلب صيانة:
1.  تنشئ طلباً جديداً عبر `MaintenanceService.createRequest`.
2.  تنشئ/تجلب محادثة مع الورشة المستهدفة وتمرر لها معرف الطلب `maintenanceRequestId` لربطهما معاً.
3.  تصيغ رسالة ملخصة تحوي كافة تفاصيل الطلب (مثل نوع الخدمة، قدرة المنظومة، نوع العاكس/البطارية، ووصف المشكلة) وترسلها تلقائياً داخل المحادثة لبدء التنسيق.

### 8. الدوال المساعدة وعمليات المسح والتنظيف
*   `clearChat(String chatId)`: تفريغ الرسائل داخل محادثة معينة محلياً فقط.
*   `deleteChat(String chatId)`: حذف المحادثة محلياً واستدعاء دالة الحذف من Supabase عبر `ChatService.deleteChat(chatId)`.
*   `deleteMultipleChats(List<String> chatIds)`: لحذف محادثات متعددة دفعة واحدة.
*   `clearChats()`: تنظيف قائمة المحادثات وإلغاء اشتراك القناة الفورية (يستخدم مثلاً عند تسجيل الخروج).
*   `dispose()`: إلغاء الاشتراك في القناة الفورية عند إتلاف الـ Provider لمنع حدوث تسريب في الذاكرة (Memory Leak).

---

## النقاط القوية والأنماط البرمجية المستخدمة في الملف

1.  **Separation of Concerns (فصل المهام):** المزود (Provider) لا يكتب بيانات مباشرة في قاعدة البيانات، بل يعتمد على كلاسات الخدمة مثل `ChatService` و `MaintenanceService`.
2.  **Optimistic UI updates:** تحسين تجربة المستخدم بشكل كبير عبر إظهار الرسائل فوراً ثم تأكيدها أو التراجع عنها بعد استجابة السيرفر.
3.  **Realtime Synchronization:** الاستماع المباشر للتحديثات يحافظ على مزامنة التطبيق مع السيرفر دون الحاجة للقيام بعمليات تحديث يدوية مستمرة (Polling).
4.  **Memory Management:** استخدام `dispose()` و `unsubscribe()` للتأكد من عدم استهلاك موارد الجهاز بدون فائدة بعد إغلاق شاشات المحادثة.
