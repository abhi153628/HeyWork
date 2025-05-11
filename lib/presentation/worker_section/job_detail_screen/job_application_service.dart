// Create a new file: lib/core/services/job_application_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'job_application_modal.dart';

class JobApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Check if user has applied for a job
  Future<bool> hasAppliedForJob(String jobId) async {
    if (currentUserId == null) return false;

    final applicationDoc = await _firestore
        .collection('jobApplications')
        .doc('${jobId}_${currentUserId}')
        .get();

    return applicationDoc.exists;
  }

  // Apply for a job
  Future<Map<String, dynamic>> applyForJob(String jobId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'You need to login first',
        };
      }

      // Check if already applied
      final hasApplied = await hasAppliedForJob(jobId);
      if (hasApplied) {
        return {
          'success': false,
          'message': 'You have already applied for this job',
        };
      }

      // Get job details
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      if (!jobDoc.exists) {
        return {
          'success': false,
          'message': 'Job not found',
        };
      }

      final jobData = jobDoc.data() as Map<String, dynamic>;

      // Get worker details
      final workerDoc =
          await _firestore.collection('workers').doc(user.uid).get();
      if (!workerDoc.exists) {
        return {
          'success': false,
          'message': 'Worker profile not found',
        };
      }

      final workerData = workerDoc.data() as Map<String, dynamic>;

      // Create application data
      final application = {
        'jobId': jobId,
        'workerId': user.uid,
        'hirerId': jobData['hirerId'] ?? '',
        'workerName': workerData['name'] ?? 'No Name',
        'workerLocation': workerData['location'] ?? 'No Location',
        'workerProfileImage': workerData['profileImage'],
        'workerPhone': workerData['phoneNumber'] ?? '',
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, accepted, rejected
        'jobTitle': jobData['jobCategory'] ?? 'No Title',
        'jobCompany': jobData['hirerBusinessName'] ?? 'No Company',
        'jobLocation': jobData['hirerLocation'] ?? 'No Location',
        'jobBudget': jobData['budget'] ?? 0,
        'jobType': jobData['jobType'] ?? 'part-time',
      };

      // Save application document with composite ID (jobId_workerId)
      final applicationId = '${jobId}_${user.uid}';

      // Use batch write for atomicity
      final batch = _firestore.batch();

      // Save to applications collection (for easy querying)
      final appRef =
          _firestore.collection('jobApplications').doc(applicationId);
      batch.set(appRef, application);

      // Add to worker's applications subcollection
      final workerAppRef = _firestore
          .collection('workers')
          .doc(user.uid)
          .collection('applications')
          .doc(jobId);
      batch.set(workerAppRef, application);

      // Add to job's applications subcollection
      final jobAppRef = _firestore
          .collection('jobs')
          .doc(jobId)
          .collection('applications')
          .doc(user.uid);
      batch.set(jobAppRef, application);

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Application submitted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error applying for job: $e',
      };
    }
  }

  // Get worker's applications
  Stream<List<JobApplicationModel>> getWorkerApplications() {
    if (currentUserId == null) {
      // Return empty stream if not logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('jobApplications')
        .where('workerId', isEqualTo: currentUserId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get applications for a specific job (for hirers)
  Stream<List<JobApplicationModel>> getJobApplications(String jobId) {
    return _firestore
        .collection('jobs')
        .doc(jobId)
        .collection('applications')
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all applications for hirer's jobs
  Stream<List<JobApplicationModel>> getHirerApplications() {
    if (currentUserId == null) {
      // Return empty stream if not logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('jobApplications')
        .where('hirerId', isEqualTo: currentUserId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => JobApplicationModel.fromFirestore(doc))
          .toList();
    });
  }

  // Update application status (for hirers)
  Future<Map<String, dynamic>> updateApplicationStatus(
      String applicationId, String status) async {
    try {
      // Parse the composite ID to get jobId and workerId
      final parts = applicationId.split('_');
      if (parts.length != 2) {
        return {
          'success': false,
          'message': 'Invalid application ID',
        };
      }

      final jobId = parts[0];
      final workerId = parts[1];

      // Use batch write to update all copies of the application
      final batch = _firestore.batch();

      // Update in jobApplications collection
      final appRef =
          _firestore.collection('jobApplications').doc(applicationId);
      batch.update(appRef, {'status': status});

      // Update in worker's applications subcollection
      final workerAppRef = _firestore
          .collection('workers')
          .doc(workerId)
          .collection('applications')
          .doc(jobId);
      batch.update(workerAppRef, {'status': status});

      // Update in job's applications subcollection
      final jobAppRef = _firestore
          .collection('jobs')
          .doc(jobId)
          .collection('applications')
          .doc(workerId);
      batch.update(jobAppRef, {'status': status});

      // Commit the batch
      await batch.commit();

      return {
        'success': true,
        'message': 'Application status updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating application status: $e',
      };
    }
  }
}
