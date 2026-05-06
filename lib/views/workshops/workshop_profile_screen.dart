import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
// import '../../widgets/post_card.dart';
import '../../widgets/primary_button.dart';
import '/views/chat/chat_conversation_screen.dart';

class WorkshopProfile extends StatefulWidget {
  final String workshopName;
  final String userHandle;
  final String location;
  final double rating;
  final String logoPath;
  final String coverImagePath;
  final int reviewCount;
  final String description;
  final bool initialFollowing;
  final Function(bool)? onFollowChanged;

  const WorkshopProfile({
    super.key,
    this.workshopName = 'كراج المجد التقني',
    this.userHandle = '@al_majd_tech',
    this.location = 'صنعاء، اليمن',
    this.rating = 4.8,
    this.logoPath = 'assets/images/logo/shams logo.png',
    this.coverImagePath = 'assets/images/post image.',
    this.reviewCount = 1250,
    this.description =
        'نبذة عن الورشة وخدماتها المتميزة في مجال حلول الطاقة المتجددة وصيانة الأنظمة الشمسية.',
    this.initialFollowing = false,
    this.onFollowChanged,
  });

  @override
  State<WorkshopProfile> createState() => _WorkshopProfileState();
}

class _WorkshopProfileState extends State<WorkshopProfile> {
  late bool _isFollowing;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialFollowing;
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
    if (widget.onFollowChanged != null) {
      widget.onFollowChanged!(_isFollowing);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        extendBodyBehindAppBar: false, // نجعل الـ AppBar منفصلاً بخلفية بيضاء
        appBar: AppBar(
          title: Text(
            '',
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
          leading: IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {},
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => Navigator.pop(context, _isFollowing),
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: CustomSolidButton(
            title: 'طلب خدمة صيانة الآن',
            onPressed: () {
              // 💡 كود الانتقال إلى شاشة المحادثة التي صممها المهندس عمر!
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatConversationScreen(
                    workshopName: widget.workshopName,
                    workshopAvatar: widget.logoPath,
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 55),
              _buildWorkshopInfo(),
              const SizedBox(height: 25),
              _buildWorkLogSection(),
              const SizedBox(
                height: 120,
              ), // مساحة لضمان عدم اختفاء المحتوى خلف الزر
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(widget.coverImagePath),
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
                backgroundImage: AssetImage(widget.logoPath),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopInfo() {
    return Column(
      children: [
        Text(
          widget.workshopName,
          style: GoogleFonts.tajawal(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ShamsColors.textGray,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          widget.userHandle,
          style: GoogleFonts.tajawal(fontSize: 13, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              widget.location,
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
              '${widget.rating}/5',
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ShamsColors.textGray,
              ),
            ),
          ],
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
                      backgroundColor: _isFollowing
                          ? Colors.white
                          : ShamsColors.solarYellow,
                      foregroundColor: _isFollowing
                          ? const Color(0xFF9EA3B0)
                          : Colors.white,
                      elevation: 0,
                      side: _isFollowing
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
                      _isFollowing ? 'الغاء المتابعة' : 'متابعة',
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
        // const SizedBox(height: 10),
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

  Widget _buildWorkLogSection() {
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
        _buildWorkLogCard(
          'منذ يومين',
          'صيانة شاملة لنظام ألواح شمسية بقدرة 10 كيلوواط مع تنظيف الألواح لزيادة الكفاءة',
          ['assets/images/post image.jpg', 'assets/images/post image.jpg'],
        ),
        _buildWorkLogCard(
          'الأسبوع الماضي',
          'فحص وتبديل محول العاكس (Inverter) لنظام طاقة شمسية منزلي واستعادة النظام للعمل',
          ['assets/images/post image.jpg', 'assets/images/post image.jpg'],
        ),
        _buildWorkLogCard(
          'منذ أسبوعين',
          'حل مشكلة ضعف شحن البطاريات وتغيير التوصيلات التالفة لنظام الطاقة الشمسية',
          ['assets/images/post image.jpg', 'assets/images/post image.jpg'],
        ),
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
