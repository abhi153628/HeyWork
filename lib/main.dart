// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hey_work/data/data_sources/remote/firebase_auth_hirer.dart';
import 'package:hey_work/firebase_options.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen.dart';
import 'package:hey_work/presentation/hirer_section/industry_selecction.dart';
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
    // Create instances of services first
 
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hirer Sign Up',
      theme: ThemeData(
        primaryColor: const Color(0xFF2020F0),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2020F0),
          primary: const Color(0xFF2020F0),
        ),
      ),
      
      home: const IndustrySelectionScreen(),
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