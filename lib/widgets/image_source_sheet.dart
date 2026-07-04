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
    builder: (_) {
      final colorScheme = Theme.of(context).colorScheme;
      final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: ext.handleBar,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              _ImageSourceTile(
                icon: Icons.photo_library_outlined,
                label: 'اختر من المعرض',
                colorScheme: colorScheme,
                ext: ext,
                onTap: () {
                  source = ImageSource.gallery;
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _ImageSourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'التقط صورة',
                colorScheme: colorScheme,
                ext: ext,
                onTap: () {
                  source = ImageSource.camera;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  return source;
}

// ─── Private tile widget ────────────────────────────────────────────────────

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final ShamsExtendedColors ext;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.ext,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.secondary),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
