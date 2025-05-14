// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../jobs_posted/job_detail_screen.dart';
// import 'package:intl/intl.dart';

// class JobsPostedScreen extends StatefulWidget {
//   final Map<String, dynamic>? submittedJob;

//   const JobsPostedScreen({
//     Key? key,
//     this.submittedJob,
//   }) : super(key: key);

//   @override
//   State<JobsPostedScreen> createState() => _JobsPostedScreenState();
// }

// class _JobsPostedScreenState extends State<JobsPostedScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   bool _isLoading = true;
//   List<Map<String, dynamic>> _jobs = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadJobs();
//   }

//   // Load jobs from Firestore
//   Future<void> _loadJobs() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final userId = _auth.currentUser?.uid;
//       if (userId == null) {
//         throw Exception('No user logged in');
//       }

//       // Query jobs by the current user
//       final snapshot = await _firestore
//           .collection('jobs')
//           .where('hirerId', isEqualTo: userId)
//           .orderBy('createdAt', descending: true)
//           .get();

//       final List<Map<String, dynamic>> loadedJobs = [];

//       for (var doc in snapshot.docs) {
//         final data = doc.data();
//         data['jobId'] = doc.id; // Add document ID to the job data

//         // Convert Firestore timestamps to DateTime
//         if (data['createdAt'] != null) {
//           data['createdAt'] = (data['createdAt'] as Timestamp).toDate();
//         }

//         if (data['updatedAt'] != null) {
//           data['updatedAt'] = (data['updatedAt'] as Timestamp).toDate();
//         }

//         loadedJobs.add(data);
//       }

//       setState(() {
//         _jobs = loadedJobs;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading jobs: $e');
//       setState(() {
//         _isLoading = false;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading jobs: $e'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }

//   // Delete job from Firestore
//   Future<void> _deleteJob(String jobId) async {
//     try {
//       // Delete from main jobs collection
//       await _firestore.collection('jobs').doc(jobId).delete();

//       // Delete from user's jobs subcollection
//       final userId = _auth.currentUser?.uid;
//       if (userId != null) {
//         await _firestore
//             .collection('hirers')
//             .doc(userId)
//             .collection('jobs')
//             .doc(jobId)
//             .delete();
//       }

