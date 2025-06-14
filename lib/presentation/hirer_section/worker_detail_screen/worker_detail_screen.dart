import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../worker_section/job_detail_screen/job_application_modal.dart';

class WorkerDetailsPage extends StatefulWidget {
  final JobApplicationModel application;

  const WorkerDetailsPage({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  _WorkerDetailsPageState createState() => _WorkerDetailsPageState();
}

class _WorkerDetailsPageState extends State<WorkerDetailsPage> {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobService _jobService = JobService();
  bool _isLoading = true;
  Map<String, dynamic>? workerData;
  List<Map<String, dynamic>> completedJobs = [];
  Map<String, int> jobCategoryCounts = {};
  int totalJobsDone = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkerData();
  }

  Future<void> _loadWorkerData() async {
    try {
      // Fetch worker profile data
      final workerDoc = await _firestore
          .collection('workers')
          .doc(widget.application.workerId)
          .get();

      if (workerDoc.exists) {
        setState(() {
          workerData = workerDoc.data();
        });
      }

      // Fetch completed jobs using the same logic as worker's own profile
      await _loadCompletedJobs();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading worker data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // FIXED: Updated to match the worker profile logic - only show HIRED jobs
  Future<void> _loadCompletedJobs() async {
    try {
      print('🔍 Loading hired jobs for worker: ${widget.application.workerId}');
      
      // Get job applications where worker was HIRED/ACCEPTED by hirer
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: widget.application.workerId)
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
          
          // Handle location safely - clean format like "Kochi, Kerala"
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
      });

      print('📈 Final results: ${jobs.length} hired jobs loaded');
      
    } catch (e) {
      print('❌ Error loading hired jobs: $e');
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  // Clean solution: Fetch phone number directly from workers document
  Future<void> _makePhoneCall() async {
    try {
      print('📱 Fetching worker phone number from database...');
      
      // Fetch worker document directly
      final workerDoc = await _firestore
          .collection('workers')
          .doc(widget.application.workerId)
          .get();

      if (!workerDoc.exists) {
        throw Exception('Worker document not found');
      }

      final workerData = workerDoc.data() as Map<String, dynamic>?;
      if (workerData == null) {
        throw Exception('Worker data is null');
      }

      // Get the phone number from loginPhoneNumber field
      final phoneNumber = workerData['loginPhoneNumber'] as String?;
      print('📞 Found phone number: "$phoneNumber"');

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number not found in worker document');
      }

      // Clean and format the phone number
      String cleanedNumber = phoneNumber.trim();
      print('🧹 Cleaned number: "$cleanedNumber"');
      
      String formattedNumber;
      
      if (cleanedNumber.startsWith('+')) {
        formattedNumber = cleanedNumber;
      } else if (cleanedNumber.startsWith('91') && cleanedNumber.length >= 12) {
        formattedNumber = '+$cleanedNumber';
      } else if (cleanedNumber.length == 10) {
        formattedNumber = '+91$cleanedNumber';
      } else {
        formattedNumber = cleanedNumber.startsWith('+') ? cleanedNumber : '+$cleanedNumber';
      }
      
      print('📱 Final formatted number: "$formattedNumber"');
      
      final Uri phoneUri = Uri.parse('tel:$formattedNumber');
      print('🔗 Phone URI: $phoneUri');
      
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        print('✅ Phone dialer launched successfully');
      } else {
        throw Exception('Cannot launch phone dialer');
      }
      
    } catch (e) {
      print('💥 Error making phone call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error making call: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Updated WhatsApp function
  Future<void> _openWhatsApp() async {
    try {
      print('💬 Fetching worker phone number for WhatsApp...');
      
      final workerDoc = await _firestore
          .collection('workers')
          .doc(widget.application.workerId)
          .get();

      if (!workerDoc.exists) {
        throw Exception('Worker document not found');
      }

      final workerData = workerDoc.data() as Map<String, dynamic>?;
      if (workerData == null) {
        throw Exception('Worker data is null');
      }

      final phoneNumber = workerData['loginPhoneNumber'] as String?;
      print('📞 Found phone number for WhatsApp: "$phoneNumber"');

      if (phoneNumber == null || phoneNumber.isEmpty) {
        throw Exception('Phone number not found in worker document');
      }

      String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      print('🧹 Cleaned WhatsApp number: "$cleanedNumber"');
      
      String whatsappNumber;
      
      if (cleanedNumber.startsWith('91') && cleanedNumber.length >= 12) {
        whatsappNumber = cleanedNumber;
      } else if (cleanedNumber.length == 10) {
        whatsappNumber = '91$cleanedNumber';
      } else {
        whatsappNumber = cleanedNumber.startsWith('91') ? cleanedNumber : '91$cleanedNumber';
      }
      
      print('💬 Final WhatsApp number: "$whatsappNumber"');
      
      final whatsappUrl = Uri.parse('https://wa.me/$whatsappNumber');
      print('🔗 WhatsApp URL: $whatsappUrl');
      
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        print('✅ WhatsApp launched successfully');
      } else {
        print('❌ Primary WhatsApp URL failed, trying alternative...');
        
        final altWhatsappUrl = Uri.parse('whatsapp://send?phone=$whatsappNumber');
        print('🔗 Alternative WhatsApp URL: $altWhatsappUrl');
        
        if (await canLaunchUrl(altWhatsappUrl)) {
          await launchUrl(altWhatsappUrl, mode: LaunchMode.externalApplication);
          print('✅ Alternative WhatsApp launched successfully');
        } else {
          _showWhatsAppNotAvailableDialog(phoneNumber);
        }
      }
      
    } catch (e) {
      print('💥 Error opening WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(child: Text('Error opening WhatsApp: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        );
      }
    }
  }

  // Beautiful WhatsApp not available dialog
  void _showWhatsAppNotAvailableDialog(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildWhatsAppNotAvailableSheet(phoneNumber),
    );
  }

