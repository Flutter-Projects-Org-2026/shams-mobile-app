import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// استدعاءات "المكعبات" الجاهزة
import '../../utils/constants.dart';
import '../../widgets/appbar.dart';
import '../../widgets/city_filter.dart';
import '../../widgets/workshop_card.dart';
import 'workshop_profile_screen.dart';

class WorkshopsListScreen extends StatefulWidget {
  const WorkshopsListScreen({super.key});

  @override
  State<WorkshopsListScreen> createState() => _WorkshopsListScreenState();
}

class _WorkshopsListScreenState extends State<WorkshopsListScreen> {
  // 1. ذاكرة الشاشة: المدن المختارة حالياً
  List<String> _selectedCities = [];

  // 2. البيانات الوهمية المحدثة لتطابق التصميم الجديد للبطاقة
  final List<Map<String, dynamic>> _dummyWorkshops = [
    {
      'username': 'مركز المجد للطاقة الشمسية',
      'userHandle': '@al_majd_solar',
      'imagePath': 'assets/images/logo/shams logo.png',
      'coverImagePath': 'assets/images/post image.jpg',
      'cityName': 'تعز',
      'rating': 4.5,
      'isFollowing': true,
    },
    {
      'username': 'نور المستقبل لأنظمة الطاقة',
      'userHandle': '@future_light_energy',
      'imagePath': 'assets/images/logo/shams logo.png',
      'coverImagePath': 'assets/images/post image.jpg',
      'cityName': 'تعز',
      'rating': 4.8,
      'isFollowing': false,
    },
    {
      'username': 'رواد الطاقة البديلة',
      'userHandle': '@alt_energy_pioneers',
      'imagePath': 'assets/images/logo/shams logo.png',
      'coverImagePath': 'assets/images/post image.jpg',
      'cityName': 'صنعاء',
      'rating': 4.9,
      'isFollowing': false,
    },
    {
      'username': 'عدن للطاقة المتجددة',
      'userHandle': '@aden_renewable',
      'imagePath': 'assets/images/logo/shams logo.png',
      'coverImagePath': 'assets/images/post image.jpg',
      'cityName': 'عدن',
      'rating': 3.9,
      'isFollowing': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 3. محرك الفلترة الذكي
    final filteredWorkshops = _selectedCities.isEmpty
        ? _dummyWorkshops
        : _dummyWorkshops.where((workshop) {
            return _selectedCities.contains(workshop['cityName']);
          }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FF),

        // ── الشريط العلوي ──
        appBar: ShamsPlatformAppBar(
          hasUnreadNotifications: false,
          onMenuTap: () {},
          onNotificationTap: () {},
          onDarkModeTap: () {},
        ),

        body: Column(
          children: [
            // ── شريط البحث الوهمي ──
            Container(
              color: ShamsColors.bgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  debugPrint('فتح شريط البحث...');
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEF0F4)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Color(0xFF9EA3B0),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ابحث عن الورشة المفضلة...',
                        style: GoogleFonts.tajawal(
                          fontSize: 13.5,
                          color: const Color(0xFF9EA3B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── منطقة الفلتر (المدن) ──
            Container(
              width: double.infinity,
              color: ShamsColors.bgWhite,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CityMultiSelectFilter(
                onSelectionChanged: (selectedCities) {
                  setState(() {
                    _selectedCities = selectedCities;
                  });
                },
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4FF)),

            // ── قائمة الورش ──
            Expanded(
              child: filteredWorkshops.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد ورش في المحافظات المحددة.',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          color: ShamsColors.textGray,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: filteredWorkshops.length,
                      itemBuilder: (context, index) {
                        final workshop = filteredWorkshops[index];
                        return WorkshopCard(
                          username: workshop['username'],
                          userHandle: workshop['userHandle'],
                          imagePath: workshop['imagePath'],
                          coverImagePath: workshop['coverImagePath'],
                          cityName: workshop['cityName'],
                          rating: workshop['rating'],
                          isFollowing: workshop['isFollowing'],
                          onFollowToggle: (isFollowing) {
                            setState(() {
                              workshop['isFollowing'] = isFollowing;
                            });
                          },
                          onEnterTap: () async {
                            final bool? newFollowState =
                                await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkshopProfile(
                                      workshopName: workshop['username'],
                                      userHandle: workshop['userHandle'],
                                      location: workshop['cityName'],
                                      rating: workshop['rating'],
                                      logoPath: workshop['imagePath'],
                                      coverImagePath:
                                          workshop['coverImagePath'],
                                      initialFollowing: workshop['isFollowing'],
                                    ),
                                  ),
                                );

                            if (newFollowState != null &&
                                newFollowState != workshop['isFollowing']) {
                              setState(() {
                                workshop['isFollowing'] = newFollowState;
                              });
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
