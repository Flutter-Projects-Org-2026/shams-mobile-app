# شرح تفصيلي لملف `chat_service.dart` مع مقارنة مع لغة Java

ملف `chat_service.dart` هو المسؤول عن كافة عمليات المحادثات وإرسال الرسائل، والربط مع نظام البث اللحظي (Supabase Realtime). 

---

## 1. المتغير العام والتهيئة

```dart
class ChatService {
  static final _db = Supabase.instance.client;
```
* **الشرح:**
  * يتم إنشاء متغير ثابت وخاص باسم `_db` يمثّل العميل للوصول إلى خدمات Supabase.
* **الفروقات عن لغة Java:**
  * **`final` و استنتاج النوع (Type Inference):** في لغة Dart، تعني كلمة `final` أن المتغير لا يمكن تغيير قيمته بعد تعيينها لأول مرة (مثل `final` في Java). ولكن في Dart، لا نحتاج لكتابة النوع صراحة (أي `SupabaseClient`) لأن المترجم يستنتج النوع تلقائياً. في Java يجب كتابة النوع: `private static final SupabaseClient db = ...`.

---

## 2. دالة `getOrCreateChat` (إنشاء أو جلب محادثة ثنائية)

```dart
  static Future<String> getOrCreateChat({
    required String otherUserId,
    String? maintenanceRequestId,
  }) async {
    final userId = _db.auth.currentUser!.id;
```

### شرح الباراميترات والتوقيع (Signature):
* **أقواس متعرجة للباراميترات `{}` (Named Parameters):** 
  * في Java، تكون كل المعاملات موضعية (Positional)، أي تُمرر بالترتيب: `getOrCreateChat("id1", "id2")`.
  * في Dart، وضع الباراميترات بين `{}` يعني أنها **باراميترات مسماة (Named Parameters)**. عند استدعاء الدالة، يجب ذكر اسم الباراميتر صراحة، هكذا: `ChatService.getOrCreateChat(otherUserId: 'xxx', maintenanceRequestId: 'yyy')`. يسهل هذا قراءة الكود ويسمح بتغيير ترتيب المعاملات أو الاستغناء عن المعاملات الاختيارية دون الحاجة لإنشاء دوال مكررة (Overloads) كما في Java.
* **الكلمة المحجوزة `required`:**
  * تعني أن الباراميتر المسمى `otherUserId` إجباري ويجب تمريره، بينما `maintenanceRequestId` اختياري. في Java، لا يوجد مرادف مباشر لـ `required` على مستوى الباراميترات، ويجب التحقق من ذلك يدوياً أو باستخدام `@NonNull`.
* **علامة الاستفهام في النوع `String?`:**
  * تعني أن المتغير قابل لأن يكون فارغاً (`Null`). في Dart، يُمنع إرسال `null` للمتغيرات العادية (Null Safety)، فمتغير `String` لا يقبل القيمة `null` أبداً، بينما `String?` يسمح بذلك. في Java، جميع كائنات الكلاسات تقبل `null` بشكل افتراضي، مما يسبب أخطاء `NullPointerException` الشائعة.
* **البرمجة غير المتزامنة (`Future` و `async`):**
  * `Future<String>` تشبه `CompletableFuture<String>` في Java، وهي تمثل عملية ستنتهي في المستقبل لتعيد نصاً.
  * الكلمة `async` توضع قبل جسم الدالة لتمكين استخدام الكلمة المفتاحية `await` بداخلها.
* **علامة التعجب `currentUser!.id`:**
  * تسمى **Null Assertion Operator** (أو Bang Operator). بما أن `currentUser` قد يكون `null` إذا لم يكن هناك تسجيل دخول، فإن وضع `!` يخبر المترجم: "أنا كمتطور أضمن لك أن المستخدم الحالي ليس فارغاً في هذه اللحظة، تعامل معه ككائن مؤكد القيمة". في Java، لا توجد علامة تعجب، ويتم كتابة الكود مباشرة مما قد يتسبب بانهيار البرنامج في حال كان الكائن فارغاً.

---

### شرح كود الدالة سطر بسطر:

