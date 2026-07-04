import 'dart:io'; // [dart:io] مكتبة Dart للتعامل مع نظام الملفات - نحتاجها لـ FileImage لعرض صور الجهاز المحلية
import 'package:flutter/material.dart'; // توفر ChangeNotifier لإدارة الحالة + NetworkImage/FileImage للتعامل مع كاش الصور
import '../models/user_model.dart'; // نموذج بيانات المستخدم الذي نخزّنه ونُحوّل إليه البيانات القادمة من Supabase
import 'package:supabase_flutter/supabase_flutter.dart'; // للوصول إلى Auth وقاعدة البيانات عبر Supabase

// أي widget يستخدم context.watch<UserProvider>() سيُعاد بناؤه تلقائياً عند استدعاء notifyListeners()
class UserProvider extends ChangeNotifier {
  // [const] القيمة الابتدائية ثابتة وقت التصريف - نستخدم قيمة مبدئية بدلاً من null لضمان أمان النوع (Null Safety)
  UserModel _currentUser = const UserModel(
    id: '',                  // معرّف فارغ يشير إلى أنه لم يُحمَّل بعد
    name: 'جاري التحميل...', // اسم مؤقت يظهر في الواجهة ريثما تنتهي عملية جلب البيانات من السيرفر
    email: '',               // بريد إلكتروني فارغ مبدئياً
  );

  // [Getter] العالَم الخارجي يقرأ فقط - لا يستطيع تعديل _currentUser مباشرة
  UserModel get currentUser => _currentUser; // [=>] Arrow Syntax: اختصار لدالة تعيد قيمة واحدة

  // [_evictImage] الشرطة السفلية _ قبل الاسم تعني private
  // الهدف: حذف الصورة من ذاكرة كاش Flutter حتى لا تظهر الصورة القديمة عند تغيير المستخدم لصورته
  void _evictImage(String? path) { // [String?] علامة ? تعني أن path قد يكون null
    if (path == null || path.isEmpty) return; // تحقق مبكر: إذا المسار فارغ أو null، اخرج فوراً دون عمل أي شيء
    try { // نلف بـ try-catch لأن evict() قد ترمي استثناء إذا الصورة لم تكن في الكاش أصلاً
      if (path.startsWith('http')) { // صورة من الإنترنت (URL من Supabase Storage مثلاً)
        // [NetworkImage(path).evict()] ينشئ مفتاح كاش للصورة ثم يحذفه من imageCache في Flutter
        // بدون هذا السطر: إذا غيّر المستخدم صورته والرابط نفسه - Flutter سيعرض الصورة القديمة من الكاش إلى الأبد
        NetworkImage(path).evict();
      } else if (!path.startsWith('assets/')) { // صورة محلية من جهاز المستخدم (اختارها من المعرض مثلاً)
        FileImage(File(path)).evict(); // [File(path)] من dart:io - ينشئ كائن ملف ثم يحذف كاشه من Flutter
      }
      // ملاحظة: صور assets/ لا نحذفها لأنها ثابتة في التطبيق ولا تتغير أبداً
    } catch (e) {
      debugPrint('Error evicting image: $e'); // [$e] String Interpolation لتضمين قيمة المتغير في النص
    }
  }

  // تُستدعى بعد نجاح تعديل الملف الشخصي في edit_profile_screen.dart
  // تُحدّث البيانات محلياً في الذاكرة مباشرة دون الحاجة للرجوع لـ Supabase مجدداً
  void updateProfile(UserModel updatedUser) {
    // نقارن رابط الصورة القديمة بالجديدة - إذا اختلفا يجب حذف الصورة القديمة من الكاش
    if (_currentUser.profileImageUrl != updatedUser.profileImageUrl) {
      _evictImage(_currentUser.profileImageUrl); // احذف الصورة القديمة من الكاش قبل التحديث
    }
    _currentUser = updatedUser; // استبدل كائن المستخدم القديم بالجديد المُحدَّث
    notifyListeners(); // أخبر كل widget يراقبنا بأن البيانات تغيّرت وأعد بناء الواجهة
  }

