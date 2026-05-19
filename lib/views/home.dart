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
import 'notifications/notifications_screen.dart';

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

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ShamsColors.backgroundLight,
        // ── AppBar المُعاد استخدامه من widgets/appbar.dart ──────────
        appBar: ShamsPlatformAppBar(
          hasUnreadNotifications: true,
          onMenuTap: () {},
          onNotificationTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
          },
          onDarkModeTap: () {},
        ),
        body: _buildBody(context),
      ),
    );
  }

  // ─── شريط البحث الثابت ────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    return Material(
      color: ShamsColors.bgWhite,
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
          const Divider(
            height: 1,
            thickness: 1,
            color: ShamsColors.dividerLight,
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
              child: Text(
                'لا توجد نتائج لـ "$_searchQuery"',
                style: GoogleFonts.tajawal(color: ShamsColors.textHint, fontSize: 16),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = filteredPosts[index];
              final postData = PostDetailData(
                postId: post.id,
                username: post.author?.name ?? 'مستخدم غير معروف',
                userHandle: post.author?.email != null ? '@${post.author!.email.split('@').first}' : '@unknown',
                avatarPath: post.author?.profileImageUrl ?? 'assets/images/logo/shams logo.png',
                content: post.textDetails,
                imagePaths: post.images.isNotEmpty ? post.images : null,
                likesCount: post.likesCount,
                commentsCount: post.comments.length,
                sharesCount: 0, // Placeholder
                isLiked: post.isLiked,
                comments: post.comments,
              );
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: postData),
                  ),
                ),
                child: PostCard(
                  username: postData.username,
                  userHandle: postData.userHandle,
                  avatarPath: postData.avatarPath,
                  content: postData.content,
                  imagePaths: postData.imagePaths,
                  likesCount: postData.likesCount,
                  commentsCount: postData.comments.length,
                  sharesCount: postData.sharesCount,
                  isLiked: postData.isLiked,
                  onLikeToggle: (liked) {
                    context.read<FeedProvider>().toggleLike(post.id);
                  },
                  onCommentTap: () => showCommentsSheet(
                    context,
                    postId: post.id,
                    comments: postData.comments,
                    commentsCount: postData.comments.length,
                  ),
                onShareTap: () => _onShare(context),
                onMenuTap: () => _showPostMenu(context),
                onUserTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: postData),
                    ),
                  );
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
          style: GoogleFonts.tajawal(color: ShamsColors.bgWhite),
        ),
        backgroundColor: ShamsColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
          decoration: const BoxDecoration(
            color: ShamsColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // مقبض
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: ShamsColors.handleBar,
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
                color: ShamsColors.dangerDark,
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
    final effectiveColor = color ?? ShamsColors.textGray;
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
