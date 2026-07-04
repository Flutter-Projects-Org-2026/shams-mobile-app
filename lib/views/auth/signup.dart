import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outlined_button.dart';
import 'signin.dart';
import 'signup_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/auth_gate.dart';
import '../../services/local_storage_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String? _emailError, _passError, _confirmPassError;
  bool _isLoading = false;
  late final StreamSubscription<AuthState> _authSubscription;

  void _listenToAuth() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async{
      final AuthChangeEvent event = data.event;
      // Only react if we are signed in and it's not just the initial session check
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
  void initState() {
    super.initState();
    _listenToAuth();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    setState(() {
      _emailError = !email.contains('@') ? 'البريد الإلكتروني غير صالح' : null;
      _passError = password.length < 6 ? 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)' : null;
      _confirmPassError = password != confirmPassword ? 'كلمتا المرور غير متطابقتين' : null;
    });

    if (_emailError == null && _passError == null && _confirmPassError == null) {
      // Cancel the listener so it doesn't prematurely navigate when signUp is called!
      _authSubscription.cancel();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpProfileScreen(
            email: email,
            password: password,
          ),
        ),
      ).then((_) {
        // Re-subscribe if the user goes back to this screen
        if (mounted) _listenToAuth();
      });
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'shams://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء التسجيل: $e', style: GoogleFonts.tajawal()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text('انضم إلى مجتمع شمس', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('خطوتك الأولى لتجربة فريدة ومتميزة معنا', style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint)),
              const SizedBox(height: 32),
              // ── بطاقة الإدخال ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                  ),
                ],
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('البريد الإلكتروني'),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 16),
                    _inputLabel('كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    const SizedBox(height: 16),
                    _inputLabel('تأكيد كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _confirmPassController, errorText: _confirmPassError),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomSolidButton(title: 'التالي', onPressed: _handleNext),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .extension<ShamsExtendedColors>()!
                                .borderLight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'أو إنشاء حساب عبر',
                            style: GoogleFonts.tajawal(
                              color: Theme.of(context)
                                  .extension<ShamsExtendedColors>()!
                                  .textHint,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .extension<ShamsExtendedColors>()!
                                .borderLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : CustomOutlinedButton(
                              title: 'Google',
                              icon: const Icon(Icons.g_mobiledata_rounded),
                              onPressed: _handleGoogleSignUp,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟',
                    style: GoogleFonts.tajawal(
                      color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    ),
                    child: Text(
                      'تسجيل الدخول',
                      style: GoogleFonts.tajawal(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}