import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class InlineSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  const InlineSearchBar({
    super.key,
    this.hintText = 'ابحث هنا...',
    this.onChanged,
    this.onClose,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      color: colorScheme.surface,
      padding: padding,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ext.borderLight,
            width: 1.2,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              size: 20,
              color: ext.textHint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    color: ext.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 6),
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, size: 20, color: ext.textHint),
              ),
          ],
        ),
      ),
    );
  }
}
