import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// A horizontally scrollable image picker that supports an unlimited number
/// of images.  The trailing slot is always an "Add" button.
///
/// ```dart
/// ScrollableImagePicker(
///   images: _images,
///   onAddTap: _pickAndAdd,
///   onRemoveTap: (i) => setState(() => _images.removeAt(i)),
/// )
/// ```
class ScrollableImagePicker extends StatelessWidget {
  /// The list of already-picked images to display.
  final List<File> images;

  /// Called when the user taps the "+" add button.
  final VoidCallback onAddTap;

  /// Called when the user taps the remove (×) badge on an image.
  final void Function(int index) onRemoveTap;

  /// Side length of each image thumbnail (and the add button).
  final double imageSize;

  const ScrollableImagePicker({
    super.key,
    required this.images,
    required this.onAddTap,
    required this.onRemoveTap,
    this.imageSize = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageSize + 10, // +10 for the remove badge overflow
      child: Directionality(
        // Keep the scroll direction LTR so the "+" button is always on the
        // right end, regardless of the app's RTL locale.
        textDirection: TextDirection.ltr,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          itemCount: images.length + 1,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index == images.length) {
              return _AddImageButton(size: imageSize, onTap: onAddTap);
            }
            return _ImageThumbnail(
              file: images[index],
              size: imageSize,
              onRemove: () => onRemoveTap(index),
            );
          },
        ),
      ),
    );
  }
}

// ─── Thumbnail ────────────────────────────────────────────────────────────────

class _ImageThumbnail extends StatelessWidget {
  final File file;
  final double size;
  final VoidCallback onRemove;

  const _ImageThumbnail({
    required this.file,
    required this.size,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ShamsColors.solarYellow, width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.file(file, fit: BoxFit.cover),
        ),
        // Remove badge
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: ShamsColors.dangerRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 13),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Add Button ───────────────────────────────────────────────────────────────

class _AddImageButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;

  const _AddImageButton({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ShamsColors.solarYellow.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              color: ShamsColors.solarYellow,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'إضافة',
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: ShamsColors.solarYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
