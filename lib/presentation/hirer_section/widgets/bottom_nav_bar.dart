import 'package:flutter/material.dart';
import '../common/bottom_nav_bar.dart';

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
    // Use fixed height instead of ScreenUtil
    const bottomNavHeight = 60.0;

    // Get the theme colors
    final Color secondaryBlue =
        const Color(0xFF0011C9); // Default color if AppTheme not available

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
