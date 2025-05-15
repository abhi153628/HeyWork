import 'package:cloud_firestore/cloud_firestore.dart';

class JobApplicationModel {
  final String id;
  final String jobId;
  final String workerId;
  final String hirerId;
  final String workerName;
  final String workerLocation;
  final String? workerProfileImage;
  final String workerPhone;
  final DateTime appliedAt;
  final String status; // pending, accepted, rejected
  final String jobTitle;
  final String jobCompany;
  final String jobLocation;
  final int jobBudget;
  final String jobType;

  JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.workerId,
    required this.hirerId,
    required this.workerName,
    required this.workerLocation,
    this.workerProfileImage,
    required this.workerPhone,
    required this.appliedAt,
    required this.status,
    required this.jobTitle,
    required this.jobCompany,
    required this.jobLocation,
    required this.jobBudget,
    required this.jobType,
  });

  factory JobApplicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Improved data extraction with more robust type checking
    return JobApplicationModel(
      id: doc.id,
      jobId: data['jobId'] is String ? data['jobId'] : '',
      workerId: data['workerId'] is String ? data['workerId'] : '',
      hirerId: data['hirerId'] is String ? data['hirerId'] : '',
      workerName: data['workerName'] is String ? data['workerName'] : 'No Name',
      workerLocation: data['workerLocation'] is String ? data['workerLocation'] : 'No Location',
      workerProfileImage: data['workerProfileImage'] is String ? data['workerProfileImage'] : null,
      workerPhone: data['workerPhone'] is String ? data['workerPhone'] : '',
      appliedAt: data['appliedAt'] is Timestamp 
          ? (data['appliedAt'] as Timestamp).toDate() 
          : DateTime.now(),
      status: data['status'] is String ? data['status'] : 'pending',
      // Handle potential Map structures for these fields
      jobTitle: _extractStringValue(data, 'jobTitle', 'No Title'),
      jobCompany: _extractStringValue(data, 'jobCompany', 'No Company'),
      jobLocation: _extractStringValue(data, 'jobLocation', 'No Location'),
      jobBudget: _extractIntValue(data, 'jobBudget', 0),
      jobType: _extractStringValue(data, 'jobType', 'part-time'),
    );
  }

  // Helper method to safely extract String values from potentially nested fields
  static String _extractStringValue(Map<String, dynamic> data, String key, String defaultValue) {
    final value = data[key];
    if (value is String) {
      return value;
    } else if (value is Map) {
      // Try to get value from nested map
      return value['value'] is String ? value['value'] : defaultValue;
    }
    return defaultValue;
  }

  // Helper method to safely extract int values from potentially nested fields
  static int _extractIntValue(Map<String, dynamic> data, String key, int defaultValue) {
    final value = data[key];
    if (value is int) {
      return value;
    } else if (value is Map) {
      // Try to get value from nested map
      return value['value'] is int ? value['value'] : defaultValue;
    } else if (value is String) {
      // Try to parse string to int
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  // Check if the application is pending
  bool get isPending => status == 'pending';

  // Check if the application is accepted
  bool get isAccepted => status == 'accepted';

  // Check if the application is rejected
  bool get isRejected => status == 'rejected';
}