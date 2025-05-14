// lib/presentation/hirer_section/login_screen/login_screen_hirer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hey_work/presentation/hirer_section/common/bottom_nav_bar.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen_hirer.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';
import 'package:hey_work/presentation/services/authentication_services.dart';

class HirerLoginScreen extends StatefulWidget {
  const HirerLoginScreen({Key? key}) : super(key: key);

  @override
  _HirerLoginScreenState createState() => _HirerLoginScreenState();
}

class _HirerLoginScreenState extends State<HirerLoginScreen> {
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
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Show custom snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: isError ? 4 : 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
      // Verify phone for hirer user type
      _verificationId = await _authService.verifyPhoneForUserType(
        _phoneController.text.trim(),
        'hirer'
      );
      
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
      
      _showSnackBar('OTP sent to your phone');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      _showSnackBar(e.toString(), isError: true);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter the OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Verify OTP and sign in
      final userCredential = await _authService.verifyOTPAndSignIn(
        _verificationId,
        _otpController.text.trim()
      );
      
      if (userCredential.user != null) {
        // Check if user is really a hirer
        final userType = await _authService.getUserType();
        
        if (userType == 'hirer') {
          // Store user type locally
          await _authService.storeUserType('hirer');
          
          // Navigate to hirer main screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => MainScreen())
          );
        } else {
          // Wrong user type, sign out
          await _authService.signOut();
          
          setState(() {
            _isLoading = false;
            _errorMessage = 'This number is registered as a worker, not a hirer. Please use worker login.';
          });
          
          _showSnackBar('This number is registered as a worker, not a hirer. Please use worker login.', isError: true);
        }
      } else {
        throw 'Failed to authenticate user.';
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid OTP or authentication failed: ${e.toString()}';
      });
      
      _showSnackBar('Invalid OTP or authentication failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive util
    _responsive.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hirer Login',
          style: GoogleFonts.roboto(
            color: Colors.blue.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.black87,
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3,
                ),
              )
            : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _responsive.getWidth(24),
                  vertical: _responsive.getHeight(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header image or icon
                      Center(
                        child: Container(
                          width: _responsive.getWidth(120),
                          height: _responsive.getWidth(120),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            size: _responsive.getWidth(60),
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: _responsive.getHeight(24)),

                      // Title
                      Center(
                        child: Text(
                          "Welcome Back, Hirer!",
                          style: GoogleFonts.roboto(
                            fontSize: _responsive.getFontSize(24),
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: _responsive.getHeight(8)),

                      // Subtitle
                      Center(
                        child: Text(
                          "Log in to access your hirer account",
                          style: GoogleFonts.roboto(
                            fontSize: _responsive.getFontSize(16),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      SizedBox(height: _responsive.getHeight(40)),

                      // Phone number field
                      Text(
                        "Mobile Number",
                        style: GoogleFonts.roboto(
                          fontSize: _responsive.getFontSize(16),
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: _responsive.getHeight(8)),
                      
                      // Phone input field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _otpSent ? Colors.grey.shade300 : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Country code prefix
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _responsive.getWidth(12),
                                vertical: _responsive.getHeight(14),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                              child: Text(
                                "+91",
                                style: GoogleFonts.roboto(
                                  fontSize: _responsive.getFontSize(16),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),

                            // Divider
                            Container(
                              height: _responsive.getHeight(30),
                              width: 1,
                              color: Colors.grey.shade300,
                            ),

                            // Phone input
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                style: GoogleFonts.roboto(
                                  fontSize: _responsive.getFontSize(16),
                                  color: Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter mobile number",
                                  hintStyle: GoogleFonts.roboto(
                                    fontSize: _responsive.getFontSize(16),
                                    color: Colors.grey.shade500,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone_android,
                                    color: Colors.grey.shade600,
                                    size: _responsive.getWidth(22),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: _responsive.getHeight(16),
                                    horizontal: _responsive.getWidth(12),
                                  ),
                                  errorStyle: GoogleFonts.roboto(
                                    fontSize: _responsive.getFontSize(0),
                                    height: 0,
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
                                enabled: !_otpSent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Error message
                      if (_errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(
                            top: _responsive.getHeight(8),
                            left: _responsive.getWidth(16),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.roboto(
                              fontSize: _responsive.getFontSize(12),
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),

                      // OTP field (visible only after OTP is sent)
                      if (_otpSent) ...[
                        SizedBox(height: _responsive.getHeight(20)),
                        Text(
                          "Enter OTP",
                          style: GoogleFonts.roboto(
                            fontSize: _responsive.getFontSize(16),
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: _responsive.getHeight(8)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: _otpController,
                            style: GoogleFonts.roboto(
                              fontSize: _responsive.getFontSize(16),
                              color: Colors.black87,
                              letterSpacing: 2,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter 6-digit OTP",
                              hintStyle: GoogleFonts.roboto(
                                fontSize: _responsive.getFontSize(16),
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade600,
                                size: _responsive.getWidth(22),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: _responsive.getHeight(16),
                                horizontal: _responsive.getWidth(16),
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
                            textAlign: TextAlign.left,
                            autofillHints: const [AutofillHints.oneTimeCode],
                          ),
                        ),
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
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size.zero,
                                padding: EdgeInsets.symmetric(
                                  horizontal: _responsive.getWidth(12),
                                  vertical: _responsive.getHeight(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(height: _responsive.getHeight(32)),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: _responsive.getHeight(54),
                        child: ElevatedButton(
                          onPressed: _otpSent ? _verifyOTP : _verifyPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _otpSent ? "Login" : "Send OTP",
                            style: GoogleFonts.roboto(
                              fontSize: _responsive.getFontSize(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: _responsive.getHeight(20)),

                      // Sign up link
                      Center(
                        child: Row(
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
                                    builder: (context) => HirerSignupPage(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign up",
                                style: GoogleFonts.roboto(
                                  fontSize: _responsive.getFontSize(14),
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}