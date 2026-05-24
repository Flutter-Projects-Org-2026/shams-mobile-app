import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/workshop_provider.dart';
import '../widgets/shams_bottom_nav_bar.dart';
import 'home.dart';
import 'workshops/workshops_list_screen.dart';
import 'user_profile/user_profile_screen.dart';
import 'chat/chat_list_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    WorkshopsListScreen(),
    ChatListScreen(), // Following screen not implemented
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchUserData();
      if (mounted) {
        final currentUser = userProvider.currentUser;
        // Fetch public workshops for the authenticated user (populates isFollowing)
        context.read<WorkshopProvider>().fetchPublicWorkshops();

        if (currentUser.id.isNotEmpty && currentUser.hasWorkshop) {
          final username = currentUser.username ?? 'owner';
          await context
              .read<WorkshopProvider>()
              .fetchMyWorkshop(currentUser.id, username);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: ShamsBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

