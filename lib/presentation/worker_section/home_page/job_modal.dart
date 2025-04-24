import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String title;
  final String company;
  final String location;
  final String district;
  final int salary;
  final String salaryPeriod;
  final String jobType;
  final String? imageUrl;
  final DateTime postedAt;

  JobModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.district,
    required this.salary,
    required this.salaryPeriod,
    required this.jobType,
    this.imageUrl,
    required this.postedAt,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return JobModel(
      id: doc.id,
      title: data['jobTitle'] ?? '',
      company: data['hirerBusinessName'] ?? '',
      location: data['hirerLocation'] ?? '',
      district: data['location'] ?? '',
      salary: data['salary'] ?? 0,
      salaryPeriod: data['salaryPeriod'] ?? 'per day',
      jobType: data['jobType'] ?? 'full-time',
      imageUrl: data['hirerProfileImage'],
      postedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}