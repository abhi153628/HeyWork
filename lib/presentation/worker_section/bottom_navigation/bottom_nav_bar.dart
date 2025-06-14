import 'package:flutter/material.dart';
import 'package:heywork/presentation/worker_section/worker_profile_page/worker_profile_screenn.dart';
import '../../hirer_section/home_page/hirer_home_page.dart';
import '../../hirer_section/jobs/posted_jobs.dart';
import '../../hirer_section/notification_screen/notification.dart'; // Keep import for future use
import '../../hirer_section/profile/hirer_profile.dart';
import '../home_page/worker_home_page.dart';
import '../worker_application_screen/worker_applications_screen.dart';

// ==============================
// APP ROUTES
// ==============================
class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const WorkerMainScreen(),
    // Notification route commented for future use
    // '/notification': (context) => const NotificationPage(),
    '/jobs': (context) => const WorkerProfilePage(),
    '/profile': (context) => const WorkerProfilePage(),
  };
}

// ==============================
// MAIN SCREEN (Contains Bottom Nav Bar & Pages)
// ==============================
class WorkerMainScreen extends StatefulWidget {
  const WorkerMainScreen({Key? key}) : super(key: key);

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _currentIndex = 0;

  // List of all screens accessible from bottom navigation
  final List<Widget> _screens = [
    const WorkerHomePage(),
    // Notification page commented out for future use
    // const NotificationPage(),
    const WorkerApplicationsScreen(),
    const WorkerProfilePage(),
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
          // Home item
          BottomNavItem(
            icon: Icons.home,
            title: 'Home',
            isActive: currentIndex == 0,
            onTap: () => onTap(0),
            activeColor: secondaryBlue,
          ),
          
          // Notification item - commented out for future use
          /*
          BottomNavItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            isActive: currentIndex == 1,
            onTap: () => onTap(1),
            activeColor: secondaryBlue,
          ),
          */
          
          // Jobs item - fixed index to match current structure without notification
          BottomNavItem(
            icon: Icons.work_outline,
            title: 'Jobs',
            isActive: currentIndex == 1, // Changed from 2 to 1
            onTap: () => onTap(1),       // Changed from 2 to 1
            activeColor: secondaryBlue,
          ),
          
          // Profile item - fixed index to match current structure without notification
          BottomNavItem(
            icon: Icons.person,
            title: 'Profile',
            isActive: currentIndex == 2, // Changed from 3 to 2
            onTap: () => onTap(2),       // Changed from 3 to 2
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

// ==============================
// Notification Page - Commented out for future use
// Below is a basic template you can use when you're ready
// ==============================
/*
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: 10, // Example count - replace with your actual notification list
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Notification ${index + 1}'),
            subtitle: Text('This is a placeholder notification description'),
            trailing: Text('${DateTime.now().hour}:${DateTime.now().minute}'),
            onTap: () {
              // Handle notification tap
            },
          );
        },
      ),
    );
  }
}
*/