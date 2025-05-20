import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final int budget;
  final Map<String, dynamic>? salaryRange;
  final String jobType;
  final String jobCategory;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime date;
  final String status;
  final String hirerId;
  final String hirerName;
  final String hirerPhone;
  final String hirerLocation;
  final String hirerIndustry;
  final String hirerBusinessName;
  final String? timeFormatted;
  final DateTime? expiryDate; // Added field for job expiration

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.budget,
    this.salaryRange,
    required this.jobType,
    required this.jobCategory,
    this.imageUrl,
    required this.createdAt,
    required this.date,
    required this.status,
    required this.hirerId,
    required this.hirerName,
    required this.hirerPhone,
    required this.hirerLocation,
    required this.hirerIndustry,
    required this.hirerBusinessName,
    this.timeFormatted,
    this.expiryDate, // Added to constructor
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Create salary range map if min and max exist in data
    Map<String, dynamic>? salaryRangeMap;
    if (data.containsKey('salaryRange')) {
      salaryRangeMap = data['salaryRange'] as Map<String, dynamic>;
    } else if (data.containsKey('min') && data.containsKey('max')) {
      salaryRangeMap = {
        'min': data['min'] ?? 0,
        'max': data['max'] ?? 0,
      };
    }

    // Handle expiry date
    DateTime? expiryDate;
    if (data.containsKey('expiryDate')) {
      expiryDate = (data['expiryDate'] as Timestamp).toDate();
    } else if (data.containsKey('date')) {
      // If expiryDate doesn't exist, calculate it as date + 20 days
      final workDate = (data['date'] as Timestamp).toDate();
      expiryDate = workDate.add(const Duration(days: 20));
    }

    return JobModel(
      id: doc.id,
      title: data['jobTitle'] ?? data['title'] ?? 'No Title',
      company: data['hirerBusinessName'] ?? 'No Company',
      location: data['hirerLocation'] ?? 'No Location',
      description: data['description'] ?? '',
      budget: data['budget'] is int ? data['budget'] : 0,
      salaryRange: salaryRangeMap,
      jobType: data['jobType'] ?? 'full-time',
      jobCategory: data['jobCategory'] ?? 'All Works',
      imageUrl: data['hirerProfileImage'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'active',
      hirerId: data['hirerId'] ?? '',
      hirerName: data['hirerName'] ?? '',
      hirerPhone: data['hirerPhone'] ?? '',
      hirerLocation: data['hirerLocation'] ?? '',
      hirerIndustry: data['hirerIndustry'] ?? '',
      hirerBusinessName: data['hirerBusinessName'] ?? '',
      timeFormatted: data['timeFormatted'],
      expiryDate: expiryDate, // Add expiry date
    );
  }
}

class JobCategory {
  final String id;
  final String name;
  final String iconPath;
  final bool isSelected;

  JobCategory({
    required this.id,
    required this.name,
    required this.iconPath,
    this.isSelected = false,
  });
}

class JobProvider extends ChangeNotifier {
  List<JobModel> _jobs = [];
  List<JobCategory> _categories = [];
  String _selectedCategory = 'All Works';
  bool _isLoading = false;

  List<JobModel> get jobs => _jobs;
  List<JobCategory> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  void setJobs(List<JobModel> jobs) {
    _jobs = jobs;
    notifyListeners();
  }

