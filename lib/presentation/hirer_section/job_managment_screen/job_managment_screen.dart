import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:lottie/lottie.dart';
import '../hirer_view_job_applications/hirer_view_job_applications.dart';

//! C L A S S - D E F I N I T I O N
class JobManagementScreen extends StatefulWidget {
  const JobManagementScreen({Key? key}) : super(key: key);

  @override
  _JobManagementScreenState createState() => _JobManagementScreenState();
}

class _JobManagementScreenState extends State<JobManagementScreen>
    with SingleTickerProviderStateMixin {
  final JobService _jobService = JobService();
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //! A P P - B A R
      appBar: AppBar(
          automaticallyImplyLeading: false,
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.work, size: 20),
                  SizedBox(width: 8),
                  Text('Active'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('Expired'),
                ],
              ),
            ),
          ],
          labelColor: Color(0xFF0000CC),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0000CC),
        ),
      ),
      //! M A I N - C O N T E N T
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveJobsList(),
          _buildExpiredJobsList(),
        ],
      ),
    );
  }
  
  //! A C T I V E - J O B S - L I S T
  Widget _buildActiveJobsList() {
    return StreamBuilder<List<JobModel>>(
      stream: _jobService.getActiveJobsForHirer(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
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
                  'No active jobs',
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(job, isActive: true);
          },
        );
      },
    );
  }

  //! E X P I R E D - J O B S - L I S T
  Widget _buildExpiredJobsList() {
    return StreamBuilder<List<JobModel>>(
      stream: _jobService.getExpiredJobsForHirer(
        FirebaseAuth.instance.currentUser?.uid ?? '',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(child:SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final jobs = snapshot.data ?? [];

        if (jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 80,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No expired jobs',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jobs expire 20 days after scheduled date',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            return _buildJobCard(job, isActive: false);
          },
        );
      },
    );
  }

  // Add this method to get application count for a specific job
  Stream<int> _getApplicationCount(String jobId) {
    return FirebaseFirestore.instance
        .collection('jobApplications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  //! J O B - C A R D
  Widget _buildJobCard(JobModel job, {required bool isActive}) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isActive 
        ? (isFullTime ? AppColors.green : Color(0xFF0000CC))
        : Colors.grey.shade400;

    // Define colors based on active/expired status
    final cardOpacity = isActive ? 1.0 : 0.6;
    final textColor = isActive ? Colors.black : Colors.grey.shade600;
    final iconColor = isActive ? AppColors.darkGrey : Colors.grey.shade400;

   return Opacity(
  opacity: cardOpacity,
  child: InkWell(
    onTap: isActive ? () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationListScreen(
            jobId: job.id,
            jobTitle: job.jobCategory,
          ),
        ),
      );
    } : null, // Disable tap for expired jobs
    borderRadius: BorderRadius.circular(16),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.05 : 0.02),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isActive 
              ? AppColors.black.withOpacity(0.3)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted date, job type and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 3),
                  child: Text(
                    'Posted ${_formatDate(job.createdAt)}',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: iconColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (!isActive) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'EXPIRED',
                          style: GoogleFonts.roboto(
                            fontSize: 10,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
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
                  color: textColor,
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
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Scheduled for ${_formatScheduledDate(job.date)}',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: iconColor,
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
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: iconColor,
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
                  color: iconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isFullTime
                      ? 'Rs. ${job.budget} per month'
                      : 'Rs. ${job.budget} per day',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
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
                  color: isActive 
                      ? Color(0xFF0000CC)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isActive ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ApplicationListScreen(
                            jobId: job.id,
                            jobTitle: job.jobCategory,
                          ),
                        ),
                      );
                    } : null, // Disable tap for expired jobs
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isActive ? Icons.people : Icons.lock,
                            size: 18,
                            color: isActive ? Colors.white : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          if (isActive) 
                            // Dynamic application count for active jobs
                            StreamBuilder<int>(
                              stream: _getApplicationCount(job.id),
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                
                                String buttonText;
                                if (count == 0) {
                                  buttonText = 'No Applications';
                                } else if (count == 1) {
                                  buttonText = '1 Application';
                                } else {
                                  buttonText = '$count Applications';
                                }
                                
                                return Text(
                                  buttonText,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                          else
                            // Static text for expired jobs
                            Text(
                              'Job Expired',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Show expiry information for expired jobs
            if (!isActive) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This job expired 20 days after the scheduled date',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
   ));
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
    String dayWithSuffix = _getDayWithSuffix(date.day);
    
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String monthName = months[date.month - 1];
    
    return '$dayWithSuffix $monthName ${date.year}';
  }
  
  //! O R D I N A L - S U F F I X
  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
}