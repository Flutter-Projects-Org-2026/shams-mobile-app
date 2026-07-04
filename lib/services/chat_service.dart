import 'package:supabase_flutter/supabase_flutter.dart'; // حزمة Supabase للوصول إلى Auth وقاعدة البيانات والـ Realtime

class ChatService {
  // [static final] متغير ثابت مشترك بين كل instances
  // المترجم يستنتج النوع تلقائياً (Type Inference) - لا نحتاج كتابته صراحة
  // الشرطة السفلية _ تعني private
  static final _db = Supabase.instance.client;

  // ── CREATE CHAT ─────────────────────────────────────────────────────────

  /// Creates a new 1-to-1 chat and returns the chat ID.
  /// If a chat already exists between these users, returns existing ID.
  // [Future<String>] وعد بإرجاع نص بعد انتهاء العملية
  // المعاملات بين {} تسمى Named Parameters
  // استدعاؤها: ChatService.getOrCreateChat(otherUserId: 'xxx') - يجب ذكر اسم الباراميتر عند الاستدعاء
  static Future<String> getOrCreateChat({
    required String otherUserId,      // [required] إجباري - لا يمكن استدعاء الدالة دون تمريره
    String? maintenanceRequestId,     // [String?] اختياري قابل للـ null - بدون required ويقبل null بعلامة ?
  }) async { // [async] تُمكّن استخدام await بداخل الدالة لانتظار الشبكة دون تجميد الواجهة
    // [!] Null Assertion: نضمن أن المستخدم مسجّل هنا - إذا كان null سينهار التطبيق وقت التشغيل
    final userId = _db.auth.currentUser!.id;

    // Check for existing chat
    // [await] توقف هنا وانتظر قاعدة البيانات دون قفل الـ UI Thread
    final myChats = await _db
        .from('chat_participants') // الجدول الهدف - يحتوي على (chat_id, user_id) لكل مشارك
        .select('chat_id')         // اجلب عمود chat_id فقط لتقليل البيانات المنقولة
        .eq('user_id', userId);    // [eq] = WHERE user_id = userId في SQL - فلتر على ID المستخدم الحالي

    final otherChats = await _db
        .from('chat_participants')
        .select('chat_id')
        .eq('user_id', otherUserId); // نفس الشيء ولكن للمستخدم الآخر

    // [map((r) => r['chat_id'])] تحويل كل صف (Map) إلى قيمة chat_id فقط
    // [r['chat_id']] الوصول لعناصر الـ Map بالأقواس المربعة
    // [(r) => r['chat_id']] Arrow Function مختصرة لدالة تُرجع قيمة واحدة
    // [.toSet()] تحويل القائمة لـ Set لتفعيل عملية intersection() وإزالة التكرار
    final myIds = myChats.map((r) => r['chat_id']).toSet();
    final otherIds = otherChats.map((r) => r['chat_id']).toSet();
    // [intersection()] عملية تقاطع رياضية: تُرجع العناصر الموجودة في كلا الـ Sets
    // المحادثة المشتركة = محادثة يشارك فيها المستخدمان معاً = محادثة 1-to-1 قائمة بينهما
    final commonIds = myIds.intersection(otherIds);

    if (commonIds.isNotEmpty) { // وُجدت محادثة قديمة بين المستخدمين - لا نُنشئ جديدة
      // [as String] تحويل صريح للنوع من dynamic إلى String
      // [commonIds.first] أخذ أول عنصر في الـ Set - محادثة واحدة كافية
      final chatId = commonIds.first as String;
      if (maintenanceRequestId != null) { // هل لدينا طلب صيانة جديد نريد ربطه بهذه المحادثة؟
        try { // try منفصلة: حتى لو فشل ربط طلب الصيانة، نُرجع معرّف المحادثة ولا نفشل الكل
          await _db.from('chats').update({
            'maintenance_req_id': maintenanceRequestId, // ربط المحادثة بطلب الصيانة الجديد
          }).eq('id', chatId); // شرط التحديث: فقط هذه المحادثة بالذات
        } catch (e) {
          print('Error updating chat maintenance request id: $e'); // فشل ربط طلب الصيانة - لا ينهار التطبيق
        }
      }
      return chatId; // أرجع معرّف المحادثة القديمة الموجودة مسبقاً
    }

    // لم توجد محادثة مشتركة - ننشئ واحدة جديدة
    // لماذا RPC وليس INSERT مباشر؟
    // إنشاء محادثة يتطلب: INSERT في chats + INSERT سجلين في chat_participants
    // سياسات RLS تمنع المستخدم من إدخال مستخدم آخر في chat_participants مباشرة
    // RPC = Remote Procedure Call: دالة تُنفَّذ على خادم Supabase كعملية ذرية (Atomic Transaction)
    // إذا فشل أي جزء من الدالة على السيرفر يُلغى كل شيء - لا بيانات ناقصة أو مكررة
    final dynamic resultId = await _db.rpc('create_new_chat', params: { // [dynamic] نوع مرن - المترجم لا يتحقق منه مسبقاً
      'other_user_uuid': otherUserId,            // باراميتر الدالة المخزّنة في قاعدة البيانات
      'maintenance_req_uuid': maintenanceRequestId, // قد يكون null - الدالة تتعامل مع ذلك
    });

    return resultId as String; // نحوّل نتيجة RPC من dynamic إلى String للتأكيد على النوع
  }

  // ── READ (User's chat list) ─────────────────────────────────────────────

  // [List<Map<String, dynamic>>] قائمة من الخرائط - كل خارطة تمثل محادثة واحدة
  static Future<List<Map<String, dynamic>>> fetchChats() async {
    final userId = _db.auth.currentUser!.id;

    // Get chat IDs for this user
    final participantRows = await _db
        .from('chat_participants')
        .select('chat_id') // نحتاج chat_id فقط لنعرف أي المحادثات يشارك فيها المستخدم
        .eq('user_id', userId);

    // [map((r) => r['chat_id'] as String)] تحويل كل صف لنص chat_id فقط - نحتاجه للـ inFilter لاحقاً
    // [.toList()] تحويل Iterable إلى List - نحتاجه لأن inFilter يتوقع List
    final chatIds = participantRows.map((r) => r['chat_id'] as String).toList();

    if (chatIds.isEmpty) return []; // لا توجد محادثات - أرجع قائمة فارغة ولا ترسل استعلاماً للسيرفر

    // Fetch chats with participants' profiles
    // هذا استعلام واحد يجلب بيانات من 3 جداول مرتبطة بشكل شجري (Hierarchical) لا مسطح (Flat)
    // بدلاً من JOIN الكلاسيكي الذي يُكرر البيانات، يرجع Supabase JSON شجري منظّم
    return await _db
        .from('chats') // الجدول الأساسي الذي نبني حوله الاستعلام
        .select('''
          *,
          chat_participants(
            profiles!chat_participants_user_id_fkey(id, name, username, profile_image_url)
          ),
          messages(id, text, sender_id, is_read, created_at)
        ''')
        // [*] جلب كل أعمدة جدول chats (id, last_message_at, maintenance_req_id, ...)
        // [chat_participants(...)] جلب سجلات المشاركين المرتبطة بكل محادثة كمصفوفة متداخلة
        // [profiles!chat_participants_user_id_fkey(...)] ربط profiles بـ chat_participants
        //   [!] علامة التعجب = Explicit Join Disambiguation: يوجّه Supabase لاستخدام مفتاح أجنبي محدد
        //   ضرورية لأن chat_participants قد يرتبط بـ profiles بأكثر من مفتاح أجنبي - بدونها: خطأ من السيرفر
        //   [(id, name, username, profile_image_url)] تحديد الأعمدة المطلوبة فقط - لا نجلب email أو تواريخ
        // [messages(...)] جلب رسائل المحادثة لعرض آخر رسالة ومعرفة هل هناك غير مقروء
        // هيكل JSON الناتج: [{id:.., chat_participants:[{profiles:{name:.., profile_image_url:..}}], messages:[{text:..}]}]
        .inFilter('id', chatIds) // [inFilter] = WHERE id IN ('id1', 'id2', ...) في SQL - نجلب محادثات المستخدم فقط
        .order('last_message_at', ascending: false); // ترتيب تنازلي: المحادثة الأحدث نشاطاً في الأعلى
  }