//       // Remove from local list
//       setState(() {
//         _jobs.removeWhere((job) => job['jobId'] == jobId);
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Job deleted successfully'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       print('Error deleting job: $e');

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error deleting job: $e'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'Posted Jobs',
//           style: GoogleFonts.poppins(
//             fontSize: 20.sp,
//             fontWeight: FontWeight.w600,
//             color: Colors.black,
//           ),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadJobs,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _jobs.isEmpty
//               ? _buildEmptyState()
//               : _buildJobsList(),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _navigateToJobDetails(),
//         backgroundColor: const Color(0xFF0011C9),
//         icon: const Icon(Icons.add),
//         label: Text(
//           'New Job',
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.work_off_outlined,
//             size: 80.sp,
//             color: Colors.grey.shade400,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'No jobs posted yet',
//             style: GoogleFonts.poppins(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Your posted jobs will appear here',
//             style: GoogleFonts.poppins(
//               fontSize: 14.sp,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           SizedBox(height: 24.h),
//           ElevatedButton.icon(
//             onPressed: () => _navigateToJobDetails(),
//             icon: const Icon(Icons.add),
//             label: const Text('Post Your First Job'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0011C9),
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildJobsList() {
//     return ListView.builder(
//       padding: EdgeInsets.all(16.w),
//       itemCount: _jobs.length,
//       itemBuilder: (context, index) {
//         final job = _jobs[index];
//         return _buildJobCard(job);
//       },
//     );
//   }

//   Widget _buildJobCard(Map<String, dynamic> job) {
//     final bool isFullTime = job['jobType'] == 'full-time';
//     final String jobCategory = job['jobCategory'] ?? 'Unknown';
//     final int budget = job['budget'] ?? 0;

//     // Format date and time if available
//     String dateTimeStr = 'N/A';
//     if (job['date'] != null && job['time'] != null) {
//       final DateTime date = job['date'] is DateTime
//           ? job['date']
//           : (job['date'] as Timestamp).toDate();

//       final TimeOfDay time = job['time'] is TimeOfDay
//           ? job['time']
//           : TimeOfDay(
//               hour: (job['time'] as Map)['hour'] ?? 0,
//               minute: (job['time'] as Map)['minute'] ?? 0);

//       final formattedDate = DateFormat('MMM dd, yyyy').format(date);
//       final formattedTime = time.format(context);
//       dateTimeStr = '$formattedDate at $formattedTime';
//     }

//     return Card(
//       margin: EdgeInsets.only(bottom: 16.h),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Job Type Badge and Category
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                   decoration: BoxDecoration(
//                     color: isFullTime
//                         ? const Color(0xFF0011C9).withOpacity(0.1)
//                         : Colors.orange.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4.r),
//                   ),
//                   child: Text(
//                     isFullTime ? 'FULL TIME' : 'PART TIME',
//                     style: GoogleFonts.poppins(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: isFullTime
//                           ? const Color(0xFF0011C9)
//                           : Colors.orange.shade800,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     jobCategory,
//                     style: GoogleFonts.poppins(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12.h),

//             // Budget/Salary
//             Row(
//               children: [
//                 Icon(
//                   Icons.monetization_on_outlined,
//                   size: 20.sp,
//                   color: Colors.green.shade700,
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   isFullTime && job.containsKey('salaryRange')
//                       ? '₹${job['salaryRange']['min']} - ₹${job['salaryRange']['max']} per month'
//                       : '₹$budget',
//                   style: GoogleFonts.poppins(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.green.shade700,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.h),

//             // Date & Time
//             Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   size: 18.sp,
//                   color: Colors.grey.shade700,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     dateTimeStr,
//                     style: GoogleFonts.poppins(
//                       fontSize: 14.sp,
//                       color: Colors.grey.shade700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8.h),

//             // Description
//             if (job['description'] != null && job['description'].isNotEmpty)
//               Padding(
//                 padding: EdgeInsets.only(bottom: 12.h),
//                 child: Text(
//                   job['description'],
//                   style: GoogleFonts.poppins(
//                     fontSize: 14.sp,
//                     color: Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),

//             // Status chip
//             if (job['status'] != null)
//               Container(
//                 margin: EdgeInsets.only(bottom: 12.h),
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(job['status']).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4.r),
//                 ),
//                 child: Text(
//                   job['status'].toUpperCase(),
//                   style: GoogleFonts.poppins(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w600,
//                     color: _getStatusColor(job['status']),
//                   ),
//                 ),
//               ),

//             // Action Buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 // View Applications Button (if any)
//                 if (job.containsKey('applications'))
//                   TextButton.icon(
//                     onPressed: () {
//                       // TODO: Navigate to applications screen
//                     },
//                     icon: Icon(
//                       Icons.people_outline,
//                       size: 18.sp,
//                       color: const Color(0xFF0011C9),
//                     ),
//                     label: Text(
//                       'Applications',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14.sp,
//                         color: const Color(0xFF0011C9),
//                       ),
//                     ),
//                   ),

//                 const Spacer(),

//                 // Edit Button
//                 IconButton(
//                   onPressed: () => _editJob(job),
//                   icon: Icon(
//                     Icons.edit_outlined,
//                     size: 20.sp,
//                     color: Colors.blue.shade700,
//                   ),
//                 ),

//                 // Delete Button
//                 IconButton(
//                   onPressed: () => _confirmDeleteJob(job['jobId']),
//                   icon: Icon(
//                     Icons.delete_outline,
//                     size: 20.sp,
//                     color: Colors.red.shade700,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'active':
//         return Colors.green.shade700;
//       case 'closed':
//         return Colors.red.shade700;
//       case 'pending':
//         return Colors.orange.shade700;
//       default:
//         return Colors.blue.shade700;
//     }
//   }

//   void _navigateToJobDetails() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const JobDetailsScreen(
//           jobCategory: '',
//           jobType: 'part-time',
//         ),
//       ),
//     ).then((result) {
//       if (result != null) {
//         _loadJobs(); // Reload jobs after creating
//       }
//     });
//   }

//   void _editJob(Map<String, dynamic> job) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => JobDetailsScreen(
//           jobCategory: job['jobCategory'] ?? '',
//           jobType: job['jobType'] ?? 'part-time',
//           existingJob: job,
//           isEditing: true,
//           jobId: job['jobId'],
//         ),
//       ),
//     ).then((result) {
//       if (result != null) {
//         _loadJobs(); // Reload jobs after editing
//       }
//     });
//   }

//   void _confirmDeleteJob(String jobId) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(
//           'Delete Job',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: Text(
//           'Are you sure you want to delete this job? This action cannot be undone.',
//           style: GoogleFonts.poppins(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: GoogleFonts.poppins(),
//             ),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteJob(jobId);
//             },
//             child: Text(
//               'Delete',
//               style: GoogleFonts.poppins(
//                 color: Colors.red,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
