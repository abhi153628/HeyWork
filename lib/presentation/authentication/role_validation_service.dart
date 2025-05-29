// lib/presentation/services/role_validation_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class RoleValidationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Ultra-Professional Design System
  static const Color primaryBlue = Color(0xFF0033FF);
  static const Color lightBlue = Color(0xFFE8EFFF);
  static const Color ultraLightBlue = Color(0xFFF0F4FF);
  static const Color darkBlue = Color(0xFF002399);
  static const Color successGreen = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color backgroundGray = Color(0xFFF9FAFB);
  static const Color borderGray = Color(0xFFE5E7EB);

  /// Check if phone number exists in either workers or hirers collection
  static Future<Map<String, dynamic>> checkPhoneNumberExists(String phoneNumber) async {
    try {
      // Format phone number
      String formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+91$phoneNumber';

      // Check in workers collection
      QuerySnapshot workerQuery = await _firestore
          .collection('workers')
          .where('loginPhoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (workerQuery.docs.isNotEmpty) {
        return {
          'exists': true,
          'userType': 'worker',
          'userId': workerQuery.docs.first.id,
        };
      }

      // Check in hirers collection
      QuerySnapshot hirerQuery = await _firestore
          .collection('hirers')
          .where('loggedPhoneNumber', isEqualTo: formattedPhone)
          .limit(1)
          .get();

      if (hirerQuery.docs.isNotEmpty) {
        return {
          'exists': true,
          'userType': 'hirer',
          'userId': hirerQuery.docs.first.id,
        };
      }

      return {
        'exists': false,
        'userType': null,
        'userId': null,
      };
    } catch (e) {
      print('Error checking phone number: $e');
      throw Exception('Failed to check phone number availability');
    }
  }

  /// Ultra-Professional Dialog with Enhanced Animations
  static Widget _buildPremiumDialog({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String content,
    required List<Widget> actions,
    Color? backgroundColor,
    Color? iconBackgroundColor,
  }) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? surfaceWhite,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withOpacity(0.08),
              offset: const Offset(0, 20),
              blurRadius: 40,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ultraLightBlue,
                      lightBlue.withOpacity(0.5),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Premium Icon Container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor ?? surfaceWhite,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBlue.withOpacity(0.1),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(child: icon),
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        content,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: textSecondary,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Actions
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: actions,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Premium Primary Button
  static Widget _buildPremiumButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    bool isLoading = false,
    bool isPrimary = true,
    IconData? icon,
  }) {
    return Container(
      height: 52,
      constraints: const BoxConstraints(minWidth: 120),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: isPrimary ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor ?? primaryBlue,
                (backgroundColor ?? primaryBlue).withOpacity(0.8),
              ],
            ) : null,
            color: isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary ? null : Border.all(
              color: borderGray,
              width: 1.5,
            ),
         
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: Lottie.asset('asset/Animation - 1748495844642.json')
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: 18,
                                color: textColor ?? (isPrimary ? Colors.white : primaryBlue),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              text,
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: textColor ?? (isPrimary ? Colors.white : primaryBlue),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Professional Role Conflict Dialog
  static void showRoleConflictDialog(
    BuildContext context, 
    String existingRole, 
    String attemptedRole,
  ) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return _buildPremiumDialog(
          context: context,
          icon: Icon(
            Icons.warning_rounded,
            color: warningOrange,
            size: 32,
          ),
          iconBackgroundColor: warningLight,
          title: "Account Conflict",
          content: "                                                                                                        This phone number is already registered as a $existingRole. You cannot ${attemptedRole == 'login' ? 'sign in' : 'create an account'} as a ${attemptedRole == 'login' ? 'different user type' : attemptedRole} using this number.\n\nPlease use a different phone number or sign in with your existing $existingRole account.",
          actions: [
            _buildPremiumButton(
              text: "Got it",
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.check_rounded,
            ),
          ],
        );
      },
    );
  }

  /// Professional Account Exists Dialog
  static void showAccountExistsDialog(BuildContext context, String userType) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return _buildPremiumDialog(
          context: context,
          icon: Icon(
            Icons.person_rounded,
            color: primaryBlue,
            size: 32,
          ),
          
          iconBackgroundColor: lightBlue,
          title: "Account Found",
          content: "                                                                                                          Great news! An account with this phone number already exists. Please sign in to continue accessing your ${userType == 'worker' ? 'worker' : 'hirer'} account.",
          
          actions: [
            _buildPremiumButton(
              text: "Sign In",
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.login_rounded,
            ),
          ],
        );
      },
    );
  }

  /// Professional Role Restriction Bottom Sheet
  static Future<bool> showRoleRestrictionDialog(
    BuildContext context, 
    String selectedRole,
  ) async {
    HapticFeedback.mediumImpact();
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: surfaceWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: warningLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: warningOrange.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.security_rounded,
                          color: warningOrange,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      "Account Security",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: ultraLightBlue,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: lightBlue,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_rounded,
                                  color: primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Important Information",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Once you create a ${selectedRole == 'worker' ? 'worker' : 'hirer'} account with this phone number, you won't be able to register as a ${selectedRole == 'worker' ? 'hirer' : 'worker'} using the same number.",
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Text(
                        "This ensures account security and prevents role conflicts. Are you sure you want to continue?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    _buildPremiumButton(
                      text: "Yes, Continue",
                      onPressed: () => Navigator.of(context).pop(true),
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPremiumButton(
                      text: "Cancel",
                      onPressed: () => Navigator.of(context).pop(false),
                      isPrimary: false,
                      icon: Icons.close_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ) ?? false;
  }

  /// Check if user data exists in Firestore after successful authentication
  static Future<bool> checkUserDataExists(String uid, String userType) async {
    try {
      String collection = userType == 'worker' ? 'workers' : 'hirers';
      
      DocumentSnapshot userDoc = await _firestore
          .collection(collection)
          .doc(uid)
          .get();
      
      return userDoc.exists;
    } catch (e) {
      print('Error checking user data: $e');
      return false;
    }
  }

  /// Professional Account Deleted Dialog
  static void showAccountDeletedDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return _buildPremiumDialog(
          context: context,
          icon: Icon(
            Icons.error_outline_rounded,
            color: errorRed,
            size: 32,
          ),
          iconBackgroundColor: errorLight,
          title: "Account Unavailable",
          content: "We couldn't find your account data in our system. This might happen if:\n\n• Your account was recently deleted\n• There was a data synchronization issue\n• Your account is temporarily suspended\n\nPlease contact our support team for assistance, or try creating a new account.",
          actions: [
            _buildPremiumButton(
              text: "Contact Support",
              onPressed: () {
                Navigator.of(context).pop();
                // Add your support contact logic here
              },
              isPrimary: false,
              icon: Icons.support_agent_rounded,
            ),
            const SizedBox(width: 12),
            _buildPremiumButton(
              text: "Start Over",
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (route) => false,
                );
              },
              icon: Icons.refresh_rounded,
            ),
          ],
        );
      },
    );
  }

  /// Professional Incorrect OTP Dialog
  static void showIncorrectOtpDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return _buildPremiumDialog(
          context: context,
          icon: Icon(
            Icons.lock_outline_rounded,
            color: errorRed,
            size: 32,
          ),
          iconBackgroundColor: errorLight,
          title: "Verification Failed",
          content: "The OTP you entered doesn't match our records. Please double-check the code sent to your phone and try again.\n\nIf you haven't received the code, you can request a new one.",
          actions: [
    
            _buildPremiumButton(
              text: "Try Again",
              onPressed: () => Navigator.of(context).pop(),
              icon: Icons.keyboard_rounded,
            ),
          ],
        );
      },
    );
  }

  /// Ultra-Premium Loading Dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.1),
                  offset: const Offset(0, 20),
                  blurRadius: 40,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        lightBlue,
                        ultraLightBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child:  Center(
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Premium Success Dialog
  static void showSuccessDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onContinue,
  }) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return _buildPremiumDialog(
          context: context,
          icon: Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFFF0033FF),
            size: 32,
          ),
          iconBackgroundColor: successLight,
          title: title,
          content: message,
          actions: [
            _buildPremiumButton(
              text: "Continue",
              backgroundColor: successGreen,
              onPressed: () {
                Navigator.of(context).pop();
                onContinue?.call();
              },
              icon: Icons.arrow_forward_rounded,
            ),
          ],
        );
      },
    );
  }

  /// Ultra-Professional Snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    bool isError = false,
  }) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    icon ?? (isError ? Icons.error_rounded : Icons.check_circle_rounded),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.roboto(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor ?? (isError ? errorRed : primaryBlue),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 8,
      ),
    );
  }

  /// Premium Toast Notification
  static void showToast(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? backgroundColor,
    bool isSuccess = false,
    bool isError = false,
  }) {
    Color bgColor = backgroundColor ?? primaryBlue;
    if (isSuccess) bgColor = successGreen;
    if (isError) bgColor = errorRed;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  offset: const Offset(0, 8),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}