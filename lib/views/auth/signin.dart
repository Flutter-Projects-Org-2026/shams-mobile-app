import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outlined_button.dart';
import 'signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/auth_gate.dart';
import '../../services/local_storage_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _emailError, _passError;
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for auth state changes (e.g. returning from Google Sign-In)
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null && user.email != null) {
          await LocalStorageService.saveLoginData(user.email!);
        }
        if (mounted) {
          context.read<UserProvider>().fetchUserData();
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const AuthGate()),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'يرجى التحقق من البريد الإلكتروني' : null;
      _passError = password.isEmpty ? 'كلمة المرور غير صحيحة' : null;
    });

    if (_emailError == null && _passError == null) {
      setState(() => _isLoading = true);
      try {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
         await LocalStorageService.saveLoginData(email);
        if (mounted) {
          await context.read<UserProvider>().fetchUserData();
          
          if (mounted) {
           
            // Remove Welcome & SignIn screens from stack and go back to root
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
            );
          }
        }
      } on AuthException catch (e) {
        if (mounted) {
          String errorMessage = e.message;
          if (e.message.contains('Invalid login credentials')) {
            errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
          } else if (e.message.contains('Email not confirmed')) {
            errorMessage = 'يرجى تأكيد بريدك الإلكتروني أولاً';
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
              content: Text('حدث خطأ أثناء تسجيل الدخول: $e', style: GoogleFonts.tajawal()), 
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

  Future<void> _handleGoogleLogin() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'shams://login-callback/',
      );
      // fetchUserData will be called by AuthGate or after redirect
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تسجيل الدخول عبر جوجل'), backgroundColor: ShamsColors.dangerRed),
        );
      }
    }
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
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)]),
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: ShamsColors.primaryBlue))
                          : CustomSolidButton(title: 'تسجيل الدخول', onPressed: _handleLogin),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomOutlinedButton(title: 'Google تسجيل الدخول بواسطة', icon: const Icon(Icons.g_mobiledata, size: 30), onPressed: _handleGoogleLogin),
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