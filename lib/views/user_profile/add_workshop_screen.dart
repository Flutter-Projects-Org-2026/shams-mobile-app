import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/constants.dart';
import '../../widgets/image_source_sheet.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scrollable_image_picker.dart';
import '../../widgets/username_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/workshop_provider.dart';
import '../../models/workshop_data.dart';
import '../../services/workshop_service.dart';

class AddWorkshopScreen extends StatefulWidget {
  const AddWorkshopScreen({super.key});

  @override
  State<AddWorkshopScreen> createState() => _AddWorkshopScreenState();
}

class _AddWorkshopScreenState extends State<AddWorkshopScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearsController = TextEditingController();

  // ── Dropdown ─────────────────────────────────────────────────────────────────
  String? _selectedCity;

  // ── Images ───────────────────────────────────────────────────────────────────
  File? _coverImage;
  File? _profileImage;
  final List<File> _images = []; // unlimited extra images

  final _picker = ImagePicker();
  bool _isLoading = false;

  // City list is sourced from ShamsConstants (single source of truth)
  // ignore: prefer_const_declarations
  final List<String> _cities = ShamsConstants.yemeniCities;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  // ── Image picking helpers ────────────────────────────────────────────────────

  Future<File?> _pick() async {
    final source = await showImageSourceSheet(context);
    if (source == null) return null;
    final xf = await _picker.pickImage(source: source, imageQuality: 85);
    return xf != null ? File(xf.path) : null;
  }

  Future<void> _pickCoverImage() async {
    final f = await _pick();
    if (f != null) setState(() => _coverImage = f);
  }

  Future<void> _pickProfileImage() async {
    final f = await _pick();
    if (f != null) setState(() => _profileImage = f);
  }

  Future<void> _pickAndAddImage() async {
    final f = await _pick();
    if (f != null) setState(() => _images.add(f));
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _onCreateTapped() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final description = _descriptionController.text.trim();
    final years = int.tryParse(_yearsController.text.trim()) ?? 0;

    // Validate required text fields
    if (name.isEmpty || description.isEmpty || _selectedCity == null) {
      _showError('يرجى تعبئة جميع الحقول المطلوبة');
      return;
    }

    // Validate username
    final usernameError = UsernameValidator.validate(username);
    if (usernameError != null) {
      _showError(usernameError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('المستخدم غير مسجل الدخول');

      // 1. Create workshop in database and upload images
      final data = await WorkshopService.createWorkshop(
        name: name,
        city: _selectedCity!,
        address: _selectedCity!,
        description: description,
        handle: '@$username',
        logo: _profileImage,
        cover: _coverImage,
        galleryImages: _images,
        yearsOfExperience: years,
      );

      // Create WorkshopData instance
      final newWorkshop = WorkshopData(
        id: data['id'] ?? user.id,
        ownerId: user.id,
        name: name,
        username: username,
        city: _selectedCity!,
        description: description,
        yearsOfExperience: years,
        profileImage: _profileImage,
        coverImage: _coverImage,
        extraImages: List.from(_images),
      );

      // 3. Update local state
      if (mounted) {
        context.read<WorkshopProvider>().setMyWorkshop(newWorkshop);
        context.read<UserProvider>().updateWorkshopStatus(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الورشة بنجاح!', style: GoogleFonts.tajawal()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showError('فشل إنشاء الورشة: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.tajawal()),
        backgroundColor: ShamsColors.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: Colors.grey.withValues(alpha: 0.1),
              height: 1,
            ),
          ),
          title: Text(
            'إضافة ورشة',
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Color(0xFF2D2D2D)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cover + Profile image header
              _buildMediaHeader(),
              const SizedBox(height: 24),

              // 2. Workshop Name
              _buildFieldLabel('اسم الورشة *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'أدخل اسم الورشة الكامل',
                prefixIcon: Icons.store_mall_directory_outlined,
              ),
              const SizedBox(height: 20),

              // 3. Username
              _buildFieldLabel('اسم المستخدم *'),
              const SizedBox(height: 8),
              UsernameField(controller: _usernameController),
              const SizedBox(height: 20),

              // 4. Years + City
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('المحافظة *'),
                        const SizedBox(height: 8),
                        _buildCityDropdown(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Description
              _buildFieldLabel('وصف مختصر للخدمات *'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _descriptionController,
                hintText: 'اكتب وصفاً موجزاً للخدمات التي تقدمها الورشة...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // 6. Unlimited extra images
              Row(
                children: [
                  _buildFieldLabel('صور الورشة'),
                  const SizedBox(width: 8),
                  Text(
                    '(${_images.length})',
                    style: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: ShamsColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ScrollableImagePicker(
                images: _images,
                onAddTap: _pickAndAddImage,
                onRemoveTap: (i) => setState(() => _images.removeAt(i)),
              ),
              const SizedBox(height: 32),

              // 7. Create button
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: ShamsColors.primaryBlue))
                    : CustomSolidButton(
                        title: 'إنشاء الورشة',
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

  // ─── Media Header: cover image + centred profile avatar ─────────────────────

  Widget _buildMediaHeader() {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image — full width, 165 px tall
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickCoverImage,
              child: Container(
                height: 165,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _coverImage != null
                        ? ShamsColors.solarYellow
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: _coverImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(_coverImage!, fit: BoxFit.cover),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: _editBadge('تغيير الغلاف'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: ShamsColors.solarYellow.withValues(
                              alpha: 0.7,
                            ),
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اضغط لإضافة صورة الغلاف',
                            style: GoogleFonts.tajawal(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          // Profile avatar — centred, overlaps the bottom edge of the cover
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _profileImage != null
                        ? Image.file(_profileImage!, fit: BoxFit.cover)
                        : Container(
                            color: const Color(0xFFF5F7FF),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  color: ShamsColors.solarYellow,
                                  size: 22,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'صورة',
                                  style: GoogleFonts.tajawal(
                                    fontSize: 10,
                                    color: ShamsColors.solarYellow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable helpers ─────────────────────────────────────────────────────────

  Widget _editBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.tajawal(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ShamsColors.textGray,
      ),
    );
  }

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
          items: _cities
              .map(
                (city) => DropdownMenuItem<String>(
                  value: city,
                  child: Text(
                    city,
                    style: GoogleFonts.tajawal(
                      fontSize: 14,
                      color: ShamsColors.textGray,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _selectedCity = v),
        ),
      ),
    );
  }
}
