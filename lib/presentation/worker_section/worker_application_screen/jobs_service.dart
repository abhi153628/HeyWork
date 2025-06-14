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
  final DateTime? expiryDate;

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
    this.expiryDate,
  });

  // Add this getter to check if job is expired
  bool get isExpired => status.toLowerCase() == 'expired';

 factory JobModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;

  // Helper function to safely extract String from potentially nested data
  String _extractString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      // Handle common nested field patterns
      return value['name'] ?? 
             value['placeName'] ?? 
             value['businessName'] ?? 
             value['title'] ?? 
             value['value'] ?? 
             defaultValue;
    }
    return value.toString();
  }

  Map<String, dynamic>? salaryRangeMap;
  if (data.containsKey('salaryRange')) {
    salaryRangeMap = data['salaryRange'] as Map<String, dynamic>;
  } else if (data.containsKey('min') && data.containsKey('max')) {
    salaryRangeMap = {
      'min': data['min'] ?? 0,
      'max': data['max'] ?? 0,
    };
  }

  DateTime? expiryDate;
  if (data.containsKey('expiryDate')) {
    expiryDate = (data['expiryDate'] as Timestamp).toDate();
  } else if (data.containsKey('date')) {
    final workDate = (data['date'] as Timestamp).toDate();
    expiryDate = workDate.add(const Duration(days: 20));
  }

  return JobModel(
    id: doc.id,
    title: _extractString(data['jobTitle'] ?? data['title'], 'No Title'),
    company: _extractString(data['hirerBusinessName'], 'No Company'),
    location: _extractString(data['hirerLocation'], 'No Location'),
    description: _extractString(data['description']),
    budget: data['budget'] is int ? data['budget'] : 0,
    salaryRange: salaryRangeMap,
    jobType: _extractString(data['jobType'], 'full-time'),
    jobCategory: _extractString(data['jobCategory'], 'All Works'),
    imageUrl: _extractString(data['hirerProfileImage']),
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    status: _extractString(data['status'], 'active'),
    hirerId: _extractString(data['hirerId']),
    hirerName: _extractString(data['hirerName']),
    hirerPhone: _extractString(data['hirerPhone']),
    hirerLocation: _extractString(data['hirerLocation']),
    hirerIndustry: _extractString(data['hirerIndustry']),
    hirerBusinessName: _extractString(data['hirerBusinessName']),
    timeFormatted: _extractString(data['timeFormatted']),
    expiryDate: expiryDate,
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

  String? get currentUserId => _auth.currentUser?.uid;

  // Helper method to safely extract job title from Firestore data
  static String extractJobTitle(Map<String, dynamic> data) {
    return data['jobCategory'] ?? 
           data['jobTitle'] ?? 
           data['title'] ?? 
           data['name'] ?? 
           data['jobName'] ?? 
           'Unknown Job';
  }

  // Helper method to safely extract company name from Firestore data
  static String extractCompanyName(Map<String, dynamic> data) {
    return data['hirerBusinessName'] ?? 
           data['company'] ?? 
           data['businessName'] ?? 
           data['companyName'] ?? 
           'Unknown Company';
  }

  // Helper method to safely extract job location from Firestore data
  static String extractJobLocation(Map<String, dynamic> data) {
    return data['hirerLocation'] ?? 
           data['location'] ?? 
           data['jobLocation'] ?? 
           'Unknown Location';
  }

  // Helper method to safely extract job type from Firestore data
  static String extractJobType(Map<String, dynamic> data) {
    return data['jobType'] ?? 
           data['type'] ?? 
           data['workType'] ?? 
           'part-time';
  }

  // Method to get job details by ID with proper title extraction
  Future<Map<String, dynamic>?> getJobDetailsById(String jobId) async {
    try {
      print('Getting job details for ID: $jobId');
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        
        final jobDetails = {
          'id': doc.id,
          'jobTitle': extractJobTitle(data),
          'company': extractCompanyName(data),
          'location': extractJobLocation(data),
          'jobType': extractJobType(data),
          'description': data['description'] ?? '',
          'budget': data['budget'] ?? 0,
          'status': data['status'] ?? 'active',
          'createdAt': data['createdAt'],
          'date': data['date'],
          'hirerId': data['hirerId'] ?? '',
          'hirerName': data['hirerName'] ?? '',
          'hirerPhone': data['hirerPhone'] ?? '',
          'originalData': data,
        };
        
        print('Successfully extracted job details: ${jobDetails['jobTitle']}');
        return jobDetails;
      }
      
      print('Job document not found');
      return null;
    } catch (e) {
      print('Error getting job details: $e');
      return null;
    }
  }

  // Enhanced method to get completed jobs for a worker with proper title extraction
  Future<List<Map<String, dynamic>>> getCompletedJobsForWorker(String workerId) async {
    try {
      print('Getting completed jobs for worker: $workerId');
      
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'accepted')
          .get();

      List<Map<String, dynamic>> jobs = [];

      for (var doc in jobsSnapshot.docs) {
        final jobData = doc.data();
        final jobId = jobData['jobId'];

        print('Processing job application: ${doc.id}, jobId: $jobId');

        if (jobId != null) {
          final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
          if (jobDoc.exists) {
            final fullJobData = jobDoc.data() ?? {};
            
            final jobDetails = {
              'id': jobDoc.id,
              'jobTitle': extractJobTitle(fullJobData),
              'hirerBusinessName': extractCompanyName(fullJobData),
              'hirerLocation': extractJobLocation(fullJobData),
              'jobType': extractJobType(fullJobData),
              'description': fullJobData['description'] ?? '',
              'budget': fullJobData['budget'] ?? 0,
              'date': fullJobData['date'],
              'createdAt': fullJobData['createdAt'],
              'status': fullJobData['status'] ?? 'completed',
              'jobCategory': fullJobData['jobCategory'] ?? 'General',
              ...fullJobData,
            };
            
            jobs.add(jobDetails);
            print('Added job: ${jobDetails['jobTitle']}');
          } else {
            print('Job document not found for jobId: $jobId');
          }
        }
      }

      print('Total completed jobs found: ${jobs.length}');
      return jobs;
    } catch (e) {
      print('Error loading completed jobs: $e');
      return [];
    }
  }

  // Method to get job category counts for a worker
  Future<Map<String, int>> getJobCategoryCountsForWorker(String workerId) async {
    try {
      final completedJobs = await getCompletedJobsForWorker(workerId);
      Map<String, int> categoryCounts = {};
      
      for (var job in completedJobs) {
        final category = job['jobCategory'] ?? 'Uncategorized';
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
      
      return categoryCounts;
    } catch (e) {
      print('Error getting job category counts: $e');
      return {};
    }
  }

  // Method to debug job data structure
  Future<void> debugJobData(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('=== DEBUG JOB DATA ===');
        print('Job ID: $jobId');
        print('Available fields: ${data.keys.toList()}');
        print('Raw data: $data');
        print('Extracted title: ${extractJobTitle(data)}');
        print('Extracted company: ${extractCompanyName(data)}');
        print('=====================');
      }
    } catch (e) {
      print('Error debugging job data: $e');
    }
  }

  // Updated method to mark job as expired instead of deleting
  void _checkAndMarkExpiredJob(JobModel job) async {
    if (job.status.toLowerCase() != 'active') {
      return;
    }

    if (job.expiryDate != null && job.expiryDate!.isBefore(DateTime.now())) {
      try {
        await _firestore.collection('jobs').doc(job.id).update({
          'status': 'expired',
          'expiredAt': FieldValue.serverTimestamp(),
          'expiryReason': 'Auto-expired after 20 days',
        });
        
        // Also update in hirer's subcollection
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('hirers')
              .doc(job.hirerId)
              .collection('jobs')
              .doc(job.id)
              .update({
            'status': 'expired',
            'expiredAt': FieldValue.serverTimestamp(),
          });
        }
        
        print('Job ${job.id} marked as expired');
      } catch (e) {
        print('Error marking job as expired ${job.id}: $e');
      }
    }
  }

  // Updated method to clean up very old jobs (optional - only delete after much longer period)
  Future<void> cleanUpVeryOldJobs() async {
    try {
      // Only delete jobs that have been expired for more than 6 months
      final cutoffDate = DateTime.now().subtract(const Duration(days: 180));
      final cutoffTimestamp = Timestamp.fromDate(cutoffDate);
      
      final snapshot = await _firestore
          .collection('jobs')
          .where('status', isEqualTo: 'expired')
          .where('expiredAt', isLessThan: cutoffTimestamp)
          .get();
      
      for (final doc in snapshot.docs) {
        await _firestore.collection('jobs').doc(doc.id).delete();
        print('Deleted very old expired job ${doc.id}');
      }
    } catch (e) {
      print('Error cleaning up very old jobs: $e');
    }
  }

  Stream<List<JobModel>> getJobsByCategory(String category,
      {String? workerLocation}) {
    if (category == 'All Jobs') {
      return getJobs();
    } else if (workerLocation != null && category == workerLocation) {
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
          _checkAndMarkExpiredJob(job);
          return job;
        } catch (e) {
          print('Error parsing job document ${doc.id}: $e');
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

  // Get active jobs for hirer
  Stream<List<JobModel>> getActiveJobsForHirer(String hirerId) {
    return _firestore
        .collection('jobs')
        .where('hirerId', isEqualTo: hirerId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final job = JobModel.fromFirestore(doc);
          _checkAndMarkExpiredJob(job);
          return job;
        } catch (e) {
          print('Error parsing active job document ${doc.id}: $e');
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

  // Get expired jobs for hirer
  Stream<List<JobModel>> getExpiredJobsForHirer(String hirerId) {
    return _firestore
        .collection('jobs')
        .where('hirerId', isEqualTo: hirerId)
        .where('status', isEqualTo: 'expired')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  Future<Map<String, dynamic>> saveJobData({
    required Map<String, dynamic> jobData,
    required BuildContext context,
    bool isEditing = false,
    String? jobId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      if (jobData.containsKey('time') && jobData['time'] is TimeOfDay) {
        final TimeOfDay timeOfDay = jobData['time'];
        jobData.remove('time');
        jobData['timeInMinutes'] = timeOfDay.hour * 60 + timeOfDay.minute;
        jobData['timeFormatted'] = timeOfDay.format(context);
      }

      if (jobData.containsKey('min') && jobData.containsKey('max')) {
        jobData['salaryRange'] = {
          'min': jobData['min'],
          'max': jobData['max'],
        };
      }

      final userDoc = await _firestore.collection('hirers').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      if (jobData.containsKey('industry')) {
        await _firestore.collection('hirers').doc(user.uid).update({
          'industry': jobData['industry'],
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

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
        jobRef = _firestore.collection('jobs').doc(jobId);
        await jobRef.update(completeJobData);
      } else {
        jobRef = _firestore.collection('jobs').doc();
        completeJobData['jobId'] = jobRef.id;
        await jobRef.set(completeJobData);

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

  Future<bool> updateJobStatus(String jobId, String status) async {
    try {
      await _firestore.collection('jobs').doc(jobId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
        if (status == 'closed') 'closedAt': FieldValue.serverTimestamp(),
        if (status == 'expired') 'expiredAt': FieldValue.serverTimestamp(),
      });
      
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

  Future<bool> deleteJob(String jobId) async {
    try {
      await _firestore.collection('jobs').doc(jobId).delete();
      
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

  List<JobCategory> getJobCategories() {
    return [
      JobCategory(
        id: 'location',
        name: 'Location',
        iconPath: 'assets/icons/location.png',
        isSelected: true,
      ),
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
}