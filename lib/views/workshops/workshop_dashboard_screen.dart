import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/post_model.dart';
import '../../models/workshop_data.dart';
import '../../providers/workshop_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/managed_post_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scrollable_image_picker.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class WorkshopDashboardScreen extends StatefulWidget {
  /// Optional workshop data passed from the Add Workshop form.
  final WorkshopData? workshopData;

  const WorkshopDashboardScreen({super.key, this.workshopData});

  @override
  State<WorkshopDashboardScreen> createState() =>
      _WorkshopDashboardScreenState();
}

class _WorkshopDashboardScreenState extends State<WorkshopDashboardScreen> {
  final ImagePicker _picker = ImagePicker();

  // ── Local image state (overrides workshopData when user picks new ones) ──────
  File? _coverImage;
  File? _profileImage;
  List<File> _extraImages = [];

  // ── Editable workshop info ────────────────────────────────────────────────
  late String _workshopName;
  late String _workshopHandle;
  late String _workshopCity;

  @override
  void initState() {
    super.initState();
    final d = widget.workshopData;
    _coverImage = d?.coverImage;
    _profileImage = d?.profileImage;
    _extraImages = List.from(d?.extraImages ?? []);
    _workshopName = d?.name ?? 'ورشتي على شمس';
    _workshopHandle =
        d?.username != null ? '@${d!.username}' : '@workshop';
    _workshopCity = d?.city ?? 'صنعاء، اليمن';
  }

  // ── Image pickers ─────────────────────────────────────────────────────────

  Future<void> _pickCoverImage() async {
    _showImageSourceSheet(onPicked: (file) {
      setState(() => _coverImage = file);
    });
  }

  Future<void> _pickProfileImage() async {
    _showImageSourceSheet(onPicked: (file) {
      setState(() => _profileImage = file);
    });
  }

  Future<void> _pickAndAddImage() async {
    _showImageSourceSheet(onPicked: (file) {
      setState(() => _extraImages.add(file));
    });
  }