```dart
    // Check for existing chat
    final myChats = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    final otherChats = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', otherUserId);
```
* **التبرير والعمل:**
  * نقوم بالاستعلام من جدول `chat_participants` مرتين بشكل منفصل:
    1. المرة الأولى لجلب جميع معرّفات المحادثات (`chat_id`) التي يشارك فيها المستخدم الحالي (`userId`).
    2. المرة الثانية لجلب جميع معرّفات المحادثات التي يشارك فيها المستخدم الآخر (`otherUserId`).
  * **`await`**: توقف تنفيذ الدالة مؤقتاً لحين انتهاء استعلام قاعدة البيانات عبر الإنترنت، دون قفل التطبيق أو تجميد الشاشة. في Java، يتطلب هذا استخدام واجهات برمجية معقدة مثل `thenApply` أو إدارة خيوط العمل (Threads) يدوياً.

```dart
    final myIds = myChats.map((r) => r['chat_id']).toSet();
    final otherIds = otherChats.map((r) => r['chat_id']).toSet();
    final commonIds = myIds.intersection(otherIds);
```
* **التبرير والعمل:**
  * نقوم بتحويل نتائج البحث إلى مجموعات فريدة (Sets) لتسهيل العمليات الرياضية عليها.
  * `intersection`: نقوم بعمل تقاطع بين مجموعتي معرّفات المحادثات. المحادثة المشتركة الناتجة تمثل المحادثة الثنائية (1-to-1) القائمة بينهما.
* **الفروقات عن لغة Java:**
  * **الوصول للماب باستخدام الأقواس `r['chat_id']`:** في Dart، يتم الوصول لقيم الـ Map مثل المصفوفات باستخدام الأقواس المربعة `[]`. في Java ستحتاج لكتابة دالة مثل `r.get("chat_id")`.
  * **رمز السهم `=>` (Arrow Syntax):** يُستخدم في Dart لكتابة الدوال التي تتكون من سطر واحد (مختصرة). في Java تُكتب باستخدام `->` مثل: `r -> r.get("chat_id")`.

```dart
    if (commonIds.isNotEmpty) {
      final chatId = commonIds.first as String;
      if (maintenanceRequestId != null) {
        try {
          await _db.from('chats').update({
            'maintenance_req_id': maintenanceRequestId,
          }).eq('id', chatId);
        } catch (e) {
          print('Error updating chat maintenance request id: $e');
        }
      }
      return chatId;
    }
```
* **التبرير والعمل:**
  * إذا وُجدت محادثة قائمة (أي أن التقاطع `commonIds` ليس فارغاً)، نأخذ أول معرّف محادثة مشترك (`commonIds.first`).
  * إذا كان هناك معرّف طلب صيانة جديد (`maintenanceRequestId`) ممرر للدالة، نقوم بتحديث سجل المحادثة في جدول `chats` لربط المحادثة بطلب الصيانة هذا.
  * نضع العملية داخل `try-catch` لضمان أنه حتى لو فشل ربط طلب الصيانة (بسبب قيود قاعدة البيانات مثلاً)، فإن الدالة ستستمر وترجع معرّف المحادثة بنجاح دون إفشال العملية بأكملها.
* **الفروقات عن لغة Java:**
  * **التحويل باستخدام `as`:** لتحويل كائن من نوع عام إلى نوع محدد في Dart، نستخدم الكلمة المحجوزة `as` (مثال: `commonIds.first as String`). في Java، يتم كتابة النوع المستهدف بين قوسين قبل الكائن: `(String) commonIds.first()`.

```dart
    // Create new chat using RPC function to create the chat and add participants atomically.
    final dynamic resultId = await _db.rpc('create_new_chat', params: {
      'other_user_uuid': otherUserId,
      'maintenance_req_uuid': maintenanceRequestId,
    });

    return resultId as String;
  }
```
* **التبرير والعمل:**
  * إذا لم توجد محادثة سابقة، يجب إنشاء واحدة جديدة. 
  * نستخدم هنا تقنية **RPC (Remote Procedure Call)** لاستدعاء دالة مخزنة داخل قاعدة بيانات Postgres بـ Supabase باسم `create_new_chat`.
  * **لماذا RPC وليس إدخالاً عادياً؟** لإنشاء محادثة ثنائية بشكل ذري (Atomic Transaction). عملية الإنشاء تتطلب إدخال سجل في جدول `chats` وسجلين في جدول `chat_participants`. لو قمنا بذلك من التطبيق مباشرة، قد تفشل العملية بسبب سياسات حماية الجداول (RLS) التي تمنع المستخدم من إضافة مستخدم آخر في جدول المشاركين مباشرة. دالة الـ RPC تنفذ كل هذا على السيرفر كعملية واحدة آمنة.
