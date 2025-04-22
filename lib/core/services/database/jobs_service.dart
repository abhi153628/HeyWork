import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JobService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Function to save job data to Firestore
  // Function to save job data to Firestore
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

    // Get user data from hirers collection
    final userDoc = await _firestore.collection('hirers').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    // Create job document with both job and user data
    final completeJobData = {
      ...jobData,
      'hirerId': user.uid,
      'hirerName': userData['name'] ?? 'User',
      'hirerBusinessName': userData['businessName'] ?? '',
      'hirerLocation': userData['location'] ?? '',
      'hirerPhone': userData['phoneNumber'] ?? '',
      'hirerProfileImage': userData['profileImage'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    };

    DocumentReference jobRef;
    
    // Rest of the function remains the same...
      
      if (isEditing && jobId != null) {
        // Update existing job
        jobRef = _firestore.collection('jobs').doc(jobId);
        await jobRef.update(completeJobData);
      } else {
        // Create new job
        jobRef = _firestore.collection('jobs').doc();
        completeJobData['jobId'] = jobRef.id;
        await jobRef.set(completeJobData);
        
        // Also update user's jobs collection
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