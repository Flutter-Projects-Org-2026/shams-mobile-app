import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// PostCard — بطاقة منشور تفاعلية بتصميم Shams Platform
///
/// الاستخدام:
/// ```dart
/// PostCard(
///   username: 'م. أحمد العمودي',
///   userHandle: '@ahmed_solar',
///   avatarPath: 'assets/images/avatar.png',
///   content: 'تم الانتهاء اليوم من تركيب منظومة...',
///   imagePaths: ['assets/images/solar1.jpg', 'assets/images/solar2.jpg'],
///   likesCount: 124,
///   commentsCount: 18,
///   sharesCount: 5,
///   isLiked: false,
/// )
/// ```
class PostCard extends StatefulWidget {
  /// الاسم الكامل للمستخدم
  final String username;

  /// المعرّف مثل @ahmed_solar
  final String userHandle;

  /// مسار صورة الملف الشخصي (asset أو network)
  final String avatarPath;

  /// نص المنشور
  final String content;

  /// قائمة صور المنشور (اختيارية)
  final List<String>? imagePaths;

  /// عدد الإعجابات
  final int likesCount;

  /// عدد التعليقات
  final int commentsCount;

  /// عدد المشاركات
  final int sharesCount;

  /// هل أعجب المستخدم بهذا المنشور؟
  final bool isLiked;

  /// callback عند الإعجاب أو إلغائه
  final ValueChanged<bool>? onLikeToggle;

  /// callback عند الضغط على التعليق
  final VoidCallback? onCommentTap;

  /// callback عند الضغط على المشاركة
  final VoidCallback? onShareTap;

  /// callback عند الضغط على القائمة (...)
  final VoidCallback? onMenuTap;

  /// callback عند الضغط على اسم المستخدم / الصورة
  final VoidCallback? onUserTap;

  /// الحد الأقصى لأسطر النص قبل عرض "قراءة المزيد"
  final int maxLines;

  const PostCard({
    super.key,
    required this.username,
    required this.userHandle,
    required this.avatarPath,
    required this.content,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    this.imagePaths,
    this.onLikeToggle,
    this.onCommentTap,
    this.onShareTap,
    this.onMenuTap,
    this.onUserTap,
    this.maxLines = 3,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late int _likesCount;
  bool _isExpanded = false;
  int _currentImageIndex = 0;

  late AnimationController _likeAnimController;
  late Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likesCount = widget.likesCount;

    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.75,
      upperBound: 1.0,
      value: 1.0,
    );
    _likeScaleAnim = _likeAnimController;
  }

