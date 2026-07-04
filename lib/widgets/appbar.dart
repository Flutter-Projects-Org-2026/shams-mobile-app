import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/providers/notification_provider.dart';
import 'package:shams_mobile_app/providers/theme_provider.dart';

/// ShamsPlatformAppBar — شريط التطبيق الرئيسي لمنصة شمس
///
/// الاستخدام:
/// ```dart
/// Scaffold(
///   appBar: ShamsPlatformAppBar(
///     onMenuTap: () {},
///     onNotificationTap: () {},
///     onDarkModeTap: () {},   // اختياري — يُوصَل تلقائياً بـ ThemeProvider
///   ),
/// )
/// ```
class ShamsPlatformAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// callback عند الضغط على أيقونة القائمة الجانبية
  final VoidCallback? onMenuTap;

  /// callback عند الضغط على أيقونة الإشعارات
  final VoidCallback? onNotificationTap;

  /// callback عند الضغط على أيقونة الوضع الليلي
  /// إذا كان null يُستخدم ThemeProvider.toggleTheme() مباشرة.
  final VoidCallback? onDarkModeTap;

  const ShamsPlatformAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onDarkModeTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationProvider>().unreadCount;
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.isDarkMode;

    // Select logo asset based on current brightness
    final logoAsset = isDark
        ? 'assets/images/logo/shams texial logo for dark mode.png'
        : 'assets/images/logo/shams texial logo for light mode small height.png';

    // The dark-mode toggle icon reflects the current mode
    final darkModeIcon =
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: colorScheme.surface,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── أيقونة القائمة الجانبية (يمين — بداية RTL) ────────────
                  _AppBarIcon(
                    icon: Icons.menu_rounded,
                    color: colorScheme.onSurface,
                    onTap: onMenuTap,
                  ),

                  // ── الشعار (الوسط) ─────────────────────────────────────────
                  Flexible(
                    child: Center(
                      child: Image.asset(
                        logoAsset,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // ── أيقونات الوضع الليلي والإشعارات (يسار — نهاية RTL) ─────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة تبديل الوضع الليلي
                      _AppBarIcon(
                        icon: darkModeIcon,
                        color: colorScheme.onSurface,
                        onTap: onDarkModeTap ??
                            () => themeProvider.toggleTheme(),
                      ),

                      const SizedBox(width: 14),

                      // أيقونة الإشعارات مع شارة
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _AppBarIcon(
                            icon: Icons.notifications_outlined,
                            color: colorScheme.onSurface,
                            onTap: onNotificationTap,
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              top: -4,
                              left: -6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 1.5,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppBarIcon — أيقونة بسيطة في شريط التطبيق
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _AppBarIcon({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 28, color: color),
    );
  }
}
