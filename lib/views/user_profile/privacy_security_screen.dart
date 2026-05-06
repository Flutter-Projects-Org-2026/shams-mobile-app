import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        // ── AppBar ──────────────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
          ),
          title: Text(
            'الخصوصية والأمان',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF2D2D2D),
                  size: 26,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),

        // ── Body ────────────────────────────────────────────────────────────
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // ── مقدمة ───────────────────────────────────────────────────────
            _buildIntroText(),
            const SizedBox(height: 28),

            // ── تشفير البيانات ──────────────────────────────────────────────
            _buildSection(
              icon: Icons.lock_outline_rounded,
              title: 'تشفير البيانات',
              body:
                  'نحن نحمي بياناتك واستخدامها الشخصي بأعلى معايير الأمان. '
                  'يتم تشفير جميع البيانات المرسلة بين الخادم والتطبيق باستخدام بروتوكول SSL/TLS.',
            ),
            const SizedBox(height: 24),

            // ── أمان الحساب ─────────────────────────────────────────────────
            _buildSection(
              icon: Icons.security_rounded,
              title: 'أمان الحساب',
              body:
                  'يمكنك تأمين حسابك عبر تفعيل التحقق بخطوتين، '
                  'وإدارة الأجهزة المرتبطة بحسابك. نوصي بتغيير كلمة المرور بشكل دوري.',
            ),
            const SizedBox(height: 24),

            // ── مشاركة المعلومات ────────────────────────────────────────────
            _buildSection(
              icon: Icons.share_outlined,
              title: 'مشاركة المعلومات',
              body:
                  'تحكم في البيانات التي تشاركها مع الآخرين داخل المنصة. '
                  'يمكنك في أي وقت مراجعة وإلغاء الأذونات الممنوحة للتطبيقات الأخرى.',
            ),
            const SizedBox(height: 24),

            // ── الوصول للموقع ───────────────────────────────────────────────
            _buildSection(
              icon: Icons.location_on_outlined,
              title: 'الوصول للموقع',
              body:
                  'تستخدم المنصة الموقع الجغرافي فقط لتزويدك بخدمات ذات صلة بمنطقتك. '
                  'يمكنك إلغاء هذا الإذن في أي وقت من إعدادات الجهاز.',
            ),
            const SizedBox(height: 40),

            // ── سياسة الخصوصية الكاملة ──────────────────────────────────────
            _buildFullPolicyButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // المقدمة النصية
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildIntroText() {
    return Text(
      'نحن نلتزم بحماية خصوصيتك وأمان بياناتك الشخصية. تتبع '
      'هذه الإعدادات التي تمنحك التحكم الكامل في كيفية معالجة '
      'ومشاركتك لمعلوماتك الشخصية لضمان تجربة آمنة ومتوازنة.',
      style: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.7,
        color: Colors.grey.shade600,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // قسم واحد: أيقونة + عنوان + نص
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان مع الأيقونة
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: ShamsColors.solarYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: ShamsColors.solarYellow),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // النص التوضيحي
        Text(
          body,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            height: 1.7,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        // خط فاصل خفيف
        Divider(color: Colors.grey.withOpacity(0.15), thickness: 1),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // زر سياسة الخصوصية الكاملة
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFullPolicyButton() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: افتح صفحة سياسة الخصوصية الكاملة
        },
        child: Text(
          'سياسة الخصوصية الكاملة',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: ShamsColors.solarYellow,
            decoration: TextDecoration.underline,
            decorationColor: ShamsColors.solarYellow,
          ),
        ),
      ),
    );
  }
}