  /// Keep local state in sync when the provider pushes a new value.
  /// This fires whenever [widget.isLiked] or [widget.likesCount] changes
  /// from the parent (e.g. after returning from PostDetailScreen).
  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked ||
        oldWidget.likesCount != widget.likesCount) {
      _isLiked = widget.isLiked;
      _likesCount = widget.likesCount;
    }
  }

  @override
  void dispose() {
    _likeAnimController.dispose();
    super.dispose();
  }

  Future<void> _handleLikeTap() async {
    await _likeAnimController.reverse();
    await _likeAnimController.forward();
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });
    widget.onLikeToggle?.call(_isLiked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ShamsColors.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ShamsColors.primaryBlue.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ───────────────────────────────────────────
          _buildHeader(),

          // ── نص المنشور ────────────────────────────────────────────
          _buildContent(),

          // ── صور المنشور ───────────────────────────────────────────
          if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
            _buildImageCarousel(),

          // ── خط فاصل ──────────────────────────────────────────────
          const Divider(color: Color(0xFFF0F4FF), thickness: 1, height: 1),

          // ── شريط التفاعلات ────────────────────────────────────────
          _buildActions(),
        ],
      ),
    );
  }

  // ─── رأس البطاقة: الصورة + الاسم + المعرّف + قائمة ───────────────────────

  Widget _buildHeader() {
    final bool isNetwork = widget.avatarPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // زر قائمة الخيارات (...)
          _MenuButton(onTap: widget.onMenuTap),

          const Spacer(),

          // الاسم والمعرّف
          GestureDetector(
            onTap: widget.onUserTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.username,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShamsColors.textGray,
                  ),
                ),
                Text(
                  widget.userHandle,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ShamsColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // الصورة الشخصية
          GestureDetector(
            onTap: widget.onUserTap,
            child: _Avatar(
              imagePath: widget.avatarPath,
              username: widget.username,
              isNetwork: isNetwork,
            ),
          ),
        ],
      ),
    );
  }

  // ─── نص المنشور مع خيار التمديد ───────────────────────────────────────────

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              widget.content,
              textAlign: TextAlign.right,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.tajawal(
                fontSize: 14.5,
                height: 1.65,
                color: ShamsColors.textGray,
              ),
            ),
            secondChild: Text(
              widget.content,
              textAlign: TextAlign.right,
              style: GoogleFonts.tajawal(
                fontSize: 14.5,
                height: 1.65,
                color: ShamsColors.textGray,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),

          // زر قراءة المزيد / أقل
          if (_shouldShowToggle())
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isExpanded ? 'عرض أقل' : 'قراءة المزيد...',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: ShamsColors.primaryBlue,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  bool _shouldShowToggle() {
    // نحتاج TextPainter لمعرفة إن كان النص مقطوعاً فعلاً
    final tp = TextPainter(
      text: TextSpan(
        text: widget.content,
        style: GoogleFonts.tajawal(fontSize: 14.5, height: 1.65),
      ),
      maxLines: widget.maxLines,
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: double.infinity);
    return tp.didExceedMaxLines;
  }

  // ─── معرض الصور مع مؤشر الصفحة ───────────────────────────────────────────

  Widget _buildImageCarousel() {
    final images = widget.imagePaths!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            // الصور
            SizedBox(
              height: 210,
              child: PageView.builder(
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                itemBuilder: (context, index) {
                  final path = images[index];
                  final isNetwork = path.startsWith('http');
                  if (isNetwork) {
                    return Image.network(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    );
                  } else if (path.startsWith('assets/')) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    );
                  } else {
                    final file = File(path);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => _imagePlaceholder(),
                      );
                    } else {
                      return _imagePlaceholder();
                    }
                  }
                },
              ),
            ),

            // مؤشر الصفحة (1/2)
            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.all(10),
                child: _PageIndicatorBadge(
                  current: _currentImageIndex + 1,
                  total: images.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFF0F4FF),
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: ShamsColors.primaryBlue.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ─── شريط التفاعلات: إعجاب، تعليق، مشاركة ────────────────────────────────

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // المشاركة (يسار)
          _ActionChip(
            icon: Icons.reply_rounded,
            count: widget.sharesCount,
            color: ShamsColors.textGray.withValues(alpha: 0.7),
            onTap: widget.onShareTap,
          ),

          Row(
            children: [
              // التعليق
              _ActionChip(
                icon: Icons.chat_bubble_outline_rounded,
                count: widget.commentsCount,
                color: ShamsColors.textGray.withValues(alpha: 0.7),
                onTap: widget.onCommentTap,
              ),

              const SizedBox(width: 18),

              // الإعجاب مع أنيميشن
              ScaleTransition(
                scale: _likeScaleAnim,
                child: _ActionChip(
                  icon: _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  count: _likesCount,
                  color: _isLiked
                      ? const Color(0xFFE53935)
                      : ShamsColors.textGray.withValues(alpha: 0.7),
                  onTap: _handleLikeTap,
                  isAnimated: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Avatar — صورة ملف شخصي دائرية
// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imagePath;
  final String username;
  final bool isNetwork;

  const _Avatar({
    required this.imagePath,
    required this.username,
    required this.isNetwork,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: ShamsColors.primaryBlue.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ShamsColors.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: isNetwork
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : (imagePath.startsWith('assets/')
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallback(),
                  )
            : (File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallback(),
                  )
                : _fallback())),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFD6E4FF),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0] : '؟',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ShamsColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _MenuButton — زر النقاط الثلاث (...)
// ─────────────────────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _MenuButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFEEF0F4)),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: ShamsColors.textGray,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PageIndicatorBadge — شارة (1/2) فوق الصور
// ─────────────────────────────────────────────────────────────────────────────

class _PageIndicatorBadge extends StatelessWidget {
  final int current;
  final int total;

  const _PageIndicatorBadge({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$current/$total',
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ActionChip — زر تفاعل (إعجاب / تعليق / مشاركة)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final VoidCallback? onTap;
  final bool isAnimated;

  const _ActionChip({
    required this.icon,
    required this.count,
    required this.color,
    this.onTap,
    this.isAnimated = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(icon, key: ValueKey(icon), size: 22, color: color),
          ),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              _formatCount(count),
              key: ValueKey(count),
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
