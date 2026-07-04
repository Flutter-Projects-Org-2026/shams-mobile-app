import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/feed_provider.dart';
import '../utils/constants.dart';
import '../views/main_screen.dart';
import '../views/user_profile/edit_profile_screen.dart';
import '../views/user_profile/about_shams_screen.dart';
import '../views/workshops/workshop_dashboard_screen.dart';
import '../widgets/auth_gate.dart';

class ShamsDrawer extends StatelessWidget {
  final int activeIndex;

  const ShamsDrawer({super.key, required this.activeIndex});

  void _navigateTo(BuildContext context, int index) {
    Navigator.pop(context);
    if (activeIndex == index) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
      (route) => false,
    );
  }

  void _showSupportMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ext.handleBar,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تواصل مع الدعم الفني',
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
                  title: Text('واتساب',
                      style: GoogleFonts.tajawal(fontSize: 16)),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri url =
                        Uri.parse('https://wa.me/967776434968');
                    try {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.phone_in_talk_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text(
                    'اتصال هاتفي',
                    style: GoogleFonts.tajawal(fontSize: 16),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri url = Uri.parse('tel:+967776434968');
                    try {
                      await launchUrl(url);
                    } catch (_) {}
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.email_outlined,
                    color: Colors.orange,
                  ),
                  title: Text(
                    'البريد الإلكتروني',
                    style: GoogleFonts.tajawal(fontSize: 16),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final Uri url =
                        Uri.parse('mailto:codyvex1@gmail.com');
                    try {
                      await launchUrl(url);
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: colorScheme.error,
                  size: 40,
                ),
                const SizedBox(height: 16),
                Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'هل أنت متأكد من رغبتك في تسجيل الخروج من منصة شمس؟',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: ext.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: GoogleFonts.tajawal(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          elevation: 0,
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'تسجيل خروج',
                          style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<UserProvider>().clearUserData();
      context.read<NotificationProvider>().clearNotifications();
      context.read<ChatProvider>().clearChats();
      context.read<FeedProvider>().clearFeed();
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthGate()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final hasAvatar = user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty &&
        user.profileImageUrl!.startsWith('http');

    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ── Drawer Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: ext.avatarFallbackBg,
                        backgroundImage: hasAvatar
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: !hasAvatar
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.hasWorkshop
                              ? colorScheme.secondary
                              : colorScheme.onPrimary
                                  .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.hasWorkshop
                              ? 'صاحب ورشة 🛠️'
                              : 'عميل شمس ☀️',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: user.hasWorkshop
                                ? colorScheme.onSecondary
                                : colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: colorScheme.onPrimary.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Menu Items ─────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'الصفحة الرئيسية',
                    isSelected: activeIndex == 0,
                    onTap: () => _navigateTo(context, 0),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.engineering_rounded,
                    title: 'قائمة الورش',
                    isSelected: activeIndex == 1,
                    onTap: () => _navigateTo(context, 1),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'محادثاتي',
                    isSelected: activeIndex == 2,
                    onTap: () => _navigateTo(context, 2),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.edit_note_rounded,
                    title: 'تعديل الملف الشخصي',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.build_circle_outlined,
                    title: 'طلبات الصيانة الخاصة بي',
                    isSelected: false,
                    onTap: () => _navigateTo(context, 2),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: 'عن منصة شمس',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutShamsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني والاتصال',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      _showSupportMenu(context);
                    },
                  ),
                  if (user.hasWorkshop) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Divider(color: ext.borderLight, height: 1),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.dashboard_customize_rounded,
                      title: 'لوحة تحكم الورشة',
                      isSelected: false,
                      onTap: () async {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const WorkshopDashboardScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            // ── Footer (Logout) ────────────────────────────────────────────
            Divider(color: ext.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: _buildMenuItem(
                context: context,
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                isSelected: false,
                textColor: colorScheme.error,
                iconColor: colorScheme.error,
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final finalTextColor = textColor ??
        (isSelected ? colorScheme.primary : colorScheme.onSurface);
    final finalIconColor = iconColor ??
        (isSelected ? colorScheme.primary : ext.textHint);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: finalIconColor, size: 22),
        title: Text(
          title,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.w500,
            color: finalTextColor,
          ),
        ),
        onTap: onTap,
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
