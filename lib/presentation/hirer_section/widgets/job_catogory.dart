import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/job_detail_page.dart/job_detail.dart';



class JobCategoriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // JOB CATEGORY GRID - First Row
        JobCategoryGrid(
          categories: [
            JobCategory(
              icon: Icons.cleaning_services_outlined,
              title: 'Cleaning\nhelp',
            ),
            JobCategory(
              icon: Icons.directions_car,
              title: 'Driver',
            ),
            JobCategory(
              icon: Icons.local_shipping_outlined,
              title: 'Quick\nTransport',
            ),
            JobCategory(
              icon: Icons.local_florist,
              title: 'Gardener',
            ),
          ],
        ),
        
        // JOB CATEGORY GRID - Second Row
        SizedBox(height: 16.h),
        JobCategoryGrid(
          categories: [
            JobCategory(
              icon: Icons.pets,
              title: 'Pet Care',
            ),
            JobCategory(
              icon: Icons.laptop,
              title: 'Laptop\nRepair',
            ),
            JobCategory(
              icon: Icons.print,
              title: 'Printing\nHelper',
            ),
            JobCategory(
              icon: Icons.delivery_dining,
              title: 'Delivery',
            ),
          ],
        ),
        
        // JOB CATEGORY GRID - Third Row
        SizedBox(height: 16.h),
        JobCategoryGrid(
          categories: [
            JobCategory(
              icon: Icons.warehouse,
              title: 'Warehouse\nAssistant',
            ),
            JobCategory(
              icon: Icons.build,
              title: 'Mechanic',
            ),
            JobCategory(
              icon: Icons.store,
              title: 'Shop\nAssistant',
            ),
            JobCategory(
              icon: Icons.bolt,
              title: 'Electrician',
            ),
          ],
        ),
      ],
    );
  }
}

class JobCategoryGrid extends StatelessWidget {
  final List<JobCategory> categories;

  const JobCategoryGrid({
    Key? key,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen width to calculate adaptive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate item width based on screen width (minus padding and gaps)
    final availableWidth = screenWidth - (32 + (3 * 12)); // horizontal padding + gaps
    final itemWidth = availableWidth / 4; // 4 items per row
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: categories.map((category) {
            return JobCategoryCard(
              icon: category.icon,
              title: category.title,
              width: itemWidth,
            );
          }).toList(),
        );
      },
    );
  }
}

class JobCategory {
  final IconData icon;
  final String title;

  JobCategory({
    required this.icon,
    required this.title,
  });
}

class JobCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double width;

  const JobCategoryCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate best height for symmetry
    final cardSize = width * 0.9; // Slightly smaller than width allocation
    
    return GestureDetector(
      onTap: () {
        // Show the bottom sheet when a category is tapped
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => WorkerTypeBottomSheet(
            jobCategory: title.replaceAll('\n', ' '),
          ),
        );
      },
      child: Column(
        children: [
          // Card container
          Container(
            width: cardSize,
            height: cardSize, // Square container
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: cardSize * 0.4, // Icon size proportional to card
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Text label with fixed height & ellipsis
          SizedBox(
            width: cardSize,
            height: 32.h, // Fixed height for title
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                height: 1.2, // Tight line height for better layout
                letterSpacing: -0.2
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// Bottom Sheet that appears when a category is clicked
class WorkerTypeBottomSheet extends StatelessWidget {
  final String jobCategory;
  
  const WorkerTypeBottomSheet({
    Key? key,
    required this.jobCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380.h, // Adjust height based on screen size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Handle indicator at the top
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2B8E).withOpacity(0.5), // Dark blue indicator
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 32.h),
          
          // Title and description text
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                Text(
                  'Post a job to reach workers around you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Browse through the applicants and choose the perfect fit.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // PART TIME WORKER Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to JobDetailsScreen with part-time selected
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(
                      jobCategory: jobCategory,
                      jobType: 'part-time',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0011C9), // Deep blue
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'PART TIME WORKER',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // FULL TIME WORKER Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to JobDetailsScreen with full-time selected
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailsScreen(
                      jobCategory: jobCategory,
                      jobType: 'full-time',
                    ),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0011C9), width: 1.5),
                foregroundColor: const Color(0xFF0011C9),
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                'FULL TIME WORKER',
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          SizedBox(height: 48.h), // Bottom padding
        ],
      ),
    );
  }
}// End: Original code with modifications

