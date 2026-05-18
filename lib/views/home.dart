import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../widgets/appbar.dart';
import '../widgets/post_card.dart';
import '../widgets/inline_search_bar.dart';
import 'posts/post_detail_screen.dart';
import '../widgets/comments_component.dart';
import 'notifications/notifications_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// بيانات تجريبية للمنشورات
// ─────────────────────────────────────────────────────────────────────────────

const _kPostContent =
    'تم الانتهاء اليوم من تركيب منظومة طاقة شمسية بقدرة 5 كيلو واط مع عاكس [مكس/JA] قياسي واط في صنعاء، تم استخدام الألواح الأداء ممتازة من غاز عبر.';

final List<CommentData> _kSampleComments = [
  CommentData(
    userName: 'م. سارة الهاشمي',
    userHandle: '@sara_energy',
    avatarPath: 'assets/images/logo/shams logo.png',
    text: 'ممتاز! هذا النوع من المنظومات يعطي كفاءة عالية جداً في الصيف.',
    timeAgo: 'منذ ٥ دقائق',
    likesCount: 4,
  ),
  CommentData(
    userName: 'م. خالد السهيل',
    userHandle: '@khalid_solar',
    avatarPath: 'assets/images/logo/shams logo.png',
    text:
        'هل استخدمت عاكس JA أم نوع آخر؟ أنا شخصياً أفضل Growatt للمنظومات الصغيرة.',
    timeAgo: 'منذ ١٢ دقيقة',
    likesCount: 2,
    isLiked: true,
  ),
  CommentData(
    userName: 'أبو عبدالله',
    userHandle: '@abuabdullah_sa',
    avatarPath: 'assets/images/logo/shams logo.png',
    text: 'كم تكلف المنظومة كاملة؟ أفكر في تركيب مشابه في منزلي.',
    timeAgo: 'منذ ٣٠ دقيقة',
    likesCount: 0,
  ),
  CommentData(
    userName: 'م. يوسف الغامدي',
    userHandle: '@yusuf_solar',
    avatarPath: 'assets/images/logo/shams logo.png',
    text: 'شغل نظيف ومتقن. بالتوفيق دائماً أستاذ أحمد!',
    timeAgo: 'منذ ساعة',
    likesCount: 7,
  ),
];

final List<Map<String, dynamic>> _kPosts = [
  {
    'username': 'م. أحمد العمودي',
    'userHandle': '@ahmed_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content': _kPostContent,
    'imagePaths': ['assets/images/post image.jpg'],
    'likesCount': 124,
    'commentsCount': 18,
    'sharesCount': 5,
    'isLiked': false,
    'comments': List<CommentData>.from(_kSampleComments),
  },
  {
    'username': 'م. أحمد العمودي',
    'userHandle': '@ahmed_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content': _kPostContent,
    'imagePaths': ['assets/images/post image.jpg'],
    'likesCount': 124,
    'commentsCount': 18,
    'sharesCount': 5,
    'isLiked': true,
    'comments': List<CommentData>.from(_kSampleComments),
  },
  {
    'username': 'م. سارة الهاشمي',
    'userHandle': '@sara_energy',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content':
        'مشروع جديد في الرياض! تركيب ألواح شمسية على مبنى تجاري بقدرة 20 كيلو واط. النتائج مبهرة والكفاءة عالية جداً.',
    'imagePaths': ['assets/images/post image.jpg'],
    'likesCount': 89,
    'commentsCount': 12,
    'sharesCount': 3,
    'isLiked': false,
    'comments': List<CommentData>.from(_kSampleComments),
  },
  {
    'username': 'م. خالد السهيل',
    'userHandle': '@khalid_solar',
    'avatarPath': 'assets/images/logo/shams logo.png',
    'content':
        'طرحت اليوم تصميمًا جديدًا لنظام إدارة الطاقة الذكي الذي يعمل مع جميع أنواع الألواح الشمسية. تواصل معي للمزيد!',
    'imagePaths': null,
    'likesCount': 56,
    'commentsCount': 7,
    'sharesCount': 10,
    'isLiked': false,
    'comments': List<CommentData>.from(_kSampleComments),
  },
];

// ─────────────────────────────────────────────────────────────────────────────
// HomeScreen — الشاشة الرئيسية لمنصة شمس
// ─────────────────────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _searchSuggestions = [
    'طاقة شمسية',
    'ألواح كهروضوئية',
    'بطاريات تخزين',
    'عاكس كهربائي',
    'تركيب منظومة',
    'شبكة الكهرباء',
    'توفير الطاقة',
    'الطاقة المتجددة',
  ];

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
    final filteredPosts = _searchQuery.isEmpty 
        ? _kPosts 
        : _kPosts.where((p) => 
            (p['content'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) || 
            (p['username'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
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
              username: post['username'] as String,
              userHandle: post['userHandle'] as String,
              avatarPath: post['avatarPath'] as String,
              content: post['content'] as String,
              imagePaths: post['imagePaths'] as List<String>?,
              likesCount: post['likesCount'] as int,
              commentsCount: post['commentsCount'] as int,
              sharesCount: post['sharesCount'] as int,
              isLiked: post['isLiked'] as bool,
              comments: post['comments'] as List<CommentData>,
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
                  debugPrint('Post $index liked: $liked');
                },
                onCommentTap: () => showCommentsSheet(
                  context,
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