  void setCategories(List<JobCategory> categories) {
    _categories = categories;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Fetch all jobs
 

  // Auto-close jobs after 20 days since work date
  void _checkAndAutoCloseJob(JobModel job) async {
    // Only check active jobs
    if (job.status.toLowerCase() != 'active') {
      return;
    }

    // If the job has an expiry date and it's in the past
    if (job.expiryDate != null && job.expiryDate!.isBefore(DateTime.now())) {
      try {
        await _firestore.collection('jobs').doc(job.id).update({
          'status': 'closed',
          'closedAt': FieldValue.serverTimestamp(),
          'closureReason': 'Auto-closed after 20 days',
        });
        
        print('Job ${job.id} auto-closed due to expiry');
      } catch (e) {
        print('Error auto-closing job ${job.id}: $e');
      }
    }
  }

  // Auto-delete jobs that were closed more than 20 days ago
  Future<void> cleanUpOldJobs() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 20));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      // Get jobs that were closed at least 20 days ago
      final snapshot = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'closed')
          .where('closedAt', isLessThan: cutoffTimestamp)
          .get();
      
      // Delete each job
      for (final doc in snapshot.docs) {
        await _firestore.collection('jobs').doc(doc.id).delete();
        print('Deleted old job ${doc.id}');
      }
    } catch (e) {
      print('Error cleaning up old jobs: $e');
    }
  }

  // In JobService class
  Stream<List<JobModel>> getJobsByCategory(String category,
      {String? workerLocation}) {
    if (category == 'All Jobs') {
      return getJobs();
    } else if (workerLocation != null && category == workerLocation) {
      // Filter by the worker's location
      return _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'active')
          .where('hirerLocation', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      });
    } else if (category == 'Full-Time') {
      return _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'active')
          .where('jobType', isEqualTo: 'full-time')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      });
    } else if (category == 'Part-Time') {
      return _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'active')
          .where('jobType', isEqualTo: 'part-time')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
      });
    }

    // Default return all jobs
    return getJobs();
  }
  Stream<List<JobModel>> getJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final job = JobModel.fromFirestore(doc);
          // Check if job should be auto-deleted
          _checkAndDeleteExpiredJob(job);
          return job;
        } catch (e) {
          print('Error parsing job document ${doc.id}: $e');
          // Return a placeholder job model with error information
          return JobModel(
            id: doc.id,
            title: 'Error parsing job',
            company: 'Error',
            location: 'Error',
            description: 'Error parsing job: $e',
            budget: 0,
            jobType: 'unknown',
            jobCategory: 'unknown',
            createdAt: DateTime.now(),
            date: DateTime.now(),
            status: 'error',
            hirerId: '',
            hirerName: '',
            hirerPhone: '',
            hirerLocation: '',
            hirerIndustry: '',
            hirerBusinessName: '',
          );
        }
      }).toList();
    });
  }

  // Auto-delete jobs 20 days after the scheduled work date
  void _checkAndDeleteExpiredJob(JobModel job) async {
    // Calculate the deletion date (20 days after the scheduled work date)
    final deletionDate = job.date.add(const Duration(days: 20));
    
    // If current date is past the deletion date, delete the job
    if (DateTime.now().isAfter(deletionDate)) {
      try {
        // Delete the job document
        await _firestore.collection('jobs').doc(job.id).delete();
        
        // Also delete from user's jobs collection
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('hirers')
              .doc(job.hirerId)
              .collection('jobs')
              .doc(job.id)
              .delete();
        }
        
        print('Job ${job.id} auto-deleted 20 days after scheduled date');
      } catch (e) {
        print('Error auto-deleting job ${job.id}: $e');
      }
    }
  }

  // Save job data to Firestore
  Future<Map<String, dynamic>> saveJobData({
    required Map<String, dynamic> jobData,
    required BuildContext context,
    bool isEditing = false,
    String? jobId,
  }) async {
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Process TimeOfDay object before saving
      if (jobData.containsKey('time') && jobData['time'] is TimeOfDay) {
        final TimeOfDay timeOfDay = jobData['time'];
        // Remove the TimeOfDay object
        jobData.remove('time');
        // Add processed time data
        jobData['timeInMinutes'] = timeOfDay.hour * 60 + timeOfDay.minute;
        jobData['timeFormatted'] = timeOfDay.format(context);
      }

      // Handle salary range if provided as min/max values
      if (jobData.containsKey('min') && jobData.containsKey('max')) {
        jobData['salaryRange'] = {
          'min': jobData['min'],
          'max': jobData['max'],
        };
        // Keep the original fields too for backward compatibility
      }

      // Get user data from hirers collection
      final userDoc = await _firestore.collection('hirers').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Check if industry data exists in jobData and save it to hirer document
      if (jobData.containsKey('industry')) {
        // Update hirer document with industry information
        await _firestore.collection('hirers').doc(user.uid).update({
          'industry': jobData['industry'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create job document with both job and user data
      final completeJobData = {
        ...jobData,
        'hirerId': user.uid,
        'hirerName': userData['name'] ?? 'User',
        'hirerBusinessName': userData['businessName'] ?? '',
        'hirerLocation': userData['location'] ?? '',
        'hirerPhone': userData['phoneNumber'] ?? '',
        'hirerProfileImage': userData['profileImage'] ?? '',
        'hirerIndustry': userData['industry'] ?? jobData['industry'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'active',
      };

      DocumentReference jobRef;

      if (isEditing && jobId != null) {
        // Update existing job
        jobRef = _firestore.collection('jobs').doc(jobId);
        await jobRef.update(completeJobData);
      } else {
        // Create new job
        jobRef = _firestore.collection('jobs').doc();
        completeJobData['jobId'] = jobRef.id;
        await jobRef.set(completeJobData);

        // Also update user's jobs collection with more complete data
        await _firestore
            .collection('hirers')
            .doc(user.uid)
            .collection('jobs')
            .doc(jobRef.id)
            .set({
          'jobId': jobRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'jobCategory': jobData['jobCategory'],
          'jobType': jobData['jobType'],
          'budget': jobData['budget'],
          'description': jobData['description'],
          'salaryRange': jobData['salaryRange'],
          'industry': jobData['industry'] ?? userData['industry'] ?? '',
          'status': 'active',
        });
      }

      return {
        'success': true,
        'jobId': jobRef.id,
        'jobData': completeJobData,
      };
    } catch (e) {
      print('Error saving job data: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Update job status (active/closed)
  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'closed') 'closedAt': FieldValue.serverTimestamp(),
      });
      
      // Also update in user's jobs collection
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('hirers')
            .doc(user.uid)
            .collection('jobs')
            .doc(jobId)
            .update({
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      return true;
    } catch (e) {
      print('Error updating job status: $e');
      return false;
    }
  }

  // Delete job
  Future<bool> deleteJob(String jobId) async {
    try {
      // Delete job document
      await _firestore.collection('jobs').doc(jobId).delete();
      
      // Delete from user's jobs collection
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('hirers')
            .doc(user.uid)
            .collection('jobs')
            .doc(jobId)
            .delete();
      }
      
      return true;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }

  // Get job by ID
Future<JobModel?> getJobById(String jobId) async {
  try {
    print('getJobById called with ID: $jobId');
    final doc = await _firestore.collection('jobs').doc(jobId).get();
    
    print('Document exists: ${doc.exists}');
    if (doc.exists) {
      final job = JobModel.fromFirestore(doc);
      print('Successfully created JobModel: ${job.title}');
      return job;
    }
    print('Document not found');
    return null;
  } catch (e) {
    print('Error in getJobById: $e');
    return null;
  }
}

  // Get predefined job categories
  List<JobCategory> getJobCategories() {
    return [
      // Location category first - placeholder that will be updated
      JobCategory(
        id: 'location',
        name: 'Location',
        iconPath: 'assets/icons/location.png',
        isSelected: true,
      ),
      // All Jobs category is second
      JobCategory(
        id: 'all',
        name: 'All Jobs',
        iconPath: 'assets/icons/all_works.png',
      ),
      JobCategory(
        id: 'full-time',
        name: 'Full-Time',
        iconPath: 'assets/icons/full_time.png',
      ),
      JobCategory(
        id: 'part-time',
        name: 'Part-Time',
        iconPath: 'assets/icons/part_time.png',
      ),
    ];
  }

  // Get worker's location
  Future<String> getWorkerLocation() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc =
            await _firestore.collection('workers').doc(user.uid).get();
        final userData = userDoc.data() ?? {};
        return userData['location'] ?? 'Location';
      } catch (e) {
        print('Error fetching worker location: $e');
        return 'Location';
      }
    }
    return 'Location';
  }

  // Stream to listen for location changes
  Stream<String> watchWorkerLocation() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('workers')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        final data = snapshot.data() ?? {};
        return data['location'] ?? 'Location';
      });
    }
    return Stream.value('Location');
  }

  // Save job data to Firestore
 }

