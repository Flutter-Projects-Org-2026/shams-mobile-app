import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';
import 'create_post_screen.dart'; // إعادة استخدام MediaFile و _AttachmentThumbnail

// ─────────────────────────────────────────────────────────────────────────────
// EditPostScreen — شاشة تعديل المنشور
// ─────────────────────────────────────────────────────────────────────────────

class EditPostScreen extends StatefulWidget {
  /// بيانات المنشور الأصلي المراد تعديله
  final Map<String, dynamic> post;

  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  late final TextEditingController _contentController;
  final ImagePicker _picker = ImagePicker();

  /// قائمة الوسائط المرفقة (مبدئياً من بيانات المنشور الأصلي)
  late List<MediaFile> _attachments;

  late bool _isHighlighted;

  // ── Init ───────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(
      text: widget.post['content'] ?? '',
    );
    _isHighlighted = widget.post['isHighlighted'] ?? false;

    // تحميل الصور الأصلية
    final List<String> existingPaths = widget.post['imagePaths'] != null 
        ? List<String>.from(widget.post['imagePaths']) 
        : (widget.post['imagePath'] != null ? [widget.post['imagePath']] : []);
        
    final isLocal = widget.post['isLocalFile'] ?? false;
    _attachments = existingPaths.map((p) => MediaFile(path: p, isAsset: !isLocal)).toList();
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickMedia() async {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'إضافة مرفق',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text('اختر طريقة الإرفاق:', style: GoogleFonts.tajawal()),
          actions: [
            TextButton(
              onPressed: () => _handlePick(ImageSource.gallery, false),
              child: Text(
                'المعرض (صور)',
                style: GoogleFonts.tajawal(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () => _handlePick(ImageSource.gallery, true),
              child: Text(
                'المعرض (فيديو)',
                style: GoogleFonts.tajawal(color: Colors.purple),
              ),
            ),
            TextButton(
              onPressed: () => _handlePick(ImageSource.camera, false),
              child: Text(
                'الكاميرا',
                style: GoogleFonts.tajawal(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.tajawal(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePick(ImageSource source, bool isVideo) async {
    Navigator.pop(context);
    try {
      final XFile? file = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(source: source);

      if (file != null) {
        setState(() {
          _attachments.add(MediaFile(path: file.path, isVideo: isVideo));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'عذراً، هذه الميزة غير مدعومة على هذا الجهاز حالياً.',
            ),
          ),
        );
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _save() {
    if (_contentController.text.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة محتوى أو صورة للمنشور')),
      );
      return;
    }

    // تجهيز بيانات المنشور المعدَّل لإعادتها للشاشة السابقة
    final updatedPost = {
      ...widget.post, // الاحتفاظ بجميع الحقول القديمة (ID، وقت النشر...إلخ)
      'content': _contentController.text,
      'isHighlighted': _isHighlighted,
      'imagePaths': _attachments.map((a) => a.path).toList(),
      'isLocalFile': _attachments.isNotEmpty && !_attachments.first.isAsset,
    };

    Navigator.pop(context, updatedPost);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: Column(
          children: [
            const Divider(
              height: 1,
              thickness: 1,
              color: ShamsColors.dividerLight,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. قسم رفع الصور والفيديو (نفس الموجود في الإنشاء)
                    _buildUploadSection(),

                    const SizedBox(height: 24),

                    // 2. قائمة الملفات المرفقة (الصور الحالية)
                    if (_attachments.isNotEmpty) _buildAttachmentsList(),

                    const SizedBox(height: 24),

                    // 3. حقل النص (مملوء مسبقاً)
                    _buildContentField(),

                    const SizedBox(height: 24),

                    // 3. خيار التمييز
                    _buildHighlightToggle(),
                  ],
                ),
              ),
            ),
            // 4. زر الحفظ السفلي الثابت
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        'تعديل المنشور',
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ShamsColors.textGray,
        ),
      ),
      // أيقونة إغلاق X (يمين في RTL)
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close_rounded, color: ShamsColors.textGray),
        tooltip: 'إغلاق',
      ),
    );
  }

  /// قسم الوسائط: الصور الحالية
  Widget _buildAttachmentsList() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _EditAttachmentThumbnail(
            media: _attachments[index],
            onRemove: () => _removeAttachment(index),
          );
        },
      ),
    );
  }

  Widget _buildUploadSection() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _pickMedia,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: Colors.black54,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: ShamsColors.solarYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'إرفاق صور أو فيديوهات',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ShamsColors.textGray,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'وثّق إنجازاتك في الطاقة الشمسية',
                style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تفاصيل المنشور',
          style: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: ShamsColors.textGray,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 5,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              color: ShamsColors.textGray,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب تفاصيل المنشور هنا',
              hintStyle: GoogleFonts.tajawal(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'تمييز المنشور',
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ShamsColors.textGray,
              ),
            ),
          ),
          Switch(
            value: _isHighlighted,
            onChanged: (val) => setState(() => _isHighlighted = val),
            activeColor: ShamsColors.solarYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: ShamsColors.solarYellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'حفظ التعديلات',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EditAttachmentThumbnail — مصغّرة الوسائط في شاشة التعديل
// ─────────────────────────────────────────────────────────────────────────────

class _EditAttachmentThumbnail extends StatelessWidget {
  final MediaFile media;
  final VoidCallback onRemove;

  const _EditAttachmentThumbnail({required this.media, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 85,
            height: 85,
            color: Colors.grey.shade100,
            child: _buildMediaPreview(),
          ),
        ),
        // أيقونة حذف حمراء في الزاوية العلوية
        Positioned(
          top: -5,
          right: -5,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    if (media.isVideo) {
      return const Center(
        child: Icon(
          Icons.play_circle_fill_rounded,
          color: Colors.purple,
          size: 40,
        ),
      );
    }
    if (media.isAsset) {
      return Image.asset(
        media.path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      );
    }
    return Image.file(
      File(media.path),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}
