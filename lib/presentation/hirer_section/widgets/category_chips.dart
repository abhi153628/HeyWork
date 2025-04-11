// ==============================
// CATEGORIES CHIPS COMPONENT
// ==============================
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hey_work/main.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adjust chip spacing based on screen width
    final chipSpacing = screenWidth * 0.02; // 2% of screen width
    
    return Wrap(
      spacing: chipSpacing,
      runSpacing: 8.h,
      children: [
        _buildCategoryChip(
          context: context,
          icon: Icons.work_outline,
          label: 'All Works',
          isDark: true,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.move_to_inbox,
          label: 'Moving',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.local_shipping_outlined,
          label: 'Transport',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.print,
          label: 'Printing assistant',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.local_shipping_outlined,
          label: 'Transport',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.directions_car,
          label: 'Driver',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.restaurant,
          label: 'Kitchen',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.local_shipping_outlined,
          label: 'Transport',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.work_outline,
          label: 'All Works',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.move_to_inbox,
          label: 'Moving',
          isDark: false,
        ),
        _buildCategoryChip(
          context: context,
          icon: Icons.local_shipping_outlined,
          label: 'Transport',
          isDark: false,
        ),
      ],
    );
  }
  

  Widget _buildCategoryChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    // Responsive text size
    final fontSize = MediaQuery.of(context).size.width * 0.03;
    
    // Clamp font size for very small or large devices
    final clampedFontSize = fontSize.clamp(10.0, 14.0);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w, 
        vertical: 8.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : AppTheme.backgroundGrey,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: isDark ? Colors.white : Colors.black54,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: clampedFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
class CategoriesHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Pagination dots
       
      ],
    );
  }
}