// JobApplicationService class to handle getting applications by status
class JobApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all applications for a job
  Stream<List<JobApplicationModel>> getJobApplications(String jobId) {
    return _firestore
        .collection('jobApplications')
        .where('jobId', isEqualTo: jobId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get applications by status
  Stream<List<JobApplicationModel>> getJobApplicationsByStatus(String jobId, String status) {
    return _firestore
        .collection('jobApplications')
        .where('jobId', isEqualTo: jobId)
        .where('status', isEqualTo: status)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update application status
  Future<Map<String, dynamic>> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      await _firestore.collection('jobApplications').doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return {
        'success': true,
        'message': 'Application ${status == "accepted" ? "accepted" : "rejected"} successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating application: $e',
      };
    }
  }

  // Delete application
  Future<Map<String, dynamic>> deleteApplication(String applicationId) async {
    try {
      await _firestore.collection('jobApplications').doc(applicationId).delete();
      
      return {
        'success': true,
        'message': 'Application deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting application: $e',
      };
    }
  }
}

// JobApplicationModel class
class JobApplicationModel {
  final String id;
  final String jobId;
  final String workerId;
  final String workerName;
  final String workerLocation;
  final String workerPhone;
  final String? workerProfileImage;
  final DateTime appliedAt;
  final String status;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.workerName,
    required this.workerLocation,
    required this.workerPhone,
    this.workerProfileImage,
    required this.appliedAt,
    required this.status,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';

  factory JobApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return JobApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      workerId: data['workerId'] ?? '',
      workerName: data['workerName'] ?? 'Unknown Worker',
      workerLocation: data['workerLocation'] ?? 'Unknown Location',
      workerPhone: data['workerPhone'] ?? '',
      workerProfileImage: data['workerProfileImage'],
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }
}