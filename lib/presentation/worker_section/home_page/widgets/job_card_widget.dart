import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';
import 'package:hey_work/core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../job_detail_screen/job_detail_page.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;

  const JobCardWidget({
    super.key,
    required this.job,
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

  // Enhanced share job function with better formatting
Future<void> _shareJob(BuildContext context) async {
  try {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing to share...'),
        duration: Duration(seconds: 1),
      ),
    );
    
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
      const SnackBar(
        content: Text('Thanks for sharing!'),
        backgroundColor: Color(0xFF0000CC),
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
}  void _navigateToJobDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailScreen(job: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFullTime = job.jobType.toLowerCase() == 'full-time';
    final jobTypeColor = isFullTime ? AppColors.green : Color(0xFF0000CC);

    // Wrap the container with GestureDetector to handle taps
    return GestureDetector(
      onTap: () => _navigateToJobDetail(context),
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
            // Posted time and job type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posted ${_getTimeAgo(job.createdAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkGrey,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: jobTypeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.jobType,
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

            // Job title and company
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
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
                  child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            job.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.business,
                                  color: AppColors.darkGrey);
                            },
                          ),
                        )
                      : const Icon(Icons.business, color: AppColors.darkGrey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobCategory,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.darkGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (job.hirerIndustry.isNotEmpty) ...[
                            Text(
                              ' (${job.hirerIndustry})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkGrey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
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
                    job.location,
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

            // Salary or Budget information
            Row(
              children: [
                const Icon(
                  Icons.currency_rupee,
                  size: 16,
                  color: AppColors.darkGrey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: isFullTime && job.salaryRange != null
                      ? Text(
                          'Rs. ${job.salaryRange!['min']} - ${job.salaryRange!['max']} per month',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey,
                          ),
                        )
                      : Text(
                          'Budget: Rs. ${job.budget}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGrey,
                          ),
                        ),
                ),
                // Share button with context
                IconButton(
                  icon: Icon(Icons.share, color: Color(0xFF0000CC)),
                  onPressed: () => _shareJob(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}