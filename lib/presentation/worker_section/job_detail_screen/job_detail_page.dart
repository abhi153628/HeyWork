import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart'; // Add this import for sharing functionality

class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isApplied = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkInitialApplicationStatus();
  }

  Future<void> _checkInitialApplicationStatus() async {
    final isApplied = await _checkIfApplied();
    setState(() {
      _isApplied = isApplied;
    });
  }

  //! N A V I G A T I O N  B U T T O N S
  Widget _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () {
              // Navigate back to applications page
              Navigator.pop(context);
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
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),

          // Share button (replacing bookmark)
          GestureDetector(
            onTap: () {
              // Share job details functionality
              Share.share(
                'Check out this ${widget.job.jobType} ${widget.job.jobCategory} job at ${widget.job.company} in ${widget.job.location}',
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
                Icons.share,
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
    final isFullTime = widget.job.jobType.toLowerCase() == 'full-time';
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
            child: widget.job.imageUrl != null && widget.job.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      widget.job.imageUrl!,
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
            widget.job.jobCategory,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),

          const SizedBox(height: 8),

          // Company name and industry
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.job.company,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGrey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.job.hirerIndustry.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    ' • ${widget.job.hirerIndustry}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

                  // Location, job type, and salary information
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8, // horizontal space between items
            runSpacing: 8, // vertical space between lines
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: jobTypeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.job.jobType,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.darkGrey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.job.location, // Show full location
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 14,
                        color: AppColors.darkGrey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          isFullTime && widget.job.salaryRange != null
                              ? '${_formatCurrency(widget.job.salaryRange!['min'])}-${_formatCurrency(widget.job.salaryRange!['max'])}/mo'
                              : '${_formatCurrency(widget.job.budget)}/day',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGrey,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
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
            value: widget.job.location,
          ),

          const Divider(height: 24),

          // Date and Time - Improved format
          _buildInfoItem(
            context,
            icon: Icons.calendar_today,
            title: 'Date',
            value: _formatDate(widget.job.date),
          ),

          const Divider(height: 24),

          // Working Hours - Fixed to correctly display timeFormatted
          _buildInfoItem(
            context,
            icon: Icons.access_time,
            title: 'Arrival Time',
            value: widget.job.timeFormatted ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.only(bottom: 20),
          ),
          
          Icon(
            Icons.work_outline,
            color: Color(0xFF0000CC),
            size: 48,
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Confirm Application',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 16),
          
          Text(
            'Are you applying for the ${widget.job.jobCategory} job at ${widget.job.company}? Once applied, the hirer will receive your application.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.visible,
          ),
          
          SizedBox(height: 24),
          
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Color(0xFF0000CC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0000CC),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // Apply button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0000CC),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Check if user has already applied
  Future<bool> _checkIfApplied() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return false;
    }

    final applicationDoc = await FirebaseFirestore.instance
        .collection('jobApplications')
        .doc('${widget.job.id}_${user.uid}')
        .get();

    return applicationDoc.exists;
  }

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

      // Check if already applied
      final applicationRef = FirebaseFirestore.instance
          .collection('jobApplications')
          .doc('${widget.job.id}_${user.uid}');

      final applicationDoc = await applicationRef.get();
      if (applicationDoc.exists) {
        // Already applied
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
        'jobId': widget.job.id,
        'workerId': user.uid,
        'hirerId': widget.job.hirerId,
        'workerName': workerData['name'] ?? 'No Name',
        'workerLocation': workerData['location'] ?? 'No Location',
        'workerProfileImage': workerData['profileImage'],
        'workerPhone': workerData['phoneNumber'] ?? '',
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
        'jobTitle': widget.job.jobCategory,
        'jobCompany': widget.job.company,
        'jobLocation': widget.job.location,
        'jobBudget': widget.job.budget,
        'jobType': widget.job.jobType,
      };

      // Save to applications collection (for easy querying)
      await applicationRef.set(application);

      // Also add to worker's applications subcollection (for worker's profile)
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .collection('applications')
          .doc(widget.job.id)
          .set(application);

      // Also add to job's applications subcollection (for hirer to see)
      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .collection('applications')
          .doc(user.uid)
          .set(application);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error applying for job: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Updated to use state variable for applied status
  Widget _buildApplyButton(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(38.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(38.0),
      child: ElevatedButton(
        onPressed: _isApplied ? null : () => _showApplyConfirmationSheet(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: _isApplied ? Colors.grey : Color(0xFF0000CC),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          _isApplied ? 'APPLIED' : 'APPLY NOW',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
   Future<void> _showApplyConfirmationSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildConfirmationBottomSheet(context),
    );
    
    if (result == true) {
      setState(() {
        _isLoading = true;
      });
      
      await _applyForJob(context);
      
      setState(() {
        _isLoading = false;
        _isApplied = true;
      });
    }
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

  // Currency formatting helper method
  String _formatCurrency(dynamic value) {
    // Safety check first
    if (value == null) return '0';
    
    // Convert to string if it's not already
    String numStr = value.toString();
    
    // Parse as double
    double? numValue = double.tryParse(numStr);
    if (numValue == null) return numStr;
    
    // For large values (millions+), convert to shorthand notation
    if (numValue >= 1000000000) {
      return '${(numValue / 1000000000).toStringAsFixed(1)}B';
    } else if (numValue >= 1000000) {
      return '${(numValue / 1000000).toStringAsFixed(1)}M';
    } else if (numValue >= 100000) {
      return '${(numValue / 100000).toStringAsFixed(1)}L';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)}K';
    }
    
    // Regular formatting for smaller numbers
    return numValue.toStringAsFixed(0);
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
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
            widget.job.description ??
                "This is a sample job description and its going to be the easiest way the hirer would type it. And obviously is going to be less than 1 paragraph since what is there to tell more about it?",
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
              height: 1.5,
            ),
            overflow: TextOverflow.visible, // Allow text to wrap naturally
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
          
          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0000CC)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}