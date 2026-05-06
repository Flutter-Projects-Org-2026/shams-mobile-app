import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/appbar.dart';
import '../../widgets/shams_bottom_nav_bar.dart';
import 'add_workshop_screen.dart';
import 'privacy_security_screen.dart';
import 'about_shams_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserProfileScreen — شاشة الملف الشخصي للمستخدم
// ─────────────────────────────────────────────────────────────────────────────

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isNotificationsEnabled = true;
  String _selectedLanguage = 'ar';

  @override
  Widget build(BuildContext context) {
    // جعل شريط الحالة شفافاً ليتناسب مع لون الهيدر
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: ShamsBottomNavBar(
          currentIndex: 3, // تبويب الملف الشخصي
          onTap: (index) {
            // التنقل بين الصفحات سيتم إعداده لاحقاً
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              _buildBusinessSection(),
              const SizedBox(height: 30),
              _buildSettingsSection(),
              const SizedBox(height: 30),
              _buildShareButton(),
              const SizedBox(height: 20),
              _buildLogoutButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header — تصميم مطابق تماماً للصورة ─────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF9E7), // لون كريمي فاتح
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40), // زيادة درجة الانحناء لتطابق الصورة
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(25, 55, 25, 45), // ضبط التبطين العلوي
      child: Column(
        children: [
          // السطر العلوي: زر التعديل والصورة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصورة الشخصية مع الحالة (يمين في RTL)
              Stack(
                children: [
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(
                        'assets/images/logo/shams logo.png',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4, // تحويل النقطة لجهة اليسار لتطابق الصورة
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                ],
              ),
              // زر تعديل الملف (يسار)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ShamsColors.solarYellow.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: ShamsColors.solarYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'تعديل الملف',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ShamsColors.solarYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // معلومات المستخدم (محاذاة لليمين)
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'أحمد منصور',
                      style: GoogleFonts.tajawal(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // const Icon(Icons.verified, color: Colors.blue, size: 18),
                  ],
                ),
                Text(
                  '@ahmed_mansour',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: ShamsColors.solarYellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'الرياض، المملكة العربية السعودية',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: ShamsColors.solarYellow,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── إدارة أعمالي ───────────────────────────────────────────────────

  Widget _buildBusinessSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('إدارة أعمالي', Icons.storefront_rounded),
        const SizedBox(height: 15),
        // كارد إضافة ورشة
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddWorkshopScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFF2F4F7)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. أيقونة الزائد (يمين في RTL)
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: ShamsColors.solarYellow,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                // 2. النصوص (في المنتصف محاذاة لليمين)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة ورشة جديدة',
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ShamsColors.textGray,
                        ),
                      ),
                      Text(
                        'انقر هنا لإضافة تفاصيل الورشة',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 3. سهم التنقل (يسار في RTL)
                const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── الإعدادات والتفضيلات ──────────────────────────────────────────

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('الإعدادات والتفضيلات', Icons.settings_rounded),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // إزالة الحواف الخارجية كما طلب المستخدم
          ),
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                showDivider: true,
                trailing: SizedBox(
                  height: 30,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: _isNotificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _isNotificationsEnabled = v),
                      activeColor: Colors.white, // الي بالصورة لون الزر أبيض
                      activeTrackColor: ShamsColors.solarYellow, // والمسار أصفر
                    ),
                  ),
                ),
              ),
              _buildSettingTile(
                icon: Icons.shield_outlined,
                title: 'الخصوصية والأمان',
                showDivider: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacySecurityScreen(),
                    ),
                  );
                },
              ),
              _buildSettingTile(
                icon: Icons.language_rounded,
                title: 'تغيير اللغة',
                trailing: _buildLanguagePill(),
                showDivider: true,
                onTap: _showLanguagePicker,
              ),
              _buildSettingTile(
                icon: Icons.headset_mic_outlined,
                title: 'تواصل مع الدعم',
                showDivider: true,
                onTap: () {},
              ),
              _buildSettingTile(
                icon: Icons.info_outline_rounded,
                title: 'عن شمس',
                showDivider: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutShamsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ShamsColors.solarYellow),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShamsColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ), // زيادة المسافة الرأسية
          horizontalTitleGap: 18, // إبعاد الكلام عن الأيقونة تماماً كالصورة
          leading: Container(
            width: 45, // تكبير الأيقونة قليلاً
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5), // لون أفتح وأرقى
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFF9E7)),
            ),
            child: Icon(icon, color: ShamsColors.solarYellow, size: 22),
          ),
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 15, // تكبير الخط ليطابق الأصل
              fontWeight: FontWeight.w600,
              color: ShamsColors.textGray,
            ),
          ),
          trailing:
              trailing ??
              const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 25,
            ), // زيادة البادينج للفواصل
            child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          ),
      ],
    );
  }

  Widget _buildLanguagePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // خلفية رمادية فاتحة جداً
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'عربي',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: ShamsColors.solarYellow,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: CustomSolidButton(title: 'مشاركة التطبيق', onPressed: () {}),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
      label: Text(
        'تسجيل الخروج',
        style: GoogleFonts.tajawal(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // --- نافذة اختيار اللغة ---
  void _showLanguagePicker() {
    String tempLang = _selectedLanguage;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تغيير اللغة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setModalState(() => tempLang = 'ar'),
                  child: _buildLangOption('عربي (AR)', tempLang == 'ar'),
                ),
                GestureDetector(
                  onTap: () => setModalState(() => tempLang = 'en'),
                  child: _buildLangOption('English (EN)', tempLang == 'en'),
                ),
                const SizedBox(height: 25),
                CustomSolidButton(
                  title: 'حفظ',
                  onPressed: () {
                    setState(() => _selectedLanguage = tempLang);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(String label, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFFF9E7) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? ShamsColors.solarYellow : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (selected)
            const Icon(Icons.check_box, color: ShamsColors.solarYellow)
          else
            const Icon(Icons.check_box_outline_blank, color: Colors.grey),
        ],
      ),
    );
  }
}
