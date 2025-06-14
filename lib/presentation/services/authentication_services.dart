// lib/core/services/auth/auth_service.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:heywork/presentation/common_screens/hire_or_work.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check user type (hirer or worker)
  Future<String?> getUserType() async {
    try {
      if (currentUser == null) return null;

      // First check local storage for faster response
      final prefs = await SharedPreferences.getInstance();
      String? storedUserType = prefs.getString('user_type');
      
      if (storedUserType != null) {
        return storedUserType;
      }

      // Check in hirer collection
      final hirerDoc = await _firestore.collection('hirers').doc(currentUser!.uid).get();
      
      if (hirerDoc.exists) {
        // Cache result
        await prefs.setString('user_type', 'hirer');
        return 'hirer';
      }
      
      // Check in worker collection
      final workerDoc = await _firestore.collection('workers').doc(currentUser!.uid).get();
      
      if (workerDoc.exists) {
        // Cache result
        await prefs.setString('user_type', 'worker');
        return 'worker';
      }
      
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }
  // In AuthService class
Future<void> signOutAndNavigateToLogin(BuildContext context) async {
  try {
    // Clear cached user type
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_type');
    
    await _auth.signOut();
    
    // Navigate to login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HirerOrWorker()), // Use your actual login screen
      (route) => false,
    );
  } catch (e) {
    print('Error signing out: $e');
    // Show error to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logout failed: ${e.toString()}')),
    );
  }
}

  // Sign out
  Future<void> signOut() async {
    try {
      // Clear cached user type
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_type');
      
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Verify phone for specific user type
  Future<String> verifyPhoneForUserType(String phoneNumber, String userType) async {
    // Format phone number to ensure it starts with +91
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber';
    }

    // Check if the phone number exists in the specified user type
    final QuerySnapshot query;
    
    if (userType == 'hirer') {
      query = await _firestore
          .collection('hirers')
          .where('loggedPhoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
    } else {
      query = await _firestore
          .collection('workers')
          .where('loggedPhoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
    }

    if (query.docs.isEmpty) {
      throw 'No $userType account found with this number. Please sign up instead.';
    }

    Completer<String> completer = Completer<String>();
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification not handled here as we want manual OTP entry
      },
      verificationFailed: (FirebaseAuthException e) {
        completer.completeError(e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(verificationId);
        }
      },
      timeout: Duration(seconds: 120),
    );

    return completer.future;
  }

  // Verify OTP and sign in
  Future<UserCredential> verifyOTPAndSignIn(String verificationId, String otp) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, 
        smsCode: otp
      );

      // Sign in the user with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error verifying OTP: $e');
      throw e;
    }
  }
  
  // Store user type in local storage
  Future<void> storeUserType(String userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType);
    } catch (e) {
      print('Error storing user type: $e');
    }
  }
}