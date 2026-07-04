import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class WorkshopCard extends StatefulWidget {
  final String username;
  final String userHandle;
  final String imagePath;
  final String coverImagePath;
  final String cityName;
  final double rating;
  final bool isFollowing;
  final int? followersCount;
  final ValueChanged<bool>? onFollowToggle;
  final VoidCallback? onEnterTap;
  final VoidCallback? onTap;

  const WorkshopCard({
    super.key,
    required this.username,
    required this.userHandle,
    required this.imagePath,
    required this.coverImagePath,
    required this.cityName,
    required this.rating,
    required this.isFollowing,
    this.followersCount,
    this.onFollowToggle,
    this.onEnterTap,
    this.onTap,
  }) : assert(rating >= 0.0 && rating <= 5.0, 'rating must be between 0 and 5');

  @override
  State<WorkshopCard> createState() => _WorkshopCardState();
}

class _WorkshopCardState extends State<WorkshopCard>
    with SingleTickerProviderStateMixin {
  late bool _isFollowing;
  late AnimationController _followAnimController;
  late Animation<double> _followScaleAnim;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
    _followAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _followScaleAnim = _followAnimController;
  }

  @override
  void didUpdateWidget(WorkshopCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      _isFollowing = widget.isFollowing;
    }
  }

  @override
  void dispose() {
    _followAnimController.dispose();
    super.dispose();
  }

  Widget _buildCoverImage(
      String path, ShamsExtendedColors ext, ColorScheme colorScheme) {
    final placeholder = Container(
      color: ext.imageErrorPlaceholder,
      child: Center(
        child: Icon(Icons.broken_image_outlined,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
      ),
    );

    if (path.isEmpty) return placeholder;
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder);
    } else if (path.startsWith('assets/')) {
      return Image.asset(path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder);
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => placeholder);
      }
      return placeholder;
    }
  }

  Widget _buildProfileImage(
      String path, String name, ShamsExtendedColors ext, ColorScheme colorScheme) {
    if (path.isEmpty) return _buildFallbackAvatar(name, ext, colorScheme);
    if (path.startsWith('http')) {
      return Image.network(path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackAvatar(name, ext, colorScheme));
    } else if (path.startsWith('assets/')) {
      return Image.asset(path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallbackAvatar(name, ext, colorScheme));
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _buildFallbackAvatar(name, ext, colorScheme));
      }
      return _buildFallbackAvatar(name, ext, colorScheme);
    }
  }

  Widget _buildFallbackAvatar(
      String name, ShamsExtendedColors ext, ColorScheme colorScheme) {
    return Container(
      color: ext.avatarFallbackBg,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '؟',
          style: GoogleFonts.tajawal(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _handleFollowTap() async {
    await _followAnimController.reverse();
    await _followAnimController.forward();
    setState(() => _isFollowing = !_isFollowing);
    widget.onFollowToggle?.call(_isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ext.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagesSection(ext, colorScheme),
            _buildInfoSection(colorScheme, ext),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection(ShamsExtendedColors ext, ColorScheme colorScheme) {
    return SizedBox(
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              color: ext.imageErrorPlaceholder,
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildCoverImage(widget.coverImagePath, ext, colorScheme),
          ),
          // Profile circle
          Positioned(
            bottom: 0,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ext.cardSurface,
                border: Border.all(color: ext.cardSurface, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildProfileImage(
                    widget.imagePath, widget.username, ext, colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme, ShamsExtendedColors ext) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.username,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            widget.userHandle,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                widget.cityName,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.star_rounded,
                  size: 16, color: colorScheme.secondary),
              const SizedBox(width: 4),
              Text(
                '${widget.rating}/5',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: _followScaleAnim,
                  child: _ActionBtn(
                    label: _isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                    isPrimary: !_isFollowing,
                    onTap: _handleFollowTap,
                    colorScheme: colorScheme,
                    ext: ext,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionBtn(
                  label: 'دخول الورشة',
                  isPrimary: true,
                  onTap: widget.onEnterTap ?? () {},
                  colorScheme: colorScheme,
                  ext: ext,
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
// _ActionBtn
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ShamsExtendedColors ext;

  const _ActionBtn({
    required this.label,
    required this.isPrimary,
    required this.onTap,
    required this.colorScheme,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isPrimary ? colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary ? colorScheme.secondary : colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isPrimary
                ? colorScheme.onSecondary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
