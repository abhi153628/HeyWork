// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hey_work/core/services/database/jobs_service.dart';
// import 'package:hey_work/presentation/worker_section/job_detail_screen/job_detail_page.dart';

// import 'package:uni_links3/uni_links.dart';

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:hey_work/core/services/database/jobs_service.dart';
// import 'package:hey_work/presentation/worker_section/job_detail_screen/job_detail_page.dart';


// class DeepLinkHandler {
//   static final DeepLinkHandler _instance = DeepLinkHandler._internal();
//   final JobService _jobService = JobService();
//   bool _isInitialized = false;
  
//   factory DeepLinkHandler() {
//     return _instance;
//   }
  
//   DeepLinkHandler._internal();
  
//   Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
//     print("Initializing DeepLinkHandler");
//     if (_isInitialized) {
//       print("DeepLinkHandler already initialized");
//       return;
//     }
//     _isInitialized = true;
    
//     try {
//       // Check for initial link on app startup
//       print("Checking for initial link...");
//       final initialLink = await getInitialUri();
//       print("Initial link: $initialLink");
//       if (initialLink != null) {
//         _handleDeepLink(initialLink, navigatorKey);
//       }
//     } catch (e) {
//       print('Error getting initial link: $e');
//     }
    
//     // Listen for links while app is running
//     print("Setting up link stream listener...");
//     uriLinkStream.listen(
//       (Uri? uri) {
//         print("Got link in stream: $uri");
//         if (uri != null) {
//           _handleDeepLink(uri, navigatorKey);
//         }
//       },
//       onError: (err) {
//         print('Error in uri link stream: $err');
//       },
//     );
    
//     print("DeepLinkHandler initialization complete");
//   }
  
//   void _handleDeepLink(Uri uri, GlobalKey<NavigatorState> navigatorKey) async {
//     print('Deep link received: $uri');
//     print('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');
//     print('Query parameters: ${uri.queryParameters}');
    
//     if (uri.scheme == 'heywork' && uri.host == 'jobs') {
//       final jobId = uri.queryParameters['id'];
//       print('Job ID extracted: $jobId');
      
//       if (jobId != null) {
//         _navigateToJobDetail(jobId, navigatorKey);
//       } else {
//         print('No job ID found in parameters');
//       }
//     } else {
//       print('Not a job link: Scheme=${uri.scheme}, Host=${uri.host}');
//     }
//   }
  
//   Future<void> _navigateToJobDetail(String jobId, GlobalKey<NavigatorState> navigatorKey) async {
//     try {
//       print('Attempting to get job details for ID: $jobId');
//       // Ensure app is ready to navigate
//       await Future.delayed(Duration(milliseconds: 1000));
      
//       final job = await _jobService.getJobById(jobId);
      
//       if (job != null) {
//         print('Job found: ${job.title}');
        
//         if (navigatorKey.currentState != null) {
//           print('Navigating to job detail screen');
//           navigatorKey.currentState!.push(
//             MaterialPageRoute(
//               builder: (context) => JobDetailScreen(job: job),
//             ),
//           );
//         } else {
//           print('Navigator state is null, cannot navigate');
//         }
//       } else {
//         print('Job not found for ID: $jobId');
//       }
//     } catch (e) {
//       print('Error in _navigateToJobDetail: $e');
//     }
//   }
// }