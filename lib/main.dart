// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hey_work/core/services/database/jobs_service.dart';

import 'package:hey_work/firebase_options.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen_hirer.dart';

import 'package:hey_work/presentation/worker_section/home_page/home_page.dart';
import 'package:hey_work/presentation/worker_section/worker_signup_page/worker_signup_page.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter binding is initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

 @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil with default design size
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(   providers: [
        ChangeNotifierProvider(create: (_) => JobProvider()),
        ],
          child: MaterialApp(
            title: 'Hey Work',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: const Color(0xFF0011C9),
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white,
              fontFamily: 'Poppins',
              useMaterial3: false,
            ),
            home: WorkerSignupPage(),
          ),
        );
      },
    );
  }
}

// ==============================
//! APP THEME
// ==============================
class AppTheme {
  // Main colors
  static const Color primaryBlue = Color(0xFF0000CC);
  static const Color secondaryBlue = Color(0xFF0033FF);
  static const Color backgroundGrey = Color(0xFFF0F2F7);
  

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryBlue,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      // Defined text styles for consistency
      displayLarge: GoogleFonts.poppins(fontSize: 22.sp, fontWeight: FontWeight.bold, color: primaryBlue), // App title
      bodyLarge: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.black87), // Search text
      bodyMedium: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87), // Category title
      bodySmall: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500), // Card titles
      labelSmall: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey), // Bottom nav text
    ),
  );
}