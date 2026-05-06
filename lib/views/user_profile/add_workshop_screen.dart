import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class AddWorkshopScreen extends StatefulWidget {
  const AddWorkshopScreen({super.key});

  @override
  State<AddWorkshopScreen> createState() => _AddWorkshopScreenState();
}

class _AddWorkshopScreenState extends State<AddWorkshopScreen> {
  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  // ── Dropdown State ───────────────────────────────────────────────────────────
  String? _selectedCity;

  final List<String> _cities = [
    'الرياض',
    'جدة',
    'مكة المكرمة',
    'المدينة المنورة',
    'الدمام',
    'الخبر',
    'أبها',
    'تبوك',
    'القصيم',
    'حائل',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,

        // ── AppBar ─────────────────────────────────────────────────────────────
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          // إضافة خط رفيع أسفل الـ AppBar كما في الصورة
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(color: Colors.grey.withOpacity(0.1), height: 1.0),
          ),
          title: Text(
            'إضافة ورشة صيانة',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D), // لون داكن مطابق للصورة
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF2D2D2D),
                  size: 26,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),

        // ── Body ───────────────────────────────────────────────────────────────
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover Image Placeholder
              _buildCoverImagePlaceholder(),
              const SizedBox(height: 16),

              // 2. Extra Photos Row
              _buildExtraPhotosRow(),
              const SizedBox(height: 24),

              // 3. Workshop Name
              _buildFieldLabel('اسم الورشة'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'أدخل اسم الورشة الكامل',
                prefixIcon: Icons.store_mall_directory_outlined,
              ),
              const SizedBox(height: 20),

              // 4. Years of Experience + City — side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Years of Experience
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('سنوات الخبرة'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _yearsController,
                          hintText: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // City Dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('المحافظة'),
                        const SizedBox(height: 8),
                        _buildCityDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Service Description
              _buildFieldLabel('وصف مختصر للخدمات'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'اكتب وصفاً موجزاً للخدمات التي تقدمها الورشة...',
                maxLines: 5,
              ),
              const SizedBox(height: 32),

              // 6. Create Button
              SizedBox(
                width: double.infinity,
                child: CustomSolidButton(
                  title: 'إنشاء',
                  onPressed: _onCreateTapped,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Cover Image Placeholder
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCoverImagePlaceholder() {
    return GestureDetector(
      onTap: () {
        // TODO: open image picker
      },
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ShamsColors.solarYellow.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: ShamsColors.solarYellow,
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'إضافة صورة الغلاف',
              style: GoogleFonts.tajawal(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Extra Photos Row
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildExtraPhotosRow() {
    return Row(
      children: [
        // "أضف + المزيد" label
        GestureDetector(
          onTap: () {
            // TODO: add more photos
          },
          child: Text(
            'أضف +\nالمزيد',
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ShamsColors.solarYellow,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Three extra photo placeholders
        Expanded(
          child: Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey, size: 22),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Field Label
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: ShamsColors.textGray,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Reusable Text Field
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: GoogleFonts.tajawal(fontSize: 14, color: ShamsColors.textGray),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.tajawal(
          fontSize: 13,
          color: Colors.grey.shade400,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey.shade400, size: 20)
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ShamsColors.solarYellow,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // City Dropdown
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildCityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCity,
          isExpanded: true,
          hint: Text(
            'اختر المحافظة',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _cities.map((city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: ShamsColors.textGray,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCity = value);
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Create Button Handler
  // ─────────────────────────────────────────────────────────────────────────────

  void _onCreateTapped() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تعبئة جميع الحقول المطلوبة',
            style: GoogleFonts.tajawal(),
          ),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    // TODO: submit form data
  }
}
