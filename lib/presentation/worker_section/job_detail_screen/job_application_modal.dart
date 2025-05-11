// Create a new file: lib/core/models/job_application_model.dart
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

    return JobApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      workerId: data['workerId'] ?? '',
      hirerId: data['hirerId'] ?? '',
      workerName: data['workerName'] ?? 'No Name',
      workerLocation: data['workerLocation'] ?? 'No Location',
      workerProfileImage: data['workerProfileImage'],
      workerPhone: data['workerPhone'] ?? '',
      appliedAt: (data['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      jobTitle: data['jobTitle'] ?? 'No Title',
      jobCompany: data['jobCompany'] ?? 'No Company',
      jobLocation: data['jobLocation'] ?? 'No Location',
      jobBudget: data['jobBudget'] is int ? data['jobBudget'] : 0,
      jobType: data['jobType'] ?? 'part-time',
    );
  }

  // Check if the application is pending
  bool get isPending => status == 'pending';

  // Check if the application is accepted
  bool get isAccepted => status == 'accepted';

  // Check if the application is rejected
  bool get isRejected => status == 'rejected';
}