  // [Future<void>] وعد بإتمام العملية مستقبلاً دون إرجاع قيمة
  // [async] تُمكّن استخدام await بداخل الدالة - بدونها await لن تعمل
  Future<void> fetchUserData() async {
    try { // نحيط كل العملية بـ try-catch لأن أي خطأ شبكي يجب ألا ينهار التطبيق
      // [!] Null Assertion Operator: نؤكد للمترجم أن currentUser ليس null هنا
      // لو كان null فعلاً وقت التشغيل سينهار التطبيق - نستخدمها هنا لأننا متأكدون أن المستخدم مسجّل دخوله
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return; // لا يوجد مستخدم مسجّل - اخرج بهدوء دون عمل أي شيء

      Map<String, dynamic>? data; // [Map<String, dynamic>?] ماب قابلة للـ null مبدئياً قبل تعبئتها من Supabase
      try { // try داخلية منفصلة: قد يفشل هذا الاستعلام إذا لم يُنشأ سجل المستخدم في profiles بعد
        data = await Supabase.instance.client // [await] توقف هنا وانتظر نتيجة الشبكة دون تجميد الواجهة
            .from('profiles')  // الجدول الهدف في Supabase
            .select()          // اجلب كل الأعمدة (SELECT *)
            .eq('id', user.id) // [eq] WHERE id = user.id بالـ SQL
            .single();         // نتوقع سجلاً واحداً فقط - لو لم يجد أي سجل يرمي استثناء -> نذهب لـ catch
      } catch (e) {
        debugPrint( // [debugPrint] أذكى من print - لا تطبع في release mode
          'Profile row not found, auto-creating default profile row: $e',
        );
        // سيناريو: المستخدم سجّل عبر Google OAuth ولم يكمل إنشاء الملف الشخصي بعد
        final email = user.email ?? ''; // [??] Null-coalescing: إذا email كان null خذ ''
        // إذا لديه بريد، خذ الجزء قبل @ كاسم مستخدم، وإلا أنشئ اسماً عشوائياً من أول 5 أحرف من الـ ID
        final defaultUsername = email.isNotEmpty
            ? email.split('@').first             // "ahmed@gmail.com" -> "ahmed"
            : 'user_${user.id.substring(0, 5)}'; // [${}] String Interpolation لتضمين تعبير داخل النص
        // ابحث عن الاسم في metadata الـ OAuth (مثل Google) بالأولوية: full_name ثم name ثم اسم افتراضي
        final defaultName =
            user.userMetadata?['full_name'] ?? // [?.] Safe Navigation: لو userMetadata كان null لا ينهار
            user.userMetadata?['name'] ??       // انتقل للبديل التالي إذا كان null
            'مستخدم شمس';                       // القيمة الافتراضية الأخيرة إذا لم يوجد اسم من أي مصدر

        // [upsert] = INSERT إذا لم يكن موجوداً، أو UPDATE إذا كان موجوداً - أذكى من INSERT العادي
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,               // معرّف المستخدم من Supabase Auth
          'name': defaultName,         // الاسم المستخرج من OAuth أو الافتراضي
          'username': defaultUsername, // الجزء قبل @ من البريد أو اسم عشوائي
          'email': email,              // البريد الإلكتروني
          'has_workshop': false,       // المستخدم الجديد لا يملك ورشة بالطبع
        });

        // الآن بعد إنشاء السجل، اجلبه مرة ثانية لتعبئة متغير data بالبيانات المُدخَلة
        data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      }

      // [Spread Operator ...data] ينسخ كل مفاتيح وقيم data داخل الماب الجديدة
      // ثم 'email' الجديد يُكتب بعده ويُستبدل به - المفتاح الأخير يفوز في Dart Maps (لا يتكرر)
      // لماذا نُعيد الإيميل؟ لأن الإيميل في جدول profiles قد لا يكون محدّثاً دائماً
      // مصدر الحقيقة الأصلي للإيميل هو جلسة Auth وليس جدول profiles
      final newUser = UserModel.fromMap({
        ...data, // [Spread ...] يفرغ كل محتوى data: {"id":..., "name":..., "email": "قديم", ...}
        'email': user.email ?? data['email'] ?? '', // يُكتب بعد الـ spread فيُلغي قيمة email القديمة في data
        // النتيجة: ماب بدون تكرار - email القديم في data استُبدل بهذا الجديد
      });

      // تحقق مرة أخرى: هل تغيّرت الصورة الشخصية بعد جلب البيانات الجديدة؟ احذف القديمة من الكاش
      if (_currentUser.profileImageUrl != newUser.profileImageUrl) {
        _evictImage(_currentUser.profileImageUrl);
      }

      _currentUser = newUser; // حدّث المتغير الداخلي بالكائن الجديد الممتلئ بالبيانات الحقيقية
      notifyListeners(); // أرسل إشعاراً لكل الواجهات المراقِبة لإعادة بنائها وعرض الاسم والصورة الجديدة
    } catch (e) {
      debugPrint('Error fetching user data: $e'); // فشل عام - اطبع في الـ console وأبقِ التطبيق يعمل
    }
  }

  // تُستدعى مباشرة بعد نجاح إنشاء ورشة جديدة في add_workshop_screen.dart
  // تُحدّث الحالة محلياً فوراً دون انتظار جلب البيانات من Supabase من جديد
  void updateWorkshopStatus(bool hasWorkshop) {
    if (_currentUser.id.isNotEmpty) { // تأكد أن هناك مستخدماً حقيقياً مسجّلاً وليس الكائن الافتراضي الفارغ
      // [copyWith] ينشئ نسخة جديدة من الكائن مع تغيير حقل واحد فقط دون المساس بباقي الحقول
      _currentUser = _currentUser.copyWith(hasWorkshop: hasWorkshop);
      notifyListeners(); // أخبر الواجهة: غيّر زر "إنشاء ورشة" إلى "لوحة تحكم الورشة" فوراً
    }
  }

  // تُستدعى من ShamsDrawer أو signOut: امسح كل بيانات المستخدم من ذاكرة التطبيق
  // هذا يحمي خصوصية المستخدم ويمنع ظهور بياناته في الجلسة التالية
  void clearUserData() {
    // أعد تهيئة _currentUser لكائن فارغ - لا نستخدم null لأن Dart لا يسمح بذلك بدون ?
    _currentUser = const UserModel(id: '', name: 'مستخدم غير مسجل', email: '');
    notifyListeners(); // أجبر الواجهة على العودة لحالة "غير مسجّل" وإخفاء البيانات الشخصية
  }
}
