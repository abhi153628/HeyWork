import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/job_detail_page.dart/job_detail.dart';








// Bottom Sheet that appears when a category is clicked (Fixed without ScreenUtil)
class WorkerTypeBottomSheet extends StatelessWidget {
  final String jobCategory;
  
  const WorkerTypeBottomSheet({
    Key? key,
    required this.jobCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380, // Fixed height instead of using ScreenUtil
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle indicator at the top
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2B8E).withOpacity(0.5), // Dark blue indicator
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          
          // Title and description text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Text(
                  'Post a job to reach workers around you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Browse through the applicants and choose the perfect fit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                'PART TIME WORKER',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // FULL TIME WORKER Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'FULL TIME WORKER',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }
}

// Placeholder for JobDetailsScreen
class JobDetailsScreen extends StatelessWidget {
  final String jobCategory;
  final String jobType;
  
  const JobDetailsScreen({
    Key? key,
    required this.jobCategory,
    required this.jobType,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$jobCategory - $jobType'),
      ),
      body: const Center(
        child: Text('Job Details Screen'),
      ),
    );
  }
}