import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/workshop_data.dart';
import '../../utils/constants.dart';
import '../../widgets/managed_post_card.dart';
import '../../widgets/primary_button.dart';
import 'create_post_screen.dart';
import 'edit_post_screen.dart';

class WorkshopDashboardScreen extends StatefulWidget {
  /// Optional workshop data passed from the Add Workshop form.
  /// When null, the screen shows placeholder/default values.
  final WorkshopData? workshopData;

  const WorkshopDashboardScreen({super.key, this.workshopData});

  @override
  State<WorkshopDashboardScreen> createState() =>
      _WorkshopDashboardScreenState();
}

class _WorkshopDashboardScreenState extends State<WorkshopDashboardScreen> {
  // ── Sample published posts ──────────────────────────────────────────────────
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'content':
          'إصلاح شامل لمحرك سيارة دفع رباعي مع تنظيف الأجزاء الداخلية وزيادة كفاءة الأداء بنسبة 20%',
      'timeAgo': 'منذ يومين',
      'viewsCount': '45.8K',
      'imagePaths': ['assets/images/engine1.jpg'],
    },
    {
      'id': '2',
      'content':
          'تغيير فلاتر الزيت والهواء لسيارة تويوتا كامري في وقت قياسي لضمان راحة العميل.',
      'timeAgo': 'منذ 4 أيام',
      'viewsCount': '12.3K',
      'imagePaths': ['assets/images/engine2.jpg'],
    },
    {
      'id': '3',
      'content':
          'فحص كمبيوتر شامل لبرمجة السيارة وتحديد الأعطال الكهربائية بدقة متناهية.',
      'timeAgo': 'منذ أسبوع',
      'viewsCount': '8.1K',
      'imagePaths': ['assets/images/engine3.jpg'],
    },
  ];

  void _deletePost(int index) {
    setState(() => _posts.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المنشور بنجاح', style: GoogleFonts.tajawal()),
        backgroundColor: ShamsColors.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Convenience getters ─────────────────────────────────────────────────────

  WorkshopData? get _data => widget.workshopData;

  String get _workshopName => _data?.name ?? 'ورشتي على شمس';
  String get _workshopHandle => _data?.username != null ? '@${_data!.username}' : '@workshop';
  String get _workshopCity => _data?.city ?? '';
  String get _workshopDescription => _data?.description ?? '';
  int get _yearsExp => _data?.yearsOfExperience ?? 0;
  File? get _coverImage => _data?.coverImage;
  File? get _profileImage => _data?.profileImage;
  List<File> get _extraImages => _data?.extraImages ?? [];

  @override
  Widget build(BuildContext context) {
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
              // ── 1. الرأس (صورة الغلاف، الصورة الشخصية، والمعلومات) ──
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // صورة الغلاف + أيقونة الكاميرا
                    Stack(
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          color: ShamsColors.primaryBlue.withOpacity(0.1),
                          child: const Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.grey,
                          ), // استبدلها بصورة الغلاف لاحقاً
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: _buildCameraBadge(),
                        ),
                      ],
                    ),

                    // الصورة الشخصية + أيقونة الكاميرا
                    Positioned(
                      top: 100,
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 45,
                              backgroundColor: Color(0xFFF0F2F5),
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey,
                              ), // استبدلها بصورة الورشة
                            ),
                          ),
                          _buildCameraBadge(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // معلومات الورشة
              Text(
                'كراج المجد التقني',
                style: GoogleFonts.tajawal(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.textGray,
                ),
              ),
              Text(
                '@al_majd_tech',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  color: const Color(0xFF9EA3B0),
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
                    'صنعاء، اليمن - شارع الستين',
                    style: GoogleFonts.tajawal(
                      fontSize: 12,
                      color: ShamsColors.textGray,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // زر تعديل ملف الورشة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: CustomSolidButton(
                    title: 'تعديل ملف الورشة',
                    onPressed: () {},
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 4. Stats bar ───────────────────────────────────────────────
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
                    _buildStatColumn('89', 'المنشورات', Icons.article_outlined),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 24),

              // ── 3. سجل الأعمال المنشور (ديناميكي) ──
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

                    if (_posts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'لا توجد أعمال منشورة حالياً.',
                            style: GoogleFonts.tajawal(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true, // مهم جداً داخل SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // تعطيل سكرول القائمة الداخلية
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return ManagedPostCard(
                            content: post['content'],
                            timeAgo: post['timeAgo'],
                            viewsCount: post['viewsCount'],
                            imagePaths: List<String>.from(
                              post['imagePaths'] ?? [],
                            ),
                            isLocalFile: post['isLocalFile'] ?? false,
                            onEdit: () async {
                              final updated = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPostScreen(post: post),
                                ),
                              );
                              if (updated != null &&
                                  updated is Map<String, dynamic>) {
                                setState(() => _posts[index] = updated);
                              }
                            },
                            onDelete: () =>
                                _deletePost(index), // استدعاء دالة الحذف
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ), // مساحة إضافية لكي لا يغطي الزر السفلي المحتوى
            ],
          ),
        ),

        // ── Sticky "Publish" button ────────────────────────────────────────────
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );

                  if (result != null && result is Map<String, dynamic>) {
                    setState(() {
                      _posts.insert(0, result);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ShamsColors.solarYellow,
                  foregroundColor: Colors.white,
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

  // ─── Header: cover image + avatar ──────────────────────────────────────────

  Widget _buildHeader() {
    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Cover image
          Stack(
            children: [
              // Cover container
              SizedBox(
                height: 150,
                width: double.infinity,
                child: _coverImage != null
                    ? Image.file(_coverImage!, fit: BoxFit.cover)
                    : Container(
                        color: ShamsColors.primaryBlue.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
              // Camera badge top-right
              Positioned(
                top: 16,
                right: 16,
                child: _buildCameraBadge(),
              ),
            ],
          ),

          // Avatar
          Positioned(
            top: 100,
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
        ],
      ),
    );
  }

  // ─── Workshop name, handle, city ───────────────────────────────────────────

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
        if (_workshopCity.isNotEmpty) ...[
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
      ],
    );
  }

  // ─── Description section ────────────────────────────────────────────────────

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: ShamsColors.solarYellow,
              ),
              const SizedBox(width: 6),
              Text(
                'عن الورشة',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ShamsColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShamsColors.borderLight),
            ),
            child: Text(
              _workshopDescription,
              style: GoogleFonts.tajawal(
                fontSize: 13.5,
                height: 1.65,
                color: ShamsColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Extra images grid ──────────────────────────────────────────────────────

  Widget _buildExtraImagesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 18,
                color: ShamsColors.solarYellow,
              ),
              const SizedBox(width: 6),
              Text(
                'صور الورشة',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _extraImages.map((file) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ShamsColors.borderLight),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Image.file(file, fit: BoxFit.cover),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── Published posts section ────────────────────────────────────────────────

  Widget _buildPostsSection() {
    return Padding(
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
          if (_posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.article_outlined,
                      size: 48,
                      color: ShamsColors.primaryBlue.withValues(alpha: 0.2),
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
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return ManagedPostCard(
                  content: post['content'],
                  timeAgo: post['timeAgo'],
                  viewsCount: post['viewsCount'],
                  imagePath: post['imagePath'],
                  onEdit: () {},
                  onDelete: () => _deletePost(index),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildCameraBadge() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: const Icon(
        Icons.camera_alt_outlined,
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
