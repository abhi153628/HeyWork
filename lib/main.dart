import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/common/bottom_nav_bar.dart';


// ==============================
//! MAIN APP ENTRY POINT
// ==============================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

// ==============================
//! APP CONFIGURATION
// ==============================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
    
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HeyWork App',
          theme: AppTheme.lightTheme,
          initialRoute: '/',
          routes: AppRoutes.routes,
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


