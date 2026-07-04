import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/outlined_button.dart';
import 'signin.dart';
import 'signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // ── الشعار والاسم ──
                Image.asset('assets/images/logo/shams logo.png', height: 100),
                const SizedBox(height: 16),
                Text(
                  'شمس',
                  style: GoogleFonts.tajawal(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  'طاقة موثوقة.. لمجتمع متصل',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                  ),
                ),
                const Spacer(),
                // ── بطاقات المميزات (Feature Highlights) ──
                Row(
                  children: [
                    _buildFeatureCard(context, Icons.bolt_rounded, 'كفاءة عالية'),
                    const SizedBox(width: 16),
                    _buildFeatureCard(context, Icons.settings_suggest_rounded, 'تحكم ذكي'),
                  ],
                ),
                const Spacer(),
                // ── الأزرار الأساسية ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomSolidButton(
                    title: 'إنشاء حساب',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomOutlinedButton(
                    title: 'تسجيل الدخول',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen())),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'شروط الخدمة من خلال الاستمرار، أنت توافق على شروط الخدمة',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 11, color: const Color(0xFFBFC3CE)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}