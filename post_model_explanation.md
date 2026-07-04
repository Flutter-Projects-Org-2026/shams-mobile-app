# شرح تفصيلي لملف `post_model.dart`

يمثل ملف `post_model.dart` نموذج البيانات (Data Model) الخاص بالمنشورات (Posts) في **منصة شمس**. وظيفته الأساسية هي تنظيم وتخزين بيانات المنشورات وتسهيل تحويلها من وإلى صيغ مختلفة (مثل Maps أو JSON) للتعامل مع قاعدة بيانات **Supabase** والواجهات في التطبيق.

---

## 1. الخصائص والحقول (Properties & Fields)

يحتوي الكلاس `PostModel` على الحقول التالية التي تصف المنشور بالكامل:

*   `id`: معرّف فريد خاص بالمنشور (String).
*   `workshopId`: معرّف الورشة التي نشرت هذا المنشور (String?).
*   `textDetails`: محتوى المنشور النصي (وصف المشكلة، الخدمة، إلخ).
*   `images`: قائمة بمسارات الصور المرفقة بالمنشور (سواءً روابط إنترنت أو ملفات محلية).
*   `isLocalFile`: مؤشر (Boolean) يحدد ما إذا كانت الصور محلية على الجهاز (تم التقاطها حديثاً) أم مرفوعة على السيرفر.
*   `viewsCount`: نص يمثل عدد المشاهدات منسقاً (مثل "45.8K" أو "250").
*   `createdAt`: نص يعبر عن زمن النشر النسبي (مثل "منذ يومين" أو "الآن").
*   `isHighlighted`: مؤشر يحدد ما إذا كان المنشور ثابتاً (Pinned/Highlighted) في أعلى صفحة الورشة.
*   `author`: كائن من نوع `UserModel` يمثل صاحب الورشة أو ناشر المنشور.
*   `likesCount`: عدد الإعجابات التي حصل عليها المنشور.
*   `isLiked`: يحدد ما إذا كان المستخدم الحالي قد تفاعل بالإعجاب مع هذا المنشور.
*   `comments`: قائمة بالتعليقات المكتوبة على هذا المنشور (كائنات من نوع `CommentModel`).

---

## 2. الدوال الموجودة في الملف (Methods & Constructors)

### أ. المشيد القياسي (Generative Constructor)
```dart
const PostModel({
  required this.id,
  this.workshopId,
  required this.textDetails,
  this.images = const [],
  this.isLocalFile = false,
  this.viewsCount = '0',
  required this.createdAt,
  this.isHighlighted = false,
  this.author,
  this.likesCount = 0,
  this.isLiked = false,
  this.comments = const [],
});
```
*   **الوظيفة:** لإنشاء كائن جديد من `PostModel` مباشرة بتمرير القيم المطلوبة والاختيارية.
*   **متى يُستخدم:** يُستخدم عند رغبتك في بناء منشور جديد يدوياً في التطبيق (مثال: عند كتابة منشور جديد في شاشة إنشاء المنشورات وقبل حفظه في السيرفر).

---

### ب. دالة الاستنساخ والتعديل `copyWith()`
```dart
PostModel copyWith({
  String? id,
  String? workshopId,
  String? textDetails,
  List<String>? images,
  bool? isLocalFile,
  String? viewsCount,
  String? createdAt,
  bool? isHighlighted,
  UserModel? author,
  int? likesCount,
  bool? isLiked,
  List<CommentModel>? comments,
}) {
  return PostModel(
    id: id ?? this.id,
    ...
  );
}
```
*   **الوظيفة:** تقوم بإنشاء نسخة جديدة مطابقة للكائن الحالي مع إمكانية تعديل حقول معينة فقط وتثبيت بقية الحقول كما هي.
*   **متى تُستخدم:** تُستخدم بكثرة في **إدارة الحالة (State Management)** لتحديث الواجهات.
    *   *مثال 1:* عندما يقوم المستخدم بالضغط على زر "إعجاب" (Like)، يتم تعديل الكائن محلياً كالتالي:
        `post = post.copyWith(isLiked: true, likesCount: post.likesCount + 1);`
    *   *مثال 2:* عند إضافة تعليق جديد للمنشور محلياً:
        `post = post.copyWith(comments: [...post.comments, newComment]);`

---

