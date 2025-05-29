// // lib/presentation/common_screens/login_or_signup.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hey_work/presentation/hirer_section/login_page/hirer_login_page.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen_hirer.dart';
// import 'package:hey_work/presentation/worker_section/worker_login_page/worker_login_page.dart';
// import 'package:hey_work/presentation/worker_section/worker_signup_page/worker_signup_page.dart';

// class LoginOrSignup extends StatefulWidget {
//   final String userType;

//   const LoginOrSignup({Key? key, required this.userType}) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _LoginOrSignupState createState() => _LoginOrSignupState();
// }

// class _LoginOrSignupState extends State<LoginOrSignup> {
  
//   @override
//   void initState() {
//     super.initState();
//     // Set status bar to transparent with white icons
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.dark,
//     ));
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     // Define the primary blue color from the image
//     const Color primaryBlue = Color(0xFF0037FF);
    
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: primaryBlue,
//             child: Column(
//               children: [
             
//                 Expanded(
//                   flex: 7,
//                   child: Image.asset(
//                     widget.userType == 'worker' 
//                         ? 'asset/8.png' 
//                         : 'asset/8.png',
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                   ),
//                 ),
                
//                 Expanded(
//                   flex: 3,
//                   child: Container(),
//                 ),
//               ],
//             ),
//           ),
          
//           // White Card Container (stacked above the image)
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30.r),
//                   topRight: Radius.circular(30.r),
//                 ),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   // Title Text
//                   Text(
//                     "Get Started dddToday",
//                     style: GoogleFonts.poppins(
//                       fontSize: 28.sp,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.black87,
//                     ),
//                   ),
                  
//                   SizedBox(height: 24.h),
                  
//                   // Create Account Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 56.h,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => widget.userType == 'hirer'
//                                 ? const HirerSignupPage()
//                                 : const WorkerSignupPage(),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: primaryBlue,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: Text(
//                         "Create an account",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   SizedBox(height: 20.h),
                  
//                   // Already have an account text
//                   Text(
//                     "Already have an account?",
//                     style: GoogleFonts.poppins(
//                       fontSize: 16.sp,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
                  
//                   SizedBox(height: 16.h),
                  
//                   // Sign in with Phone Number Button
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => widget.userType == 'hirer'
//                               ? const HirerLoginScreen()
//                               : const WorkerLoginScreen(),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       height: 56.h,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300, width: 1),
//                         borderRadius: BorderRadius.circular(12.r),
//                       ),
//                       child: Center(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.phone,
//                               color: primaryBlue,
//                               size: 20.w,
//                             ),
//                             SizedBox(width: 8.w),
//                             Text(
//                               "Sign in with Phone number",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w500,
//                                 color: primaryBlue,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
                  
               
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }