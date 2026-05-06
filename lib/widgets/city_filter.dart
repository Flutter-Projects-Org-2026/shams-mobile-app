import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart'; // تأكد من مسار ملف الثوابت

class CityMultiSelectFilter extends StatefulWidget {
  /// دالة نمررها للشاشة الرئيسية لنخبرها بالمدن التي تم اختيارها لتقوم بفلترة الورش
  final ValueChanged<List<String>> onSelectionChanged;

  const CityMultiSelectFilter({super.key, required this.onSelectionChanged});

  @override
  State<CityMultiSelectFilter> createState() => _CityMultiSelectFilterState();
}

class _CityMultiSelectFilterState extends State<CityMultiSelectFilter> {
  // 1. قاعدة بيانات المدن المتاحة
  final List<String> _availableCities = [
    'تعز',
    'صنعاء',
    'عدن',
    'حضرموت',
    'مأرب',
    'الحديدة'
  ];

  // 2. الذاكرة (State) التي تحفظ المدن المختارة حالياً
  final List<String> _selectedCities = [];

  // دالة فتح نافذة الاختيار
  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // StatefulBuilder مهم جداً هنا لكي يتم تحديث الـ Checkbox داخل النافذة
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: ShamsColors.bgWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'اختر المحافظات',
                style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, color: ShamsColors.primaryBlue),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true, // لكي لا تأخذ النافذة كل طول الشاشة
                  itemCount: _availableCities.length,
                  itemBuilder: (context, index) {
                    final city = _availableCities[index];
                    final isChecked = _selectedCities.contains(city);

                    return CheckboxListTile(
                      title: Text(city, style: GoogleFonts.tajawal(fontSize: 15)),
                      value: isChecked,
                      activeColor: ShamsColors.solarYellow, // لون التحديد من التصميم
                      checkColor: ShamsColors.textGray,
                      onChanged: (bool? value) {
                        // تحديث حالة النافذة
                        setStateDialog(() {
                          if (value == true) {
                            _selectedCities.add(city);
                          } else {
                            _selectedCities.remove(city);
                          }
                        });
                        // تحديث حالة الويدجت الأصلية وإرسال البيانات للشاشة
                        setState(() {});
                        widget.onSelectionChanged(_selectedCities);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('تم', style: GoogleFonts.tajawal(color: ShamsColors.primaryBlue, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // دالة حذف مدينة من الرقاقات (Chips)
  void _removeCity(String city) {
    setState(() {
      _selectedCities.remove(city);
    });
    widget.onSelectionChanged(_selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. زر الفلتر (المحافظات) ──
        GestureDetector(
          onTap: _showMultiSelectDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: ShamsColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEEF0F4), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_alt_outlined, size: 20, color: ShamsColors.textGray),
                const SizedBox(width: 8),
                Text(
                  'المحافظات',
                  style: GoogleFonts.tajawal(fontSize: 14, fontWeight: FontWeight.w600, color: ShamsColors.textGray),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ShamsColors.textGray),
                
                // شارة (Badge) تظهر فقط إذا كان هناك مدن مختارة
                if (_selectedCities.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: ShamsColors.solarYellow,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_selectedCities.length}',
                      style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold, color: ShamsColors.textGray),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),

        // ── 2. الرقاقات (Chips) للمدن المختارة ──
        // تظهر فقط إذا كانت القائمة غير فارغة
        if (_selectedCities.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedCities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0), // مسافة بين الرقاقات
                  child: InputChip(
                    label: Text(
                      city,
                      style: GoogleFonts.tajawal(fontSize: 13, color: ShamsColors.textGray, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: ShamsColors.solarYellow.withValues(alpha: 0.15),
                    deleteIconColor: ShamsColors.textGray,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: ShamsColors.solarYellow),
                    ),
                    onDeleted: () => _removeCity(city), // تفعيل زر الحذف (X)
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}