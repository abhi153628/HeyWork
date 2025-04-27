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
  Stream<List<JobModel>> getJobs() {
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return JobModel.fromFirestore(doc);
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

  // Fetch jobs by category
  Stream<List<JobModel>> getJobsByCategory(String category) {
    if (category == 'All Works') {
      return getJobs();
    }
    
    return _firestore
        .collection('jobs')
        .where('status', isEqualTo: 'active')
        .where('jobCategory', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    });
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore.collection('jobs').doc(jobId).get();
      if (doc.exists) {
        return JobModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching job by ID: $e');
      return null;
    }
  }

  // Get predefined job categories - updated based on screenshot
  List<JobCategory> getJobCategories() {
    return [
      JobCategory(
        id: 'all',
        name: 'All Works',
        iconPath: 'assets/icons/all_works.png',
        isSelected: true,
      ),
      JobCategory(
        id: 'food-server',
        name: 'Food Server',
        iconPath: 'assets/icons/food_server.png',
      ),
      JobCategory(
        id: 'cleaning',
        name: 'Cleaning',
        iconPath: 'assets/icons/cleaning.png',
      ),
      JobCategory(
        id: 'moving',
        name: 'Moving',
        iconPath: 'assets/icons/moving.png',
      ),
      JobCategory(
        id: 'cooking',
        name: 'Cooking',
        iconPath: 'assets/icons/cooking.png',
      ),
      JobCategory(
        id: 'driving',
        name: 'Driving',
        iconPath: 'assets/icons/driving.png',
      ),
      JobCategory(
        id: 'housekeeping',
        name: 'Housekeeping',
        iconPath: 'assets/icons/housekeeping.png',
      ),
      JobCategory(
        id: 'hospitality',
        name: 'Hospitality & Hotels',
        iconPath: 'assets/icons/hospitality.png',
      ),
    ];
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
}