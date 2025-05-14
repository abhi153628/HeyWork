// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // Needed for SystemUiOverlayStyle

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // Remove debug banner
//       title: 'Fast Food Login',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         fontFamily: 'SF Pro Display',
//       ),
//       home: const LoginOrSignup(),
//     );
//   }
// }

// class LoginOrSignup extends StatelessWidget {
//   const LoginOrSignup({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     //! SETUP - Getting device size and orientation for responsive design
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 360;
    
//     //! SETUP - Setting status bar to white color
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light, // White status bar icons
//     ));
    
//     return Scaffold(
//       //! APP BACKGROUND - Blue background color
//       backgroundColor: const Color(0xFF0047FF),
//       // Remove any default safe area to have full control
//       body: Stack(
//         fit: StackFit.expand, // Make sure stack fills entire screen
//         children: [
//           //! BACKGROUND - Full screen worker image
//           SizedBox.expand(
//             child: Image.asset(
//               'asset/8.png',
//               fit: BoxFit.cover,
//               // Fallback if image fails to load
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: const Color(0xFF0047FF),
//                   child: const Center(
//                     child: Text(
//                       "Worker Image\n(Replace with your asset)",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
          
//           //! CONTENT - Bottom white container that stacks above the image
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenSize.width * 0.05,
//                 vertical: screenSize.height * 0.025,
//               ),
//               // Using FractionallySizedBox to ensure container is proportionally 
//               // sized across all devices
//               height: screenSize.height * 0.33,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//                 // Add subtle shadow for depth
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               //! FORM ELEMENTS - Login/signup options
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   // Calculate appropriate spacing based on available height
//                   return Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       //! TITLE - Get Started Today heading
//                       Text(
//                         "Get Started Today",
//                         style: TextStyle(
//                           fontSize: isSmallScreen ? 24 : 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
                      
//                       //! PRIMARY BUTTON - Create account
//                       SizedBox(
//                         width: double.infinity,
//                         height: constraints.maxHeight * 0.18, // Responsive height
//                         child: ElevatedButton(
//                           onPressed: () {},
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF0047FF),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             "Create an account",
//                             style: TextStyle(
//                               fontSize: isSmallScreen ? 16 : 18,
//                             ),
//                           ),
//                         ),
//                       ),
                      
//                       //! TEXT - Already have account
//                       Text(
//                         "Already have an account?",
//                         style: TextStyle(
//                           fontSize: isSmallScreen ? 14 : 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
                      
//                       //! SECONDARY BUTTON - Sign in with phone
//                       SizedBox(
//                         width: double.infinity,
//                         height: constraints.maxHeight * 0.18, // Responsive height
//                         child: OutlinedButton.icon(
//                           onPressed: () {},
//                           icon: const Icon(
//                             Icons.email,
//                             color: Color(0xFF0047FF),
//                           ),
//                           label: Text(
//                             "Sign in with Phone number",
//                             style: TextStyle(
//                               fontSize: isSmallScreen ? 15 : 16,
//                               color: const Color(0xFF0047FF),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(
//                               color: Color(0xFF0047FF),
//                               width: 1.5,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }