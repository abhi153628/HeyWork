import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
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
  final JobService _jobService = JobService(); // Enhanced job service
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

      // Fetch completed jobs using enhanced service
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

  Future<void> _loadCompletedJobs() async {
    try {
      print('Loading completed jobs for worker: ${widget.application.workerId}');
      
      // Query for completed jobs where worker was hired
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: widget.application.workerId)
          .where('status', isEqualTo: 'accepted')
          .get();

      List<Map<String, dynamic>> jobs = [];
      Map<String, int> categoryCounts = {};
      int totalJobs = 0;

      // Process each job application
      for (var doc in jobsSnapshot.docs) {
        final jobData = doc.data();
        final jobId = jobData['jobId'];

        print('Processing job application: ${doc.id}, jobId: $jobId');

        // Get the actual job details
        if (jobId != null) {
          final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
          
          if (jobDoc.exists) {
            final fullJobData = jobDoc.data() ?? {};
            
            // Helper function to safely get job title
            String getJobTitle(Map<String, dynamic> data) {
              // In your database, jobCategory IS the job title (Cashier, Security Guard, etc.)
              final jobTitle = data['jobCategory'] ?? 
                               data['jobTitle'] ?? 
                               data['title'] ?? 
                               data['name'] ?? 
                               'Unknown Job';
              
              print('DEBUG: Job title from jobCategory: $jobTitle');
              return jobTitle;
            }
            
            // Helper function to safely get company name
            String getCompanyName(Map<String, dynamic> data) {
              return data['hirerBusinessName'] ?? 
                     data['company'] ?? 
                     data['businessName'] ?? 
                     data['companyName'] ?? 
                     'Unknown Company';
            }
            
            // Helper function to safely get location
            String getJobLocation(Map<String, dynamic> data) {
              return data['hirerLocation'] ?? 
                     data['location'] ?? 
                     data['jobLocation'] ?? 
                     'Unknown Location';
            }
            
            // Helper function to safely get job type
            String getJobType(Map<String, dynamic> data) {
              return data['jobType'] ?? 
                     data['type'] ?? 
                     data['workType'] ?? 
                     'part-time';
            }
            
            // Create job details with proper extraction
            final jobDetails = {
              'id': jobDoc.id,
              'jobTitle': getJobTitle(fullJobData),
              'hirerBusinessName': getCompanyName(fullJobData),
              'hirerLocation': getJobLocation(fullJobData),
              'jobType': getJobType(fullJobData),
              'description': fullJobData['description'] ?? '',
              'budget': fullJobData['budget'] ?? 0,
              'date': fullJobData['date'],
              'createdAt': fullJobData['createdAt'],
              'status': fullJobData['status'] ?? 'completed',
              'jobCategory': fullJobData['jobCategory'] ?? 'General',
              // Include all original data for compatibility
              ...fullJobData,
            };
            
            jobs.add(jobDetails);
            print('Added job: ${jobDetails['jobTitle']}');

            // Count job categories
            final category = fullJobData['jobCategory'] ?? 'Uncategorized';
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            totalJobs++;
          } else {
            print('Job document not found for jobId: $jobId');
          }
        }
      }

      setState(() {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = totalJobs;
      });

      print('Total completed jobs found: ${jobs.length}');
      
      // Debug: Print first job title if available
      if (jobs.isNotEmpty) {
        print('First job title: ${jobs.first['jobTitle']}');
        print('All job titles: ${jobs.map((job) => job['jobTitle']).toList()}');
      }
    } catch (e) {
      print('Error loading completed jobs: $e');
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
    
    // The number from your database is already in correct format (+918078339710)
    // But let's ensure it's properly formatted
    String formattedNumber;
    
    if (cleanedNumber.startsWith('+')) {
      // Already properly formatted
      formattedNumber = cleanedNumber;
    } else if (cleanedNumber.startsWith('91') && cleanedNumber.length >= 12) {
      // Add + to country code
      formattedNumber = '+$cleanedNumber';
    } else if (cleanedNumber.length == 10) {
      // Add +91 to 10-digit number
      formattedNumber = '+91$cleanedNumber';
    } else {
      // Use as is, but ensure it has +
      formattedNumber = cleanedNumber.startsWith('+') ? cleanedNumber : '+$cleanedNumber';
    }
    
    print('📱 Final formatted number: "$formattedNumber"');
    
    // Create the tel URI
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

// Updated WhatsApp function with beautiful error dialog

Future<void> _openWhatsApp() async {
  try {
    print('💬 Fetching worker phone number for WhatsApp...');
    
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
    print('📞 Found phone number for WhatsApp: "$phoneNumber"');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      throw Exception('Phone number not found in worker document');
    }

    // Clean the phone number for WhatsApp (remove + and non-digits)
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    print('🧹 Cleaned WhatsApp number: "$cleanedNumber"');
    
    // Format for WhatsApp (should be: 918078339710)
    String whatsappNumber;
    
    if (cleanedNumber.startsWith('91') && cleanedNumber.length >= 12) {
      // Already has country code
      whatsappNumber = cleanedNumber;
    } else if (cleanedNumber.length == 10) {
      // Add 91 country code
      whatsappNumber = '91$cleanedNumber';
    } else {
      // Use as is, but ensure it has 91 prefix
      whatsappNumber = cleanedNumber.startsWith('91') ? cleanedNumber : '91$cleanedNumber';
    }
    
    print('💬 Final WhatsApp number: "$whatsappNumber"');
    
    // Create WhatsApp URL
    final whatsappUrl = Uri.parse('https://wa.me/$whatsappNumber');
    print('🔗 WhatsApp URL: $whatsappUrl');
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      print('✅ WhatsApp launched successfully');
    } else {
      print('❌ Primary WhatsApp URL failed, trying alternative...');
      
      // Try alternative WhatsApp scheme
      final altWhatsappUrl = Uri.parse('whatsapp://send?phone=$whatsappNumber');
      print('🔗 Alternative WhatsApp URL: $altWhatsappUrl');
      
      if (await canLaunchUrl(altWhatsappUrl)) {
        await launchUrl(altWhatsappUrl, mode: LaunchMode.externalApplication);
        print('✅ Alternative WhatsApp launched successfully');
      } else {
        // Show beautiful WhatsApp not available dialog
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
          
          // Title
          Text(
            'WhatsApp Not Available',
            style: GoogleFonts.roboto(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          // Message
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
          
          // Phone number display
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
          
          // Action buttons
          Column(
            children: [
              // Call button
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
              
              // Alternative actions row
              Row(
                children: [
                  // Install WhatsApp button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        // Try to open Play Store/App Store to install WhatsApp
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
                  
                  // Cancel button
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

// Keep the original phone call function unchanged


// Optional: Enhanced version with loading states
Future<void> _openWhatsAppWithLoading() async {
  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ),
            SizedBox(height: 16.h),
            Text(
              'Opening WhatsApp...',
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  try {
    await _openWhatsApp();
  } finally {
    // Close loading dialog if still open
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
  void _hireWorker() {
    // Show beautiful confirmation bottom sheet
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
            SizedBox(height: 20.h),
            
            // Icon
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
            
            // Title
            Text(
              'Hire this Worker?',
              style: GoogleFonts.roboto(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Message
            Text(
              'You are about to hire ${widget.application.workerName} for this job. This action cannot be undone.',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                color: Colors.grey.shade700,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Buttons
            Row(
              children: [
                // Cancel button
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
                
                // Confirm button
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
      // Close the confirmation sheet
      Navigator.pop(context);
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
        ),
      );

      // Update application status to accepted
      await _firestore
          .collection('jobApplications')
          .doc(widget.application.id)
          .update({
        'status': 'accepted',
        'updatedAt': FieldValue.serverTimestamp(),
        'hiredAt': FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Worker hired successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to application list
        Navigator.pop(context);
      }
    } catch (e) {
      // Close loading dialog if open
      Navigator.pop(context);
      
      // Show error message
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

  Widget _buildLocationText(String workerId, String fallbackLocation) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('workers').doc(workerId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final location = data?['location'];
          
          // Handle different location formats
          String locationText = fallbackLocation;
          if (location != null) {
            if (location is Map) {
              // If location is stored as a Map, extract just the place name
              locationText = location['placeName']?.toString() ?? 
                          location.values.first?.toString() ?? fallbackLocation;
            } else {
              // If location is a simple string
              locationText = location.toString();
            }
          }
          
          if (locationText.isNotEmpty) {
            return Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    locationText,
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }
        }
        
        // Fallback
        return Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16.sp,
              color: Colors.white,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                fallbackLocation,
                style: GoogleFonts.roboto(
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
                maxLines: 1,
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
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
            )
          : SingleChildScrollView(
              // Add bottom padding to ensure consistent bottom spacing
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                children: [
                  // Top curved background with profile
                  _buildProfileHeader(),

                  // Body content with consistent spacing
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contact and hire buttons
                        _buildContactButtons(),

                        // Experience section
                        _buildExperienceSection(),

                        // Job history with reduced gap
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
        // Background design elements
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

        // Content
        Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            children: [
              // Back button and title
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
                    SizedBox(width: 35.w), // For symmetry
                  ],
                ),
              ),

              // Profile picture
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

              SizedBox(height: 16.h),

              // Worker name with verification icon - PROPERLY CENTERED AND RESPONSIVE
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

              // Location - PROPERLY CENTERED AND RESPONSIVE
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildResponsiveLocationText(
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

// Updated location widget for better responsiveness and centering
Widget _buildResponsiveLocationText(String workerId, String fallbackLocation) {
  return StreamBuilder<DocumentSnapshot>(
    stream: _firestore.collection('workers').doc(workerId).snapshots(),
    builder: (context, snapshot) {
      String locationText = fallbackLocation;
      
      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>?;
        final location = data?['location'];
        
        // Handle different location formats
        if (location != null) {
          if (location is Map) {
            // If location is stored as a Map, extract just the place name
            locationText = location['placeName']?.toString() ?? 
                        location.values.first?.toString() ?? fallbackLocation;
          } else {
            // If location is a simple string
            locationText = location.toString();
          }
        }
      }
      
      // Return centered location with proper responsive design
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            size: 18.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              locationText.isNotEmpty ? locationText : 'Location not specified',
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

  Widget _buildContactButtons() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: Column(
        children: [
          // Contact and Hire Buttons Row
          Row(
            children: [
              // Show Number button
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
              // WhatsApp button
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

          // Hire Button - Only show if status is pending
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
            
          // Show status badge for accepted or rejected applications
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
          
          // Work count with colored badge
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
          
          // Job category statistics
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

  Widget _buildJobHistorySection() {
    return Container(
      margin: EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed Jobs',
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
                      Icons.history,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No completed jobs',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
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
                
                // Format date
                String formattedDate = 'Unknown date';
                if (job.containsKey('date') && job['date'] is Timestamp) {
                  final date = (job['date'] as Timestamp).toDate();
                  formattedDate = '${date.day}/${date.month}/${date.year}';
                }
                
                final isLastItem = index == completedJobs.length - 1;
                
                // FIXED: Properly extract job details from the job data
                final jobTitle = job['jobTitle'] ?? 'Unknown Job';
                final companyName = job['hirerBusinessName'] ?? 'Unknown Company';
                final jobLocation = job['hirerLocation'] ?? 'Unknown Location';
                final jobType = job['jobType'] ?? 'Unknown Type';
                
                // Debug print for this specific job
                print('Job ${index}: Title = $jobTitle, Company = $companyName');
                
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
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: jobType == 'full-time'
                                  ? Colors.blue.shade100
                                  : jobType == 'part-time'
                                      ? Colors.amber.shade100
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              jobType,
                              style: GoogleFonts.roboto(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: jobType == 'full-time'
                                    ? Colors.blue.shade800
                                    : jobType == 'part-time'
                                        ? Colors.amber.shade800
                                        : Colors.green.shade800,
                              ),
                            ),
                          ),
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
                          SizedBox(width: 8.w),
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
                      
                      // Add budget information if available
                      if (job['budget'] != null && job['budget'] > 0) ...[
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