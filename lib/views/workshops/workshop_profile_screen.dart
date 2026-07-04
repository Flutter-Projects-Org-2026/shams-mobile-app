import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/inline_search_bar.dart';
import '../../views/chat/chat_conversation_screen.dart';
import '../../providers/workshop_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/feed_provider.dart';
import '../../models/user_model.dart';
import '../../models/public_workshop_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkshopProfile — صفحة الملف الشخصي للورشة
//
// • Accepts [workshopId] in its constructor.
// • Watches [WorkshopProvider] for live updates to the workshop details and follow status.
// • Dynamically connects to ChatProvider to get or create a chat on button press.
// ─────────────────────────────────────────────────────────────────────────────

class WorkshopProfile extends StatefulWidget {
  final String workshopId;

  const WorkshopProfile({
    super.key,
    required this.workshopId,
  });

  @override
  State<WorkshopProfile> createState() => _WorkshopProfileState();
}

class _WorkshopProfileState extends State<WorkshopProfile> {
  bool _isSearching = false;

  Widget _buildCoverImage(String path) {
    if (path.isEmpty) {
      return Container(
        color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
        child: const Center(
          child: Icon(Icons.broken_image_outlined, color: Colors.grey),
        ),
      );
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
        );
      } else {
        return Container(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
          child: const Center(
            child: Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        );
      }
    }
  }

  Widget _buildProfileImage(String path, String name) {
    if (path.isEmpty) {
      return _buildFallbackAvatar(name);
    }

    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(name),
        );
      } else {
        return _buildFallbackAvatar(name);
      }
    }
  }

  Widget _buildFallbackAvatar(String name) {
    return Builder(builder: (context) {
      return Container(
        color: Theme.of(context).extension<ShamsExtendedColors>()!.avatarFallbackBg,
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0] : '؟',
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
            ),
          ),
        ),
      );
    });
  }

  void _toggleFollow() {
    context.read<WorkshopProvider>().toggleFollow(widget.workshopId);
  }

  void _showMaintenanceRequestSheet(BuildContext context, PublicWorkshopModel workshop) {
    String? selectedService;
    String? selectedInverter;
    String? selectedBattery;
    final capacityController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(ctx).extension<ShamsExtendedColors>()!.handleBar,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'طلب خدمة صيانة من ${workshop.name}',
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(ctx).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Service Type Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedService,
                        hint: Text('نوع الخدمة المطلوبة', style: GoogleFonts.tajawal(fontSize: 14)),
                        items: ShamsConstants.solarServiceTypes
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.tajawal(fontSize: 14))))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedService = val),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 12),

                      // Inverter Brand Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedInverter,
                        hint: Text('نوع المحول (الإنفرتر)', style: GoogleFonts.tajawal(fontSize: 14)),
                        items: ShamsConstants.inverterBrands
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.tajawal(fontSize: 14))))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedInverter = val),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 12),

                      // Battery Type Dropdown
                      DropdownButtonFormField<String>(
                        initialValue: selectedBattery,
                        hint: Text('نوع البطاريات', style: GoogleFonts.tajawal(fontSize: 14)),
                        items: ShamsConstants.batteryTypes
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.tajawal(fontSize: 14))))
                            .toList(),
                        onChanged: (val) => setSheetState(() => selectedBattery = val),
                        decoration: _inputDecoration(),
                      ),
                      const SizedBox(height: 12),

                      // Capacity
                      TextField(
                        controller: capacityController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'حجم المنظومة (بالوات) - اختياري',
                        ),
                        style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: _inputDecoration().copyWith(
                          hintText: 'تفاصيل المشكلة (مثال: الشحن ضعيف وقت الظهيرة...)',
                        ),
                        style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      const SizedBox(height: 20),

                      CustomSolidButton(
                        title: 'إرسال الطلب',
                        onPressed: () async {
                          if (selectedService == null || descController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('يرجى تحديد نوع الخدمة وتفاصيل المشكلة', style: GoogleFonts.tajawal(color: Colors.white)),
                                backgroundColor: Theme.of(ctx).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          // 1. Close bottom sheet
                          Navigator.pop(ctx);

                          // Show loading indicator
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('جاري إرسال الطلب وإنشاء المحادثة...', style: GoogleFonts.tajawal(color: Colors.white)),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );

                          final capacityVal = double.tryParse(capacityController.text.trim());
                          final problemDesc = descController.text.trim();

                          // 3. Prepare target workshop data as UserModel
                          final workshopData = UserModel(
                            id: workshop.ownerId, // Real owner user ID!
                            name: workshop.name,
                            email: '${workshop.handle.replaceFirst('@', '')}@shams.com',
                            profileImageUrl: workshop.logoPath,
                          );

                          // 4. Create the maintenance chat session
                          final currentUser = context.read<UserProvider>().currentUser;
                          String generatedChatId = '';
                          try {
                            generatedChatId = await context
                                .read<ChatProvider>()
                                .createMaintenanceChat(
                                  currentUser: currentUser,
                                  workshopId: workshop.id, // Real workshop database ID!
                                  targetWorkshop: workshopData,
                                  serviceType: selectedService!,
                                  problemDescription: problemDesc,
                                  systemCapacityKw: capacityVal,
                                  inverterBrand: selectedInverter,
                                  batteryType: selectedBattery,
                                );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إرسال الطلب: $e', style: GoogleFonts.tajawal(color: Colors.white)),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                            return;
                          }

                          // 5. Router Navigation
                          if (context.mounted) {
                            if (generatedChatId.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    chatId: generatedChatId,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('فشل في إرسال الطلب، يرجى المحاولة لاحقاً', style: GoogleFonts.tajawal(color: Colors.white)),
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
        ),
      ),
      hintStyle: GoogleFonts.tajawal(
        fontSize: 13,
        color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Single source of truth: watch provider for live updates ──────────────
    final workshopProvider = context.watch<WorkshopProvider>();
    final workshop = workshopProvider.getWorkshopById(widget.workshopId);

    if (workshop == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0.5,
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          body: Center(
            child: Text(
              'الورشة المطلوبة غير متوفرة حالياً.',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    final isFollowing = workshop.isFollowing;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            workshop.name,
            style: GoogleFonts.tajawal(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0.5,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'search') {
                  setState(() {
                    _isSearching = true;
                  });
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'search',
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'بحث',
                        style: GoogleFonts.tajawal(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: CustomSolidButton(
            title: 'طلب خدمة صيانة الآن',
            onPressed: () => _showMaintenanceRequestSheet(context, workshop),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          child: Column(
            children: [
              if (_isSearching)
                SafeArea(
                  bottom: false,
                  child: InlineSearchBar(
                    hintText: 'ابحث في الورشة...',
                    onChanged: (val) {},
                    onClose: () {
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
              _buildHeader(context, workshop),
              const SizedBox(height: 55),
              _buildWorkshopInfo(workshop, isFollowing),
              const SizedBox(height: 25),
              _buildWorkLogSection(workshop),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PublicWorkshopModel workshop) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        Container(
          height: 220,
          width: double.infinity,
          color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
          child: _buildCoverImage(workshop.coverImagePath),
        ),
        // Overlay for better back button visibility
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Profile Image (Avatar)
        Positioned(
          bottom: -45,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
                ),
                clipBehavior: Clip.antiAlias,
                child: _buildProfileImage(workshop.logoPath, workshop.name),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopInfo(PublicWorkshopModel workshop, bool isFollowing) {
    return Column(
      children: [
        Text(
          workshop.name,
          style: GoogleFonts.tajawal(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          workshop.handle,
          style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              workshop.city,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.star_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '${workshop.rating}/5',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '(${workshop.reviewCount} تقييم)',
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            workshop.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Social icons and Follow button row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _toggleFollow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.secondary,
                      foregroundColor: isFollowing
                          ? Theme.of(context).extension<ShamsExtendedColors>()!.textHint
                          : Theme.of(context).colorScheme.onSecondary,
                      elevation: 0,
                      side: isFollowing
                          ? BorderSide(
                              color: Theme.of(context).extension<ShamsExtendedColors>()!.borderLight,
                              width: 1.5,
                            )
                          : BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      isFollowing ? 'الغاء المتابعة' : 'متابعة',
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildCircularSocialIcon(
                Icons.chat_bubble_outline_rounded,
                const Color(0xFF25D366),
              ),
              _buildCircularSocialIcon(
                Icons.phone_in_talk_rounded,
                Theme.of(context).colorScheme.onSurface,
              ),
              _buildCircularSocialIcon(
                Icons.camera_alt_rounded,
                const Color(0xFFE1306C),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Divider(color: Colors.grey.shade300, thickness: 1),
      ],
    );
  }

  Widget _buildCircularSocialIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ميزة التواصل متوفرة قريباً', style: GoogleFonts.tajawal(color: Colors.white)),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildWorkLogSection(PublicWorkshopModel workshop) {
    final feedPosts = context.watch<FeedProvider>().posts;
    final workshopPosts = feedPosts.where((post) => post.workshopId == workshop.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل الأعمال',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فتح سجل الأعمال بالكامل (قريباً)...', style: GoogleFonts.tajawal(color: Colors.white)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'عرض الكل',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (workshopPosts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'لا توجد أعمال في هذا السجل حالياً.',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: Theme.of(context)
                      .extension<ShamsExtendedColors>()!
                      .textHint,
                ),
              ),
            ),
          )
        else
          ...workshopPosts.map((post) => _buildWorkLogCard(
                post.createdAt,
                post.textDetails,
                post.images,
              )),
      ],
    );
  }

  Widget _buildWorkLogCard(String time, String content, List<String> images) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time Badge
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: GoogleFonts.tajawal(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          // Simple Horizontal Image List (matches swiping behavior)
          if (images.isNotEmpty)
            SizedBox(
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: _buildCoverImage(images[index]),
                        ),
                        // 1/2 indicator
                        if (images.length > 1)
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}/${images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

