import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class WorkshopCard extends StatefulWidget {
  final String username;
  final String userHandle; // جديد: معرف المستخدم مثل @techzone_sa
  final String imagePath; // صورة الملف الشخصي الدائرية
  final String coverImagePath; // جديد: صورة الغلاف العلوية للورشة
  final String cityName;
  final double rating;
  final bool isFollowing;
  final int? followersCount; // يمكن الاستغناء عنه لاحقاً إذا لم يكن في التصميم
  final ValueChanged<bool>? onFollowToggle;
  final VoidCallback? onEnterTap; // جديد: أمر الضغط على زر دخول الورشة
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

  Future<void> _handleFollowTap() async {
    await _followAnimController.reverse();
    await _followAnimController.forward();
    setState(() => _isFollowing = !_isFollowing);
    widget.onFollowToggle?.call(_isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetworkAvatar = widget.imagePath.startsWith('http');
    final bool isNetworkCover = widget.coverImagePath.startsWith('http');

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ShamsColors.bgWhite,
          borderRadius: BorderRadius.circular(16), // حواف دائرية أنعم
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
            // ── 1. قسم الصور (الغلاف + الدائرية) ─────────────────────────
            _buildImagesSection(isNetworkCover, isNetworkAvatar),

            // ── 2. قسم النصوص والبيانات ──────────────────────────────────
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  // بناء قسم الصور (تداخل الصورة الشخصية مع الغلاف)
  Widget _buildImagesSection(bool isNetworkCover, bool isNetworkAvatar) {
    return SizedBox(
      height: 140, // 110 للغلاف + 30 لبروز الصورة الشخصية للأسفل
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // صورة الغلاف
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              color: const Color(0xFFEEF0F4), // لون احتياطي
              image: DecorationImage(
                image: isNetworkCover
                    ? NetworkImage(widget.coverImagePath) as ImageProvider
                    : AssetImage(widget.coverImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // الصورة الشخصية الدائرية (على اليمين وتبرز للأسفل)
          Positioned(
            bottom: 0,
            right: 16,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ShamsColors.bgWhite, // خلفية بيضاء قبل الصورة
                border: Border.all(
                  color: ShamsColors.bgWhite,
                  width: 3,
                ), // إطار أبيض
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: isNetworkAvatar
                    ? Image.network(widget.imagePath, fit: BoxFit.cover)
                    : Image.asset(widget.imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء قسم النصوص والأزرار
  Widget _buildInfoSection() {
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
              color: ShamsColors.textGray,
            ),
          ),
          Text(
            widget.userHandle,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9EA3B0),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF9EA3B0),
              ),
              const SizedBox(width: 4),
              Text(
                widget.cityName,
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9EA3B0),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: ShamsColors.solarYellow,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.rating}/5',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ShamsColors.solarYellow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── صف الأزرار الجديد والمضمون ──
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // يضمن توزيع المساحات
            children: [
              // هذه هي المسافة الإجبارية الفاصلة بين الزرين
              Expanded(
                child: ScaleTransition(
                  scale: _followScaleAnim,
                  child: _ActionBtn(
                    label: _isFollowing ? 'إلغاء المتابعة' : 'متابعة',
                    isPrimary: !_isFollowing,
                    onTap: _handleFollowTap,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ActionBtn(
                  label: 'دخول الورشة',
                  isPrimary: true,
                  onTap: widget.onEnterTap ?? () {},
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
// زر الإجراءات الموحد (Action Button) - مصمم ليطابق التصميم الأصفر
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ), // تم تصغير الزر ليكون أنيقاً
        decoration: BoxDecoration(
          color: isPrimary ? ShamsColors.solarYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? ShamsColors.solarYellow
                : const Color(0xFFD0D5DD),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isPrimary ? ShamsColors.bgWhite : const Color(0xFF9EA3B0),
          ),
        ),
      ),
    );
  }
}
