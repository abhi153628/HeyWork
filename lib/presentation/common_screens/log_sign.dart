// lib/presentation/common_screens/login_or_signup.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hey_work/presentation/common_screens/hire_or_work.dart';
import 'package:hey_work/presentation/common_screens/hirer_or_worker.dart';
import 'package:hey_work/presentation/hirer_section/login_page/login_page.dart';

import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen_hirer.dart';
import 'package:hey_work/presentation/services/authentication_services.dart';

import 'package:hey_work/presentation/worker_section/worker_login_page/worker_login_page.dart';
import 'package:hey_work/presentation/worker_section/worker_signup_page/worker_signup_page.dart';

class LoginOrSignup extends StatefulWidget {
  final String userType;
  
  const LoginOrSignup({Key? key, required this.userType}) : super(key: key);

  @override
  _LoginOrSignupState createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {
  final AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with back button
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HirerOrWorker(),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22.w,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Body content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        SizedBox(height: 30.h),
                        
                        // App logo
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.userType == 'hirer' 
                                ? Icons.person_outline 
                                : Icons.work_outline,
                            size: 60.w,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Title
                        Text(
                          widget.userType == 'hirer'
                              ? "Hirer Account"
                              : "Worker Account",
                          style: GoogleFonts.poppins(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        
                        SizedBox(height: 8.h),
                        
                        // Subtitle
                        Text(
                          widget.userType == 'hirer'
                              ? "Hire skilled workers for your needs"
                              : "Find jobs that match your skills",
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 60.h),
                        
                        // Login option
                        Container(
                          width: double.infinity,
                          height: 160.h,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Already have an account?",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              
                              SizedBox(height: 8.h),
                              
                              Text(
                                "Log in with your registered phone number",
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              
                              SizedBox(height: 20.h),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => widget.userType == 'hirer'
                                            ? HirerLoginScreen()
                                            : WorkerLoginScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Signup option
                        Container(
                          width: double.infinity,
                          height: 160.h,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "New to Hey Work?",
                                style: GoogleFonts.poppins(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              
                              SizedBox(height: 8.h),
                              
                              Text(
                                widget.userType == 'hirer'
                                    ? "Create a hirer account and start hiring"
                                    : "Create a worker account and find jobs",
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              
                              SizedBox(height: 20.h),
                              
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => widget.userType == 'hirer'
                                            ? HirerSignupPage()
                                            : WorkerSignupPage(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      side: BorderSide(
                                        color: Colors.blue.shade700,
                                        width: 1.5,
                                      ),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Create Account",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}