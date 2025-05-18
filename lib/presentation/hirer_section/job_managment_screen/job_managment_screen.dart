import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import '../hirer_view_job_applications/hirer_view_job_applications.dart';

//! C L A S S - D E F I N I T I O N
class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  _JobManagementScreenState createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen> {
  final JobService _jobService = JobService();
  
  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //! A P P - B A R
      appBar: AppBar(
        title: Text(
          'My Jobs',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      //! M A I N - C O N T E N T
      body: _buildJobList(),
      
    );
  }
  
  //! J O B - L I S T
  Widget _buildJobList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getJobsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final jobDocs = snapshot.data?.docs ?? [];

        if (jobDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_off,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No jobs posted yet',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a job to see it here',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        // Convert docs to JobModel
        final jobs = jobDocs.map((doc) => JobModel.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(job);
          },
        );
      },
    );
  }

  //! D A T A - F E T C H
  Stream<QuerySnapshot> _getJobsStream() {
    var query = FirebaseFirestore.instance
      .collection('jobs')
      .where('hirerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .orderBy('createdAt', descending: true);

    return query.snapshots();
  }

  //! J O B - C A R D
  Widget _buildJobCard(JobModel job) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.black.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posted date and job type
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
               padding: const EdgeInsets.only(left: 3),
                child: Text(
                  'Posted ${_formatDate(job.createdAt)}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: jobTypeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.jobType,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          // Job title
          Padding(
           padding: const EdgeInsets.only(left: 3),
            child: Text(
              job.jobCategory,
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 8),

          // Scheduled job date
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                'Scheduled for ${_formatScheduledDate(job.date)}',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.location,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: AppColors.darkGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Budget information
          Row(
            children: [
              Icon(
                Icons.currency_rupee,
                size: 16,
                color: AppColors.darkGrey,
              ),
              const SizedBox(width: 4),
              Text(
                isFullTime
                    ? 'Rs. ${job.budget} per month'
                    : 'Rs. ${job.budget} per day',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //! A C T I O N - B U T T O N S
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFF0000CC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ApplicationListScreen(
                        jobId: job.id,
                        jobTitle: job.jobCategory,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Applications',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //! D A T E - F O R M A T T I N G
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return difference.inMinutes == 1 
          ? '1 minute ago' 
          : '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return difference.inHours == 1 
          ? '1 hour ago' 
          : '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return difference.inDays == 1 
          ? '1 day ago' 
          : '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  //! S C H E D U L E D - D A T E - F O R M A T T I N G
  String _formatScheduledDate(DateTime date) {
    // Get day with ordinal suffix (1st, 2nd, 3rd, etc.)
    String dayWithSuffix = _getDayWithSuffix(date.day);
    
    // Get month name
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String monthName = months[date.month - 1];
    
    // Format the date as "1st May 2024"
    return '$dayWithSuffix $monthName ${date.year}';
  }
  
  //! O R D I N A L - S U F F I X
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th'; // 11th, 12th, 13th
    }
    
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
}