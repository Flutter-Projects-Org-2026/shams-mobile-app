# شرح تفصيلي لملف `user_provider.dart`

ملف `user_provider.dart` هو أحد مزودي الحالة (Providers) الأساسيين في تطبيق **شمس**. يرث الكلاس من `ChangeNotifier` التابع لمكتبة Flutter، مما يسمح له بإدارة حالة المستخدم الحالي (`UserModel`) وتنبيه الواجهات (UI) لإعادة البناء فور حدوث أي تعديل.

---

## 1. شرح الاستيرادات (Imports)

* **السطر 1:** `import 'dart:io';`
  * يستورد مكتبة إدخال وإخراج الملفات من لغة Dart لتوفير كائن `File` اللازم للتعامل مع الصور المخزنة محلياً على الجهاز.
* **السطر 2:** `import 'package:flutter/material.dart';`
  * يستورد مكتبة Flutter الأساسية للواجهات الرسومية، والتي توفر كلاس `ChangeNotifier` وكلاسات إدارة الصور مثل `NetworkImage` و`FileImage`.
* **السطر 3:** `import '../models/user_model.dart';`
  * يستورد نموذج بيانات المستخدم `UserModel` لتحويل ومعالجة البيانات الخاصة بالمستخدم الحالي.
* **السطر 4:** `import 'package:supabase_flutter/supabase_flutter.dart';`
  * يستورد حزمة Supabase للتعامل مع قاعدة البيانات والمصادقة (Authentication).

---

## 2. تعريف الكلاس والمتغيرات

```dart
class UserProvider extends ChangeNotifier {
  UserModel _currentUser = const UserModel(
    id: '',
    name: 'جاري التحميل...',
    email: '',
  );

  UserModel get currentUser => _currentUser;
```
* **السطر 6:** تعريف الكلاس `UserProvider` الذي يرث `ChangeNotifier` لتفعيل إدارة الحالة.
* **الأسطر 7-11:** تعريف متغير خاص (Private) باسم `_currentUser` لتخزين كائن المستخدم الحالي. يتم إعطاؤه قيمة افتراضية أولية تشير إلى أن البيانات "جاري التحميل..." لتجنب الأخطاء البرمجية الناتجة عن القيم الفارغة (Null Pointer Exceptions) عند بدء التطبيق.
* **السطر 13:** توفير مُسترجِع (Getter) عام باسم `currentUser` للوصول إلى بيانات المستخدم الخاص بشكل آمن للقراءة فقط من خارج الكلاس.

---

## 3. الدالة الخاصة `_evictImage` (تفريغ ذاكرة الصورة)

```dart
  void _evictImage(String? path) {
    if (path == null || path.isEmpty) return;
    try {
      if (path.startsWith('http')) {
        NetworkImage(path).evict();
      } else if (!path.startsWith('assets/')) {
        FileImage(File(path)).evict();
      }
    } catch (e) {
      debugPrint('Error evicting image: $e');
    }
  }
```
* **الوظيفة:** تفريغ كاش الصورة (Image Cache Eviction) من ذاكرة Flutter المؤقتة. هذا يضمن أنه عند تحديث المستخدم لصورته الشخصية بنفس المسار، يقوم التطبيق بتحميل الصورة الجديدة بدلاً من عرض الصورة القديمة المخزنة مؤقتاً.
* **السطر 16:** التحقق مما إذا كان مسار الصورة فارغاً أو غير معرف، وعندها يتم الخروج من الدالة فوراً.
* **السطر 17:** بدء كتلة `try-catch` لتفادي توقف التطبيق في حال حدوث خطأ أثناء محاولة حذف كاش الصورة.
* **الأسطر 18-19:** إذا كان المسار يبدأ بـ `http` (صورة من الإنترنت)، يتم إنشاء كائن `NetworkImage` واستدعاء دالة `.evict()` لحذفها من الكاش.
* **الأسطر 20-22:** إذا كان المسار ليس من ملفات الأصول المحلية (`assets/`)، فيتم التعامل معها كصورة محلية مرفوعة من الجهاز عن طريق إنشاء كائن `FileImage` محلي وتفريغه من الكاش بنفس الطريقة.

