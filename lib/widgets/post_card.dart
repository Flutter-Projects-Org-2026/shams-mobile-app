import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// PostCard — بطاقة منشور تفاعلية بتصميم Shams Platform
import 'dart:io';

class PostCard extends StatefulWidget {
  final String username;
  final String userHandle;
  final String avatarPath;
  final String content;
  final List<String>? imagePaths;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final ValueChanged<bool>? onLikeToggle;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final VoidCallback? onMenuTap;
  final VoidCallback? onUserTap;
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
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: ext.cardSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.07),
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
          _buildHeader(colorScheme, ext),
          _buildContent(colorScheme),
          if (widget.imagePaths != null && widget.imagePaths!.isNotEmpty)
            _buildImageCarousel(ext),
          Divider(color: ext.dividerLight, thickness: 1, height: 1),
          _buildActions(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, ShamsExtendedColors ext) {
    final bool isNetwork = widget.avatarPath.startsWith('http');

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _MenuButton(onTap: widget.onMenuTap, ext: ext, colorScheme: colorScheme),
          const Spacer(),
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
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.userHandle,
                  style: GoogleFonts.tajawal(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.onUserTap,
            child: _Avatar(
              imagePath: widget.avatarPath,
              username: widget.username,
              isNetwork: isNetwork,
              colorScheme: colorScheme,
              ext: ext,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
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
                color: colorScheme.onSurface,
              ),
            ),
            secondChild: Text(
              widget.content,
              textAlign: TextAlign.right,
              style: GoogleFonts.tajawal(
                fontSize: 14.5,
                height: 1.65,
                color: colorScheme.onSurface,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
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
                    color: colorScheme.primary,
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

  Widget _buildImageCarousel(ShamsExtendedColors ext) {
    final images = widget.imagePaths!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
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
                      errorBuilder: (_, _, _) => _imagePlaceholder(ext),
                    );
                  } else if (path.startsWith('assets/')) {
                    return Image.asset(
                      path,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => _imagePlaceholder(ext),
                    );
                  } else {
                    final file = File(path);
                    if (file.existsSync()) {
                      return Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, _, _) => _imagePlaceholder(ext),
                      );
                    } else {
                      return _imagePlaceholder(ext);
                    }
                  }
                },
              ),
            ),
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

  Widget _imagePlaceholder(ShamsExtendedColors ext) {
    return Container(
      color: ext.imageErrorPlaceholder,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 48,
          color: ext.textHint.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildActions(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _ActionChip(
                icon: Icons.chat_bubble_outline_rounded,
                count: widget.commentsCount,
                color: colorScheme.onSurfaceVariant,
                onTap: widget.onCommentTap,
              ),
              const SizedBox(width: 18),
              ScaleTransition(
                scale: _likeScaleAnim,
                child: _ActionChip(
                  icon: _isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  count: _likesCount,
                  color: _isLiked
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
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

// ── _Avatar ────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String imagePath;
  final String username;
  final bool isNetwork;
  final ColorScheme colorScheme;
  final ShamsExtendedColors ext;

  const _Avatar({
    required this.imagePath,
    required this.username,
    required this.isNetwork,
    required this.colorScheme,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
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
      color: ext.avatarFallbackBg,
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0] : '؟',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// ── _MenuButton ──────────────────────────────────────────────────────────────

class _MenuButton extends StatelessWidget {
  final VoidCallback? onTap;
  final ShamsExtendedColors ext;
  final ColorScheme colorScheme;

  const _MenuButton({this.onTap, required this.ext, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: ext.borderLight),
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── _PageIndicatorBadge ───────────────────────────────────────────────────────

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

// ── _ActionChip ───────────────────────────────────────────────────────────────

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
