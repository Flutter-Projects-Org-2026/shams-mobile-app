import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../utils/constants.dart';
import '../../widgets/appbar.dart';
import '../../widgets/city_filter.dart';
import '../../widgets/workshop_card.dart';
import '../../widgets/inline_search_bar.dart';
import '../../providers/workshop_provider.dart';
import '../../providers/notification_provider.dart';
import 'workshop_profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../widgets/shams_drawer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WorkshopsListScreen — قائمة الورش العامة
//
// • Reads live data from WorkshopProvider via context.watch() in build().
// • All mutations (toggleFollow) use context.read() inside callbacks.
// • No Consumer widgets used anywhere.
// ─────────────────────────────────────────────────────────────────────────────

class WorkshopsListScreen extends StatefulWidget {
  const WorkshopsListScreen({super.key});

  @override
  State<WorkshopsListScreen> createState() => _WorkshopsListScreenState();
}

class _WorkshopsListScreenState extends State<WorkshopsListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Local UI state — search query and selected city filters.
  List<String> _selectedCities = [];
  final List<String> _selectedServices = [];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // ── Single source of truth: watch provider for live updates ──────────────
    final workshops = context.watch<WorkshopProvider>().publicWorkshops;

    // ── Smart filter: apply city + search query ───────────────────────────────
    final filteredWorkshops = workshops.where((workshop) {
      final matchesCity =
          _selectedCities.isEmpty || _selectedCities.contains(workshop.city);
      final matchesSearch = _searchQuery.isEmpty ||
          workshop.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesService = _selectedServices.isEmpty ||
          workshop.serviceTypes.any((s) => _selectedServices.contains(s));
      return matchesCity && matchesSearch && matchesService;
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const ShamsDrawer(activeIndex: 1),
        backgroundColor: const Color(0xFFF5F7FF),

        // ── الشريط العلوي ──────────────────────────────────────────────────
        appBar: ShamsPlatformAppBar(
          onMenuTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          onNotificationTap: () {
            context.read<NotificationProvider>().markAllAsRead();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsScreen()),
            );
          },
          onDarkModeTap: () {},
        ),

        body: Column(
          children: [
            // ── شريط البحث ──────────────────────────────────────────────────
            InlineSearchBar(
              hintText: 'ابحث عن الورشة المفضلة...',
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),

            // ── فلتر المدن ──────────────────────────────────────────────────
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

            // ── فلتر الخدمات ────────────────────────────────────────────────
            Container(
              width: double.infinity,
              color: ShamsColors.bgWhite,
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ShamsConstants.solarServiceTypes.length,
                  itemBuilder: (context, index) {
                    final service = ShamsConstants.solarServiceTypes[index];
                    final isSelected = _selectedServices.contains(service);
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: FilterChip(
                        label: Text(
                          service,
                          style: GoogleFonts.tajawal(
                            fontSize: 13,
                            color: isSelected ? Colors.black87 : ShamsColors.textHint,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                        selectedColor: ShamsColors.solarYellow,
                        backgroundColor: ShamsColors.bgWhite,
                        checkmarkColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? ShamsColors.solarYellow : const Color(0xFFEEF0F4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F4FF)),

            // ── قائمة الورش ────────────────────────────────────────────────
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
                          username: workshop.name,
                          userHandle: workshop.handle,
                          imagePath: workshop.logoPath,
                          coverImagePath: workshop.coverImagePath,
                          cityName: workshop.city,
                          rating: workshop.rating,
                          // isFollowing reflects live provider state via watch()
                          isFollowing: workshop.isFollowing,
                          // context.read() inside callback — correct usage.
                          onFollowToggle: (_) => context
                              .read<WorkshopProvider>()
                              .toggleFollow(workshop.id),
                          onEnterTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  WorkshopProfile(workshopId: workshop.id),
                            ),
                          ),
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
