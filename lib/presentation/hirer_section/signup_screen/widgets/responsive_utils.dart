// lib/utils/responsive_util.dart
import 'package:flutter/material.dart';
// lib/utils/debouncer.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

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
    return (height / 844.0) * screenHeight;
  }

  // Get responsive width
  double getWidth(double width) {
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



class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// lib/utils/validator.dart
class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business name is required';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Business location is required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    
    final cleanPhone = value.trim().replaceAll(RegExp(r'\D'), '');
    
    if (cleanPhone.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    
    return null;
  }
}