// lib/main.dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:heywork/firebase_options.dart';
import 'package:heywork/presentation/common_screens/splash_screen.dart';
import 'package:heywork/presentation/worker_section/worker_application_screen/jobs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Core


// Presentation



void main() async {
  try {
    // Ensure Flutter binding is initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize SharedPreferences
    await SharedPreferences.getInstance();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize App Check
    await FirebaseAppCheck.instance.activate(
      // Use provider appropriate for your platform
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.appAttest,
    );
    
    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Handle initialization error appropriately
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => JobProvider()),
          ],
          child: MaterialApp(
            title: 'Hey Work',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: SplashScreen(), // Use our splash screen that handles auth
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
  static const Color primaryBlue = Color(0xFF0011C9);
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
      displayLarge: GoogleFonts.poppins(
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
          color: primaryBlue), // App title
      bodyLarge: GoogleFonts.poppins(
          fontSize: 16.sp, color: Colors.black87), // Search text
      bodyMedium: GoogleFonts.poppins(
          fontSize: 14.sp, color: Colors.black87), // Category title
      bodySmall: GoogleFonts.poppins(
          fontSize: 12.sp, fontWeight: FontWeight.w500), // Card titles
      labelSmall: GoogleFonts.poppins(
          fontSize: 10.sp, color: Colors.grey), // Bottom nav text
    ),
  );
}
