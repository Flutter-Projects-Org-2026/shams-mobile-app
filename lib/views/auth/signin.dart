import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outlined_button.dart';
import 'signup.dart';
import '../chat/chat_list_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _emailError, _passError;

  void _handleLogin() {
    setState(() {
      _emailError = _emailController.text.isEmpty ? 'يرجى التحقق من البريد الإلكتروني' : null;
      _passError = _passController.text.isEmpty ? 'كلمة المرور غير صحيحة' : null;

      if (_emailError == null && _passError == null) {
        // الانتقال إلى قائمة المحادثات وعدم السماح بالرجوع لشاشة الدخول
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
              Text('مرحباً بعودتك!', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: ShamsColors.textGray)),
              const SizedBox(height: 8),
              Text('سجل الدخول للمتابعة في رحلتك مع شمس', style: GoogleFonts.tajawal(fontSize: 14, color: const Color(0xFF9EA3B0))),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('البريد الإلكتروني أو الهاتف'),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 20),
                    _inputLabel('كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () {}, child: Text('نسيت كلمة المرور؟', style: GoogleFonts.tajawal(color: ShamsColors.primaryBlue, fontSize: 12)))),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, height: 50, child: CustomSolidButton(title: 'تسجيل الدخول', onPressed: _handleLogin)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomOutlinedButton(title: 'Google تسجيل الدخول بواسطة', icon: const Icon(Icons.g_mobiledata, size: 30), onPressed: () {}),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ليس لديك حساب؟', style: GoogleFonts.tajawal(color: const Color(0xFF9EA3B0))),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())), child: Text('انضم إلينا الآن', style: GoogleFonts.tajawal(color: ShamsColors.solarYellow, fontWeight: FontWeight.bold))),
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