  Widget _buildWhatsAppNotAvailableSheet(String phoneNumber) {
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
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            
            // WhatsApp icon with error indicator
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF00A81E).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'asset/images-removebg-preview (1).png',
                      width: 40.w,
                      height: 40.w,
                      color: Color(0xFF00A81E).withOpacity(0.7),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.w,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 24.h),
            
            Text(
              'WhatsApp Not Available',
              style: GoogleFonts.roboto(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 12.h),
            
            Text(
              'WhatsApp is not installed on your device or this number may not be registered with WhatsApp.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: Color(0xFF414ce4),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    phoneNumber,
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _makePhoneCall();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00A81E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Call Instead',
                          style: GoogleFonts.roboto(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          final playStoreUrl = Uri.parse('https://play.google.com/store/apps/details?id=com.whatsapp');
                          if (await canLaunchUrl(playStoreUrl)) {
                            await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Color(0xFF414ce4),
                          side: BorderSide(color: Color(0xFF414ce4)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download, size: 18.sp),
                            SizedBox(width: 6.w),
                            Text(
                              'Install WhatsApp',
                              style: GoogleFonts.roboto(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12.w),
                    
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  void _hireWorker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHireConfirmationSheet(),
    );
  }
  
  Widget _buildHireConfirmationSheet() {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: Color(0xFF414ce4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                color: Color(0xFF414ce4),
                size: 40.sp,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            Text(
              'Hire this Worker?',
              style: GoogleFonts.roboto(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            Text(
              'You are about to hire ${widget.application.workerName} for this job. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirmHiring,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF414ce4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Confirm Hire',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _confirmHiring() async {
    try {
      Navigator.pop(context);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: SizedBox(
            width: 140,
            height: 140,
            child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
          )
        ),
      );

      await _firestore
          .collection('jobApplications')
          .doc(widget.application.id)
          .update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
        'hiredAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker hired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error hiring worker: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // FIXED: Updated location handling to match worker profile format
  Widget _buildLocationText(String workerId, String fallbackLocation) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('workers').doc(workerId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final location = data?['location'];
          
          String locationText = fallbackLocation;
          if (location != null) {
            if (location is Map) {
              // Extract just the place name, not the full object
              locationText = location['placeName']?.toString() ?? fallbackLocation;
            } else {
              locationText = location.toString();
            }
          }
          
          if (locationText.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: 18.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    locationText,
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
        }
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              size: 18.sp,
              color: Colors.white.withOpacity(0.9),
            ),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                fallbackLocation,
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
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
                child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
              )
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
                        _buildContactButtons(),
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
    return Container(
      width: double.infinity,
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

          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios),
                        color: Colors.white,
                      ),
                      Text(
                        "Worker Profile",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 35.w),
                    ],
                  ),
                ),

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
                    child: widget.application.workerProfileImage != null
                        ? CachedNetworkImage(
                            imageUrl: widget.application.workerProfileImage!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: Center(
                                child: SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
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

                SizedBox(height: 16.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.application.workerName,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 27.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(3.w),
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
                ),

                SizedBox(height: 12.h),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _buildLocationText(
                    widget.application.workerId, 
                    widget.application.workerLocation
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _makePhoneCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00A81E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone, size: 20.sp, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        'Call Now',
                        style: GoogleFonts.roboto(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: _openWhatsApp,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Color(0xFF00A81E)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'asset/images-removebg-preview (1).png',
                        width: 20.w,
                        height: 20.h,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'WhatsApp',
                        style: GoogleFonts.roboto(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          if (widget.application.status.toLowerCase() == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hireWorker,
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
                    SizedBox(width: 8.w),
                    Text(
                      'HIRE THIS WORKER',
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
            
          if (widget.application.isAccepted) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'HIRED',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
                      'This worker has no prior work experience in the app',
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

  // FIXED: Clean work history section without status indicators
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
                      'This worker has no completed work yet',
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
                
                final String jobTitle = job['jobTitle']?.toString() ?? 'Unknown Job';
                final String companyName = job['hirerBusinessName']?.toString() ?? 'Unknown Company';
                final String jobLocation = job['hirerLocation']?.toString() ?? 'Unknown Location';
                
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
                          // NO STATUS BADGE - clean design
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
                              jobLocation, // Clean location format
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
}