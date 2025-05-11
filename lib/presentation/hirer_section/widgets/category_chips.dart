import 'package:flutter/material.dart';

// ==============================
// CATEGORIES CHIPS COMPONENT (Fixed without ScreenUtil)
// ==============================
class CategoryChips extends StatelessWidget {
  const CategoryChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust chip spacing based on screen width
    final chipSpacing = screenWidth * 0.02; // 2% of screen width

    return Wrap(
      spacing: chipSpacing,
      runSpacing: 8, // Fixed size instead of ScreenUtil
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

    // Get background color - defaulting to light grey if AppTheme not available
    final Color backgroundColor = isDark ? Colors.black : Colors.grey[200]!;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark ? Colors.white : Colors.black54,
          ),
          const SizedBox(width: 6),
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
  const CategoriesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'View All',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
