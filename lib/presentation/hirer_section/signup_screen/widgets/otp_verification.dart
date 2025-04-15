// lib/screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:hey_work/data/data_sources/remote/firebase_auth_hirer.dart';
import 'package:hey_work/data/modals/hirer/hirer_modal.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String businessName;
  final String businessLocation;
  final Place? selectedPlace;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.name,
    required this.businessName,
    required this.businessLocation,
    this.selectedPlace,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final ResponsiveUtil _responsive = ResponsiveUtil();
  
  bool _isLoading = false;
  bool _otpSent = false;
  String _errorMessage = '';
  late AnimationController _animController;
  int _resendSecondsRemaining = 60;
  bool _showTimer = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    
    // Request OTP when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestOTP();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Start resend timer
  void _startResendTimer() {
    setState(() {
      _showTimer = true;
      _resendSecondsRemaining = 60;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendSecondsRemaining > 0) {
        setState(() {
          _resendSecondsRemaining--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _showTimer = false;
        });
      }
    });
  }

  // Request OTP
  Future<void> _requestOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendOTP(
        widget.phoneNumber,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          setState(() {
            _isLoading = true;
          });
          
          await _signInWithCredential(credential);
        },
        onVerificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Verification failed';
          });
        },
        onCodeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
          });
          _startResendTimer();
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Verify OTP
  Future<void> _verifyOTP(String otp) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await authService.verifyOTP(otp);
      
      await _saveUserData(userCredential.user!.uid);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    }
  }

  // Sign in with credential
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      await _saveUserData(userCredential.user!.uid);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Save user data
  Future<void> _saveUserData(String uid) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      final hirer = Hirer(
        uid: uid,
        name: widget.name,
        businessName: widget.businessName,
        businessLocation: widget.businessLocation,
        phoneNumber: widget.phoneNumber,
        businessLocationId: widget.selectedPlace?.placeId,
        locationData: widget.selectedPlace?.toMap(),
      );
      
      await firebaseService.saveHirerData(hirer);
      
      if (!mounted) return;
      
      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _responsive.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black87,
        ),
        title: Text(
          'Verify Phone Number',
          style: TextStyle(
            color: Colors.black87,
            fontSize: _responsive.getFontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            FadeTransition(
              opacity: _animController,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _responsive.getWidth(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _responsive.verticalSpace(40),
                    // Icon
                    Icon(
                      Icons.sms_outlined,
                      size: _responsive.getWidth(64),
                      color: const Color(0xFF2020F0),
                    ),
                    _responsive.verticalSpace(24),
                    
                    // Title & Description
                    Text(
                      'OTP Verification',
                      style: TextStyle(
                        fontSize: _responsive.getFontSize(24),
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    _responsive.verticalSpace(16),
                    Text(
                      'Enter the verification code sent to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _responsive.getFontSize(14),
                        color: Colors.grey[600],
                      ),
                    ),
                    _responsive.verticalSpace(4),
                    Text(
                      '+91 ${widget.phoneNumber}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _responsive.getFontSize(16),
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    _responsive.verticalSpace(40),
                    
                    // OTP Input
                    OTPInputField(
                      controller: _otpController,
                      onCompleted: _verifyOTP,
                      responsiveUtil: _responsive,
                    ),
                    _responsive.verticalSpace(16),
                    
                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: _responsive.getHeight(16)),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _responsive.getFontSize(14),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    
                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive code? ',
                          style: TextStyle(
                            fontSize: _responsive.getFontSize(14),
                            color: Colors.grey[600],
                          ),
                        ),
                        _showTimer
                            ? Text(
                                '${_resendSecondsRemaining}s',
                                style: TextStyle(
                                  fontSize: _responsive.getFontSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF2020F0),
                                ),
                              )
                            : GestureDetector(
                                onTap: _requestOTP,
                                child: Text(
                                  'Resend',
                                  style: TextStyle(
                                    fontSize: _responsive.getFontSize(14),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF2020F0),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    _responsive.verticalSpace(40),
                    
                    // Verify Button
                    CustomButton(
                      text: 'Verify',
                      onPressed: () => _verifyOTP(_otpController.text),
                      responsiveUtil: _responsive,
                      isLoading: _isLoading,
                      isEnabled: _otpController.text.length == 6,
                    ),
                  ],
                ),
              ),
            ),
            
            // Loading overlay
            if (_isLoading && !_otpSent)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2020F0)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/home_screen.dart


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ResponsiveUtil _responsive = ResponsiveUtil();
  bool _isLoading = true;
  Hirer? _hirer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      final user = authService.currentUser;
      if (user != null) {
        final hirerData = await firebaseService.getHirerData(user.uid);
        
        setState(() {
          _hirer = hirerData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
      
      if (!mounted) return;
      
      // Navigate back to sign up screen
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _responsive.init(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.black87,
            fontSize: _responsive.getFontSize(18),
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hirer == null
              ? Center(
                  child: Text(
                    'No user data found',
                    style: TextStyle(
                      fontSize: _responsive.getFontSize(16),
                    ),
                  ),
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: _responsive.getWidth(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _responsive.verticalSpace(40),
                        
                        Center(
                          child: CircleAvatar(
                            radius: _responsive.getWidth(50),
                            backgroundColor: const Color(0xFF2020F0).withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: _responsive.getWidth(50),
                              color: const Color(0xFF2020F0),
                            ),
                          ),
                        ),
                        _responsive.verticalSpace(24),
                        
                        Center(
                          child: Text(
                            'Welcome, ${_hirer!.name}!',
                            style: TextStyle(
                              fontSize: _responsive.getFontSize(24),
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        _responsive.verticalSpace(40),
                        
                        // User details
                        _buildInfoTile('Business Name', _hirer!.businessName),
                        _buildInfoTile('Business Location', _hirer!.businessLocation),
                        _buildInfoTile('Phone Number', '+91 ${_hirer!.phoneNumber}'),
                        _buildInfoTile('Account Created', _formatDate(_hirer!.createdAt)),
                        
                        const Spacer(),
                        
                        CustomButton(
                          text: 'Continue to Dashboard',
                          onPressed: () {
                            // Navigate to dashboard
                          },
                          responsiveUtil: _responsive,
                        ),
                        _responsive.verticalSpace(24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: _responsive.getHeight(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _responsive.getFontSize(14),
              color: Colors.grey[600],
            ),
          ),
          _responsive.verticalSpace(4),
          Text(
            value,
            style: TextStyle(
              fontSize: _responsive.getFontSize(16),
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}