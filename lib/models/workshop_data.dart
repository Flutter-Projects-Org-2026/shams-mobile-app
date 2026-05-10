import 'dart:io';

/// WorkshopData — نموذج بيانات الورشة
///
/// Carries the values entered in [AddWorkshopScreen] to
/// [WorkshopDashboardScreen] via Navigator result.
class WorkshopData {
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

  const WorkshopData({
    required this.name,
    required this.username,
    required this.city,
    required this.description,
    required this.yearsOfExperience,
    this.profileImage,
    this.coverImage,
    this.extraImages = const [],
  });
}
