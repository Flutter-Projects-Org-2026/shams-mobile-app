import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

/// Shows a modal bottom sheet with Gallery / Camera options.
/// Returns the chosen [ImageSource], or `null` if dismissed.
Future<ImageSource?> showImageSourceSheet(BuildContext context) async {
  ImageSource? source;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: ShamsColors.handleBar,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            _ImageSourceTile(
              icon: Icons.photo_library_outlined,
              label: 'اختر من المعرض',
              onTap: () {
                source = ImageSource.gallery;
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _ImageSourceTile(
              icon: Icons.camera_alt_outlined,
              label: 'التقط صورة',
              onTap: () {
                source = ImageSource.camera;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );

  return source;
}

// ─── Private tile widget ──────────────────────────────────────────────────────

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: ShamsColors.solarYellow),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: ShamsColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
