import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/text_field.dart';
import '../../widgets/primary_button.dart';
import 'signin.dart';
import '../chat/chat_list_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  String? _nameError, _emailError, _passError;

void _handleSignUp() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'يرجى إدخال اسمك الكامل' : null;
      _emailError = !_emailController.text.contains('@') ? 'البريد الإلكتروني غير صالح' : null;
      _passError = _passController.text.length < 6 ? 'كلمة المرور قصيرة جداً' : null;

      if (_nameError == null && _emailError == null && _passError == null) {
        // الانتقال إلى قائمة المحادثات بعد نجاح التسجيل
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatListScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: ShamsColors.textGray)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('انضم إلى مجتمع شمس', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: ShamsColors.textGray)),
              const SizedBox(height: 8),
              Text('ابدأ رحلتك اليوم واستمتع بتجربة فريدة ومتميزة معنا', style: GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF9EA3B0))),
              const SizedBox(height: 32),
              // ── بطاقة الإدخال ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('الاسم الكامل'),
                    CustomTextField(hintText: 'أدخل اسمك الكامل', prefixIcon: Icons.person_outline, controller: _nameController, errorText: _nameError),
                    const SizedBox(height: 20),
                    _inputLabel('البريد الإلكتروني'),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 20),
                    _inputLabel('كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    const SizedBox(height: 32),
                    SizedBox(width: double.infinity, height: 50, child: CustomSolidButton(title: 'متابعة', onPressed: _handleSignUp)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('لديك حساب بالفعل؟', style: GoogleFonts.tajawal(color: const Color(0xFF9EA3B0))),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen())), child: Text('تسجيل الدخول', style: GoogleFonts.tajawal(color: ShamsColors.solarYellow, fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: GoogleFonts.tajawal(fontSize: 13, fontWeight: FontWeight.w600, color: ShamsColors.textGray)));
}