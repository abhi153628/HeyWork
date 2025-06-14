// lib/presentation/common_screens/hirer_or_worker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:heywork/presentation/authentication/auth_options_screen.dart';
import 'package:heywork/presentation/hirer_section/login_page/hirer_login_page.dart';
import 'package:heywork/presentation/hirer_section/signup_screen/signup_screen_hirer.dart';
import 'package:heywork/presentation/worker_section/worker_login_page/worker_login_page.dart';
import 'package:heywork/presentation/worker_section/worker_signup_page/worker_signup_page.dart';


class HirerOrWorker extends StatelessWidget {
  const HirerOrWorker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set status bar to transparent with white icons
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      body: Stack(
        children: [
          // Blue background that covers the entire screen
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Color(0xFF0e18ff),
          ),
          
          // This will be the image of 3 people (to be added by user)
          // It takes up the entire screen height
          Positioned.fill(
            child: Image.asset(
              'asset/Rectangle 24928.png', // Replace with your actual image path
              fit: BoxFit.cover,
            ),
          ),
          
          // Bottom container that overlaps with the image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "What are you looking for?" text
                  Text(
                    "What are you looking for?",
                    style: GoogleFonts.poppins(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // "I want to work" button
                  GestureDetector(
              onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AuthOptionsScreen(
        userType: 'worker',
        loginScreen: WorkerLoginScreen(),
        signupScreen: WorkerSignupPage(),
      ),
    ),
  );
},
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color(0xFF0e18ff), width: 2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "I want to work",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0e18ff),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // "I want to Hire" button
                  GestureDetector(
                  onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AuthOptionsScreen(
        userType: 'hirer',
        loginScreen: HirerLoginScreen(),
        signupScreen: HirerSignupPage(),
      ),
    ),
  );
},
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF0e18ff),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Text(
                          "I want to Hire",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}