### ج. تحويل الكائن إلى خريطة بيانات `toMap()`
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'workshopId': workshopId,
    'textDetails': textDetails,
    'images': images,
    'isLocalFile': isLocalFile,
    'viewsCount': viewsCount,
    'createdAt': createdAt,
    'isHighlighted': isHighlighted,
    'author': author?.toMap(),
    'likesCount': likesCount,
    'isLiked': isLiked,
    'comments': comments.map((c) => c.toMap()).toList(),
  };
}
```
*   **الوظيفة:** تحويل كائن الـ `PostModel` إلى صيغة `Map<String, dynamic>` (خريطة مفتاح وقيمة) التي يمكن تحويلها بسهولة إلى صيغة JSON.
*   **متى تُستخدم:** 
    *   عند حفظ بيانات المنشور محلياً في ذاكرة الجهاز (مثل `shared_preferences` أو `SQLite`).
    *   عند إرسال بيانات المنشور كـ Request Body إلى سيرفرات خارجية أو واجهات برمجة التطبيقات (APIs).

---

### د. بناء الكائن من خريطة بيانات `fromMap()`
```dart
factory PostModel.fromMap(Map<String, dynamic> map) {
  return PostModel(
    id: map['id'] ?? '',
    workshopId: map['workshopId'],
    textDetails: map['textDetails'] ?? '',
    images: List<String>.from(map['images'] ?? []),
    isLocalFile: map['isLocalFile'] ?? false,
    ...
  );
}
```
*   **الوظيفة:** مشيّد مصنع (Factory Constructor) يقوم بتحويل خريطة بيانات `Map` (عادةً قادمة من كاش محلي أو ملف JSON تم فك تشفيره) إلى كائن منظم من نوع `PostModel`.
*   **متى تُستخدم:** عند قراءة أو جلب المنشورات المخزنة محلياً على جهاز المستخدم لإعادة عرضها له (Offline caching).

---

### هـ. الدالة المساعدة لزمن النشر `_timeAgo()`
```dart
static String _timeAgo(String isoString) {
  try {
    final parsed = DateTime.parse(isoString);
    final diff = DateTime.now().difference(parsed);
    if (diff.inDays > 7) {
      return '${parsed.year}-${parsed.month}-${parsed.day}';
    } else if (diff.inDays >= 1) {
      return 'منذ ${diff.inDays} يوم';
    } ...
  } catch (_) {
    return isoString;
  }
}
```
*   **الوظيفة:** دالة خاصة (private) ومستقلة (static) تأخذ تاريخاً بصيغة ISO القياسية القادمة من السيرفر (مثل `2026-06-03T12:00:00Z`) وتقارنه بالوقت الحالي، ثم تُرجع نصاً عربياً يعبر عن الفارق الزمني (مثل "منذ يوم" أو "منذ ساعة" أو تاريخ اليوم الفعلي إذا كان قديماً جداً).
*   **متى تُستخدم:** يتم استدعاؤها داخلياً فقط في مشيد `fromSupabase()` لمعالجة وعرض حقل تاريخ النشر `createdAt` بشكل مناسب للمستخدم.

---

### و. بناء الكائن من Supabase مباشرة `fromSupabase()`
```dart
factory PostModel.fromSupabase(
  Map<String, dynamic> map, {
  bool isLiked = false,
  List<CommentModel> comments = const [],
}) {
  final authorMap = map['profiles'];
  final author = authorMap != null ? UserModel.fromMap(authorMap) : null;
  final viewsVal = map['views_count'] ?? 0;
  
  return PostModel(
    id: map['id'] ?? '',
    workshopId: map['workshop_id'],
    textDetails: map['text_details'] ?? '',
    images: List<String>.from(map['images'] ?? []),
    isLocalFile: false,
    viewsCount: viewsVal > 1000 ? '${(viewsVal / 1000).toStringAsFixed(1)}K' : '$viewsVal',
    createdAt: _timeAgo(map['created_at'] ?? ''),
    isHighlighted: map['is_highlighted'] ?? false,
    author: author,
    likesCount: map['likes_count'] ?? 0,
    isLiked: isLiked,
    comments: comments,
  );
}
```
*   **الوظيفة:** مشيّد مصنع مخصص للبيانات القادمة من **Supabase** مباشرة. يقوم بالآتي:
    1.  يستخرج بيانات الكاتب/الورشة من الجدول المرتبط `profiles`.
    2.  يقوم بتهيئة وعرض عدد المشاهدات بشكل مبسط (فإذا كان العدد 1500 يحوله لـ `1.5K` لتوفير المساحة في التصميم).
    3.  يحول تاريخ الإنشاء من تاريخ شبكي معقد إلى نص نسبي باستخدام دالة `_timeAgo()`.
*   **متى تُستخدم:** تُستدعى دائماً عند جلب المنشورات من قاعدة بيانات Supabase أونلاين عبر الخدمات، كاستدعائها بداخل `fetchMyWorkshopPosts` في الـ `WorkshopProvider`.
