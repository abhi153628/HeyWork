// ==============================
// APP ROUTES
// ==============================
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hey_work/main.dart';
import 'package:hey_work/presentation/hirer_section/home_page/home_page.dart';
import 'package:hey_work/presentation/hirer_section/jobs/jobs.dart';
import 'package:hey_work/presentation/hirer_section/notification_screen/notification.dart';
import 'package:hey_work/presentation/hirer_section/profile/profile.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const MainScreen(),
    '/navigator': (context) => const NotificationPage(),
    '/jobs': (context) => const JobsScreen(),
    '/profile': (context) => const ProfileScreen(),
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
    const HeyWorkHomePage(),
    const NotificationPage(),
    const JobsScreen(),
    const ProfileScreen(),
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
// BOTTOM NAVIGATION BAR COMPONENT
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
    // Calculate adaptive heights based on device
    final bottomNavHeight = 60.h;
    
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
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            title: 'Notification',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          BottomNavItem(
            icon: Icons.work_outline,
            title: 'Jobs',
            isActive: currentIndex == 2,
            onTap: () => onTap(2),
          ),
         
          BottomNavItem(
            icon: Icons.person,
            title: 'Profile',
            isActive: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

// ==============================
// BOTTOM NAVIGATION ITEM COMPONENT
// ==============================
class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
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
            color: isActive ? AppTheme.secondaryBlue : Colors.grey,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppTheme.secondaryBlue : Colors.grey,
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}