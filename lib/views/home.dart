import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/appbar.dart';
import '../widgets/post_card.dart';
import '../widgets/inline_search_bar.dart';
import 'posts/post_detail_screen.dart';
import '../widgets/comments_component.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/workshop_provider.dart';
import '../models/public_workshop_model.dart';
import 'notifications/notifications_screen.dart';
import 'workshops/workshop_profile_screen.dart';
import '../widgets/shams_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// (أُزيلت البيانات الوهمية، يتم جلبها الآن من FeedProvider)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — الشاشة الرئيسية لمنصة شمس
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ShamsDrawer(activeIndex: 0),
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        // ── AppBar المُعاد استخدامه من widgets/appbar.dart ──────────
        appBar: ShamsPlatformAppBar(
          onMenuTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          onNotificationTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          },
          // onDarkModeTap intentionally omitted — AppBar uses ThemeProvider.toggleTheme() by default
        ),
        body: _buildBody(context),
      ),
    );
  }

  // ─── شريط البحث الثابت ────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InlineSearchBar(
            hintText: 'ابحث عن قبليات، مشاريع أو قطع غيار...',
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: ext.dividerLight,
          ),
        ],
      ),
    );
  }

  // ─── محتوى الصفحة: بحث ثابت + قائمة المنشورات ───────────────────────────

  Widget _buildBody(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final allPosts = feedProvider.posts;

    final filteredPosts = _searchQuery.isEmpty 
        ? allPosts 
        : allPosts.where((p) => 
            p.textDetails.toLowerCase().contains(_searchQuery.toLowerCase()) || 
            (p.author?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    return CustomScrollView(
      slivers: [
        // ── شريط البحث الثابت ────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchBarDelegate(child: _buildSearchBar(context)),
        ),

        // ── فراغ علوي قبل المنشورات ───────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // ── قائمة المنشورات ───────────────────────────────
        if (filteredPosts.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: _searchQuery.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 60,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد منشورات حتى الآن',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'لا توجد نتائج لـ "$_searchQuery"',
                      style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                    ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = filteredPosts[index];
              // Resolve workshop for the post's owner display
              final workshops = context.watch<WorkshopProvider>().publicWorkshops;
              PublicWorkshopModel? postWorkshop;
              if (post.workshopId != null) {
                try {
                  postWorkshop = workshops.firstWhere((w) => w.id == post.workshopId);
                } catch (_) {}
              }
              if (postWorkshop == null && post.author != null) {
                try {
                  postWorkshop = workshops.firstWhere((w) => w.id == post.author!.id);
                } catch (_) {}
              }
              
              final displayName = postWorkshop?.name ?? post.author?.name ?? 'مستخدم غير معروف';
              final displayHandle = postWorkshop?.handle ?? (post.author?.email != null ? '@${post.author!.email.split('@').first}' : '@unknown');
              final displayAvatar = postWorkshop?.logoPath ?? post.author?.profileImageUrl ?? 'assets/images/logo/shams logo.png';

              return GestureDetector(
                // Pass only the postId — PostDetailScreen reads all live data
                // from FeedProvider via context.watch inside its own build().
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: post.id),
                  ),
                ),
                child: PostCard(
                  username: displayName,
                  userHandle: displayHandle,
                  avatarPath: displayAvatar,
                  content: post.textDetails,
                  imagePaths: post.images.isNotEmpty ? post.images : null,
                  likesCount: post.likesCount,
                  commentsCount: post.comments.length,
                  sharesCount: 0,
                  isLiked: post.isLiked,
                  // context.read() inside a callback — correct usage.
                  onLikeToggle: (_) =>
                      context.read<FeedProvider>().toggleLike(post.id),
                  onCommentTap: () => showCommentsSheet(
                    context,
                    postId: post.id,
                  ),
                  onShareTap: () => _onShare(context),
                  onMenuTap: () => _showPostMenu(context),
                   onUserTap: () {
                    final workshops = context.read<WorkshopProvider>().publicWorkshops;
                    PublicWorkshopModel? targetWorkshop;
                    
                    if (post.workshopId != null) {
                      try {
                        targetWorkshop = workshops.firstWhere((w) => w.id == post.workshopId);
                      } catch (_) {}
                    }
                    
                    if (targetWorkshop == null && post.author != null) {
                      try {
                        targetWorkshop = workshops.firstWhere((w) => w.id == post.author!.id);
                      } catch (_) {}
                    }
                    
                    final targetId = targetWorkshop?.id ?? post.author?.id;
                    if (targetId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkshopProfile(workshopId: targetId),
                        ),
                      );
                    }
                  },
                ),
              );
            }, childCount: filteredPosts.length),
          ),

        // ── فراغ سفلي ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  void _onShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت مشاركة المنشور',
          style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onInverseSurface),
        ),
        backgroundColor:
            Theme.of(context).colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  // ─── قائمة خيارات المنشور ─────────────────────────────────────────────────

  void _showPostMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .handleBar,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _MenuOption(
                icon: Icons.bookmark_border_rounded,
                label: 'حفظ المنشور',
                onTap: () => Navigator.pop(context),
              ),
              _MenuOption(
                icon: Icons.person_add_outlined,
                label: 'متابعة الحساب',
                onTap: () => Navigator.pop(context),
              ),
              _MenuOption(
                icon: Icons.flag_outlined,
                label: 'الإبلاغ عن المنشور',
                color: Theme.of(context).colorScheme.error,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchBarDelegate — مفوض شريط البحث الثابت
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _SearchBarDelegate({required this.child});

  // ارتفاع شريط البحث: تبطين (10) + حقل (46) + تبطين (10) + فاصل (1)
  static const double _height = 67.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_SearchBarDelegate oldDelegate) =>
      oldDelegate.child != child;
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOption — عنصر في قائمة خيارات المنشور
// ─────────────────────────────────────────────────────────────────────────────

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
