// lib/presentation/common_screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey_work/presentation/common_screens/hire_or_work.dart';

import 'package:hey_work/presentation/common_screens/hirer_or_worker.dart';
import 'package:hey_work/presentation/hirer_section/common/bottom_nav_bar.dart';
import 'package:hey_work/presentation/services/authentication_services.dart';
import 'package:hey_work/presentation/worker_section/bottom_navigation/bottom_nav_bar.dart';

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

  Future<void> _checkAuthState() async {
    // Wait for animation to complete partially
    await Future.delayed(Duration(milliseconds: 1800));
    
    try {
      User? currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // User is logged in, check user type
        String? userType = await _authService.getUserType();
        
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    Image.asset(
                      'assets/logo.png', // Make sure to add your logo
                      width: 150.w,
                      height: 150.w,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Hey Work',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 40.h),
                    SizedBox(
                      width: 40.w,
                      height: 40.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
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