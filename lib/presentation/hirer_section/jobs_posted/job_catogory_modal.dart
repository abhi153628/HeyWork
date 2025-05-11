import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/worker_type_bottom_sheet.dart';

class JobCategoryGrid extends StatelessWidget {
  const JobCategoryGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: jobCategories.length,
      itemBuilder: (context, index) {
        return _buildCategoryCard(context, jobCategories[index]);
      },
    );
  }

  // Individual category card
  Widget _buildCategoryCard(
      BuildContext context, Map<String, dynamic> category) {
    return InkWell(
      onTap: () => _showWorkerTypeSheet(context, category['name']),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category icon
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 24.sp,
              ),
            ),
            SizedBox(height: 8.h),

            // Category name
            Text(
              category['name'],
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Show bottom sheet when category is tapped
  void _showWorkerTypeSheet(BuildContext context, String categoryName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkerTypeBottomSheet(
        jobCategory: categoryName,
      ),
    );
  }
}

// Sample job categories
final List<Map<String, dynamic>> jobCategories = [
  {
    'name': 'Plumber',
    'icon': Icons.plumbing,
    'color': const Color(0xFF4A6FFF),
  },
  {
    'name': 'Electrician',
    'icon': Icons.electrical_services,
    'color': const Color(0xFFFF4A4A),
  },
  {
    'name': 'Carpenter',
    'icon': Icons.handyman,
    'color': const Color(0xFFFFAA4A),
  },
  {
    'name': 'Painter',
    'icon': Icons.format_paint,
    'color': const Color(0xFF4AFFB3),
  },
  {
    'name': 'Cleaner',
    'icon': Icons.cleaning_services,
    'color': const Color(0xFF4AD1FF),
  },
  {
    'name': 'Gardener',
    'icon': Icons.yard,
    'color': const Color(0xFF8B4AFF),
  },
  {
    'name': 'Driver',
    'icon': Icons.drive_eta,
    'color': const Color(0xFFFF4A8B),
  },
  {
    'name': 'Cook',
    'icon': Icons.restaurant,
    'color': const Color(0xFF4AFF4A),
  },
  {
    'name': 'Babysitter',
    'icon': Icons.child_care,
    'color': const Color(0xFFD1FF4A),
  },
];
