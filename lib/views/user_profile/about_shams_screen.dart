import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class AboutShamsScreen extends StatelessWidget {
  const AboutShamsScreen({super.key});

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
          centerTitle: false,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── شعار التطبيق ──────────────────────────────────────────────
              _buildLogo(),
              const SizedBox(height: 10),

              // ── اسم التطبيق ───────────────────────────────────────────────
              Text(
                'شمس',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 28),

              // ── من نحن؟ ──────────────────────────────────────────────────
              _buildSectionHeader('من نحن؟'),
              const SizedBox(height: 10),
              _buildBodyText(
                'نحن في "شمس" نؤمن بأن الطاقة المستقبلية يجب أن '
                'تكون نظيفة، مستدامة، وصالحة للجميع. نسعى جاهدين '
                'لتحويل كل منزل ومؤسسة إلى واحة من الطاقة المتجددة '
                'باستخدام أحدث الحلول التقنية.',
              ),
              const SizedBox(height: 28),

              // ── رؤيتنا ───────────────────────────────────────────────────
              _buildVisionCard(),
              const SizedBox(height: 28),

              // ── لماذا تختارنا؟ ────────────────────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: _buildSectionHeader('لماذا تختارنا؟'),
              ),
              const SizedBox(height: 16),
              _buildFeaturesGrid(),
              const SizedBox(height: 36),

              // ── وسائل التواصل ─────────────────────────────────────────────
              _buildSocialRow(),
              const SizedBox(height: 16),

              // ── رقم الإصدار ───────────────────────────────────────────────
              Text(
                'الإصدار v1.0.0 Alpha',
                style: GoogleFonts.tajawal(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 8),
              // ── حقوق النشر ────────────────────────────────────────────────
              Text(
                'جميع الحقوق محفوظة © 2026 شركة شمس',
                style: GoogleFonts.tajawal(
                  fontSize: 11,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // شعار التطبيق
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E7),
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(15),
      child: Image.asset(
        'assets/images/logo/shams logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // عنوان قسم
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: ShamsColors.solarYellow,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // نص توضيحي
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildBodyText(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.8,
        color: Colors.grey.shade600,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // كارد الرؤية
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildVisionCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFF9E7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: ShamsColors.solarYellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_red_eye_outlined,
                color: ShamsColors.solarYellow,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'رؤيتنا',
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أن نكون الرواد في تمكين المجتمعات العربية من خلال '
              'الابتكار في تقنيات الطاقة الشمسية، لنبني مستقبل '
              'أنضر ومشرق للأجيال القادمة.',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                height: 1.7,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // شبكة المميزات — 3 أعمدة
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFeaturesGrid() {
    // قائمة المميزات
    final List<Map<String, dynamic>> features = [
      {'icon': Icons.bolt_rounded, 'label': 'سهولة الوصول'},
      {'icon': Icons.eco_rounded, 'label': 'الاستدامة'},
      {'icon': Icons.store_outlined, 'label': 'ورشة مباشرة'},
      {'icon': Icons.verified_user_outlined, 'label': 'موثوقية عالية'},
      {'icon': Icons.support_agent_rounded, 'label': 'دعم مستمر'},
      {'icon': Icons.speed_rounded, 'label': 'أداء سريع'},
    ];

    return GridView.builder(
      // منع GridView من التمرير داخل SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureItem(
          icon: features[index]['icon'] as IconData,
          label: features[index]['label'] as String,
        );
      },
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: ShamsColors.solarYellow.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ShamsColors.solarYellow, size: 26),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // أيقونات وسائل التواصل الاجتماعي
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(Icons.camera_alt_outlined), // Instagram
        const SizedBox(width: 20),
        _buildSocialIcon(Icons.alternate_email), // X (Twitter)
        const SizedBox(width: 20),
        _buildSocialIcon(Icons.facebook_outlined), // Facebook
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: Colors.grey.shade600),
    );
  }
}
