import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _selectedLocation;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // قائمة الـ 21 محافظة يمنية المطلوبة
  final List<String> _cities = [
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'حضرموت',
    'ذمار',
    'عمران',
    'الضالع',
    'لحج',
    'أبين',
    'المهرة',
    'شبوة',
    'البيضاء',
    'مأرب',
    'الجوف',
    'صعدة',
    'المحويت',
    'حجة',
    'ريمة',
    'سقطرى',
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة البيانات المسبقة من الـ Provider
    final currentUser = context.read<UserProvider>().currentUser;
    _nameController.text = currentUser.name;
    _usernameController.text =
        currentUser.username ?? currentUser.email.split('@').first;
    _selectedLocation = currentUser.location ?? 'صنعاء';
    _phoneController.text = currentUser.phone ?? '';
    _bioController.text = currentUser.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  ImageProvider _getProfileImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/images/logo/shams logo.png');
    }
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    return const AssetImage('assets/images/logo/shams logo.png');
  }

  // دالة اختيار الصورة
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // دالة الحفظ وإرسال البيانات للـ Provider و Supabase
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    final provider = context.read<UserProvider>();
    final currentUser = provider.currentUser;

    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();
    final location = _selectedLocation;

    String? imageUrl = currentUser.profileImageUrl;
    String? uploadError;

    // 1. رفع الصورة إلى Supabase إن وجدت صورة مختارة وجلسة نشطة
    if (_selectedImage != null) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final fileExt = _selectedImage!.path.split('.').last;
          final fileName =
              '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

          final imageBytes = await _selectedImage!.readAsBytes();

          await Supabase.instance.client.storage
              .from('avatars')
              .uploadBinary(
                fileName,
                imageBytes,
                fileOptions: const FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                ),
              );
          imageUrl = Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(fileName);
        } else {
          // في حال عدم وجود جلسة، نستخدم المسار المحلي مؤقتاً للتطوير
          imageUrl = _selectedImage!.path;
        }
      } catch (e) {
        debugPrint('Image upload failed: $e');
        uploadError = e.toString();
      }
    }

    if (uploadError != null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'فشل رفع الصورة: $uploadError',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: const Color(0xFFD32F2F), // لون أحمر للفشل
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // 2. تحديث البيانات في قاعدة البيانات إن وجدت جلسة نشطة
    bool isSuccess = true;
    String? dbError;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final Map<String, dynamic> updates = {
          'name': name,
          'username': username,
          'phone': phone,
          'bio': bio,
          'location': location,
        };
        if (imageUrl != null) {
          updates['profile_image_url'] = imageUrl;
        }
        await Supabase.instance.client
            .from('profiles')
            .update(updates)
            .eq('id', user.id);
      }
    } catch (e) {
      debugPrint('Error updating profiles in database: $e');
      dbError = e.toString();
      isSuccess = false;
    }

    final updatedUser = currentUser.copyWith(
      name: name,
      username: username,
      phone: phone,
      bio: bio,
      location: location,
      profileImageUrl: imageUrl,
    );

    if (isSuccess) {
      // 3. تحديث الموديل محلياً في الـ Provider
      provider.updateProfile(updatedUser);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث الملف الشخصي بنجاح',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: const Color(0xFF2CC069), // لون أخضر للنجاح
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء حفظ التعديلات في السيرفر: ${dbError ?? ''}',
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: const Color(0xFFD32F2F), // لون أحمر للفشل
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().currentUser;

    return Directionality(
      textDirection: TextDirection.rtl, // لضمان الاتجاه من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white, // الخلفية البيضاء السادة كما في التصميم
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.black87,
            ), // سهم خلف أسود
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'تعديل الملف الشخصي',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // ── قسم الصورة الدائرية (Avatar) المطابق للتصميم ──
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الحدود المتدرجة (البرتقالي والأصفر)
                    Container(
                      padding: const EdgeInsets.all(4), // سمك الحدود
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFA726),
                            Color(0xFFFFD600),
                          ], // البرتقالي والاصفر الشمسي
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 55, // الحجم مطابق للتصميم
                        backgroundColor: Colors.white,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!) as ImageProvider
                            : _getProfileImageProvider(
                                currentUser.profileImageUrl,
                              ),
                      ),
                    ),
                    // أيقونة الكاميرا الصفراء في موضعها الصحيح (أسفل اليسار للمشاهد)
                    Positioned(
                      bottom: 0,
                      left: 0, // جهة اليسار برمجياً في الـ Stack الـ RTL
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFFFD600,
                            ), // اللون الأصفر الشمسي
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ), // حد أبيض سميك
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── حقول الإدخال (Form Fields) - بتصميم الـ Border الجديد ──

              // حقل الاسم الكامل
              _buildInputLabel('الاسم الكامل'),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _nameController,
                hintText: 'الاسم الكامل',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 24),

              // حقل اسم المستخدم
              _buildInputLabel('اسم المستخدم'),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _usernameController,
                hintText: 'اسم المستخدم',
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 24),

              // // حقل الموقع (Dropdown)
              // _buildInputLabel('الموقع'),
              // const SizedBox(height: 8),
              // _buildDropdownField(),
              // const SizedBox(height: 24),

              // حقل رقم الهاتف
              _buildInputLabel('رقم الهاتف'),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _phoneController,
                hintText: 'أدخل رقم الهاتف',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 24),

              // حقل نبذة شخصية
              _buildInputLabel('نبذة شخصية'),
              const SizedBox(height: 8),
              _buildCustomTextField(
                controller: _bioController,
                hintText: 'مهتم بالطاقة المتجددة...',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 48),

              // ── زر الحفظ (Save Button) ──
              SizedBox(
                width: double.infinity,
                height: 52, // الارتفاع مطابق للتصميم
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600), // الأصفر الشمسي
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // حواف دائرية خفيفة
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'حفظ التغييرات',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء عنوان الحقل
  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w700, // Bold
          color: Colors.black87,
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء الحقل النصي بتصميم الحدود الجديد (بلا خلفية)
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.tajawal(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.tajawal(
          color: const Color(0xFFBFC3CE),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF9EA3B0), size: 22),
        filled: false, // لا توجد خلفية ممتلئة
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        // الحدود الرمادية الفاتحة والنحيفة كما في التصميم
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFFD600),
            width: 1.5,
          ), // تحديد بلون التطبيق عند الوقوف عليه
        ),
      ),
    );
  }

  // ويدجت مساعدة لبناء قائمة الموقع المنسدلة بنفس تصميم الحدود
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedLocation,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF9EA3B0),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          color: Color(0xFF9EA3B0),
          size: 22,
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD600), width: 1.5),
        ),
      ),
      items: _cities.map((city) {
        return DropdownMenuItem(
          value: city,
          child: Text(city, style: GoogleFonts.tajawal(fontSize: 15)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLocation = value;
        });
      },
    );
  }
}
