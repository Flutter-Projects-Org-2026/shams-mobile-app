import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/text_field.dart';
import '../../widgets/primary_button.dart';
import '../../providers/user_provider.dart';
import '../../widgets/auth_gate.dart';

class SignUpProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const SignUpProfileScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<SignUpProfileScreen> createState() => _SignUpProfileScreenState();
}

class _SignUpProfileScreenState extends State<SignUpProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  File? _profileImage;
  String? _nameError;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _handleCreateAccount() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();

    setState(() {
      _nameError = name.isEmpty ? 'يرجى إدخال اسمك الكامل' : null;
    });

    if (_nameError == null) {
      setState(() => _isLoading = true);
      try {
        // 1. Create the user in Supabase
        final res = await Supabase.instance.client.auth.signUp(
          email: widget.email,
          password: widget.password,
          data: {'full_name': name},
        );

        if (res.user != null) {
          String? imageUrl;

          // 2. Upload image if selected
          if (_profileImage != null) {
            try {
              final fileExt = _profileImage!.path.split('.').last;
              final fileName = '${res.user!.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';
              
              // Read as bytes to avoid some SocketExceptions with File uploads
              final imageBytes = await _profileImage!.readAsBytes();
              
              await Supabase.instance.client.storage.from('avatars').uploadBinary(
                fileName,
                imageBytes,
                fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
              );
              imageUrl = Supabase.instance.client.storage.from('avatars').getPublicUrl(fileName);
            } catch (e) {
              debugPrint('Image upload failed: $e');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ أثناء رفع الصورة: $e', style: GoogleFonts.tajawal()), 
                    backgroundColor: ShamsColors.dangerRed,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            }
          }

          // 3. Update profile row
          try {
            await Supabase.instance.client.from('profiles').update({
              if (phone.isNotEmpty) 'phone': phone,
              if (bio.isNotEmpty) 'bio': bio,
              if (imageUrl != null) 'profile_image_url': imageUrl,
            }).eq('id', res.user!.id);
          } catch (e) {
            debugPrint('Profile update failed: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('حدث خطأ أثناء تحديث بيانات الملف: $e', style: GoogleFonts.tajawal()), 
                  backgroundColor: ShamsColors.dangerRed,
                ),
              );
            }
          }
        }

        if (mounted) {
          await context.read<UserProvider>().fetchUserData();
          
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          String errorMessage = e.message;
          if (e.message.contains('User already registered')) {
            errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً، حاول تسجيل الدخول من الشاشة السابقة';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: GoogleFonts.tajawal()), 
              backgroundColor: ShamsColors.dangerRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء إكمال الحساب: $e', style: GoogleFonts.tajawal()), 
              backgroundColor: ShamsColors.dangerRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: Colors.transparent, 
          elevation: 0, 
          iconTheme: const IconThemeData(color: ShamsColors.textGray),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('أكمل ملفك الشخصي', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: ShamsColors.textGray)),
              const SizedBox(height: 8),
              Text('دع مجتمع شمس يتعرف عليك أكثر', style: GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF9EA3B0))),
              const SizedBox(height: 32),
              
              // ── بطاقة الإدخال ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF0F2F5),
                              backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                              child: _profileImage == null 
                                  ? const Icon(Icons.person_outline, size: 50, color: Colors.grey)
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: ShamsColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    _inputLabel('الاسم الكامل *'),
                    CustomTextField(hintText: 'أدخل اسمك الكامل', prefixIcon: Icons.person_outline, controller: _nameController, errorText: _nameError),
                    const SizedBox(height: 16),
                    _inputLabel('رقم الهاتف (اختياري)'),
                    CustomTextField(hintText: '05xxxxxxxx', prefixIcon: Icons.phone_outlined, controller: _phoneController),
                    const SizedBox(height: 16),
                    _inputLabel('نبذة شخصية (اختياري)'),
                    CustomTextField(hintText: 'مهتم بالطاقة المتجددة...', prefixIcon: Icons.info_outline, controller: _bioController),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: ShamsColors.primaryBlue))
                          : CustomSolidButton(title: 'إنشاء الحساب', onPressed: _handleCreateAccount),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: ShamsColors.textGray)));
}
