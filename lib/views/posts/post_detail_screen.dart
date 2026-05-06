import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comments_component.dart';

// ─────────────────────────────────────────────────────────────────────────────
// نموذج بيانات المنشور لشاشة التفاصيل
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailData {
  final String username;
  final String userHandle;
  final String avatarPath;
  final String content;
  final List<String>? imagePaths;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final List<CommentData> comments;

  const PostDetailData({
    required this.username,
    required this.userHandle,
    required this.avatarPath,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.comments,
    this.imagePaths,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PostDetailScreen — شاشة تفاصيل المنشور
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailScreen extends StatefulWidget {
  final PostDetailData post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ShamsColors.backgroundLight,

        // ── شريط التطبيق ─────────────────────────────────────────
        appBar: _buildAppBar(context),

        // ── المحتوى ──────────────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة المنشور كاملة (بدون تقليص النص)
              PostCard(
                username: widget.post.username,
                userHandle: widget.post.userHandle,
                avatarPath: widget.post.avatarPath,
                content: widget.post.content,
                imagePaths: widget.post.imagePaths,
                likesCount: widget.post.likesCount,
                commentsCount: widget.post.comments.length,
                sharesCount: widget.post.sharesCount,
                isLiked: widget.post.isLiked,
                // نعرض النص كاملاً دون تقليص
                maxLines: 999,
                onCommentTap: () async {
                  await showCommentsSheet(
                    context,
                    comments: widget.post.comments,
                    commentsCount: widget.post.comments.length,
                  );
                  // تحديث الواجهة بعد إغلاق نافذة التعليقات لعرض العدد والتعليقات الجديدة
                  setState(() {});
                },
                onShareTap: () => _onShare(context),
                onMenuTap: () => _showMenu(context),
              ),

              // ── الهاشتاقات ───────────────────────────────────
              // _buildHashtags(),
              const SizedBox(height: 8),

              // ── قسم التعليقات المعاينة ────────────────────────
              _buildCommentsPreview(context),

              const SizedBox(height: 20),
            ],
          ),
        ),

        // ── شريط التنقل السفلي ──────────────────────────────────
        // bottomNavigationBar: ShamsBottomNavBar(
        //   currentIndex: _currentNavIndex,
        //   onTap: (index) => setState(() => _currentNavIndex = index),
        // ),
      ),
    );
  }

  // ── AppBar مع سهم الرجوع ─────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        color: ShamsColors.solarYellow,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // زر الرجوع
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: ShamsColors.textGray,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // العنوان
                  Text(
                    'تفاصيل المنشور',
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ShamsColors.textGray,
                    ),
                  ),

                  const Spacer(),

                  // زر المشاركة
                  GestureDetector(
                    onTap: () => _onShare(context),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 22,
                      color: ShamsColors.textGray,
                    ),
                  ),

                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── الهاشتاقات ───────────────────────────────────────────────────────────

  // Widget _buildHashtags() {
  //   const tags = [
  //     '#طاقة_شمسية',
  //     '#ألواح_كهروضوئية',
  //     '#عاكس_كهربائي',
  //     '#منظومة_شمسية',
  //   ];

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  //     child: Wrap(
  //       spacing: 8,
  //       runSpacing: 6,
  //       children: tags.map((tag) => _HashtagChip(label: tag)).toList(),
  //     ),
  //   );
  // }

  // ── قسم معاينة التعليقات ─────────────────────────────────────────────────

  Widget _buildCommentsPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ShamsColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ShamsColors.primaryBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس القسم
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  'التعليقات',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: ShamsColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${widget.post.comments.length}',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ShamsColors.primaryBlue,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    await showCommentsSheet(
                      context,
                      comments: widget.post.comments,
                      commentsCount: widget.post.comments.length,
                    );
                    setState(() {});
                  },
                  child: Text(
                    'عرض الكل',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ShamsColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: ShamsColors.dividerLight),

          // معاينة أول تعليقين (أو أقل)
          if (widget.post.comments.isNotEmpty)
            ...widget.post.comments.take(2).expand((comment) {
              return [
                _PreviewComment(
                  avatarPath: comment.avatarPath,
                  userName: comment.userName,
                  text: comment.text,
                  timeAgo: comment.timeAgo,
                ),
                if (comment != widget.post.comments.take(2).last)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: ShamsColors.dividerLight,
                    indent: 62,
                  ),
              ];
            }),

          // زر إضافة تعليق
          GestureDetector(
            onTap: () async {
              await showCommentsSheet(
                context,
                comments: widget.post.comments,
                commentsCount: widget.post.comments.length,
              );
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.all(14),
              height: 42,
              decoration: BoxDecoration(
                color: ShamsColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ShamsColors.borderLight),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 18,
                    color: ShamsColors.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'اكتب تعليقك هنا...',
                    style: GoogleFonts.tajawal(
                      fontSize: 13.5,
                      color: ShamsColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

  void _showMenu(BuildContext context) {
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
// _PreviewComment — تعليق معاينة مبسّط
// ─────────────────────────────────────────────────────────────────────────────

class _PreviewComment extends StatelessWidget {
  final String avatarPath;
  final String userName;
  final String text;
  final String timeAgo;

  const _PreviewComment({
    required this.avatarPath,
    required this.userName,
    required this.text,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = avatarPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ShamsColors.primaryBlue.withValues(alpha: 0.15),
              ),
            ),
            child: ClipOval(
              child: isNetwork
                  ? Image.network(avatarPath, fit: BoxFit.cover)
                  : Image.asset(
                      avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: ShamsColors.avatarFallbackBg,
                        child: Center(
                          child: Text(
                            userName[0],
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.w700,
                              color: ShamsColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userName,
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: ShamsColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    height: 1.4,
                    color: ShamsColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuOption — خيار في قائمة المنشور
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
