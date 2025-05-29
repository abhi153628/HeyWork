// lib/presentation/common_screens/splash_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/common_screens/hire_or_work.dart';
import 'package:hey_work/presentation/hirer_section/common/bottom_nav_bar.dart';
import 'package:hey_work/presentation/services/authentication_services.dart';
import 'package:hey_work/presentation/worker_section/bottom_navigation/bottom_nav_bar.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
    
    // Check auth state and navigate after animation
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

 // Replace the _checkAuthState method in splash_screen.dart with this:

Future<void> _checkAuthState() async {
  // Wait for animation to complete partially
  await Future.delayed(Duration(milliseconds: 1800));
  
  try {
    User? currentUser = _authService.currentUser;
    
    if (currentUser != null) {
      // User is logged in, check user type from both collections
      String? userType = await _getUserTypeFromFirestore(currentUser.uid);
      
      if (userType == 'hirer') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen())
        );
      } else if (userType == 'worker') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WorkerMainScreen())
        );
      } else {
        // User type unknown, log out and navigate to selection screen
        await _authService.signOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HirerOrWorker())
        );
      }
    } else {
      // No user is logged in, navigate to hirer/worker selection
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HirerOrWorker())
      );
    }
  } catch (e) {
    print('Error in auth check: $e');
    // On error, navigate to selection screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HirerOrWorker())
    );
  }
}

// Add this helper method to the SplashScreen class:
Future<String?> _getUserTypeFromFirestore(String uid) async {
  try {
    // Check in workers collection first
    DocumentSnapshot workerDoc = await FirebaseFirestore.instance
        .collection('workers')
        .doc(uid)
        .get();
        
    if (workerDoc.exists && workerDoc.data() != null) {
      return 'worker';
    }
    
    // Check in hirers collection
    DocumentSnapshot hirerDoc = await FirebaseFirestore.instance
        .collection('hirers')
        .doc(uid)
        .get();
        
    if (hirerDoc.exists && hirerDoc.data() != null) {
      return 'hirer';
    }
    
    // If user is authenticated but no data exists, sign them out
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }
    
    return null;
  } catch (e) {
    print('Error getting user type: $e');
    return null;
  }
}

// Don't forget to import Firestore at the top:
// import 'package:cloud_firestore/cloud_firestore.dart';

  @override
  Widget build(BuildContext context) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    return Scaffold(
      backgroundColor:Color(0xFF0c17fd),
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  
                    Container(decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Image.asset(
                          'asset/new loo trans blue.png', // Make sure to add your logo
                          width: 50.w,
                          height: 50.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Heywork',
                      style: GoogleFonts.poppins(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                      SizedBox(height: 40.h),
                 
                    
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}