// lib/utils/snackbar_util.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackBarUtil {
  // Show a snackbar with consistent styling across the app
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration? duration,
    SnackBarAction? action,
  }) {
    // Hide any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Show the new snackbar with proper positioning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF0033FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        // Use fixed margins instead of dynamic calculation that causes errors
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        duration: duration ?? Duration(seconds: isError ? 4 : 3),
        action: action ?? SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}