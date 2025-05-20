import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/snack_bar_utils.dart';

import 'package:hey_work/presentation/services/authentication_services.dart';
import 'package:hey_work/presentation/worker_section/bottom_navigation/bottom_nav_bar.dart';
import 'package:hey_work/presentation/worker_section/worker_signup_page/worker_signup_page.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';
// Import the SnackBar utility

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({Key? key}) : super(key: key);

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  String _verificationId = '';
  String? _errorMessage;

  // Responsive util instance
  final ResponsiveUtil _responsive = ResponsiveUtil();

  @override
  void initState() {
    super.initState();
    // Set status bar to transparent with white icons
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Show custom snackbar - updated to use SnackBarUtil
  void _showSnackBar(String message, {bool isError = false}) {
    SnackBarUtil.showSnackBar(context, message, isError: isError);
  }

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format phone number to ensure it starts with +91
      String phoneNumber = _phoneController.text.trim();
      if (!phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }

      // Verify phone for worker user type using Firebase directly
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (mainly on Android)
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              setState(() {
                _isLoading = false;
              });
              
              // Navigate to main worker screen on success
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerMainScreen(),
                ),
              );
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
              _errorMessage = e.toString();
            });
            _showSnackBar('Auto-verification failed: $e', isError: true);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });

          // Handle specific error types
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.message != null && e.message!.contains('BILLING_NOT_ENABLED')) {
            errorMessage = 'Authentication service is temporarily unavailable. Please try again later.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many attempts from this device. Please try again later.';
          } else {
            errorMessage = e.message ?? 'Verification failed';
          }

          _showSnackBar(errorMessage, isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _verificationId = verificationId;
          });
          _showSnackBar('OTP sent to your phone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter the OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create credential with the verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Sign in with the credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        setState(() {
          _isLoading = false;
        });
        
        // Navigate to main worker screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkerMainScreen(),
          ),
        );
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      _showSnackBar('Invalid OTP or verification failed. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive util
    _responsive.init(context);
    
    // Get screen dimensions
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
                strokeWidth: 3,
              ),
            )
          : Stack(
              children: [
                // Blue background
                Container(
                  height: screenHeight,
                  width: screenWidth,
                  color: const Color(0xFF0033FF), // Bright blue color from image
                ),
                
                // Worker image (top 65% of screen)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: screenHeight * 0.65,
                  child: Image.asset(
                    'asset/6.png', // Replace with your actual asset path
                    fit: BoxFit.cover,
                  ),
                ),
                
                // White bottom container (overlaps the image)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: _otpSent ? screenHeight * 0.5 : screenHeight * 0.4, // Adjust height based on OTP state
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.04,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            _otpSent 
                              ? "Enter OTP to verify" 
                              : "Enter your mobile number to sign in",
                            style: GoogleFonts.roboto(
                              fontSize: _responsive.getFontSize(24),
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: _responsive.getHeight(24)),
                          
                          // Phone input field with country code
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                // Country flag and code
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _responsive.getWidth(12),
                                    vertical: _responsive.getHeight(14),
                                  ),
                                  child: Row(
                                    children: [
                                      // Indian flag image
                                      ClipRRect(borderRadius: BorderRadius.circular(3),
                                        child: Image.asset(
                                          'asset/Flag_of_India.png', // Replace with your actual asset path
                                          width: _responsive.getWidth(24),
                                          height: _responsive.getHeight(18),
                                        ),
                                      ),
                                      SizedBox(width: _responsive.getWidth(8)),
                                      Text(
                                        "+91 |",
                                        style: GoogleFonts.roboto(
                                          fontSize: _responsive.getFontSize(16),
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF0033FF)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Phone input
                                Expanded(
                                  child: TextFormField(
                                    controller: _phoneController,
                                    style: GoogleFonts.roboto(
                                      fontSize: _responsive.getFontSize(16),
                                      color: const Color(0xFF0033FF)
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "Enter mobile number",
                                      hintStyle: GoogleFonts.roboto(
                                        fontSize: _responsive.getFontSize(16),
                                        color: const Color(0xFF0033FF),
                                        fontWeight: FontWeight.w600
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: _responsive.getHeight(16),
                                        horizontal: _responsive.getWidth(12),
                                      ),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      if (value.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      }
                                      return null;
                                    },
                                    enabled: !_otpSent, // Disable when OTP is sent
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // OTP Input field - Show only when OTP is sent (updated to match phone input style)
                          if (_otpSent) ...[
                            SizedBox(height: _responsive.getHeight(20)),
                            
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  // Lock icon container (matching the flag container's style)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: _responsive.getWidth(12),
                                      vertical: _responsive.getHeight(14),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.lock_outline,
                                          color: const Color(0xFF0033FF),
                                          size: _responsive.getWidth(24),
                                        ),
                                        SizedBox(width: _responsive.getWidth(8)),
                                        Text(
                                          "OTP |",
                                          style: GoogleFonts.roboto(
                                            fontSize: _responsive.getFontSize(16),
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0033FF)
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // OTP input (matching the phone input's style)
                                  Expanded(
                                    child: TextFormField(
                                      controller: _otpController,
                                      style: GoogleFonts.roboto(
                                        fontSize: _responsive.getFontSize(16),
                                        color: const Color(0xFF0033FF),
                                        letterSpacing: 2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter 6-digit OTP",
                                        hintStyle: GoogleFonts.roboto(
                                          fontSize: _responsive.getFontSize(16),
                                          color: const Color(0xFF0033FF),
                                          fontWeight: FontWeight.w600
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: _responsive.getHeight(16),
                                          horizontal: _responsive.getWidth(12),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter the OTP';
                                        }
                                        if (value.length != 6) {
                                          return 'OTP must be 6 digits';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Add resend OTP option
                            SizedBox(height: _responsive.getHeight(12)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: _verifyPhoneNumber,
                                  child: Text(
                                    "Resend OTP",
                                    style: GoogleFonts.roboto(
                                      fontSize: _responsive.getFontSize(14),
                                      color: const Color(0xFF0033FF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          SizedBox(height: _responsive.getHeight(20)),
                          
                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            height: _responsive.getHeight(56),
                            child: ElevatedButton(
                              onPressed: _otpSent ? _verifyOtp : _verifyPhoneNumber,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0033FF), // Same blue as background
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _otpSent ? "Verify" : "Continue",
                                style: GoogleFonts.roboto(
                                  fontSize: _responsive.getFontSize(16),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          
                          // Sign up link (if needed)
                          if (!_otpSent) ...[
                            SizedBox(height: _responsive.getHeight(20)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.roboto(
                                    fontSize: _responsive.getFontSize(14),
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WorkerSignupPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Sign up",
                                    style: GoogleFonts.roboto(
                                      fontSize: _responsive.getFontSize(14),
                                      color: const Color(0xFF0033FF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}