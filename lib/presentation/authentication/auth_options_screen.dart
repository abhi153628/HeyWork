// lib/presentation/common_screens/auth_options_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Auth Options Screen with support for different images
/// 
/// Usage Example:
/// ```dart
/// AuthOptionsScreen(
///   userType: 'worker',
///   loginScreen: WorkerLoginScreen(),
///   signupScreen: WorkerSignupScreen(),
///   workerImage: 'asset/worker_background.png',
///   hirerImage: 'asset/hirer_background.png',
/// )
/// ```

class AuthOptionsScreen extends StatefulWidget {
  final String userType; // 'worker' or 'hirer'
  final Widget loginScreen;
  final Widget signupScreen;
  final String? hirerImage; // Custom image for hirer
  final String? workerImage; // Custom image for worker

  const AuthOptionsScreen({
    Key? key,
    required this.userType,
    required this.loginScreen,
    required this.signupScreen,
    this.hirerImage,
    this.workerImage,
  }) : super(key: key);

  @override
  State<AuthOptionsScreen> createState() => _AuthOptionsScreenState();
}

class _AuthOptionsScreenState extends State<AuthOptionsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Set status bar to transparent with white icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  /// Get the appropriate image based on user type and provided parameters
  String _getImageForUserType() {
    if (widget.userType == 'worker') {
      return widget.workerImage ?? 'asset/8.png'; // Default worker image
    } else {
      return widget.hirerImage ?? 'asset/hirer  1st page.png'; // Default hirer image
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary blue color
    const Color primaryBlue = Color(0xFF0033FF);
    
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: primaryBlue,
            child: Column(
              children: [
                Expanded(
                  flex: 7,
                  child: Image.asset(
                    _getImageForUserType(),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
                
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
              ],
            ),
          ),
          
          // White Card Container (stacked above the image)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title Text
                  Text(
                    "Get Started Today",
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => widget.signupScreen,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Create an account",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Already have an account text
                  Text(
                    "Already have an account?",
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Sign in with Phone Number Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => widget.loginScreen,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              color: primaryBlue,
                              size: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              "Sign in with Phone number",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}