---

## 4. دالة `updateProfile` (تحديث الملف الشخصي محلياً)

```dart
  void updateProfile(UserModel updatedUser) {
    if (_currentUser.profileImageUrl != updatedUser.profileImageUrl) {
      _evictImage(_currentUser.profileImageUrl);
    }
    _currentUser = updatedUser;
    notifyListeners();
  }
```
* **الوظيفة:** تحديث بيانات المستخدم الحالي محلياً داخل التطبيق (مثلاً بعد قيام المستخدم بتحديث بياناته في شاشة تعديل الحساب بنجاح).
* **الأسطر 29-31:** مقارنة رابط الصورة الشخصية القديم بالجديد؛ فإذا اختلفا، يتم تفريغ الصورة القديمة من ذاكرة الكاش عبر دالة `_evictImage`.
* **السطر 32:** تعيين كائن المستخدم المحدث `updatedUser` ليكون هو المستخدم الحالي `_currentUser`.
* **السطر 33:** استدعاء `notifyListeners()` لإرسال إشعار لكافة الواجهات المستمعة لتقوم بإعادة بناء نفسها وعرض البيانات الجديدة فوراً.

---

## 5. دالة `fetchUserData` (جلب بيانات المستخدم من Supabase)

تعتبر هذه الدالة هي الأهم والأكبر في هذا الملف، وهي مقسمة لعدة أجزاء:

### أ. التحقق من جلسة تسجيل الدخول:
```dart
  Future<void> fetchUserData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
```
* **السطر 36:** تعريف الدالة كدالة غير متزامنة تفيد بعدم إرجاع قيمة مباشرة (`Future<void>`).
* **السطر 38:** جلب بيانات المستخدم المسجل حالياً في نظام المصادقة بـ Supabase Auth.
* **السطر 39:** إذا لم يكن هناك مستخدم مسجل (أي لا توجد جلسة نشطة)، يتم إيقاف التنفيذ فوراً.

### ب. محاولة جلب السجل من جدول `profiles`:
```dart
      Map<String, dynamic>? data;
      try {
        data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      }
```
* **الأسطر 41-47:** تعريف متغير `data` لتخزين البيانات المسترجعة، ثم محاولة الاستعلام من جدول `profiles` عن السجل الذي يطابق معرّف المستخدم الحالي (`id == user.id`). تعيد الدالة `.single()` السجل كخارطة مفاتيح وقيم (`Map<String, dynamic>`).

### ج. معالجة عدم وجود السجل وإنشائه تلقائياً (Auto-creation):
```dart
      } catch (e) {
        debugPrint('Profile row not found, auto-creating default profile row: $e');
        final email = user.email ?? '';
        final defaultUsername = email.isNotEmpty ? email.split('@').first : 'user_${user.id.substring(0, 5)}';
        final defaultName = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'مستخدم شمس';
        
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'name': defaultName,
          'username': defaultUsername,
          'email': email,
          'has_workshop': false,
        });

        data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      }
```
* **السطر 48:** في حال فشل الاستعلام (مثال: مستخدم جديد يسجل لأول مرة ولم ينشأ له سطر في جدول المخطط الشخصي)، يتم الانتقال لكتلة الـ `catch`.
* **السطر 50:** أخذ البريد الإلكتروني للمستخدم أو وضع نص فارغ كبديل.
* **السطر 51:** إنشاء اسم مستخدم تلقائي (Username)؛ فإذا كان لديه بريد إلكتروني، يتم أخذ الجزء ما قبل علامة `@` كاسم للمستخدم، وإلا يتم توليد اسم عشوائي يحتوي على معرّف فريد قصير.
* **السطر 52:** استخراج الاسم التلقائي للمستخدم من بيانات المصادقة الوصفية (Metadata) القادمة من جوجل أو تسجيل البريد، مع وضع "مستخدم شمس" كقيمة افتراضية.
* **الأسطر 54-60:** إدراج السجل الافتراضي الجديد في جدول `profiles` باستخدام الدالة `.upsert()`.
* **الأسطر 62-66:** إعادة الاستعلام مرة أخرى بعد إنشاء السجل لملء كائن الـ `data` بالبيانات المدخلة حديثاً.

