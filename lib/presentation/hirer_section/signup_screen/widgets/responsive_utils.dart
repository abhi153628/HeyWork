// lib/utils/responsive_util.dart
import 'package:flutter/material.dart';
// lib/utils/debouncer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class ResponsiveUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  // Get responsive height
  double getHeight(double height) {
    // Based on design height of 844 (iPhone 13 mini)
    return (height / 844.0) * screenHeight;
  }

  // Get responsive width
  double getWidth(double width) {
    // Based on design width of 390 (iPhone 13 mini)
    return (width / 390.0) * screenWidth;
  }

  // Responsive SizedBox for height
  Widget verticalSpace(double height) {
    return SizedBox(height: getHeight(height));
  }

  // Responsive SizedBox for width
  Widget horizontalSpace(double width) {
    return SizedBox(width: getWidth(width));
  }

  // Get adaptive font size
  double getFontSize(double size) {
    final scaleFactor = screenWidth / 390.0;
    return size * scaleFactor;
  }
}

// Add this class if it's missing in your code


// Class to handle validation
class FormValidator {
  // Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  // Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  // Validate business name
  static String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your business name';
    }
    if (value.length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  // Validate location
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your location';
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    // Basic email validation
    bool emailValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
    if (!emailValid) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Validate OTP
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }
}

// A debouncer class to limit the frequency of actions
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Custom dialog for login type conflict
