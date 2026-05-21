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

  void _toggleFollow() {
    context.read<WorkshopProvider>().toggleFollow(widget.workshopId);
  }

  void _showMaintenanceRequestSheet(BuildContext context, PublicWorkshopModel workshop) {
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: ShamsColors.bgWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
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
                      color: ShamsColors.handleBar,
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
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يرجى كتابة تفاصيل المشكلة أو الخدمة المطلوبة لنتمكن من خدمتك بشكل أفضل.',
                  style: GoogleFonts.tajawal(
                    fontSize: 13.5,
                    color: ShamsColors.textHint,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'مثال: أريد فحص منظومة الطاقة الشمسية وتنظيف الألواح وتغيير البطاريات...',
                    hintStyle: GoogleFonts.tajawal(
                      fontSize: 13,
                      color: ShamsColors.textHint,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8F9FE),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ShamsColors.borderLight),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ShamsColors.primaryBlue, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ShamsColors.borderLight),
                    ),
                  ),
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: ShamsColors.textGray,
                  ),
                ),
                const SizedBox(height: 20),
                CustomSolidButton(
                  title: 'إرسال الطلب',
                  onPressed: () {
                    final requestText = textController.text.trim();
                    if (requestText.isEmpty) {
                      ScaffoldMessenger.of(bCtx).showSnackBar(
                        SnackBar(
                          content: Text(
                            'يرجى كتابة تفاصيل الطلب أولاً',
                            style: GoogleFonts.tajawal(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: ShamsColors.dangerRed,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    // 1. Close bottom sheet
                    Navigator.pop(bCtx);

                    // 2. Prepare target workshop data as UserModel
                    final workshopData = UserModel(
                      id: workshop.id,
                      name: workshop.name,
                      email: '${workshop.handle.replaceFirst('@', '')}@shams.com',
                      profileImageUrl: workshop.logoPath,
                    );

                    // 3. Create the maintenance chat session
                    final currentUser = context.read<UserProvider>().currentUser;
                    final generatedChatId = context
                        .read<ChatProvider>()
                        .createMaintenanceChat(currentUser, workshopData, requestText);

                    // 4. Router Navigation
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatConversationScreen(
                          chatId: generatedChatId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
          backgroundColor: const Color(0xFFF8F9FE),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            iconTheme: const IconThemeData(color: ShamsColors.textGray),
          ),
          body: Center(
            child: Text(
              'الورشة المطلوبة غير متوفرة حالياً.',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                color: ShamsColors.textGray,
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
        backgroundColor: const Color(0xFFF8F9FE),
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          title: Text(
            workshop.name,
            style: GoogleFonts.tajawal(
              color: ShamsColors.textGray,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: ShamsColors.textGray),
          leading: PopupMenuButton<String>(
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
                    const Icon(Icons.search_rounded,
                        size: 20, color: ShamsColors.textGray),
                    const SizedBox(width: 8),
                    Text('بحث',
                        style: GoogleFonts.tajawal(
                          color: ShamsColors.textGray,
                        )),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
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
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(workshop.coverImagePath),
              fit: BoxFit.cover,
            ),
          ),
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
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage(workshop.logoPath),
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
            color: ShamsColors.textGray,
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
            const Icon(
              Icons.star_rounded,
              size: 16,
              color: ShamsColors.solarYellow,
            ),
            const SizedBox(width: 4),
            Text(
              '${workshop.rating}/5',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ShamsColors.textGray,
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
                      backgroundColor:
                          isFollowing ? Colors.white : ShamsColors.solarYellow,
                      foregroundColor: isFollowing
                          ? const Color(0xFF9EA3B0)
                          : Colors.white,
                      elevation: 0,
                      side: isFollowing
                          ? const BorderSide(
                              color: Color(0xFFD0D5DD),
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
                Colors.black87,
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildWorkLogSection(PublicWorkshopModel workshop) {
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
                  color: ShamsColors.textGray,
                ),
              ),
              Text(
                'عرض الكل',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ShamsColors.solarYellow,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (workshop.posts.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'لا توجد أعمال في هذا السجل حالياً.',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: ShamsColors.textHint,
                ),
              ),
            ),
          )
        else
          ...workshop.posts.map((post) => _buildWorkLogCard(
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
        color: Colors.white,
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
                color: const Color(0xFFF8F9FE),
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
              color: ShamsColors.textGray,
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
                        Image.asset(
                          images[index],
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
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
