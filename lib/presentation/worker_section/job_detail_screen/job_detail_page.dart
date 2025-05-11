import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';

class JobDetailScreen extends StatelessWidget {
  final JobModel job;

  const JobDetailScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  //! N A V I G A T I O N  B U T T O N S
  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),

          // Bookmark button
          GestureDetector(
            onTap: () {
              // Bookmark functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Job saved to bookmarks'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_border,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! H E A D E R  S E C T I O N
  Widget _buildHeader() {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Company logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      job.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.business,
                          color: AppColors.darkGrey,
                          size: 40,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.business,
                    color: AppColors.darkGrey,
                    size: 40,
                  ),
          ),

          const SizedBox(height: 16),

          // Job title
          Text(
            job.jobCategory,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Company name and industry
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                job.company,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
              if (job.hirerIndustry.isNotEmpty) ...[
                Text(
                  ' • ${job.hirerIndustry}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Location, job type, and salary information
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: jobTypeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job.jobType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColors.darkGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.location.split(',').first, // Only show city name
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      size: 14,
                      color: AppColors.darkGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFullTime && job.salaryRange != null
                          ? '${job.salaryRange!['min']}-${job.salaryRange!['max']}/mo'
                          : '${job.budget}/day',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //! I N F O R M A T I O N  S E C T I O N
  Widget _buildInformationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Location with full address
          _buildInfoItem(
            context,
            icon: Icons.location_on,
            title: 'Location',
            value: job.location,
          ),

          const Divider(height: 24),

          // Date and Time - Improved format
          _buildInfoItem(
            context,
            icon: Icons.calendar_today,
            title: 'Date',
            value: _formatDate(job.date),
          ),

          const Divider(height: 24),

          // Working Hours - Fixed to correctly display timeFormatted
          _buildInfoItem(
            context,
            icon: Icons.access_time,
            title: 'Arival Time',
            value: job.timeFormatted ?? 'Not specified',
          ),
        ],
      ),
    );
  }

// Add to JobDetailScreen class in the first file
  Future<void> _applyForJob(BuildContext context) async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to apply for jobs'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Check if already applied
      final applicationRef = FirebaseFirestore.instance
          .collection('jobApplications')
          .doc('${job.id}_${user.uid}');

      final applicationDoc = await applicationRef.get();
      if (applicationDoc.exists) {
        // Already applied, close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already applied for this job'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Get worker data
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .get();

      if (!workerDoc.exists) {
        // Close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Worker profile not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final workerData = workerDoc.data() as Map<String, dynamic>;

      // Create application record with composite ID (jobId_workerId)
      final application = {
        'jobId': job.id,
        'workerId': user.uid,
        'hirerId': job.hirerId,
        'workerName': workerData['name'] ?? 'No Name',
        'workerLocation': workerData['location'] ?? 'No Location',
        'workerProfileImage': workerData['profileImage'],
        'workerPhone': workerData['phoneNumber'] ?? '',
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
        'jobTitle': job.jobCategory,
        'jobCompany': job.company,
        'jobLocation': job.location,
        'jobBudget': job.budget,
        'jobType': job.jobType,
      };

      // Save to applications collection (for easy querying)
      await applicationRef.set(application);

      // Also add to worker's applications subcollection (for worker's profile)
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .collection('applications')
          .doc(job.id)
          .set(application);

      // Also add to job's applications subcollection (for hirer to see)
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(job.id)
          .collection('applications')
          .doc(user.uid)
          .set(application);

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying for job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Update the _buildApplyButton method to check if already applied
  Widget _buildApplyButton(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfApplied(),
      builder: (context, snapshot) {
        // Show loading indicator while checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(38.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final bool hasApplied = snapshot.data ?? false;

        return Padding(
          padding: const EdgeInsets.all(38.0),
          child: ElevatedButton(
            onPressed: hasApplied ? null : () => _applyForJob(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasApplied ? Colors.grey : Color(0xFF0000CC),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              hasApplied ? 'APPLIED' : 'APPLY NOW',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

// Add a method to check if the user has already applied
  Future<bool> _checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final applicationDoc = await FirebaseFirestore.instance
        .collection('jobApplications')
        .doc('${job.id}_${user.uid}')
        .get();

    return applicationDoc.exists;
  }

  String _formatDate(DateTime date) {
    // Format: "Monday, May 5, 2025"
    final List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF0000CC).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Color(0xFF0000CC),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //! J O B  D E S C R I P T I O N
  Widget _buildJobDescription() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Job Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            job.description ??
                "This is a sample job description and its going to be the easiest way the hirer would type it. And obviously is going to be less than 1 paragraph since what is there to tell more about it?",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to match UI background color
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // No app bar now
      body: Stack(
        children: [
          // Scroll content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 34),
                // Navigation buttons (replacing app bar)
                _buildNavigationButtons(context),

                // Top decoration
                Container(
                  height: 10,
                  width: double.infinity,
                  color: Colors.grey.shade50,
                ),

                // Header with logo, title, company
                _buildHeader(),

                const SizedBox(height: 24),

                // Job description
                _buildJobDescription(),

                // Information section
                _buildInformationSection(context),

                // Space for bottom button
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Fixed bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildApplyButton(context),
          ),
        ],
      ),
    );
  }
}
