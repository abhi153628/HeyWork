    
//     import 'package:flutter/material.dart';

// class name extends StatelessWidget {
//       const name({super.key});
    
//       @override
//       Widget build(BuildContext context) {
//         return         Container(
//               height: 180,
//               margin: EdgeInsets.symmetric(horizontal: 16),
//               decoration: BoxDecoration(
//                 color: Color(0xFF0000CC),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Stack(
//                 children: [
//                   Positioned(
//                     left: 20,
//                     top: 30,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Find Part-Time',
//                           style: GoogleFonts.roboto(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           'Jobs Near Me',
//                           style: GoogleFonts.roboto(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     bottom: 0,
//                     child: Image.asset(
//                       'assets/images/worker.png', // Make sure this image exists
//                       height: 150,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: 16),

//             // Search bar - updated to match image
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: GestureDetector(
//                 onTap: _navigateToSearchPage,
//                 child: Container(
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(50),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 10,
//                         spreadRadius: 0,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(width: 16),
//                       Icon(Icons.search, color: Colors.grey),
//                       SizedBox(width: 8),
//                       Text(
//                         'Search here...',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Spacer(),
//                       Container(
//                         margin: EdgeInsets.all(5),
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(40),
//                         ),
//                         child: Icon(
//                           Icons.tune,
//                           color: Colors.grey,
//                           size: 20,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),;
//       }
//     }
    
       