* **الفروقات عن لغة Java:**
  * **النوع `dynamic`:** نوع بيانات في Dart يخبر المترجم بإيقاف التحقق من نوع المتغير أثناء كتابة الكود (Type Checking) وترك التحقق لوقت التشغيل. في Java، أقرب شبيه له هو استخدام كائن `Object` ولكن مع قيود صارمة من المترجم تتطلب كتابة كود إضافي للتحقق والتحويل.

---

## 3. دالة `fetchChats` (جلب قائمة المحادثات)

```dart
  static Future<List<Map<String, dynamic>>> fetchChats() async {
    final userId = _db.auth.currentUser!.id;

    // Get chat IDs for this user
    final participantRows = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', userId);

    final chatIds = participantRows.map((r) => r['chat_id'] as String).toList();

    if (chatIds.isEmpty) return [];
```
* **الوظيفة:** تجلب قائمة بكافة المحادثات التي يشارك فيها المستخدم الحالي لتعرض في صندوق الوارد (Chat Inbox).
* **طريقة العمل:** تجلب معرّفات المحادثات للمستخدم، ثم تستعلم من جدول `chats` عن تفاصيلها مع جلب بيانات الملف الشخصي للمشاركين الآخرين وآخر الرسائل بترتيب تنازلي.

#### شرح تفصيلي لاستعلام قاعدة البيانات المتداخل:
```dart
    return await _db
        .from('chats')
        .select('''
          *,
          chat_participants(
            profiles!chat_participants_user_id_fkey(id, name, username, profile_image_url)
          ),
          messages(id, text, sender_id, is_read, created_at)
        ''')
        .inFilter('id', chatIds)
        .order('last_message_at', ascending: false);
  }
```
* **التبرير والعمل:**
  * نجلب تفاصيل المحادثات التي تطابق معرّفاتها القائمة `chatIds`.
  * نستخدم الاستعلام المتداخل لـ Supabase لجلب:
    * بيانات المشاركين في المحادثة من جدول `chat_participants` والربط مع جدول `profiles` باستخدام المفتاح الأجنبي المحدد (`chat_participants_user_id_fkey`).
    * الرسائل التابعة للمحادثة لتحديد آخر رسالة وتفاصيلها.
  * `order('last_message_at', ascending: false)`: ترتيب المحادثات بحيث تظهر المحادثات ذات التفاعل الأحدث في الأعلى.
* **الفروقات عن لغة Java:**
  * **علامة الاقتباس الثلاثية `'''`:** تسمح بكتابة نصوص متعددة الأسطر (Multi-line Strings) بشكل مريح جداً لتنسيق كود الاستعلام دون الحاجة لعلامات الربط `+` أو `\n` كما هو الحال في إصدارات Java القديمة.
  * **نوع البيانات المرجعة `List<Map<String, dynamic>>`:** مصفوفة من الخرائط (Maps). في Java يتم تمثيلها كـ `List<Map<String, Object>>`.

---

## 4. دالة `fetchMessages` (جلب رسائل محادثة معينة مجزأة)

```dart
  static Future<List<Map<String, dynamic>>> fetchMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) async {
    return await _db
        .from('messages')
        .select('''
          *,
          profiles!messages_sender_id_fkey(id, name, profile_image_url)
        ''')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }
```
* **التبرير والعمل:**
  * جلب الرسائل التابعة لمحادثة معينة مع ربط بيانات المرسل وعرضها بترتيب تنازلي حسب وقت الإنشاء.
  * **`range(offset, offset + limit - 1)`**: استخدام التصفح المجزأ (Pagination) بحيث يتم جلب 50 رسالة فقط في كل مرة يقوم فيها المستخدم بالتمرير للأعلى، مما يوفر استهلاك البيانات وسرعة استجابة التطبيق.
* **الفروقات عن لغة Java:**
  * **القيم الافتراضية للمعاملات (`int limit = 50`):** تدعم لغة Dart إعطاء قيم افتراضية للباراميترات مباشرة في التوقيع. إذا استدعينا الدالة دون تمرير `limit` أو `offset` فسيتم أخذ القيم الافتراضية (50 و 0). في Java، لإنجاز ذلك يجب كتابة عدة دوال مكررة بتواقيع مختلفة (Method Overloading):
    ```java
    public List<Map<String, Object>> fetchMessages(String chatId) {
        return fetchMessages(chatId, 50, 0);
    }
    ```

