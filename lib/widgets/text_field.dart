import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? errorText; // متغير للتحكم بحالة الخطأ

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    // تحديد ما إذا كان هناك خطأ لتغيير ألوان الأيقونات
    final bool hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.tajawal(
            fontSize: 15,
            color: hasError ? Colors.red : ShamsColors.textGray,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.tajawal(color: const Color(0xFFBFC3CE)),
            filled: true,
            fillColor: Colors.white, // خلفية بيضاء للحقل
            // الأيقونة الأمامية
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: hasError ? Colors.red : const Color(0xFF9EA3B0))
                : null,
            // زر إظهار/إخفاء كلمة المرور أو أيقونة الخطأ
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: hasError ? Colors.red : const Color(0xFF9EA3B0),
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : (hasError ? const Icon(Icons.error_outline_rounded, color: Colors.red) : null),
            
            // هندسة الحدود (Borders)
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ShamsColors.solarYellow, width: 1.5),
            ),
            // حدود الخطأ (اللون الأحمر)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
        ),
        // عرض رسالة الخطأ أسفل الحقل إن وجدت
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.red, size: 14),
                const SizedBox(width: 4),
                Text(
                  widget.errorText!,
                  style: GoogleFonts.tajawal(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
          ),
      ],
    );
  }
}