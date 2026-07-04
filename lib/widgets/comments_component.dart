import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants.dart';

import 'package:provider/provider.dart';
import '../models/comment_model.dart';
import '../providers/feed_provider.dart';
import '../providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

// ─────────────────────────────────────────────────────────────────────────────
// دالة مساعدة لعرض التعليقات كـ Modal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showCommentsSheet(
  BuildContext context, {
  required String postId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CommentsComponent(postId: postId),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CommentsComponent — نافذة التعليقات
//
// • Uses context.watch<FeedProvider>() instead of Consumer<FeedProvider>.
// • All mutations use context.read<FeedProvider>() inside callbacks.
// ─────────────────────────────────────────────────────────────────────────────

class CommentsComponent extends StatefulWidget {
  final String postId;

  const CommentsComponent({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsComponent> createState() => _CommentsComponentState();
}

class _CommentsComponentState extends State<CommentsComponent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final currentUser = context.read<UserProvider>().currentUser;
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.postId,
      text: text,
      timestamp: DateTime.now(),
      user: currentUser,
    );

    context.read<FeedProvider>().addComment(widget.postId, newComment);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final feed = context.watch<FeedProvider>();
    final post = feed.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => feed.posts.first,
    );
    final currentComments = post.comments;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: screenH * 0.85 + bottomInset,
        decoration: BoxDecoration(
          color: ext.backgroundLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(ext),
            Expanded(
              child: Column(
                children: [
                  _buildTitle(currentComments.length),
                  Divider(height: 1, thickness: 1, color: ext.borderLight),
                  Expanded(
                    child: currentComments.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: currentComments.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              thickness: 1,
                              color: ext.dividerLight,
                              indent: 70,
                            ),
                            itemBuilder: (context, index) {
                              final comment = currentComments[index];
                              return InkWell(
                                onTap: () => _showCommentMenu(
                                  context,
                                  index,
                                  currentComments,
                                  post.author?.id,
                                ),
                                child: _CommentTile(
                                  comment: comment,
                                  onLikeTap: () => context
                                      .read<FeedProvider>()
                                      .toggleCommentLike(
                                          widget.postId, comment.id),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: ext.borderLight),
            _buildInputBar(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ShamsExtendedColors ext) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ext.handleBar,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildTitle(int count) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            'التعليقات',
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 52,
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد تعليقات بعد.\nكن أول من يعلّق!',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: ext.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(double bottomInset) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      color: colorScheme.surface,
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomInset),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: ext.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ext.borderLight),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 22,
                        color: ext.textHint,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                        hintStyle: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          color: ext.textHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendComment,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.send_rounded,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentMenu(
    BuildContext context,
    int index,
    List<CommentModel> currentComments,
    String? postAuthorId,
  ) {
    final comment = currentComments[index];
    final currentUser = context.read<UserProvider>().currentUser;
    final commentAuthorId = comment.user.id;

    final bool canDelete = currentUser.id == commentAuthorId ||
        (postAuthorId != null && currentUser.id == postAuthorId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .handleBar,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.copy_rounded,
                    color: Theme.of(context).colorScheme.onSurface),
                title:
                    Text('نسخ النص', style: GoogleFonts.tajawal(fontSize: 16)),
                onTap: () async {
                  Navigator.pop(context);
                  await Clipboard.setData(ClipboardData(text: comment.text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ التعليق',
                          style: GoogleFonts.tajawal(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.inverseSurface,
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              if (canDelete)
                ListTile(
                  leading: Icon(Icons.delete_outline_rounded,
                      color: Theme.of(context).colorScheme.error),
                  title: Text(
                    'حذف التعليق',
                    style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context
                        .read<FeedProvider>()
                        .deleteComment(widget.postId, comment.id);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommentTile — تعليق واحد
// ─────────────────────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback onLikeTap;

  const _CommentTile({required this.comment, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    final avatarPath =
        comment.user.profileImageUrl ?? 'assets/images/logo/shams logo.png';
    final bool isNetwork = avatarPath.startsWith('http');
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة الشخصية
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: isNetwork
                  ? Image.network(
                      avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _avatarFallback(colorScheme, ext),
                    )
                  : (avatarPath.startsWith('assets/')
                      ? Image.asset(
                          avatarPath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              _avatarFallback(colorScheme, ext),
                        )
                      : (File(avatarPath).existsSync()
                          ? Image.file(
                              File(avatarPath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _avatarFallback(colorScheme, ext),
                            )
                          : _avatarFallback(colorScheme, ext))),
            ),
          ),

          const SizedBox(width: 10),

          // محتوى التعليق
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اسم المستخدم + الوقت
                Row(
                  children: [
                    Text(
                      comment.user.name,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeago.format(comment.timestamp, locale: 'ar'),
                      style: GoogleFonts.tajawal(
                        fontSize: 11.5,
                        color: ext.textHint,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // نص التعليق
                Text(
                  comment.text,
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                // زر الإعجاب
                GestureDetector(
                  onTap: onLikeTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comment.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 15,
                        color: comment.isLiked ? colorScheme.error : ext.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.likesCount > 0
                            ? '${comment.likesCount}'
                            : 'إعجاب',
                        style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: comment.isLiked
                              ? colorScheme.error
                              : ext.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(ColorScheme colorScheme, ShamsExtendedColors ext) {
    return Container(
      color: ext.avatarFallbackBg,
      child: Center(
        child: Text(
          comment.user.name.isNotEmpty ? comment.user.name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
