import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';
import 'package:heywork/core/theme/app_colors.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../job_detail_screen/worker_job_detail_page.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;
  final bool isApplied; // Add this parameter to track application status

  const JobCardWidget({
    super.key,
    required this.job,
    this.isApplied = false, // Default to false
  });

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  // Check if posted within 2 hours
  bool _isRecentlyPosted(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inHours < 2;
  }

  // Enhanced share job function with better formatting
Future<void> _shareJob(BuildContext context) async {
  try {
    // Show loading indicator
   
    
    // Create custom URL scheme link
    final String customSchemeLink = 'heywork://jobs/${job.id}';
    
    // Calculate application closing date (5 days from now)
    final closeDate = DateTime.now().add(Duration(days: 5));
    final closeDay = closeDate.day;
    final closeMonth = _getMonthName(closeDate.month);
    
    // Format payment text based on job type
    final String paymentText = job.jobType.toLowerCase() == 'full-time' && job.salaryRange != null 
        ? '₹${job.salaryRange!['min']} - ₹${job.salaryRange!['max']} per month' 
        : '₹${job.budget}/day';
    
    // Improved share text with better marketing tactics
    final String shareText = '''
🚨 URGENT ${job.jobCategory.toUpperCase()} JOB IN ${job.location.toUpperCase()} 🚨
This won't last long – APPLY NOW!

📍 Location: ${job.location}, Kerala
💰 Pay: $paymentText
⏰ Type: ${job.jobType}
📅 Applications close: $closeDay $closeMonth, ${DateTime.now().year}

No long waits. No hassle. Just real jobs, fast.
Employers ready to hire – today!

Don't have the app? Download HeyWork now:
https://play.google.com/store/apps/details?id=com.example.hey_work

✅ Local Jobs
✅ 1-Click Apply  
✅ Direct Contact with Employers

⚠️ Spots filling fast – don't miss out!
Join hundreds of satisfied job seekers in India.
''';

    // Share with image if possible
    try {
      final ByteData imageData = await rootBundle.load('asset/team1.png');
      final Uint8List bytes = imageData.buffer.asUint8List();
      
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/heywork_job.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: 'Urgent Job Opportunity: ${job.jobCategory} in ${job.location}',
      );
    } catch (imageError) {
      print('Error sharing with image: $imageError. Falling back to text-only share.');
      await Share.share(
        shareText,
        subject: 'Urgent Job Opportunity: ${job.jobCategory} in ${job.location}',
      );
    }
    
    // Success message
     ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Thanks for sharing!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFF0000CC),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          duration: Duration(seconds: 2),
          elevation: 6,
        ),
      );
  } catch (e) {
    print('Error sharing: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not share: $e')),
    );
  }
}

// Helper method to get month name
String _getMonthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month - 1];
}

  void _navigateToJobDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(job: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG: Print the applied status
    print('Job ${job.id} - ${job.jobCategory}: isApplied = $isApplied');
    
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);
    final isRecent = _isRecentlyPosted(job.createdAt);
    
    // Get screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    // Responsive font sizes
    final titleFontSize = isSmallScreen ? 16.0 : 18.0;
    final companyFontSize = isSmallScreen ? 13.0 : 14.0;
    final industryFontSize = isSmallScreen ? 11.0 : 12.0;
    final detailFontSize = isSmallScreen ? 13.0 : 14.0;

    return GestureDetector(
      onTap: () => _navigateToJobDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
        decoration: BoxDecoration(
          // ONLY background color changes for applied jobs
          color: isApplied ? const Color.fromARGB(132, 237, 237, 237) : Colors.white,
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
            color: AppColors.black.withOpacity(0.3), // Same border for all
            width: 1, // Same border width for all
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Posted time and job type - Make more responsive
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 3,
                  child: Row(
                    children: [
                      // Show green dot for recent posts (only if not applied)
                      if (isRecent && !isApplied) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6),
                      ],
                      // Show applied icon for applied jobs
                      if (isApplied) ...[
                        Icon(
                          Icons.check_circle,
                          color: Color.fromARGB(255, 255, 119, 0), // Green tick mark for applied jobs
                          size: 14,
                        ),
                        SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          isApplied ? 'Applied ' : 'Posted ${_getTimeAgo(job.createdAt)}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 11 : 12,
                            color: isApplied ? Color.fromARGB(255, 255, 119, 0): (isRecent && !isApplied ? Colors.green : AppColors.darkGrey), // Green for applied, green for recent, normal for others
                            fontWeight: (isRecent && !isApplied) || isApplied ? FontWeight.w400 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // Job type badge (always shows job type, never "APPLIED")
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10, 
                    vertical: 4
                  ),
                  decoration: BoxDecoration(
                    color: jobTypeColor, 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.jobType, 
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isSmallScreen ? 10 : 12),

            // Job title and company - Improved responsive layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company logo/icon
                Container(
                  width: isSmallScreen ? 55 : 60,
                  height: isSmallScreen ? 55 : 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // Same color for all
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network( // No color filter - same image for all
                            job.imageUrl!,
                            width: isSmallScreen ? 55 : 60,
                            height: isSmallScreen ? 55 : 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.business,
                                color: AppColors.darkGrey, // Same icon color for all
                                size: isSmallScreen ? 20 : 24,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.business, 
                          color: AppColors.darkGrey, // Same icon color for all
                          size: isSmallScreen ? 20 : 24,
                        ),
                ),
                
                SizedBox(width: isSmallScreen ? 10 : 12),
                
                // Job details - Flexible and responsive
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Category (Title)
                      Text(
                        job.jobCategory,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Same color for all
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: 3),
                      
                      // Company Name
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: companyFontSize,
                          color: AppColors.darkGrey, // Same color for all
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Industry (only if not empty and space permits)
                      if (job.hirerIndustry.isNotEmpty) ...[
                         SizedBox(height: 4),
                        Text(
                          '[${job.hirerIndustry}]',
                          style: TextStyle(
                            fontSize: industryFontSize,
                            color: AppColors.darkGrey, // Same color for all
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Location - Responsive
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: isSmallScreen ? 14 : 16,
                  color: AppColors.darkGrey, // Same color for all
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: TextStyle(
                      fontSize: detailFontSize,
                      color: AppColors.darkGrey, // Same color for all
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 8),

            // Salary and Share button - Better responsive layout
            Row(
              children: [
                Icon(
                  Icons.currency_rupee,
                  size: isSmallScreen ? 14 : 16,
                  color: AppColors.darkGrey, // Same color for all
                ),
                SizedBox(width: 4),
                
                // Salary/Budget - Takes available space
                Expanded(
                  child: isFullTime && job.salaryRange != null
                      ? Text(
                          'Rs. ${job.salaryRange!['min']} - ${job.salaryRange!['max']} per month',
                          style: TextStyle(
                            fontSize: detailFontSize,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey, // Same color for all
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Budget: Rs. ${job.budget}',
                          style: TextStyle(
                            fontSize: detailFontSize,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey, // Same color for all
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                
                // Share button - Fixed size
                Container(
                  width: isSmallScreen ? 40 : 38,
                  height: isSmallScreen ? 40 : 38,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(
                      Icons.share,
                      color: Color(0xFF0000CC), // Same color for all
                      size: isSmallScreen ? 20 : 24,
                    ),
                    onPressed: () => _shareJob(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}