import 'dart:io';

/// WorkshopData — نموذج بيانات الورشة
///
/// Carries the values entered in [AddWorkshopScreen] to
/// [WorkshopDashboardScreen] via Navigator result.
class WorkshopData {
  /// المعرف الفريد للورشة
  final String id;

  /// معرف مالك الورشة
  final String ownerId;

  /// اسم الورشة
  final String name;

  /// اسم المستخدم (بدون @)
  final String username;

  /// المحافظة / المدينة
  final String city;

  /// وصف مختصر للخدمات
  final String description;

  /// سنوات الخبرة
  final int yearsOfExperience;

  /// صورة البروفايل المختارة من المعرض (اختيارية)
  final File? profileImage;

  /// صورة الغلاف المختارة من المعرض (اختيارية)
  final File? coverImage;

  /// صور إضافية من المعرض (غير محدودة)
  final List<File> extraImages;

  /// رابط صورة اللوجو على السيرفر
  final String? logoUrl;

  /// رابط صورة الغلاف على السيرفر
  final String? coverUrl;

  /// روابط الصور الإضافية على السيرفر
  final List<String> galleryUrls;

  const WorkshopData({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.username,
    required this.city,
    required this.description,
    required this.yearsOfExperience,
    this.profileImage,
    this.coverImage,
    this.extraImages = const [],
    this.logoUrl,
    this.coverUrl,
    this.galleryUrls = const [],
  });
}
