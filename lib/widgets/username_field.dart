import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Username Validator — pure logic, no Flutter dependency
// ─────────────────────────────────────────────────────────────────────────────

/// Validates a username against global standards.
///
/// Rules:
/// • 3–30 characters
/// • Only `a-z`, `A-Z`, `0-9`, `.` and `_`
/// • Cannot start or end with `.` or `_`
/// • No two consecutive special characters (`.`, `_`)
class UsernameValidator {
  UsernameValidator._();

  /// Returns an Arabic error message, or `null` if the value is valid.
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

  /// Returns `true` when the value passes all rules.
  static bool isValid(String value) => validate(value) == null;
}

// ─────────────────────────────────────────────────────────────────────────────
// UsernameField widget
// ─────────────────────────────────────────────────────────────────────────────

/// A styled text field for username input with real-time inline validation.
///
/// The parent is responsible for supplying the [controller] and reading
/// `UsernameValidator.validate(controller.text)` on form submission.
class UsernameField extends StatefulWidget {
  final TextEditingController controller;

  const UsernameField({super.key, required this.controller});

  @override
  State<UsernameField> createState() => _UsernameFieldState();
}

class _UsernameFieldState extends State<UsernameField> {
  String? _error;
  bool _touched = false; // only show errors after the first character

  void _onChanged(String value) {
    setState(() {
      _touched = value.isNotEmpty;
      _error = _touched ? UsernameValidator.validate(value) : null;
    });
  }

  bool get _isValid => _touched && _error == null;

  @override
  Widget build(BuildContext context) {
    final borderColor = !_touched
        ? Colors.grey.shade200
        : _isValid
            ? ShamsColors.verifiedGreen
            : ShamsColors.dangerRed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Input field ────────────────────────────────────────────────────
        TextField(
          controller: widget.controller,
          onChanged: _onChanged,
          // Force LTR so the "@" prefix and Latin characters display correctly
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            color: ShamsColors.textGray,
            letterSpacing: 0.3,
          ),
          decoration: InputDecoration(
            hintText: 'your_username',
            hintStyle: GoogleFonts.tajawal(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              child: Text(
                '@',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isValid
                      ? ShamsColors.verifiedGreen
                      : ShamsColors.textHint,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
            // Live status icon (checkmark / X)
            suffixIcon: _touched
                ? Icon(
                    _isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _isValid
                        ? ShamsColors.verifiedGreen
                        : ShamsColors.dangerRed,
                    size: 20,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
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

        // ── Inline rule feedback ───────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _buildFeedback(),
        ),
      ],
    );
  }

  Widget _buildFeedback() {
    if (!_touched) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          'مثال: ahmed_solar.99  |  3–30 حرفاً، إنجليزية فقط',
          style: GoogleFonts.tajawal(fontSize: 11, color: ShamsColors.textHint),
        ),
      );
    }

    if (_isValid) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 13,
              color: ShamsColors.verifiedGreen,
            ),
            const SizedBox(width: 4),
            Text(
              'اسم المستخدم متاح ومقبول',
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: ShamsColors.verifiedGreen,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 13, color: ShamsColors.dangerRed),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              _error ?? '',
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: ShamsColors.dangerRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