  void _showImageSourceSheet({required void Function(File file) onPicked}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: ShamsColors.handleBar,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildSheetOption(
                  icon: Icons.photo_library_outlined,
                  label: 'اختر من المعرض',
                  color: ShamsColors.primaryBlue,
                  onTap: () async {
                    Navigator.pop(ctx);
                    final xf = await _picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (xf != null) onPicked(File(xf.path));
                  },
                ),
                _buildSheetOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'التقط صورة',
                  color: ShamsColors.solarYellow,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final xf = await _picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 85,
                      );
                      if (xf != null) onPicked(File(xf.path));
                    } catch (_) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'الكاميرا غير متاحة على هذا الجهاز.',
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: GoogleFonts.tajawal(fontSize: 15)),
    );
  }

  // ── Cities list (mirrors AddWorkshopScreen) ─────────────────────────────

  static const List<String> _cities = [
    'أمانة العاصمة', 'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'حضرموت', 'ذمار',
    'عمران', 'الضالع', 'لحج', 'أبين', 'المهرة', 'شبوة', 'البيضاء', 'مأرب',
    'الجوف', 'صعدة', 'المحويت', 'حجة', 'ريمة', 'سقطرى',
  ];

  // ── Edit workshop info bottom sheet ──────────────────────────────────────

  void _showEditWorkshopSheet() {
    final nameCtrl = TextEditingController(text: _workshopName);
    final handleCtrl = TextEditingController(
      text: _workshopHandle.replaceFirst('@', ''),
    );
    // تحديد المدينة الحالية إذا كانت موجودة في القائمة
    String? selectedCity = _cities.contains(_workshopCity) ? _workshopCity : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        // StatefulBuilder لإعادة بناء الـ dropdown عند تغيير الاختيار
        child: StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مقبض
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: ShamsColors.handleBar,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'تعديل ملف الورشة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditField(
                  controller: nameCtrl,
                  label: 'اسم الورشة',
                  icon: Icons.store_outlined,
                ),
                const SizedBox(height: 14),
                _buildEditField(
                  controller: handleCtrl,
                  label: 'اسم المستخدم',
                  icon: Icons.alternate_email_rounded,
                  prefix: '@',
                ),
                const SizedBox(height: 14),

                // ── Dropdown المحافظة ──────────────────────────────────────
                Text(
                  'المحافظة',
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: ShamsColors.textHint,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: ShamsColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedCity != null
                          ? ShamsColors.primaryBlue
                          : ShamsColors.borderLight,
                      width: selectedCity != null ? 1.5 : 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCity,
                      isExpanded: true,
                      hint: Text(
                        'اختر المحافظة',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: ShamsColors.primaryBlue,
                      ),
                      items: _cities
                          .map(
                            (city) => DropdownMenuItem<String>(
                              value: city,
                              child: Text(
                                city,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: ShamsColors.textGray,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setSheetState(() => selectedCity = v),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (nameCtrl.text.trim().isNotEmpty) {
                          _workshopName = nameCtrl.text.trim();
                        }
                        if (handleCtrl.text.trim().isNotEmpty) {
                          _workshopHandle = '@${handleCtrl.text.trim()}';
                        }
                        if (selectedCity != null) {
                          _workshopCity = selectedCity!;
                        }
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ معلومات الورشة بنجاح',
                            style: GoogleFonts.tajawal(),
                          ),
                          backgroundColor: ShamsColors.verifiedGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ShamsColors.solarYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'حفظ التعديلات',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? prefix,
  }) {
    return TextField(
      controller: controller,
      style: GoogleFonts.tajawal(fontSize: 14, color: ShamsColors.textGray),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.tajawal(color: ShamsColors.textHint),
        prefixIcon: Icon(icon, color: ShamsColors.primaryBlue, size: 20),
        prefixText: prefix,
        prefixStyle: GoogleFonts.tajawal(
          color: ShamsColors.textGray,
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: ShamsColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ShamsColors.primaryBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────

  void _confirmDelete(PostModel post) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'حذف المنشور',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا المنشور؟ لا يمكن التراجع عن هذا الإجراء.',
            style: GoogleFonts.tajawal(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: ShamsColors.textHint),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: GoogleFonts.tajawal(color: ShamsColors.dangerRed),
              ),
            ),
          ],
        ),
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<WorkshopProvider>().deletePost(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف المنشور بنجاح', style: GoogleFonts.tajawal()),
            backgroundColor: ShamsColors.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
 @override
  Widget build(BuildContext context) {
    // 💡 التعديل الجديد: تعريف المتغير الذي يراقب حالة الورشة
    final workshopState = context.watch<WorkshopProvider>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: ShamsColors.textGray,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'لوحة تحكم الورشة',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ShamsColors.textGray,
            ),
          ),
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── 1. الرأس ──
              _buildHeader(),

              // ── 2. معلومات الورشة ──
              _buildWorkshopInfo(),
              const SizedBox(height: 16),

              // ── صور الورشة الإضافية ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'صور الورشة',
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${_extraImages.length})',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: ShamsColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ScrollableImagePicker(
                  images: _extraImages,
                  onAddTap: _pickAndAddImage,
                  onRemoveTap: (i) => setState(() => _extraImages.removeAt(i)),
                ),
              ),
              const SizedBox(height: 24),

              // ── 3. زر تعديل ملف الورشة ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: CustomSolidButton(
                    title: 'تعديل ملف الورشة',
                    onPressed: _showEditWorkshopSheet,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 4. Stats bar (شريط الإحصائيات) ──
              Divider(color: Colors.grey.shade200, height: 1),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _buildStatColumn(
                      '1.2K',
                      'المتابعون',
                      Icons.people_alt_outlined,
                    ),
                    VerticalDivider(
                      color: Colors.grey.shade200,
                      width: 1,
                      thickness: 1,
                    ),
                    _buildStatColumn(
                      '${workshopState.postCount}', // 💡 استخدام مباشر للمتغير
                      'المنشورات',
                      Icons.article_outlined,
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 24),

              // ── 5. سجل الأعمال المنشور ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سجل الأعمال المنشور',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ShamsColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 💡 حذفنا الـ Consumer واستخدمنا Builder عادي للترتيب التنظيمي فقط
                    Builder(
                      builder: (context) {
                        // 💡 استخدام المتغير لقراءة مصفوفة المنشورات
                        final posts = workshopState.posts;

                        if (posts.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 48,
                                    color: ShamsColors.primaryBlue
                                        .withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'لا توجد أعمال منشورة حالياً.\nاضغط "نشر عمل جديد" للبدء!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.tajawal(
                                      fontSize: 14,
                                      color: ShamsColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return ManagedPostCard(
                              content: post.textDetails,
                              timeAgo: post.createdAt,
                              viewsCount: post.viewsCount,
                              imagePaths: post.images,
                              isLocalFile: post.isLocalFile,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditPostScreen(post: post),
                                  ),
                                );
                              },
                              onDelete: () => _confirmDelete(post),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),

        // ── زر نشر عمل جديد ──
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShamsColors.solarYellow,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  'نشر عمل جديد',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header: cover + avatar with tappable camera badges ───────────────────

  Widget _buildHeader() {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // صورة الغلاف
          GestureDetector(
            onTap: _pickCoverImage,
            child: Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: _coverImage != null
                      ? Image.file(_coverImage!, fit: BoxFit.cover)
                      : Container(
                          color:
                              ShamsColors.primaryBlue.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.image_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // طبقة شفافة للنقر على صورة الغلاف
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildCameraBadge(),
                ),
              ],
            ),
          ),

          // الصورة الشخصية
          Positioned(
            top: 100,
            child: GestureDetector(
              onTap: _pickProfileImage,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: _profileImage != null
                        ? ClipOval(
                            child: Image.file(
                              _profileImage!,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircleAvatar(
                            radius: 45,
                            backgroundColor: Color(0xFFF0F2F5),
                            child: Icon(
                              Icons.store_rounded,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  _buildCameraBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopInfo() {
    return Column(
      children: [
        Text(
          _workshopName,
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ShamsColors.textGray,
          ),
        ),
        Text(
          _workshopHandle,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            color: ShamsColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: ShamsColors.textGray,
            ),
            const SizedBox(width: 4),
            Text(
              _workshopCity,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: ShamsColors.textGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCameraBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        size: 16,
        color: ShamsColors.textGray,
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, IconData icon) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, size: 16, color: ShamsColors.textGray),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: const Color(0xFF9EA3B0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
