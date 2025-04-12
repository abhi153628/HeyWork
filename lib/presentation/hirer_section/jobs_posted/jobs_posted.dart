import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/job_detail_page.dart/job_detail.dart';
import 'package:intl/intl.dart';


class JobsPostedScreen extends StatefulWidget {
  final Map<String, dynamic> submittedJob; // Newly submitted job from the form

  const JobsPostedScreen({
    Key? key,
  required this.submittedJob,
  }) : super(key: key);

  @override
  State<JobsPostedScreen> createState() => _JobsPostedScreenState();
}

class _JobsPostedScreenState extends State<JobsPostedScreen> {
  // Static list to hold posted jobs (acts as a simple in-memory database)
  static List<Map<String, dynamic>> _postedJobs = [];

  @override
  void initState() {
    super.initState();
    
    // Add the newly submitted job if available
  addJob(widget.submittedJob);
  }

  // Add a new job to the list
  void addJob(Map<String, dynamic> jobData) {
    setState(() {
      // Check if job already exists (based on timestamp or some other unique identifier)
      bool jobExists = false;
      
      // In a real app, you would use a unique ID to check for duplicates
      for (var job in _postedJobs) {
        if (job['date'] == jobData['date'] && 
            job['time'] == jobData['time'] && 
            job['jobCategory'] == jobData['jobCategory']) {
          jobExists = true;
          break;
        }
      }
      
      // Only add if it doesn't already exist
      if (!jobExists) {
        _postedJobs.add(jobData);
      }
    });
  }

  // Edit an existing job
  void editJob(int index, Map<String, dynamic> updatedJobData) {
    setState(() {
      _postedJobs[index] = updatedJobData;
    });
  }

  // Delete a job
  void deleteJob(int index) {
    setState(() {
      _postedJobs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // App Bar widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Posted Jobs',
        style: GoogleFonts.poppins(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  // Main body content
  Widget _buildBody() {
    return _postedJobs.isEmpty
        ? _buildEmptyState()
        : _buildJobsList();
  }

  // Empty state when no jobs are posted
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 80.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Jobs Posted Yet',
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              'Your posted jobs will appear here. Tap the + button to post a new job.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // List of posted jobs
  Widget _buildJobsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: _postedJobs.length,
      itemBuilder: (context, index) {
        return _buildJobCard(index);
      },
    );
  }

  // Individual job card
  Widget _buildJobCard(int index) {
    final job = _postedJobs[index];
    final DateTime? jobDate = job['date'] as DateTime?;
final TimeOfDay? jobTime = job['time'] as TimeOfDay?;
final String formattedDate = jobDate != null 
    ? DateFormat('MMM dd, yyyy').format(jobDate)
    : 'No date';
  '${formattedDate}, ${jobTime != null ? jobTime.format(context) : 'No time'}';
    final bool isPartTime = job['jobType'] == 'part-time';

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            spreadRadius: 0,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job header with category and type
          _buildJobHeader(job, isPartTime),
          
          // Job description
         
          
          // Job details (date, time, budget)
          _buildJobDetails(formattedDate, jobTime, job['budget']),
          
          // Action buttons
          _buildActionButtons(index),
        ],
      ),
    );
  }

  // Job header with category and type
  Widget _buildJobHeader(Map<String, dynamic> job, bool isPartTime) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF0011C9).withOpacity(0.04),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Job category
          Expanded(
            child: Text(
              job['jobCategory'],
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Job type badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isPartTime 
                  ? const Color(0xFF0011C9).withOpacity(0.1)
                  : const Color(0xFF00C94F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              isPartTime ? 'Part-time' : 'Full-time',
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isPartTime ? const Color(0xFF0011C9) : const Color(0xFF00C94F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Job details (date, time, budget)
  Widget _buildJobDetails(String formattedDate, TimeOfDay? jobTime, int budget) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    child: Row(
      children: [
        // Date and time
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  '$formattedDate, ${jobTime != null ? jobTime.format(context) : "No time"}',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Budget
        Row(
          children: [
            Icon(
              Icons.monetization_on_outlined,
              size: 16.sp,
              color: Colors.grey,
            ),
            SizedBox(width: 4.w),
            Text(
              '₹$budget',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

  // Action buttons (edit, delete)
  Widget _buildActionButtons(int index) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Edit button
          _buildActionButton(
            icon: Icons.edit_outlined,
            label: 'Edit',
            color: const Color(0xFF0011C9),
            onPressed: () => _navigateToEditJob(index),
          ),
          SizedBox(width: 16.w),
          
          // Delete button
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red,
            onPressed: () => _showDeleteConfirmation(index),
          ),
        ],
      ),
    );
  }

  // Generic action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18.sp,
              color: color,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating action button to add new job
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _navigateToAddJob,
      backgroundColor: const Color(0xFF0011C9),
      child: const Icon(Icons.add,size: 30,color: Colors.white,),
    );
  }

  // Navigation to add a new job
  void _navigateToAddJob() async {
    // Navigate to JobDetailsScreen with default values
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const JobDetailsScreen(
          jobCategory: '',
          jobType: 'part-time',
        ),
      ),
    );
  }

  // Navigation to edit an existing job
  void _navigateToEditJob(int index) async {
    final job = _postedJobs[index];
    
    // Navigate to JobDetailsScreen with existing job data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(
          jobCategory: job['jobCategory'],
          jobType: job['jobType'],
          existingJob: job,
          isEditing: true,
        ),
      ),
    );
    
    // If result is not null, update the job
    if (result != null && result is Map<String, dynamic>) {
      editJob(index, result);
    }
  }

  // Confirmation dialog before deleting a job
  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Job',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this job posting?',
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              deleteJob(index);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}