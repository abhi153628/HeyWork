import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heywork/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({Key? key}) : super(key: key);

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> completedJobs = [];
  Map<String, int> jobCategoryCounts = {};
  int totalJobsDone = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      print('👤 Loading user data for: ${user.uid}');
      
      // Get worker data
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = 
          await _firestore
              .collection('workers')
              .doc(user.uid)
              .get();
          
      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          userData = docSnapshot.data();
        });
        
        print('✅ Worker data loaded: ${userData?['name']}');
        
        // Load completed jobs
        await _loadCompletedJobs(user.uid);
        
      } else {
        print('❌ Worker document does not exist');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
 // Replace your _loadCompletedJobs method with this simple version:

// Replace your _loadCompletedJobs method with this clean version:

Future<void> _loadCompletedJobs(String workerId) async {
  try {
    print('🔍 Loading hired jobs for worker: $workerId');
    
    // Get job applications where worker was HIRED/ACCEPTED by hirer
    final jobsSnapshot = await _firestore
        .collection('jobApplications')
        .where('workerId', isEqualTo: workerId)
        .get();

    print('📊 Found ${jobsSnapshot.docs.length} total job applications');

    List<Map<String, dynamic>> jobs = [];
    Map<String, int> categoryCounts = {};

    // Process each job application and show only HIRED ones
    for (var doc in jobsSnapshot.docs) {
      final applicationData = doc.data();
      final applicationStatus = applicationData['status']?.toString() ?? 'pending';
      
      print('📋 Checking application: ${applicationData['jobTitle']} - Status: $applicationStatus');

      // ONLY include jobs where worker was HIRED/ACCEPTED
      if (applicationStatus == 'accepted' || 
          applicationStatus == 'hired' || 
          applicationStatus == 'completed' || 
          applicationStatus == 'approved' ||
          applicationStatus == 'confirmed' ||
          applicationStatus == 'selected') {
        
        // Extract data safely from application
        final String jobTitle = applicationData['jobTitle']?.toString() ?? 'Unknown Job';
        final String company = applicationData['jobCompany']?.toString() ?? 'Unknown Company';
        
        // Handle location safely
        String location = 'Unknown Location';
        if (applicationData['jobLocation'] != null) {
          location = applicationData['jobLocation'].toString();
        }
        
        final String jobType = applicationData['jobType']?.toString() ?? 'part-time';
        
        // Handle budget safely
        dynamic budget = 0;
        if (applicationData['jobBudget'] != null) {
          if (applicationData['jobBudget'] is num) {
            budget = applicationData['jobBudget'];
          } else if (applicationData['jobBudget'] is String) {
            budget = int.tryParse(applicationData['jobBudget']) ?? 0;
          }
        }

        // Create job details from application data
        final jobDetails = {
          'id': doc.id,
          'jobTitle': jobTitle,
          'hirerBusinessName': company,
          'hirerLocation': location,
          'jobType': jobType,
          'description': applicationData['jobDescription']?.toString() ?? '',
          'budget': budget,
          'date': applicationData['appliedAt'] ?? Timestamp.now(),
          'createdAt': applicationData['appliedAt'] ?? Timestamp.now(),
          'jobCategory': jobTitle,
          'hirerId': applicationData['hirerId']?.toString() ?? '',
          'workerId': applicationData['workerId']?.toString() ?? '',
        };
        
        jobs.add(jobDetails);
        categoryCounts[jobTitle] = (categoryCounts[jobTitle] ?? 0) + 1;
        
        print('✅ Added hired job: $jobTitle at $company');
      }
    }

    setState(() {
      completedJobs = jobs;
      jobCategoryCounts = categoryCounts;
      totalJobsDone = jobs.length;
      _isLoading = false;
    });

    print('📈 Final results: ${jobs.length} hired jobs loaded');

  } catch (e) {
    print('❌ Error loading hired jobs: $e');
    setState(() {
      _isLoading = false;
    });
  }
}

// Clean work history section WITHOUT any status indicators:

Widget _buildJobHistorySection() {
  return Container(
    margin: EdgeInsets.only(bottom: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Work History',
          style: GoogleFonts.roboto(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        
        if (completedJobs.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Column(
                children: [
                  Icon(
                    Icons.work_history,
                    size: 40.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No work history yet',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Complete jobs to build your work history',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: completedJobs.length,
            itemBuilder: (context, index) {
              final job = completedJobs[index];
              
              // Format date safely
              String formattedDate = 'Unknown date';
              try {
                if (job['date'] != null && job['date'] is Timestamp) {
                  final date = (job['date'] as Timestamp).toDate();
                  formattedDate = '${date.day}/${date.month}/${date.year}';
                }
              } catch (e) {
                print('Error formatting date: $e');
              }
              
              final isLastItem = index == completedJobs.length - 1;
              
              // Extract data safely
              final String jobTitle = job['jobTitle']?.toString() ?? 'Unknown Job';
              final String companyName = job['hirerBusinessName']?.toString() ?? 'Unknown Company';
              final String jobLocation = job['hirerLocation']?.toString() ?? 'Unknown Location';
              final String jobType = job['jobType']?.toString() ?? 'part-time';
              
              return Container(
                margin: EdgeInsets.only(bottom: isLastItem ? 0 : 8.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF414ce4).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.work,
                            color: Color(0xFF414ce4),
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobTitle,
                                style: GoogleFonts.roboto(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                companyName,
                                style: GoogleFonts.roboto(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // NO STATUS BADGE - completely removed
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            jobLocation,
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 50.w),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          formattedDate,
                          style: GoogleFonts.roboto(
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    // Show budget if available
                    if (job['budget'] != null && job['budget'] != 0) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            size: 16.sp,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '₹${job['budget']}',
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    ),
  );
}

  // Method 1: Load from job applications with completed status
  Future<void> _loadFromJobApplications(String workerId) async {
    try {
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: workerId)
          .get();

      print('📊 Found ${jobsSnapshot.docs.length} job applications');

      List<Map<String, dynamic>> jobs = [];
      Map<String, int> categoryCounts = {};

      for (var doc in jobsSnapshot.docs) {
        final jobData = doc.data();
        final jobId = jobData['jobId'];
        final applicationStatus = jobData['status'];
        
        print('📋 Application Status: $applicationStatus, JobID: $jobId');

        // Check for completed/accepted status
        if (applicationStatus != null && 
            (applicationStatus == 'accepted' || 
             applicationStatus == 'completed' || 
             applicationStatus == 'hired' || 
             applicationStatus == 'finished' ||
             applicationStatus == 'done' ||
             applicationStatus == 'success' ||
             applicationStatus == 'approved')) {
          
          if (jobId != null) {
            final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
            if (jobDoc.exists) {
              final fullJobData = jobDoc.data() ?? {};
              final jobDetails = _createJobDetails(doc.id, fullJobData, jobData);
              jobs.add(jobDetails);
              
              final category = fullJobData['jobCategory'] ?? 'Uncategorized';
              categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
              
              print('✅ Added completed job: ${jobDetails['jobTitle']}');
            }
          }
        }
      }

      if (jobs.isNotEmpty) {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = jobs.length;
        print('✅ Loaded ${jobs.length} completed jobs from applications');
      }
    } catch (e) {
      print('❌ Error loading from job applications: $e');
    }
  }

  // Method 2: Load from jobs collection directly
  Future<void> _loadFromJobsCollection(String workerId) async {
    try {
      // Try different field names for worker assignment
      List<QuerySnapshot> queries = [];
      
      // Query 1: assignedWorkerId field
      queries.add(await _firestore
          .collection('jobs')
          .where('assignedWorkerId', isEqualTo: workerId)
          .get());
      
      // Query 2: workerId field
      queries.add(await _firestore
          .collection('jobs')
          .where('workerId', isEqualTo: workerId)
          .get());
      
      // Query 3: hiredWorkerId field
      queries.add(await _firestore
          .collection('jobs')
          .where('hiredWorkerId', isEqualTo: workerId)
          .get());

      List<Map<String, dynamic>> jobs = [];
      Map<String, int> categoryCounts = {};

      for (var querySnapshot in queries) {
        print('🔍 Found ${querySnapshot.docs.length} direct jobs in query');
        
        for (var doc in querySnapshot.docs) {
          final jobData = doc.data() as Map<String, dynamic>;
          final status = jobData['status'];
          
          // Check if job is completed
          if (status == 'completed' || 
              status == 'finished' || 
              status == 'done' ||
              status == 'success' ||
              jobData['isCompleted'] == true) {
            
            final jobDetails = _createJobDetails(doc.id, jobData, {});
            jobs.add(jobDetails);
            
            final category = jobData['jobCategory'] ?? 'Uncategorized';
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            
            print('✅ Added direct job: ${jobDetails['jobTitle']}');
          }
        }
      }

      if (jobs.isNotEmpty) {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = jobs.length;
        print('✅ Loaded ${jobs.length} completed jobs from jobs collection');
      }
    } catch (e) {
      print('❌ Error loading from jobs collection: $e');
    }
  }

  // Method 3: Load from work history collection (if exists)
  Future<void> _loadFromWorkHistoryCollection(String workerId) async {
    try {
      final workHistorySnapshot = await _firestore
          .collection('workHistory')
          .where('workerId', isEqualTo: workerId)
          .get();

      print('🔍 Found ${workHistorySnapshot.docs.length} work history records');

      if (workHistorySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> jobs = [];
        Map<String, int> categoryCounts = {};

        for (var doc in workHistorySnapshot.docs) {
          final historyData = doc.data();
          final jobDetails = _createJobDetails(doc.id, historyData, {});
          jobs.add(jobDetails);
          
          final category = historyData['jobCategory'] ?? 'Uncategorized';
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
          
          print('✅ Added work history: ${jobDetails['jobTitle']}');
        }

        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = jobs.length;
        print('✅ Loaded ${jobs.length} jobs from work history collection');
      }
    } catch (e) {
      print('❌ Error loading from work history: $e');
    }
  }

  // Method 4: Load from worker document subcollection
  Future<void> _loadFromWorkerSubcollection(String workerId) async {
    try {
      final completedJobsSnapshot = await _firestore
          .collection('workers')
          .doc(workerId)
          .collection('completedJobs')
          .get();

      print('🔍 Found ${completedJobsSnapshot.docs.length} completed jobs in subcollection');

      if (completedJobsSnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> jobs = [];
        Map<String, int> categoryCounts = {};

        for (var doc in completedJobsSnapshot.docs) {
          final jobData = doc.data();
          final jobDetails = _createJobDetails(doc.id, jobData, {});
          jobs.add(jobDetails);
          
          final category = jobData['jobCategory'] ?? 'Uncategorized';
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
          
          print('✅ Added subcollection job: ${jobDetails['jobTitle']}');
        }

        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = jobs.length;
        print('✅ Loaded ${jobs.length} jobs from worker subcollection');
      }
    } catch (e) {
      print('❌ Error loading from worker subcollection: $e');
    }
  }

  // Helper method to create consistent job details
  Map<String, dynamic> _createJobDetails(String docId, Map<String, dynamic> jobData, Map<String, dynamic> applicationData) {
    // Helper functions for safe data extraction
    String getJobTitle(Map<String, dynamic> data) {
      return data['jobCategory'] ?? 
             data['jobTitle'] ?? 
             data['title'] ?? 
             data['name'] ?? 
             applicationData['jobTitle'] ??
             'Unknown Job';
    }
    
    String getCompanyName(Map<String, dynamic> data) {
      return data['hirerBusinessName'] ?? 
             data['company'] ?? 
             data['businessName'] ?? 
             data['companyName'] ?? 
             applicationData['jobCompany'] ??
             'Unknown Company';
    }
    
    String getJobLocation(Map<String, dynamic> data) {
      if (data['hirerLocation'] != null) {
        final loc = data['hirerLocation'];
        if (loc is Map && loc['placeName'] != null) {
          return loc['placeName'];
        } else if (loc is String) {
          return loc;
        }
      }
      return data['location'] ?? 
             data['jobLocation'] ?? 
             applicationData['jobLocation'] ??
             'Unknown Location';
    }
    
    String getJobType(Map<String, dynamic> data) {
      return data['jobType'] ?? 
             data['type'] ?? 
             data['workType'] ?? 
             applicationData['jobType'] ??
             'part-time';
    }
    
    dynamic getBudget(Map<String, dynamic> data) {
      return data['budget'] ?? 
             data['salary'] ?? 
             data['payment'] ?? 
             applicationData['jobBudget'] ??
             0;
    }

    return {
      'id': docId,
      'jobTitle': getJobTitle(jobData),
      'hirerBusinessName': getCompanyName(jobData),
      'hirerLocation': getJobLocation(jobData),
      'jobType': getJobType(jobData),
      'description': jobData['description'] ?? '',
      'budget': getBudget(jobData),
      'date': jobData['date'] ?? jobData['createdAt'] ?? applicationData['appliedAt'],
      'createdAt': jobData['createdAt'] ?? applicationData['appliedAt'],
      'status': 'completed',
      'jobCategory': jobData['jobCategory'] ?? 'General',
      // Include original data
      ...jobData,
    };
  }

// Replace your _loadCompletedJobs method with this version that only shows HIRED jobs:


// Update the section title and empty state to reflect "Work History" (hired jobs only):

  
  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
  
  void _navigateToEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(
        userData: userData,
        onProfileUpdated: () {
          _loadUserData();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      body: _isLoading
          ? Center(
              child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                children: [
                  _buildProfileHeader(),
    
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditProfileButton(),
                        _buildExperienceSection(),
                        _buildJobHistorySection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    String name = userData?['name'] ?? 'Worker Name';
    String location = 'Location';
    
    if (userData != null && userData!.containsKey('location')) {
      final locationData = userData!['location'];
      if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
        location = locationData['placeName'] ?? 'Location';
      } else if (locationData is String) {
        location = locationData;
      }
    }
    
    final String? profileImage = userData?['profileImage'];
    
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Color(0xFF414ce4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90.w,
            top: 140.h,
            child: Transform.rotate(
              angle: -0.99,
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Color(0xFF000ec4),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),
          Positioned(
            right: -100.w,
            bottom: 100.h,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Color(0xFF5c63fc),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w, 
                      vertical: 15.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 35.w),
                        Text(
                          "Worker",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SettingsScreen()),
                          ),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(flex: 1),

                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.r),
                      child: profileImage != null && profileImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: SizedBox(
                        width: 140,
                        height: 140,
                        child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                      )
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 50.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 50.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),

                  Spacer(flex: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 27.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          location,
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _navigateToEditProfile(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF414ce4),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 22.sp,color: Colors.white,),
              SizedBox(width: 8.w),
              Text(
                'EDIT PROFILE',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: Color(0xFF414ce4),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Work Experience',
                style: GoogleFonts.roboto(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF414ce4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Color(0xFF414ce4),
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Total Works: $totalJobsDone',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF414ce4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          if (jobCategoryCounts.isNotEmpty) ...[
            Text(
              'Experience by Category:',
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: jobCategoryCounts.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No work history yet',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Complete your first job to see your experience here',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

 
}

// [The EditProfileBottomSheet and related classes remain the same as in your original code]

// Enhanced EditProfileBottomSheet with image cropping and compression
class EditProfileBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onProfileUpdated;

  const EditProfileBottomSheet({
    Key? key,
    required this.userData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileBottomSheetState createState() => _EditProfileBottomSheetState();
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  bool _isImageProcessing = false; // Add this for image processing state
  File? _imageFile;
  String? _currentImageUrl;
  
  // Add these new fields for location search
  List<Map<String, String>> _locationSuggestions = [];
  Map<String, String>? _selectedLocation;
  bool _showLocationSuggestions = false;
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.userData != null) {
      _nameController.text = widget.userData!['name'] ?? '';
      
      if (widget.userData!.containsKey('location')) {
        final locationData = widget.userData!['location'];
        if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
          _locationController.text = locationData['placeName'] ?? '';
        } else if (locationData is String) {
          _locationController.text = locationData;
        }
      }
      
      _currentImageUrl = widget.userData!['profileImage'];
    }
  }
  
  // Add this method for location search
  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _showLocationSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showLocationSuggestions = true;
    });

    try {
      final suggestions = await fetchLocationSuggestions(query);
      setState(() {
        _locationSuggestions = suggestions;
        _isSearching = false;
      });
    } catch (e) {
      print('Error fetching locations: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  // Add the location API methods
  Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
    // First try cached results for faster response
    if (_cachedLocations.containsKey(query)) {
      return _cachedLocations[query]!;
    }

    // Next, check the most popular Indian cities
    List<Map<String, String>> filteredCities = _indianCities
        .where((city) => city['placeName']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredCities.isNotEmpty) {
      _cachedLocations[query] = filteredCities;
      return filteredCities;
    }

    try {
      // If no local matches, try the API
      final apiResults = await fetchFromOpenStreetMap(query);
      _cachedLocations[query] = apiResults;
      return apiResults;
    } catch (e) {
      print("OpenStreetMap API error: $e");
      return _getMockData(query);
    }
  }

  // Static cache for location results
  static Map<String, List<Map<String, String>>> _cachedLocations = {};

  // Method to fetch data from OpenStreetMap
  Future<List<Map<String, String>>> fetchFromOpenStreetMap(String query) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$query+india&format=json&addressdetails=1&limit=10&countrycodes=in&bounded=1';

    Map<String, String> headers = {
      'User-Agent': 'YourApp/1.0',
      'Accept-Language': 'en-US,en;q=0.9',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);

      return results.map<Map<String, String>>((result) {
        String displayName = result['display_name'] ?? '';
        Map<String, dynamic> address = result['address'] ?? {};
        
        String formattedName = '';
        List<String> addressParts = [];

        if (address.isNotEmpty) {
          if (address['city'] != null) addressParts.add(address['city']);
          else if (address['town'] != null) addressParts.add(address['town']);
          else if (address['village'] != null) addressParts.add(address['village']);
          else if (address['suburb'] != null) addressParts.add(address['suburb']);

          if (address['state_district'] != null) addressParts.add(address['state_district']);
          else if (address['county'] != null) addressParts.add(address['county']);
          
          if (address['state'] != null) addressParts.add(address['state']);
          
          formattedName = addressParts.join(', ');
        }

        if (formattedName.isEmpty) {
          List<String> nameParts = displayName.split(', ');
          formattedName = nameParts.length > 3
              ? '${nameParts[0]}, ${nameParts[nameParts.length - 3]}, India'
              : displayName.replaceAll(', India', '') + ', India';
        }

        return {
          'placeName': formattedName,
          'placeId': result['place_id']?.toString() ?? '',
          'latitude': result['lat']?.toString() ?? '',
          'longitude': result['lon']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load from OpenStreetMap: ${response.statusCode}');
    }
  }

  // Popular Indian cities data for quick results
  final List<Map<String, String>> _indianCities = [
    {'placeName': 'Mumbai, Maharashtra', 'placeId': 'city_mumbai', 'latitude': '19.0760', 'longitude': '72.8777'},
    {'placeName': 'Delhi, NCR', 'placeId': 'city_delhi', 'latitude': '28.7041', 'longitude': '77.1025'},
    {'placeName': 'Bangalore, Karnataka', 'placeId': 'city_bangalore', 'latitude': '12.9716', 'longitude': '77.5946'},
    {'placeName': 'Hyderabad, Telangana', 'placeId': 'city_hyderabad', 'latitude': '17.3850', 'longitude': '78.4867'},
    {'placeName': 'Chennai, Tamil Nadu', 'placeId': 'city_chennai', 'latitude': '13.0827', 'longitude': '80.2707'},
    {'placeName': 'Kolkata, West Bengal', 'placeId': 'city_kolkata', 'latitude': '22.5726', 'longitude': '88.3639'},
    {'placeName': 'Pune, Maharashtra', 'placeId': 'city_pune', 'latitude': '18.5204', 'longitude': '73.8567'},
    {'placeName': 'Ahmedabad, Gujarat', 'placeId': 'city_ahmedabad', 'latitude': '23.0225', 'longitude': '72.5714'},
    {'placeName': 'Jaipur, Rajasthan', 'placeId': 'city_jaipur', 'latitude': '26.9124', 'longitude': '75.7873'},
    {'placeName': 'Kochi, Kerala', 'placeId': 'city_kochi', 'latitude': '9.9312', 'longitude': '76.2673'},
    {'placeName': 'Goa', 'placeId': 'city_goa', 'latitude': '15.2993', 'longitude': '74.1240'},
  ];

  // Mock data for fallback
  List<Map<String, String>> _getMockData(String query) {
    return [
      {'placeName': 'Delhi, NCR, India', 'placeId': 'mock_delhi', 'latitude': '28.7041', 'longitude': '77.1025'},
      {'placeName': 'Mumbai, Maharashtra, India', 'placeId': 'mock_mumbai', 'latitude': '19.0760', 'longitude': '72.8777'},
      {'placeName': '$query Area, India', 'placeId': 'mock_custom', 'latitude': '20.5937', 'longitude': '78.9629'},
    ];
  }
  
  // Enhanced image picker with crop and compression (from signup)
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  "Update Profile Picture",
                  style: GoogleFonts.roboto(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Image will be automatically optimized",
                  style: GoogleFonts.roboto(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),

                // Camera Option
                _buildOptionTile(
                  context: context,
                  icon: Icons.camera_alt,
                  title: "Camera",
                  subtitle: "Take a new photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.camera);
                  },
                ),

                SizedBox(height: 16.h),

                // Gallery Option
                _buildOptionTile(
                  context: context,
                  icon: Icons.photo_library,
                  title: "Gallery",
                  subtitle: "Choose from library",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.gallery);
                  },
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Color(0xFF414ce4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Color(0xFF414ce4),
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced image picker with cropping functionality (from signup)
  Future<void> _pickAndCropImage(ImageSource source) async {
    setState(() {
      _isImageProcessing = true;
    });

    try {
      print('📸 Starting image selection and processing...');

      // Pick image with built-in compression
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024, // Optimal size for profile pics
        maxHeight: 1024, // Optimal size for profile pics
        imageQuality: 75, // Good compression (75% quality)
      );

      if (pickedFile == null) {
        setState(() {
          _isImageProcessing = false;
        });
        return;
      }

      print('📏 Image picked, starting crop...');

      // Crop with additional compression
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80, // Additional compression
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Color(0xFF414ce4),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Color(0xFF414ce4),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        final File finalImage = File(croppedFile.path);
        final int finalSize = await finalImage.length();
        final double finalSizeMB = finalSize / 1024 / 1024;

        print('✅ Image processed! Final size: ${finalSizeMB.toStringAsFixed(2)} MB');

        setState(() {
          _imageFile = finalImage;
        });
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to process image. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageProcessing = false;
        });
      }
    }
  }

  // Enhanced image upload method with compression (from signup)
  Future<String?> _uploadProfileImage(String userId) async {
    if (_imageFile == null) return _currentImageUrl;
    
    try {
      print('Starting optimized image upload...');

      // Get file size
      final int fileSize = await _imageFile!.length();
      print('Image file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Generate unique filename
      final uuid = Uuid();
      String fileName = '${uuid.v4()}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName');

      // Upload with metadata
      final uploadTask = storageRef.putFile(
        _imageFile!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'file_size': '$fileSize',
            'optimized': 'true',
          },
        ),
      );

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
  
  // Update the upload method to include location data
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user signed in'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      // Upload new profile image if selected
      final String? profileImageUrl = await _uploadProfileImage(user.uid);
      
      // Prepare location data
      Map<String, dynamic> locationData;
      if (_selectedLocation != null) {
        locationData = {
          'placeName': _selectedLocation!['placeName'],
          'placeId': _selectedLocation!['placeId'],
          'latitude': _selectedLocation!['latitude'],
          'longitude': _selectedLocation!['longitude'],
        };
      } else {
        locationData = {'placeName': _locationController.text};
      }
      
      // Update firestore
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'location': locationData,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Notify parent about the update
      widget.onProfileUpdated();
      
      // Show success message and close bottom sheet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF414ce4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
    
  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF414ce4),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                // Enhanced Profile Image Picker with cropping
                Center(
                  child: GestureDetector(
                    onTap: _isImageProcessing ? null : () => _showImagePickerDialog(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.r),
                            child: _isImageProcessing
                                ? Container(
                                    color: Colors.grey[300],
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 30.w,
                                          height: 30.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            color: Color(0xFF414ce4),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Processing...",
                                          style: GoogleFonts.roboto(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : (_imageFile != null
                                    ? Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: _currentImageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: SizedBox(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 50.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.add_a_photo,
                                                  size: 32.w,
                                                  color: Colors.grey.shade500,
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  "Add Photo",
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))),
                          ),
                        ),
                        if (!_isImageProcessing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: Color(0xFF414ce4),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Name Field
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                // Location Field with Search
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                Column(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'Enter your location',
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        suffixIcon: _isSearching
                            ? Padding(
                                padding: EdgeInsets.all(12.w),
                                child: SizedBox(
                                  height: 16.h,
                                  width: 16.w,
                                  child: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF414ce4),
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your location';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _searchDebouncer.run(() {
                          _searchLocation(value);
                        });
                      },
                      onTap: () {
                        if (_locationController.text.length >= 3) {
                          setState(() {
                            _showLocationSuggestions = true;
                          });
                        }
                      },
                    ),
                    if (_showLocationSuggestions && _locationSuggestions.isNotEmpty)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        constraints: BoxConstraints(maxHeight: 200.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemCount: _locationSuggestions.length > 5 ? 5 : _locationSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = _locationSuggestions[index];
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedLocation = suggestion;
                                  _locationController.text = suggestion['placeName'] ?? '';
                                  _showLocationSuggestions = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 20.sp,
                                      color: Color(0xFF414ce4),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        suggestion['placeName'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                
                SizedBox(height: 32.h),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF414ce4),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24.h,
                            width: 24.h,
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),
                          ),
                  ),
                ),
                
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}