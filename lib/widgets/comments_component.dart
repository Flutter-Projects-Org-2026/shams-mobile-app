import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// بيانات تجريبية للتعليقات
// ─────────────────────────────────────────────────────────────────────────────

class CommentData {
  final String userName;
  final String userHandle;
  final String avatarPath;
  final String text;
  final String timeAgo;
  bool isLiked;
  int likesCount;

  CommentData({
    required this.userName,
    required this.userHandle,
    required this.avatarPath,
    required this.text,
    required this.timeAgo,
    this.isLiked = false,
    this.likesCount = 0,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// دالة مساعدة لعرض التعليقات كـ Modal Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

Future<void> showCommentsSheet(
  BuildContext context, {
  required List<CommentData> comments,
  int commentsCount = 0,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        CommentsComponent(comments: comments, commentsCount: commentsCount),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CommentsComponent — نافذة التعليقات
// ─────────────────────────────────────────────────────────────────────────────

class CommentsComponent extends StatefulWidget {
  final List<CommentData> comments;
  final int commentsCount;

  const CommentsComponent({
    super.key,
    required this.comments,
    this.commentsCount = 0,
  });

  @override
  State<CommentsComponent> createState() => _CommentsComponentState();
}

class _CommentsComponentState extends State<CommentsComponent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late List<CommentData> _comments;

  @override
  void initState() {
    super.initState();
    // نستخدم نفس القائمة الأصلية بدلاً من أخذ نسخة منها (List.from)
    // لكي ينعكس أي تعليق جديد على الشاشة الرئيسية وشاشة التفاصيل
    _comments = widget.comments;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendComment() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(
        0,
        CommentData(
          userName: 'أنت',
          userHandle: '@me',
          avatarPath: 'assets/images/logo/shams logo.png',
          text: text,
          timeAgo: 'الآن',
          likesCount: 0,
        ),
      );
      _controller.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // نجعل الورقة تغطي ~85% من الشاشة
    final screenH = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: screenH * 0.85 + bottomInset,
        decoration: const BoxDecoration(
          color: ShamsColors.backgroundLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // ── مقبض ───────────────────────────────────────────────
            _buildHandle(),

            // ── عنوان ─────────────────────────────────────────────
            _buildTitle(),

            const Divider(height: 1, thickness: 1, color: ShamsColors.borderLight),

            // ── قائمة التعليقات ─────────────────────────────────
            Expanded(
              child: _comments.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _comments.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        thickness: 1,
                        color: ShamsColors.dividerLight,
                        indent: 70,
                      ),
                      itemBuilder: (context, index) {
                        return _CommentTile(
                          comment: _comments[index],
                          onLikeTap: () => setState(() {
                            final c = _comments[index];
                            c.isLiked = !c.isLiked;
                            c.likesCount += c.isLiked ? 1 : -1;
                          }),
                        );
                      },
                    ),
            ),

            const Divider(height: 1, thickness: 1, color: ShamsColors.borderLight),

            // ── شريط الإدخال ────────────────────────────────────
            _buildInputBar(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: ShamsColors.handleBar,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            'التعليقات',
            style: GoogleFonts.tajawal(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: ShamsColors.textGray,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: ShamsColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '${_comments.length}',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ShamsColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 52,
            color: ShamsColors.primaryBlue.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد تعليقات بعد.\nكن أول من يعلّق!',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: ShamsColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(double bottomInset) {
    return Container(
      color: ShamsColors.bgWhite,
      padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottomInset),
      child: Row(
        children: [
          // زر الإرسال
          const SizedBox(width: 8),

          // حقل الإدخال
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: ShamsColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ShamsColors.borderLight),
              ),
              child: Row(
                children: [
                  // const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.emoji_emotions_outlined,
                        size: 22,
                        color: ShamsColors.textHint,
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
                        color: ShamsColors.textGray,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقك هنا...',
                        hintStyle: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          color: ShamsColors.textHint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),

                  // أيقونة الإيموجي
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
                color: ShamsColors.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: ShamsColors.bgWhite,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CommentTile — تعليق واحد
// ─────────────────────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final CommentData comment;
  final VoidCallback onLikeTap;

  const _CommentTile({required this.comment, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = comment.avatarPath.startsWith('http');

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
                color: ShamsColors.primaryBlue.withValues(alpha: 0.15),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: isNetwork
                  ? Image.network(
                      comment.avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _avatarFallback(),
                    )
                  : Image.asset(
                      comment.avatarPath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _avatarFallback(),
                    ),
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
                      comment.userName,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comment.timeAgo,
                      style: GoogleFonts.tajawal(
                        fontSize: 11.5,
                        color: ShamsColors.textHint,
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
                    color: ShamsColors.textGray,
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
                        color: comment.isLiked
                            ? ShamsColors.dangerRed
                            : ShamsColors.textHint,
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
                              ? ShamsColors.dangerRed
                              : ShamsColors.textHint,
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

  Widget _avatarFallback() {
    return Container(
      color: ShamsColors.avatarFallbackBg,
      child: Center(
        child: Text(
          comment.userName.isNotEmpty ? comment.userName[0] : '؟',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ShamsColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