### د. تحديث الحالة المحلية وتنبيه المستمعين:
```dart
      final newUser = UserModel.fromMap({
        ...data,
        'email': user.email ?? data['email'] ?? '',
      });

      if (_currentUser.profileImageUrl != newUser.profileImageUrl) {
        _evictImage(_currentUser.profileImageUrl);
      }

      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }
```
* **الأسطر 69-72:** تحويل الخارطة `data` إلى كائن `UserModel` عبر دالة المصنع التابعة له `fromMap`، مع التأكيد على جلب البريد الإلكتروني الفعلي من جلسة المصادقة للتأكد من دقته.
* **الأسطر 74-76:** التحقق مما إذا كانت الصورة الشخصية قد تم تعديلها في قاعدة البيانات لمسح الصورة القديمة من ذاكرة الكاش.
* **السطر 78:** تعيين الكائن الجديد الممتلئ بالبيانات الحية `newUser` لـ `_currentUser`.
* **السطر 79:** تنبيه الواجهات المستمعة لتقوم بعرض الصورة والاسم المحدّثين فوراً.
* **الأسطر 80-82:** الإمساك بأي خطأ عام قد يحدث أثناء هذه العملية بالكامل وطباعته في الكونسول لتسهيل التنقيح.

---

## 6. دالة `updateWorkshopStatus` (تحديث حالة الورشة)

```dart
  void updateWorkshopStatus(bool hasWorkshop) {
    if (_currentUser.id.isNotEmpty) {
      _currentUser = _currentUser.copyWith(hasWorkshop: hasWorkshop);
      notifyListeners();
    }
  }
```
* **الوظيفة:** تستدعى هذه الدالة لتحديث حالة امتلاك المستخدم لورشة عمل بعد إنشاء ورشة جديدة بنجاح في الواجهة لتحديث القوائم والخيارات المتاحة له داخل التطبيق فوراً دون الحاجة لإعادة جلب البيانات من الإنترنت.
* **السطر 86:** التأكد من أن معرّف المستخدم مسجل بالفعل وليس فارغاً.
* **السطر 87:** استخدام دالة `.copyWith()` المتاحة في النموذج لإنشاء نسخة جديدة من بيانات المستخدم مع استبدال خاصية `hasWorkshop` بالقيمة الجديدة الممررة.
* **السطر 88:** إشعار المستمعين للتحديث الفوري للواجهات (مثلاً: لإظهار زر "لوحة تحكم الورشة" بدلاً من زر "إنشاء ورشة جديدة").

---

## 7. دالة `clearUserData` (مسح البيانات عند تسجيل الخروج)

```dart
  void clearUserData() {
    _currentUser = const UserModel(
      id: '',
      name: 'مستخدم غير مسجل',
      email: '',
    );
    notifyListeners();
  }
```
* **الوظيفة:** تُستدعى عند تسجيل الخروج (Sign Out) لمسح بيانات المستخدم النشط من ذاكرة التطبيق الحية لحماية الخصوصية ومنع عرض بيانات الجلسة السابقة للمستخدم التالي.
* **الأسطر 93-97:** إعادة تهيئة `_currentUser` إلى كائن مستخدم افتراضي فارغ يحمل الاسم "مستخدم غير مسجل".
* **السطر 98:** إرسال إشعار بتعديل البيانات لإجبار الشاشات على العودة لوضع تسجيل الدخول وإخفاء أي تفاصيل شخصية.
