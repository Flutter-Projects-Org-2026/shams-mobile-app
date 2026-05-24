import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ManagedPostCard extends StatefulWidget {
  final String content;
  final String timeAgo;
  final String viewsCount;
  final int likesCount;
  final List<String> imagePaths;
  final bool isLocalFile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManagedPostCard({
    super.key,
    required this.content,
    required this.timeAgo,
    required this.viewsCount,
    this.likesCount = 0,
    required this.imagePaths,
    this.isLocalFile = false,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ManagedPostCard> createState() => _ManagedPostCardState();
}

class _ManagedPostCardState extends State<ManagedPostCard> {
  int _currentPage = 0;

  /// Returns true when [path] has a common video file extension.
  static bool _isVideoPath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.3gp');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ShamsColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. الرأس: القائمة المنسدلة + الوقت ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // القائمة المنسدلة الثلاثية (...)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: ShamsColors.textGray,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  onSelected: (value) {
                    if (value == 'edit') widget.onEdit();
                    if (value == 'delete') widget.onDelete();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        'تعديل',
                        style: GoogleFonts.tajawal(fontSize: 14),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'حذف',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                // شارة الوقت (مثال: منذ يومين)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.timeAgo,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: const Color(0xFF9EA3B0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 2. نص المنشور ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.content,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ShamsColors.textGray,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── 3. قسم الصور (سلايدر للصور المتعددة) ──
          if (widget.imagePaths.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 220,
                  width: double.infinity,
                  child: Stack(
                    children: [
                       PageView.builder(
                        itemCount: widget.imagePaths.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final path = widget.imagePaths[index];
                          // فيديو — نعرض thumbnail مميز بدلاً من الصورة
                          if (_isVideoPath(path)) {
                            return _buildVideoPlaceholder();
                          }
                          final isNetwork = path.startsWith('http') || path.startsWith('https');
                          if (isNetwork) {
                            return Image.network(
                              path,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholder(),
                            );
                          }
                          // صورة محلية من الجهاز (مسار يبدأ بـ /)
                          final isLocal = path.startsWith('/') ||
                              path.startsWith('file://');
                          return isLocal
                              ? Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                )
                              : Image.asset(
                                  path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(),
                                );
                        },
                      ),

                      // عداد الصور (يسار تحت)
                      if (widget.imagePaths.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPage + 1}/${widget.imagePaths.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: Color(0xFF9EA3B0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.viewsCount,
                      style: GoogleFonts.tajawal(
                        color: const Color(0xFF9EA3B0),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_border_rounded,
                      size: 16,
                      color: Color(0xFF9EA3B0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.likesCount}',
                      style: GoogleFonts.tajawal(
                        color: const Color(0xFF9EA3B0),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, color: Colors.grey, size: 50),
    );
  }

  /// واجهة مميزة لعرض مكان الفيديو — بدون حزمة video_player
  Widget _buildVideoPlaceholder() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // نمط خطوط شبكي خفيف
          CustomPaint(painter: _GridPainter()),
          // أيقونة التشغيل في المنتصف
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
          // بطاقة "فيديو" في الأسفل يسار
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'فيديو',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
}

// ── خلفية شبكية للفيديو ──────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
