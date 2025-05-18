import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
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

      // Fetch completed jobs
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

        // Get the actual job details
        if (jobId != null) {
          final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
          if (jobDoc.exists) {
            final fullJobData = jobDoc.data() ?? {};
            
            // Add to completed jobs list
            jobs.add({
              'id': jobDoc.id,
              ...fullJobData,
            });

            // Count job categories
            final category = fullJobData['jobCategory'] ?? 'Uncategorized';
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            totalJobs++;
          }
        }
      }

      setState(() {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = totalJobs;
      });
    } catch (e) {
      print('Error loading completed jobs: $e');
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: widget.application.workerPhone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final phoneNumber = widget.application.workerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('WhatsApp is not installed on your device'),
            backgroundColor: Colors.red,
          ),
        );
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
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF414ce4)),
          ),
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
              child: CircularProgressIndicator(
                color: Color(0xFF414ce4),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Top curved background with profile
                  _buildProfileHeader(),

                  // Body content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Contact and hire buttons
                        _buildContactButtons(),

                        // Experience section
                        _buildExperienceSection(),

                        // Job history
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
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF414ce4),
                                  ),
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
                            child: Icon(
                              Icons.person,
                              size: 50.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Worker name with verification icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.application.workerName,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 27.sp,
                        fontWeight: FontWeight.bold,
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

                // Location
                Padding(
                 padding: const EdgeInsets.only(left: 100,top: 10),
                  child: _buildLocationText(widget.application.workerId, widget.application.workerLocation),
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
      padding: EdgeInsets.symmetric(vertical: 20.h),
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

          SizedBox(height: 12.h),

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
                    Icon(Icons.check_circle_outline, size: 22.sp),
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
            SizedBox(height: 16.h),
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
      margin: EdgeInsets.only(bottom: 20.h),
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
          SizedBox(height: 16.h),
          
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
          
          SizedBox(height: 16.h),
          
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
            SizedBox(height: 12.h),
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
                padding: EdgeInsets.all(16.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
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
                    SizedBox(height: 8.h),
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
      margin: EdgeInsets.only(bottom: 20.h),
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
          SizedBox(height: 12.h),
          
          if (completedJobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
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
              itemCount: completedJobs.length,
              itemBuilder: (context, index) {
                final job = completedJobs[index];
                
                // Format date
                String formattedDate = 'Unknown date';
                if (job.containsKey('date') && job['date'] is Timestamp) {
                  final date = (job['date'] as Timestamp).toDate();
                  formattedDate = '${date.day}/${date.month}/${date.year}';
                }
                
                return Container(
                  margin: EdgeInsets.only(bottom: 12.h),
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
                                  job['title'] ?? 'Unknown Job',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  job['hirerBusinessName'] ?? 'Unknown Company',
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
                              color: job['jobType'] == 'full-time'
                                  ? Colors.blue.shade100
                                  : job['jobType'] == 'part-time'
                                      ? Colors.amber.shade100
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              job['jobType'] ?? 'Unknown',
                              style: GoogleFonts.roboto(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: job['jobType'] == 'full-time'
                                    ? Colors.blue.shade800
                                    : job['jobType'] == 'part-time'
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
                          Text(
                            job['hirerLocation'] ?? 'Unknown Location',
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Spacer(),
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