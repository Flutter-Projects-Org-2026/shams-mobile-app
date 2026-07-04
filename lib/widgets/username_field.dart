import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Username Validator — pure logic, no Flutter dependency
// ─────────────────────────────────────────────────────────────────────────────

class UsernameValidator {
  UsernameValidator._();

  static String? validate(String value) {
    if (value.isEmpty) return 'اسم المستخدم مطلوب';
    if (value.length < 3) return 'يجب أن يكون 3 أحرف على الأقل';
    if (value.length > 30) return 'يجب ألا يتجاوز 30 حرفاً';

    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return 'يُسمح فقط بـ: أحرف إنجليزية، أرقام، نقطة، شرطة سفلية';
    }
    if (RegExp(r'^[._]').hasMatch(value)) {
      return 'لا يمكن أن يبدأ بنقطة أو شرطة سفلية';
    }
    if (RegExp(r'[._]$').hasMatch(value)) {
      return 'لا يمكن أن ينتهي بنقطة أو شرطة سفلية';
    }
    if (RegExp(r'[._]{2,}').hasMatch(value)) {
      return 'لا يمكن استخدام رمزين خاصين متتاليين';
    }
    return null;
  }

  static bool isValid(String value) => validate(value) == null;
}

// ─────────────────────────────────────────────────────────────────────────────
// UsernameField widget
// ─────────────────────────────────────────────────────────────────────────────

class UsernameField extends StatefulWidget {
  final TextEditingController controller;

  const UsernameField({super.key, required this.controller});

  @override
  State<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<UsernameField> {
  String? _error;
  bool _touched = false;

  void _onChanged(String value) {
    setState(() {
      _touched = value.isNotEmpty;
      _error = _touched ? UsernameValidator.validate(value) : null;
    });
  }

  bool get _isValid => _touched && _error == null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final Color borderColor = !_touched
        ? ext.borderLight
        : _isValid
            ? colorScheme.tertiary
            : colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: colorScheme.onSurface,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: 'your_username',
            hintStyle: GoogleFonts.tajawal(
              fontSize: 13,
              color: ext.textHint,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 13),
              child: Text(
                '@',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isValid ? colorScheme.tertiary : ext.textHint,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            suffixIcon: _touched
                ? Icon(
                    _isValid
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: _isValid ? colorScheme.tertiary : colorScheme.error,
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: ext.inputFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _buildFeedback(colorScheme, ext),
        ),
      ],
    );
  }

  Widget _buildFeedback(ColorScheme colorScheme, ShamsExtendedColors ext) {
    if (!_touched) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'مثال: ahmed_solar.99  |  3–30 حرفاً، إنجليزية فقط',
          style: GoogleFonts.tajawal(fontSize: 11, color: ext.textHint),
        ),
      );
    }

    if (_isValid) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 13, color: colorScheme.tertiary),
            const SizedBox(width: 4),
            Text(
              'اسم المستخدم متاح ومقبول',
              style: GoogleFonts.tajawal(
                  fontSize: 11, color: colorScheme.tertiary),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 13, color: colorScheme.error),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _error ?? '',
              style:
                  GoogleFonts.tajawal(fontSize: 11, color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
