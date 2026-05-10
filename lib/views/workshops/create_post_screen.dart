import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MediaFile — نموذج للملفات المرفقة
// ─────────────────────────────────────────────────────────────────────────────

class MediaFile {
  final String path;
  final bool isVideo;
  final bool isAsset;

  MediaFile({required this.path, this.isVideo = false, this.isAsset = false});
}

// ─────────────────────────────────────────────────────────────────────────────
// CreatePostScreen — شاشة إضافة عمل جديد
// ─────────────────────────────────────────────────────────────────────────────

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  // ── State ──────────────────────────────────────────────────────────────────

  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  /// قائمة تمثّل الملفات المرفقة (صور أو فيديوهات)
  final List<MediaFile> _attachments = [];

  bool _isHighlighted = true;

  // ── Dispose ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// دالة لاختيار الصور أو الفيديوهات
  Future<void> _pickMedia() async {
    print("Attempting to pick media..."); // رسالة للتأكد من وصول النقرة

    // لإظهار الخيارات بشكل سريع وبسيط
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'إضافة مرفق',
            style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'اختر نوع الملف الذي تريد إرفاقه:',
            style: GoogleFonts.tajawal(),
          ),
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
    print("Picking ${isVideo ? 'Video' : 'Image'} from $source");

    try {
      XFile? file;
      if (isVideo) {
        file = await _picker.pickVideo(source: source);
      } else {
        file = await _picker.pickImage(source: source);
      }

      if (file != null) {
        print("File picked: ${file.path}");
        setState(() {
          _attachments.add(MediaFile(path: file!.path, isVideo: isVideo));
        });
      } else {
        print("No file selected.");
      }
    } catch (e) {
      print("Error during picking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "عذراً، الكاميرا أو هذه الميزة قد لا تكون مدعومة على هذا النظام حالياً.",
          ),
        ),
      );
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _publish() {
    if (_contentController.text.isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إضافة محتوى أو صورة للمنشور')),
      );
      return;
    }

    // تجهيز بيانات المنشور الجديد لإعادتها للشاشة السابقة
    final newPost = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': _contentController.text,
      'timeAgo': 'الآن',
      'viewsCount': '0',
      'imagePaths': _attachments.map((a) => a.path).toList(),
      'isLocalFile': _attachments.isNotEmpty && !_attachments.first.isAsset,
    };

    Navigator.pop(context, newPost);
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
                    // 1. قسم رفع الصور والفيديو
                    _buildUploadSection(),

                    const SizedBox(height: 24),

                    // 2. قائمة الملفات المرفقة
                    if (_attachments.isNotEmpty) _buildAttachmentsList(),

                    const SizedBox(height: 24),

                    // 3. حقل تفاصيل المنشور
                    _buildContentField(),

                    const SizedBox(height: 24),

                    // 4. خيار التمييز
                    _buildHighlightToggle(),

                    const SizedBox(height: 12),

                    // 5. تلميح
                    _buildHint(),
                  ],
                ),
              ),
            ),
            _buildPublishButton(),
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
        'إضافة عمل جديد',
        style: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: ShamsColors.textGray,
        ),
      ),
      // زر الرجوع (يمين في RTL)
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_forward_rounded,
          color: ShamsColors.textGray,
        ),
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
                      child: const Icon(
                        Icons.add,
                        size: 14,
                        color: Colors.black,
                      ),
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

  Widget _buildAttachmentsList() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _AttachmentThumbnail(
            media: _attachments[index],
            onRemove: () => _removeAttachment(index),
          );
        },
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تمييز المنشور في البروفايل',
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'سيظهر في أعلى صفحتك الشخصية',
                  style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey),
                ),
              ],
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

  Widget _buildHint() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'المنشورات المميزة تساعدك في الوصول لأفضل أعمالك بسرعة أكبر',
              style: GoogleFonts.tajawal(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPublishButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _publish,
          style: ElevatedButton.styleFrom(
            backgroundColor: ShamsColors.solarYellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'نشر العمل الآن',
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

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ShamsColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AttachmentThumbnail — مصغرة للمرفق (صورة أو فيديو)
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentThumbnail extends StatelessWidget {
  final MediaFile media;
  final VoidCallback onRemove;

  const _AttachmentThumbnail({required this.media, required this.onRemove});

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
            child: Stack(
              fit: StackFit.expand,
              children: [
                // عرض الصورة أو أيقونة الفيديو
                media.isVideo
                    ? const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.purple,
                          size: 40,
                        ),
                      )
                    : Image.file(
                        File(media.path),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                // ملصق صغير إذا كان فيديو
                if (media.isVideo)
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'فيديو',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
}
