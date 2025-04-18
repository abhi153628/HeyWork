import 'package:flutter/material.dart';
import 'package:hey_work/presentation/hirer_section/common/bottom_nav_bar.dart';

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
    final Color secondaryBlue = const Color(0xFF0011C9); // Default color if AppTheme not available
    
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

// // ==============================
// // BOTTOM NAVIGATION ITEM COMPONENT (Fixed without ScreenUtil)
// // ==============================
// class BottomNavItem extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final bool isActive;
//   final VoidCallback onTap;
//   final Color activeColor;

//   const BottomNavItem({
//     Key? key,
//     required this.icon,
//     required this.title,
//     required this.isActive,
//     required this.onTap,
//     required this.activeColor,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       behavior: HitTestBehavior.opaque,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             color: isActive ? activeColor : Colors.grey,
//             size: 24, // Fixed size instead of using ScreenUtil
//           ),
//           const SizedBox(height: 4), // Fixed size instead of using ScreenUtil
//           Text(
//             title,
//             style: TextStyle(
//               color: isActive ? activeColor : Colors.grey,
//               fontSize: 10, // Fixed size instead of using ScreenUtil
//               fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }