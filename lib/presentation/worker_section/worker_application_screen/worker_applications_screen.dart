// lib/presentation/worker_section/applications/worker_applications_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hey_work/presentation/worker_section/job_detail_screen/job_application_modal.dart';
import 'package:hey_work/presentation/worker_section/job_detail_screen/job_application_service.dart';
import 'package:hey_work/presentation/worker_section/job_detail_screen/worker_job_detail_page.dart'; 
import 'package:hey_work/core/services/database/jobs_service.dart' as jobs_service;
import 'package:lottie/lottie.dart';

class WorkerApplicationsScreen extends StatefulWidget {
  const WorkerApplicationsScreen({Key? key}) : super(key: key);

  @override
  _WorkerApplicationsScreenState createState() =>
      _WorkerApplicationsScreenState();
}

class _WorkerApplicationsScreenState extends State<WorkerApplicationsScreen>
    with SingleTickerProviderStateMixin {
  final JobApplicationService _applicationService = JobApplicationService();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Applications',
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
          labelColor: Color(0xFF0000CC),
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Color(0xFF0000CC),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Accepted'),
          ],
        ),
      ),
      body: StreamBuilder<List<JobApplicationModel>>(
        stream: _applicationService.getWorkerApplications(),
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

          final allApplications = snapshot.data ?? [];

          if (allApplications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No applications yet',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apply for jobs to see them here',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          final acceptedApplications =
              allApplications.where((app) => app.isAccepted).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // All applications
              _buildApplicationsList(allApplications),
              // Accepted applications
              acceptedApplications.isEmpty
                  ? _buildEmptyState('No accepted applications')
                  : _buildApplicationsList(acceptedApplications),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.roboto(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<JobApplicationModel> applications) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final application = applications[index];
        return _buildApplicationCard(application);
      },
    );
  }

  Widget _buildApplicationCard(JobApplicationModel application) {
    final statusColor = application.isPending
        ? Colors.orange
        : application.isAccepted
            ? AppColors.green
            : Colors.orange;

    final statusText = application.isPending
        ? 'Pending'
        : application.isAccepted
            ? 'Accepted'
            : 'Pending';

    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>  Center(
            child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ),
          ),
        );
        
        try {
          final jobDoc = await FirebaseFirestore.instance
              .collection('jobs')
              .doc(application.jobId)
              .get();
          
          Navigator.pop(context);
          
          if (jobDoc.exists) {
            final job = jobs_service.JobModel.fromFirestore(jobDoc);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailScreen(job: job),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job not found or has been removed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading job details: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
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
            // Application status and job type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.darkGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Applied ${_formatDate(application.appliedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Job title and company with dynamic hirer image using CachedNetworkImage
            Row(
              children: [
                // FutureBuilder to load job details and show hirer image
                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('jobs')
                      .doc(application.jobId)
                      .get(),
                  builder: (context, snapshot) {
                    String? imageUrl;
                    
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final jobData = snapshot.data!.data() as Map<String, dynamic>;
                      imageUrl = jobData['hirerProfileImage'];
                    }

                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.fitWidth,
                                placeholder: (context, url) => Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                             
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.business,
                                    color: AppColors.darkGrey,
                                    size: 24,
                                  ),
                                ),
                                fadeInDuration: const Duration(milliseconds: 300),
                                fadeOutDuration: const Duration(milliseconds: 100),
                                // Cache configuration
                                memCacheWidth: 100, // Optimize memory usage
                                memCacheHeight: 100,
                                maxWidthDiskCache: 200,
                                maxHeightDiskCache: 200,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.business,
                                  color: AppColors.darkGrey,
                                  size: 24,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.jobTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        application.jobCompany,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.darkGrey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    application.jobLocation,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Job type and budget
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 16,
                  color: AppColors.darkGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${application.jobBudget}/day',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}