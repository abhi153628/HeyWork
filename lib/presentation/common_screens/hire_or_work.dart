// lib/presentation/common_screens/hirer_or_worker.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/common_screens/log_sign.dart';
import 'package:hey_work/presentation/common_screens/login_or_signup.dart';

class HirerOrWorker extends StatelessWidget {
  const HirerOrWorker({Key? key}) : super(key: key);

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
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  
                  // App logo
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 60.w,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // App name
                  Text(
                    "Hey Work",
                    style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 8.h),
                  
                  // Tagline
                  Text(
                    "Connect workers with opportunities",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // Choose account type text
                  Text(
                    "Choose account type",
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Hirer option
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => LoginOrSignup(userType: 'hirer'),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
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
                      child: Row(
                        children: [
                          // Hirer icon
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_outline,
                              size: 30.w,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          
                          SizedBox(width: 16.w),
                          
                          // Hirer text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "I want to hire",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                
                                SizedBox(height: 4.h),
                                
                                Text(
                                  "Post jobs and hire workers for your needs",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18.w,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Worker option
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => LoginOrSignup(userType: 'worker'),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
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
                      child: Row(
                        children: [
                          // Worker icon
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.work_outline,
                              size: 30.w,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          
                          SizedBox(width: 16.w),
                          
                          // Worker text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "I want to work",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                                
                                SizedBox(height: 4.h),
                                
                                Text(
                                  "Find jobs that match your skills",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 18.w,
                            color: Colors.grey.shade500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}