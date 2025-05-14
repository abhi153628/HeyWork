import 'package:flutter/material.dart';
import '../home_page/hirer_home_page.dart';
import '../job_managment_screen/job_managment_screen.dart';
import '../jobs/posted_jobs.dart';
import '../notification_screen/notification.dart';
import '../profile/hirer_profile.dart';

// ==============================
// APP ROUTES
// ==============================
class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const MainScreen(),
    '/navigator': (context) => const NotificationPage(),
    '/jobs': (context) => const JobManagementScreen(
          
        ),
    '/profile': (context) => const HirerProfilePage(),
  };
}

// ==============================
// MAIN SCREEN (Contains Bottom Nav Bar & Pages)
// ==============================
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of all screens accessible from bottom navigation
  final List<Widget> _screens = [
    const HirerHomePage(),
    const NotificationPage(),
    const JobManagementScreen(),
    const HirerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BODY: Current selected screen from bottom nav
      body: _screens[_currentIndex],

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: BottomNavBar(
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

// ==============================
// BOTTOM NAVIGATION BAR COMPONENT - NO SCREENUTIL
// ==============================
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fixed height instead of using ScreenUtil
    const double bottomNavHeight = 60.0;

    // Fixed color instead of relying on AppTheme
    const Color secondaryBlue = Color(0xFF0011C9);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      height: bottomNavHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomNavItem(
            icon: Icons.home,
            title: 'Home',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            activeColor: secondaryBlue,
          ),
          BottomNavItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            activeColor: secondaryBlue,
          ),
          BottomNavItem(
            icon: Icons.work_outline,
            title: 'Jobs',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
            activeColor: secondaryBlue,
          ),
          BottomNavItem(
            icon: Icons.person,
            title: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
            activeColor: secondaryBlue,
          ),
        ],
      ),
    );
  }
}

// ==============================
// BOTTOM NAVIGATION ITEM COMPONENT - NO SCREENUTIL
// ==============================
class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final Color activeColor;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
    required this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : Colors.grey,
            size: 24, // Fixed size instead of using ScreenUtil
          ),
          const SizedBox(height: 4), // Fixed size
          Text(
            title,
            style: TextStyle(
              color: isActive ? activeColor : Colors.grey,
              fontSize: 10, // Fixed size
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
