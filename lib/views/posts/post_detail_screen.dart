import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/post_card.dart';
import '../../widgets/comments_component.dart';

import '../../providers/feed_provider.dart';
import '../../providers/workshop_provider.dart';
import '../../models/public_workshop_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../workshops/workshop_profile_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PostDetailScreen — شاشة تفاصيل المنشور
//
// • Accepts ONLY a [postId] — no full Post object is passed.
// • Reads live data from FeedProvider via context.watch() in build().
// • Mutations use context.read() strictly inside callbacks (never in build).
// • No Consumer widget is used anywhere.
// ─────────────────────────────────────────────────────────────────────────────

class PostDetailScreen extends StatelessWidget {
  /// The unique identifier of the post to display.
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    // ── Single source of truth: watch the provider for live updates ──────────
    // context.watch causes the entire build to re-run whenever FeedProvider
    // calls notifyListeners(), guaranteeing the UI is always up-to-date.
    final feed = context.watch<FeedProvider>();
    final post = feed.getPostById(postId);

    // Guard: if the post was deleted while open, pop back gracefully.
    if (post == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ShamsColors.backgroundLight,
          appBar: _buildAppBar(context),
          body: Center(
            child: Text(
              'لم يُعثر على المنشور',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: ShamsColors.textHint,
              ),
            ),
          ),
        ),
      );
    }

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

    // Derived display values — computed inside build, never stored in state.
    final username = postWorkshop?.name ?? post.author?.name ?? 'مستخدم غير معروف';
    final userHandle = postWorkshop?.handle ?? (post.author?.email != null ? '@${post.author!.email.split('@').first}' : '@unknown');
    final avatarPath = postWorkshop?.logoPath ?? post.author?.profileImageUrl ?? 'assets/images/logo/shams logo.png';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ShamsColors.backgroundLight,

        // ── AppBar ───────────────────────────────────────────────────────────
        appBar: _buildAppBar(context),

        // ── Body ─────────────────────────────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── بطاقة المنشور الكاملة ──────────────────────────────────────
              PostCard(
                username: username,
                userHandle: userHandle,
                avatarPath: avatarPath,
                content: post.textDetails,
                imagePaths: post.images.isNotEmpty ? post.images : null,
                likesCount: post.likesCount,
                commentsCount: post.comments.length,
                sharesCount: 0,
                isLiked: post.isLiked,
                // Show full text — no truncation on the detail screen.
                maxLines: 999,
                // context.read() inside a callback — correct usage.
                onLikeToggle: (_) =>
                    context.read<FeedProvider>().toggleLike(postId),
                onCommentTap: () => _openCommentsSheet(context),
                onShareTap: () => _onShare(context),
                onMenuTap: () => _showMenu(context),
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

              const SizedBox(height: 8),

              // ── قسم التعليقات ─────────────────────────────────────────────
              _CommentsSection(postId: postId),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  void _openCommentsSheet(BuildContext context) async {
    await showCommentsSheet(context, postId: postId);
    // No setState needed — FeedProvider notified, context.watch rebuilds us.
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
                  Text(
                    'تفاصيل المنشور',
                    style: GoogleFonts.tajawal(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ShamsColors.textGray,
                    ),
                  ),
                  const Spacer(),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommentsSection — the full comments block (header + preview + add button).
//
// Reads the live comments list from context.watch inside its own build so
// it re-renders automatically when FeedProvider notifies (e.g. after addComment).
// ─────────────────────────────────────────────────────────────────────────────

class _CommentsSection extends StatelessWidget {
  final String postId;

  const _CommentsSection({required this.postId});

  @override
  Widget build(BuildContext context) {
    // Watch FeedProvider directly to make this section perfectly reactive
    final feed = context.watch<FeedProvider>();
    final post = feed.getPostById(postId);

    if (post == null) return const SizedBox.shrink();
    final comments = post.comments;

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
          // ── رأس القسم ──────────────────────────────────────────────────────
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
                // Live count badge — updates automatically via context.watch
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
                    '${comments.length}',
                    style: GoogleFonts.tajawal(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: ShamsColors.primaryBlue,
                    ),
                  ),
                ),
                const Spacer(),
                // context.read() inside onTap callback — correct usage.
                GestureDetector(
                  onTap: () => _openSheet(context),
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

          const Divider(
            height: 1,
            thickness: 1,
            color: ShamsColors.dividerLight,
          ),

          // ── معاينة أول تعليقين ─────────────────────────────────────────────
          if (comments.isNotEmpty)
            ...comments.take(2).expand((comment) {
              return [
                _PreviewComment(
                  avatarPath:
                      comment.user.profileImageUrl ??
                      'assets/images/logo/shams logo.png',
                  userName: comment.user.name,
                  text: comment.text,
                  timeAgo: timeago.format(comment.timestamp, locale: 'ar'),
                ),
                if (comment != comments.take(2).last)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: ShamsColors.dividerLight,
                    indent: 62,
                  ),
              ];
            }),

          // ── زر إضافة تعليق ─────────────────────────────────────────────────
          GestureDetector(
            // context.read() inside a callback — correct usage.
            onTap: () => _openSheet(context),
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

  Future<void> _openSheet(BuildContext context) async {
    await showCommentsSheet(context, postId: postId);
    // No setState — FeedProvider notifies, context.watch in the parent rebuilds.
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PreviewComment — مصغّر تعليق في القائمة
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
          // الصورة الشخصية
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
                  : (avatarPath.startsWith('assets/')
                      ? Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: ShamsColors.avatarFallbackBg,
                            child: Center(
                              child: Text(
                                userName.isNotEmpty ? userName[0] : '؟',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.w700,
                                  color: ShamsColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        )
                      : (File(avatarPath).existsSync()
                          ? Image.file(
                              File(avatarPath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: ShamsColors.avatarFallbackBg,
                                child: Center(
                                  child: Text(
                                    userName.isNotEmpty ? userName[0] : '؟',
                                    style: GoogleFonts.tajawal(
                                      fontWeight: FontWeight.w700,
                                      color: ShamsColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: ShamsColors.avatarFallbackBg,
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty ? userName[0] : '؟',
                                  style: GoogleFonts.tajawal(
                                    fontWeight: FontWeight.w700,
                                    color: ShamsColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ))),
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
// _MenuOption — خيار في قائمة خيارات المنشور
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
