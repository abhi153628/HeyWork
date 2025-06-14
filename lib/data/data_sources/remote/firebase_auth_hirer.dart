// lib/services/firebase_service.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heywork/data/modals/hirer/hirer_modal.dart';

import 'package:uuid/uuid.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Phone verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: Duration(seconds: 60),
    );
  }

  // Verify OTP
  Future<UserCredential> verifyOTP(
      String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Clear any previous login attempts
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // Sign in with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print("OTP Verification error: $e");
      throw e;
    }
  }

  // Upload image to Firebase Storage
  Future<String> uploadProfileImage(File imageFile) async {
    final uuid = Uuid();
    String fileName = '${uuid.v4()}.jpg';
    final storageRef = _storage.ref().child('profile_images/$fileName');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Save user data to Firestore
  Future<void> saveUserData(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  // Check if user exists
  Future<bool> checkIfUserExists(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    return doc.exists;
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
