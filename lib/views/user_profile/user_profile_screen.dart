import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';
import 'add_workshop_screen.dart';
import 'privacy_security_screen.dart';
import 'about_shams_screen.dart';
import '../workshops/workshop_dashboard_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/auth_gate.dart';
import 'edit_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchUserData();
    });
  }

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
    final currentUser = context.watch<UserProvider>().currentUser;
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
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  backgroundImage: _getProfileImageProvider(currentUser.profileImageUrl),
                ),
              ),
              // زر تعديل الملف (يسار)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ShamsColors.solarYellow.withValues(alpha: 0.2),
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
                      currentUser.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ShamsColors.textGray,
                      ),
                    ),
                  ],
                ),
                Text(
                  '@${currentUser.email.split('@').first}',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (currentUser.phone != null &&
                    currentUser.phone!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: ShamsColors.solarYellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentUser.phone!,
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (currentUser.bio != null &&
                        currentUser.bio!.isNotEmpty) ...[
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: ShamsColors.solarYellow,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          currentUser.bio!,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: ShamsColors.solarYellow,
                      ),
                      const SizedBox(width: 4),
                    ],
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
        // Workshop tile — toggles between Add and Manage based on _hasWorkshop
        _buildWorkshopTile(),
      ],
    );
  }

  // ─── Dynamic Workshop Tile ───────────────────────────────────────────

  Widget _buildWorkshopTile() {
    final bool hasWorkshop = context
        .watch<UserProvider>()
        .currentUser
        .hasWorkshop;

    return InkWell(
      onTap: hasWorkshop ? _openWorkshopDashboard : _openAddWorkshop,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: hasWorkshop
                ? ShamsColors.solarYellow.withValues(alpha: 0.35)
                : const Color(0xFFF2F4F7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading icon container
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasWorkshop ? Icons.dashboard_customize_rounded : Icons.add,
                color: ShamsColors.solarYellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            // Text column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasWorkshop ? 'لوحة تحكم الورشة' : 'إضافة ورشة جديدة',
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ShamsColors.textGray,
                    ),
                  ),
                  Text(
                    hasWorkshop
                        ? 'إدارة منشوراتك وإحصاءات ورشتك'
                        : 'انقر هنا لإضافة تفاصيل الورشة',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            // Trailing arrow
            const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  /// Navigates to AddWorkshopScreen
  void _openAddWorkshop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkshopScreen()),
    ).then((_) {
      if (mounted) {
        final hasWorkshop = context
            .read<UserProvider>()
            .currentUser
            .hasWorkshop;
        if (hasWorkshop) {
          _showWorkshopCreatedSnackBar();
        }
      }
    });
  }

  /// Navigates to the workshop dashboard.
  void _openWorkshopDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkshopDashboardScreen()),
    );
  }

  /// Floating success SnackBar shown after a workshop is created.
  void _showWorkshopCreatedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إنشاء الورشة بنجاح! 🎉',
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ShamsColors.verifiedGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
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
                      activeThumbColor:
                          Colors.white, // الي بالصورة لون الزر أبيض
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
                onTap: _showSupportMenu,
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
            child: Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
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
      child: CustomSolidButton(
        title: 'مشاركة التطبيق',
        onPressed: () {
          SharePlus.instance.share(
            ShareParams(
              text:
                  'حمّل تطبيق شمس وانضم إلينا الآن!\nhttps://shams.app/download',
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: _showLogoutConfirmation,
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? ShamsColors.dangerRed : ShamsColors.verifiedGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- نافذة تواصل مع الدعم ---
  void _showSupportMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
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
                'تواصل مع الدعم',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF25D366),
                ),
                title: Text('واتساب', style: GoogleFonts.tajawal(fontSize: 16)),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse('https://wa.me/967776434968');
                  try {
                    final success = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!success) {
                      _showSnackBar(
                        'لم نتمكن من فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق.',
                        isError: true,
                      );
                    }
                  } catch (_) {
                    _showSnackBar(
                      'لم نتمكن من فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق.',
                      isError: true,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.phone_in_talk_outlined,
                  color: ShamsColors.primaryBlue,
                ),
                title: Text(
                  'اتصال هاتفي',
                  style: GoogleFonts.tajawal(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse('tel:+967776434968');
                  try {
                    final success = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!success) {
                      _showSnackBar('تعذر إجراء الاتصال الهاتفي حالياً.', isError: true);
                    }
                  } catch (_) {
                    _showSnackBar('تعذر إجراء الاتصال الهاتفي حالياً.', isError: true);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.orange),
                title: Text('إيميل', style: GoogleFonts.tajawal(fontSize: 16)),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse('mailto:codyvex1@gmail.com');
                  try {
                    final success = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!success) {
                      _showSnackBar('لم نتمكن من فتح تطبيق البريد الإلكتروني.', isError: true);
                    }
                  } catch (_) {
                    _showSnackBar('لم نتمكن من فتح تطبيق البريد الإلكتروني.', isError: true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- نافذة تأكيد تسجيل الخروج ---
  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
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
                'تسجيل الخروج',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.dangerRed,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: ShamsColors.textGray,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Sign out from Supabase
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          // 2. Clear local user data
                          context.read<UserProvider>().clearUserData();
                          // 3. Navigate to AuthGate to reset the app state
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AuthGate(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ShamsColors.dangerRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
                  onTap: () {}, // Disabled
                  child: _buildLangOption(
                    'English (EN)',
                    false,
                    badgeText: 'قريباً',
                  ),
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

  Widget _buildLangOption(String label, bool selected, {String? badgeText}) {
    final bool isDisabled = badgeText != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFFFF9E7)
            : (isDisabled ? Colors.grey.shade100 : const Color(0xFFF9FAFB)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? ShamsColors.solarYellow : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ShamsColors.solarYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: ShamsColors.solarYellow,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (selected)
            const Icon(Icons.check_box, color: ShamsColors.solarYellow)
          else
            Icon(
              Icons.check_box_outline_blank,
              color: isDisabled ? Colors.grey.shade300 : Colors.grey,
            ),
        ],
      ),
    );
  }
}