  // ── READ (Messages in a chat — paginated) ───────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchMessages({
    required String chatId,
    int limit = 50,  // [قيمة افتراضية] إذا لم يُمرَّر limit عند الاستدعاء، يُستخدم 50 تلقائياً
    int offset = 0,  // نقطة البداية للتصفح المجزأ (Pagination) - الصفحة الأولى تبدأ من 0
  }) async {
    return await _db
        .from('messages')
        .select('''
          *,
          profiles!messages_sender_id_fkey(id, name, profile_image_url)
        ''')
        // [profiles!messages_sender_id_fkey] ربط بيانات المرسل من جدول profiles
        // [!] تحديد المفتاح الأجنبي صراحة لتجنب الغموض في الربط
        .eq('chat_id', chatId)                // فلتر: فقط رسائل هذه المحادثة
        .order('created_at', ascending: false) // الأحدث أولاً (من الأسفل للأعلى في واجهة الدردشة)
        .range(offset, offset + limit - 1);    // [range] = LIMIT/OFFSET في SQL - نجلب 50 رسالة فقط في المرة الأولى
        // مثال: limit=50, offset=0 -> نجلب من السجل 0 إلى 49
        // عند التمرير للأعلى: limit=50, offset=50 -> نجلب من 50 إلى 99 (الصفحة الثانية)
  }

  // ── SEND MESSAGE ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final userId = _db.auth.currentUser!.id;
    final message = await _db.from('messages').insert({
      'chat_id': chatId,    // ربط الرسالة بالمحادثة الصحيحة
      'sender_id': userId,  // تسجيل هوية المرسل
      'text': text,         // نص الرسالة
    }).select().single(); // [.select().single()] أرجع السجل المُدخَل - نحتاجه لعرضه فوراً في الواجهة

    // [بدون await] - قرار تصميمي "Fire and Forget": نطلق الإشعار دون انتظار نتيجته
    // السبب: إنشاء الإشعار يتطلب استعلامات إضافية (جلب اسم المرسل، معرّف المُستلم)
    // لو انتظرناها ستتأخر ظهور الرسالة في الواجهة - المستخدم يجب أن يرى رسالته فوراً
    _createMessageNotification(chatId: chatId, senderId: userId, text: text);

    return message; // أرجع بيانات الرسالة المُنشأة لعرضها في واجهة الدردشة
  }

  // دالة private (شرطة سفلية _) - مساعدة لإنشاء الإشعار في الخلفية بشكل مستقل
  // [void] لا ترجع قيمة، و [async] لاستخدام await بداخلها دون أن يكون المستدعي مضطراً للانتظار
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
          .eq('chat_id', chatId)     // من هم المشاركون في هذه المحادثة؟
          .neq('user_id', senderId); // [neq] = NOT EQUAL = WHERE user_id != senderId
          // نبحث عن المستلم = أي مشارك في المحادثة ليس هو المرسل نفسه

      if (participants.isNotEmpty) {
        // [participants.first['user_id']] الوصول لأول عنصر في القائمة ثم لقيمة user_id منه
        final recipientId = participants.first['user_id'] as String;

        // Fetch sender's name
        final senderProfile = await _db
            .from('profiles')
            .select('name')
            .eq('id', senderId)
            .maybeSingle(); // [maybeSingle] يُرجع null إذا لم يجد السجل - أآمن من single() الذي يرمي استثناء
            // [single()] يُرجع خطأً إذا لم يجد السجل - لا نريد ذلك هنا
        // [senderProfile?['name']] [?.] Safe Navigation: إذا senderProfile كان null لا ينهار التطبيق
        // [??] إذا كانت النتيجة null، استخدم 'مستخدم شمس' كقيمة افتراضية
        final senderName = senderProfile?['name'] ?? 'مستخدم شمس';

        await _db.from('notifications').insert({
          'user_id': recipientId,                 // من سيستقبل الإشعار
          'title': 'رسالة جديدة',                // عنوان الإشعار
          'message': 'أرسل $senderName: $text',  // [$senderName] String Interpolation لتضمين المتغير مباشرة في النص
          'type': 'message',                      // نوع الإشعار لتحديد كيف تتصرف واجهة الإشعارات معه
          'target_id': chatId,                    // لفتح المحادثة الصحيحة عند الضغط على الإشعار
        });
      }
    } catch (e) {
      print('Error creating message notification: $e'); // فشل الإشعار - لا يؤثر على إرسال الرسالة
    }
  }

  // ── MARK AS READ ────────────────────────────────────────────────────────

  static Future<void> markChatAsRead(String chatId) async {
    final userId = _db.auth.currentUser!.id;
    await _db
        .from('messages')
        .update({'is_read': true})   // حدّث حقل is_read إلى true
        .eq('chat_id', chatId)       // فقط رسائل هذه المحادثة
        .neq('sender_id', userId)    // فقط الرسائل التي أرسلها الآخرون (ليس أنا)
        .eq('is_read', false);       // فقط الرسائل التي لم تُقرأ بعد - لا نعيد تحديث المقروءة مسبقاً
        // الثلاثة شروط مجتمعة = UPDATE ... WHERE chat_id=? AND sender_id!=? AND is_read=false
  }

  // ── DELETE CHAT ─────────────────────────────────────────────────────────

  // حذف محادثة واحدة - CASCADE DELETE في Supabase سيحذف المشاركين والرسائل تلقائياً
  static Future<void> deleteChat(String chatId) async {
    await _db.from('chats').delete().eq('id', chatId); // WHERE id = chatId
  }

  // حذف عدة محادثات دفعة واحدة - أكفأ من استدعاء deleteChat() بحلقة
  static Future<void> deleteChats(List<String> chatIds) async {
    await _db.from('chats').delete().inFilter('id', chatIds); // WHERE id IN ('id1', 'id2', ...)
  }

  // ── REAL-TIME STREAM ──────────────────────────────────────────────────
  // الـ Realtime يعمل عبر WebSocket: قناة اتصال مفتوحة بين التطبيق والسيرفر
  // بدلاً من "Polling" (سؤال السيرفر كل ثانية) يُرسل السيرفر البيانات تلقائياً عند حدوث تغيير
  // [جهاز A يرسل رسالة] -> [Supabase DB] -> (حدث Insert) -> [WebSocket] -> [جهاز B يستقبلها فوراً]

  /// Subscribe to new messages in a specific chat.
  /// Returns a RealtimeChannel that should be disposed when leaving the screen.
  static RealtimeChannel subscribeToMessages({
    required String chatId,
    // [void Function(...)] الدالة نفسها كمعامل (First-Class Function)
    // نمرر الدالة مباشرة - الواجهة ستُمرر دالة تُضيف الرسالة الجديدة للقائمة المعروضة
    required void Function(Map<String, dynamic> newMessage) onNewMessage,
  }) { // لاحظ: لا يوجد async لأن الدالة لا تنتظر شيئاً - تُنشئ القناة وتعود فوراً
    return _db
        .channel('chat:$chatId') // [$chatId] String Interpolation - اسم فريد للقناة مثل "chat:uuid-123"
        // الاسم الفريد ضروري لكي لا تتداخل رسائل محادثات مختلفة في نفس القناة
        .onPostgresChanges( // استمع لتغييرات قاعدة البيانات PostgreSQL
          event: PostgresChangeEvent.insert, // [insert فقط] نريد الرسائل الجديدة فقط - لا التعديل أو الحذف
          schema: 'public',  // المخطط الذي يحتوي على جدول messages
          table: 'messages', // الجدول الذي نراقبه
          filter: PostgresChangeFilter( // [فلتر مهم جداً] بدونه سيصل لنا كل INSERT في جدول messages من أي محادثة
            type: PostgresChangeFilterType.eq, // [eq] مساوٍ لـ - فقط رسائل تطابق chatId المحدد
            column: 'chat_id', // العمود الذي نفلتر عليه في السيرفر نفسه (ليس في التطبيق)
            value: chatId,     // قيمة الفلتر: معرّف المحادثة المفتوحة حالياً
          ), // الفلتر يعمل على الـ Server-Side - نتلقى فقط رسائل هذه المحادثة تحديداً
          callback: (payload) { // callback: دالة تُنفَّذ عند وصول رسالة جديدة
            // [payload.newRecord] يحتوي على بيانات السجل المُدخَل حديثاً كـ Map
            onNewMessage(payload.newRecord); // نُمرر الرسالة الجديدة للدالة الممررة من الواجهة
          },
        )
        .subscribe(); // ابدأ الاتصال والمصافحة (Handshake) لفتح قناة WebSocket
        // [RealtimeChannel] نُرجعه للشاشة لحفظه وإغلاقه عند الخروج: channel.unsubscribe()
        // بدون unsubscribe: Memory Leak - القناة تبقى مفتوحة بعد مغادرة الشاشة وتستهلك الموارد
  }

  /// Subscribe to chat list updates (new messages across all user's chats).
  // هذه الدالة تُستخدم في شاشة قائمة المحادثات (inbox) وليس داخل محادثة مفتوحة
  // الفرق عن subscribeToMessages: تستمع لكل محادثات المستخدم وليس محادثة واحدة
  static RealtimeChannel subscribeToChatList({
    required List<String> chatIds, // قائمة بمعرّفات كل محادثات المستخدم الحالي
    required void Function() onUpdate, // [void Function()] دالة بدون معاملات - نستدعيها عند أي تغيير
  }) {
    return _db
        .channel('chat-list') // اسم ثابت لأننا نراقب كل المحادثات وليس محادثة بعينها
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // [all] كل الأحداث: INSERT(رسالة جديدة) + UPDATE(قُرئت) + DELETE(حُذفت)
          // لماذا all وليس insert فقط؟ نريد تحديث القائمة عند: وصول رسالة جديدة أو قراءتها أو حذفها
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.inFilter, // [inFilter] مثل SQL IN - يقبل قائمة وليس قيمة واحدة
            column: 'chat_id',
            value: chatIds, // فلتر على كل محادثات المستخدم دفعة واحدة - لا نتلقى رسائل الآخرين
          ),
          // [(_) =>] الشرطة السفلية _ كاسم المعامل: تعني "لا أهتم بمحتوى payload"
          // تُوضّح صراحة للقارئ أن هذا المعامل مقصود تجاهله
          callback: (_) => onUpdate(), // عند أي تغيير: استدعِ onUpdate() لتحديث قائمة المحادثات
        )
        .subscribe();
  }
}