---

## 5. دالتا `sendMessage` و `_createMessageNotification` (إرسال الرسائل والإشعارات)

```dart
  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final userId = _db.auth.currentUser!.id;
    final message = await _db.from('messages').insert({
      'chat_id': chatId,
      'sender_id': userId,
      'text': text,
    }).select().single();

    // Trigger notification asynchronously
    _createMessageNotification(chatId: chatId, senderId: userId, text: text);

    return message;
  }
```
* **التبرير والعمل:**
  * يتم إدخال الرسالة في جدول `messages`.
  * `.select().single()`: يطلب من قاعدة البيانات إرجاع السجل المُنشأ حديثاً كخارطة مفردة (`Map`) لكي نعرضه فوراً في الواجهة.
  * **تنفيذ الإشعار بدون `await`:** نلاحظ استدعاء الدالة `_createMessageNotification` بدون الكلمة المفتاحية `await`. هذا قرار تصميمي مقصود (Fire and Forget)؛ فعملية إنشاء الإشعار تتطلب عمليات استعلام إضافية عبر الإنترنت وقد تستغرق وقتاً. من خلال عدم انتظارها، يتم إرسال الرسالة وعرضها فوراً في واجهة المستخدم لتبدو الدردشة سريعة جداً، بينما يتم معالجة إرسال الإشعار في الخلفية.

---

### دالة إنشاء الإشعار (`_createMessageNotification`):

```dart
  static void _createMessageNotification({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      // Find the other participant in the chat
      final participants = await _db
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', chatId)
          .neq('user_id', senderId);
```
* **التبرير والعمل:**
  * `.neq('user_id', senderId)`: تعني Not Equal. نود إرسال الإشعار للشخص الآخر في المحادثة، لذلك نبحث عن مستخدم في جدول المشاركين لا يتطابق معرفه مع معرّف مرسل الرسالة الحالي.

```dart
      if (participants.isNotEmpty) {
        final recipientId = participants.first['user_id'] as String;

        // Fetch sender's name
        final senderProfile = await _db
            .from('profiles')
            .select('name')
            .eq('id', senderId)
            .maybeSingle();
        final senderName = senderProfile?['name'] ?? 'مستخدم شمس';
```
* **التبرير والعمل:**
  * **`maybeSingle()`**: تُستخدم لجلب سجل واحد، وهي تختلف عن `single()`؛ حيث أن `single()` تتسبب بانهيار التطبيق ورمي استثناء (Exception) إذا لم تجد السجل المطلوب في قاعدة البيانات. أما `maybeSingle()` فترجع القيمة `null` بشكل آمن إذا لم تجد السجل، وهو ما نريده هنا لنضع اسماً افتراضياً 'مستخدم شمس' بدلاً من إيقاف التطبيق.
* **الفروقات عن لغة Java:**
  * **عامل الاندماج الصفري والوصول الآمن `senderProfile?['name'] ?? ...`:** تم شرحه سابقاً، وهو كود شديد الاختصار لمنع أخطاء القيم الفارغة وتوفير قيم بديلة.

```dart
        await _db.from('notifications').insert({
          'user_id': recipientId,
          'title': 'رسالة جديدة',
          'message': 'أرسل $senderName: $text',
          'type': 'message',
          'target_id': chatId,
        });
      }
    } catch (e) {
      print('Error creating message notification: $e');
    }
  }
```
* **التبرير والعمل:**
  * يتم إدخال سجل الإشعار في جدول `notifications`.
* **الفروقات عن لغة Java:**
  * **تضمين المتغيرات في النص `'أرسل $senderName: $text'` (String Interpolation):** يتم دمج قيم المتغيرات داخل النص مباشرة باستخدام رمز `$`، مما يجعل الكود أنظف بكثير مقارنة بـ Java التي تتطلب عملية الدمج اليدوي بالجمع `+`.

---

## 6. دالة `markChatAsRead` (تعليم الرسائل كمقروءة)

```dart
  static Future<void> markChatAsRead(String chatId) async {
    final userId = _db.auth.currentUser!.id;
    await _db
        .from('messages')
        .update({'is_read': true})
        .eq('chat_id', chatId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }
```
* **التبرير والعمل:**
  * تقوم بتحديث حقل `is_read` إلى `true` في جدول `messages`.
  * **شروط التحديث الدقيقة:** نحدث فقط الرسائل التابعة لهذه المحادثة (`eq('chat_id', chatId)`) والتي لم يرسلها المستخدم الحالي (`neq('sender_id', userId)`) والتي كانت حالتها غير مقروءة بعد (`eq('is_read', false)`). هذا يحمي البيانات من التعديل العشوائي ويقلل العمليات على قاعدة البيانات.

---

## 7. دالات الحذف (`deleteChat` / `deleteChats`)

```dart
  static Future<void> deleteChat(String chatId) async {
    await _db.from('chats').delete().eq('id', chatId);
  }

  static Future<void> deleteChats(List<String> chatIds) async {
    await _db.from('chats').delete().inFilter('id', chatIds);
  }
```
* **التبرير والعمل:**
  * حذف محادثة أو عدة محادثات. تم تفعيل خيار الحذف المتتابع (CASCADE Delete) في قاعدة بيانات Postgres، وبالتالي عند حذف سجل المحادثة، سيتم تلقائياً حذف سجلات المشاركين والرسائل المرتبطة بها لحفظ نظافة وسلامة قاعدة البيانات.
  * **`inFilter`**: مرادف للاستعلام `IN` في SQL، للبحث والحذف داخل قائمة معينة من المعرّفات.

---

## 8. الاشتراكات اللحظية (Real-Time Streams)

```dart
  static RealtimeChannel subscribeToMessages({
    required String chatId,
    required void Function(Map<String, dynamic> newMessage) onNewMessage,
  }) {
    return _db
        .channel('chat:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            onNewMessage(payload.newRecord);
          },
        )
        .subscribe();
  }
```
* **التبرير والعمل:**
  * إنشاء قناة اتصال مستمرة (Websocket) للاستماع لأي عمليات إضافة رسائل جديدة تخص هذه المحادثة بالتحديد على مستوى قاعدة البيانات.
  * **`PostgresChangeFilterType.eq`**: يضمن تصفية البيانات على خوادم Supabase بحيث لا يستقبل التطبيق إلا الرسائل التي تحمل معرف المحادثة المطلوبة فقط، مما يمنع تسريب البيانات غير المصرح بها ويوفر موارد المعالجة.
  * **الإرجاع `RealtimeChannel`:** تُرجع الدالة كائن القناة المشتركة لكي تتمكن الواجهة الرسومية من حفظه في الذاكرة وإلغاء الاشتراك فيه يدوياً (`unsubscribe`) عند الخروج من شاشة المحادثة لمنع حدوث تسريب في الذاكرة (Memory Leaks).
* **الفروقات عن لغة Java:**
  * **تمرير الدوال كمعاملات (`void Function(...) onNewMessage`):** في لغة Dart، تعتبر الدوال عناصر أساسية (First-Class Citizens)، حيث يمكن تمرير دالة كمعامل لدالة أخرى بشكل طبيعي كما نمرر النصوص أو الأرقام. في Java لا يمكن القيام بذلك بشكل مباشر، بل يجب تعريف واجهة (Interface) مثل `MessageCallback` ثم تمرير كائن يطبقها.

```dart
  static RealtimeChannel subscribeToChatList({
    required List<String> chatIds,
    required void Function() onUpdate,
  }) {
    return _db
        .channel('chat-list')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter,
            column: 'chat_id',
            value: chatIds,
          ),
          callback: (_) => onUpdate(),
        )
        .subscribe();
  }
}
```
* **التبرير والعمل:**
  * دالة شبيهة بالسابقة ولكنها تستمع لجميع التغيرات (`PostgresChangeEvent.all`) التي تحدث على الرسائل في قائمة المحادثات النشطة للمستخدم بالكامل. يتم استخدامها في شاشة قائمة الرسائل لتحديث الواجهة بمجرد استقبال أي رسالة جديدة في أي محادثة.
* **الفروقات عن لغة Java:**
  * **تجاهل المعامل باستخدام الرمز الشرطة السفلية `_`:** في دالة الـ callback: `(_) => onUpdate()`. عندما تمرر دالة مجهولة وتكون غير مهتم بالمعاملات الممررة إليها (هنا الـ payload)، يُستخدم الرمز `_` كاسم متغير مخصص للإشارة إلى أن هذا المعامل غير مستخدم ومهمش. في Java لا يوجد رمز مخصص مبني لغوياً لتجاهل المعاملات بهذه الطريقة المباشرة.
