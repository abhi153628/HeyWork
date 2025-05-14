// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Hiring App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const HiringScreen(),
//     );
//   }
// }

// class HiringScreen extends StatelessWidget {
//   const HiringScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
    
//     return Scaffold(
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         color: const Color.fromARGB(255, 0, 0, 0),
//         child: Stack(
//           children: [
//             // Adding a visible placeholder to see if positioning is correct
//             Positioned(
//               top: screenHeight * 0.15,
//               left: 0,
//               right: 0,
//               height: screenHeight * 0.45,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color.fromARGB(255, 4, 4, 4), width: 3),
//                   color: Colors.black.withOpacity(0.1),
//                 ),
//                 child: Center(
//                   // Wrapping SVG in a Container with a fixed size for testing
//                   child: Container(
//                     height: 300,
//                     width: 300,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.red, width: 2),
//                     ),
//                     child: SvgPicture.asset(
//                       'asset/icons.svg',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
            
//             // Bottom white container with buttons
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               height: screenHeight * 0.37,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     const Text(
//                       'What are you looking for?',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF222222),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 24),
                    
//                     // "I want to work" button
//                     OutlinedButton(
//                       onPressed: () {
//                         // Add your action here
//                       },
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Color(0xFF0039FF), width: 2),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'I want to work',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF0039FF),
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // "I want to Hire" button
//                     ElevatedButton(
//                       onPressed: () {
//                         // Add your action here
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF0039FF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       child: const Text(
//                         'I want to Hire',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }