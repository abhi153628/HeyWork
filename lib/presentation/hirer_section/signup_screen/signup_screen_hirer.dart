import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heywork/presentation/authentication/role_validation_service.dart';
import 'package:heywork/presentation/hirer_section/industry_selecction.dart';
import 'package:heywork/presentation/hirer_section/login_page/hirer_login_page.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:lottie/lottie.dart';
import '../common/bottom_nav_bar.dart';
import '../home_page/hirer_home_page.dart';
import 'widgets/responsive_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

// Google Places API Service
class GooglePlacesService {
  static const String GOOGLE_PLACES_API_KEY = 'AIzaSyDesC50s7p1LcBNRBhT1DzkmwlO1C4M6p8'; // Replace with your actual API key
  
  // Cache for storing recent searches
  static final Map<String, List<PlaceInfo>> _cache = {};
  static const int CACHE_DURATION_MINUTES = 30;
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Session token for billing optimization
  static String? _sessionToken;
  
  static String get sessionToken {
    _sessionToken ??= const Uuid().v4();
    return _sessionToken!;
  }

  static void resetSession() {
    _sessionToken = null;
  }

  static Future<List<PlaceInfo>> getAutocompleteSuggestions(String input) async {
    if (input.length < 2) return [];

    // Check cache first
    final cacheKey = input.toLowerCase().trim();
    if (_cache.containsKey(cacheKey) && _cacheTimestamps.containsKey(cacheKey)) {
      final cacheTime = _cacheTimestamps[cacheKey]!;
      if (DateTime.now().difference(cacheTime).inMinutes < CACHE_DURATION_MINUTES) {
        return _cache[cacheKey]!;
      }
    }

    try {
      final results = await _fetchFromGooglePlaces(input);
      
      // Cache the results
      _cache[cacheKey] = results;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return results;
    } catch (e) {
      print('Google Places API Error: $e');
      // Return fallback data for common Indian cities
      return _getFallbackSuggestions(input);
    }
  }

static Future<List<PlaceInfo>> _fetchFromGooglePlaces(String input) async {
    // ✅ FIXED: Correct validation logic
    if (GOOGLE_PLACES_API_KEY == 'YOUR_API_KEY_HERE' || GOOGLE_PLACES_API_KEY.isEmpty) {
      throw Exception('Please configure your Google Places API key');
    }

    const String url = 'https://places.googleapis.com/v1/places:autocomplete';
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': GOOGLE_PLACES_API_KEY,
      'X-Goog-FieldMask': 'suggestions.placePrediction.placeId,suggestions.placePrediction.text,suggestions.placePrediction.structuredFormat,suggestions.placePrediction.types',
    };

    final Map<String, dynamic> requestBody = {
      'input': input,
      'sessionToken': sessionToken,
      'locationBias': {
        'rectangle': {
          'low': {'latitude': 6.4626999, 'longitude': 68.1097},
          'high': {'latitude': 35.513327, 'longitude': 97.39535869999999}
        }
      },
      'includedPrimaryTypes': [
        'locality',
        'sublocality',
        'administrative_area_level_1',
        'administrative_area_level_2',
        'postal_code'
      ],
      'includedRegionCodes': ['IN'],
      'languageCode': 'en',
      // 'maxResultCount': 8,
    };

    print('🔑 Using API Kery: ${GOOGLE_PLACES_API_KEY.substring(0, 10)}...');
    print('🌐 Making request to: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(requestBody),
    );

    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];
      
      List<PlaceInfo> results = [];
      
      for (var suggestion in suggestions) {
        final placePrediction = suggestion['placePrediction'];
        if (placePrediction != null) {
          final placeInfo = PlaceInfo.fromGooglePlaces(placePrediction);
          if (placeInfo != null) {
            results.add(placeInfo);
          }
        }
      }
      
      print('✅ Successfully parsed ${results.length} suggestions');
      return results;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    try {
      final String url = 'https://places.googleapis.com/v1/places/$placeId';
      
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': GOOGLE_PLACES_API_KEY,
        'X-Goog-FieldMask': 'location,displayName,formattedAddress',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PlaceDetails.fromJson(data);
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return null;
  }

  static List<PlaceInfo> _getFallbackSuggestions(String input) {
    final fallbackCities = [
      PlaceInfo(
        placeId: 'fallback_mumbai',
        displayName: 'Mumbai, Maharashtra, India',
        formattedAddress: 'Mumbai, Maharashtra, India',
      ),
      PlaceInfo(
        placeId: 'fallback_delhi',
        displayName: 'Delhi, NCR, India',
        formattedAddress: 'Delhi, NCR, India',
      ),
      PlaceInfo(
        placeId: 'fallback_bangalore',
        displayName: 'Bangalore, Karnataka, India',
        formattedAddress: 'Bangalore, Karnataka, India',
      ),
      PlaceInfo(
        placeId: 'fallback_hyderabad',
        displayName: 'Hyderabad, Telangana, India',
        formattedAddress: 'Hyderabad, Telangana, India',
      ),
      PlaceInfo(
        placeId: 'fallback_chennai',
        displayName: 'Chennai, Tamil Nadu, India',
        formattedAddress: 'Chennai, Tamil Nadu, India',
      ),
      PlaceInfo(
        placeId: 'fallback_pune',
        displayName: 'Pune, Maharashtra, India',
        formattedAddress: 'Pune, Maharashtra, India',
      ),
    ];

    return fallbackCities
        .where((city) => city.displayName.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }
}

// Data models
class PlaceInfo {
  final String placeId;
  final String displayName;
  final String formattedAddress;
  final String? mainText;
  final String? secondaryText;

  PlaceInfo({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    this.mainText,
    this.secondaryText,
  });

  static PlaceInfo? fromGooglePlaces(Map<String, dynamic> data) {
    try {
      final placeId = data['placeId'] as String?;
      final text = data['text'];
      final structuredFormat = data['structuredFormat'];
      
      if (placeId == null || text == null) return null;
      
      String displayName = text['text'] ?? '';
      String? mainText;
      String? secondaryText;
      
      if (structuredFormat != null) {
        mainText = structuredFormat['mainText']?['text'];
        secondaryText = structuredFormat['secondaryText']?['text'];
        
        if (mainText != null && secondaryText != null) {
          displayName = '$mainText, $secondaryText';
        }
      }
      
      return PlaceInfo(
        placeId: placeId,
        displayName: displayName,
        formattedAddress: displayName,
        mainText: mainText,
        secondaryText: secondaryText,
      );
    } catch (e) {
      print('Error parsing place info: $e');
      return null;
    }
  }

  Map<String, String> toMap() {
    return {
      'placeId': placeId,
      'placeName': displayName,
      'formattedAddress': formattedAddress,
    };
  }
}

class PlaceDetails {
  final double? latitude;
  final double? longitude;
  final String? displayName;
  final String? formattedAddress;

  PlaceDetails({
    this.latitude,
    this.longitude,
    this.displayName,
    this.formattedAddress,
  });

  static PlaceDetails? fromJson(Map<String, dynamic> data) {
    try {
      final location = data['location'];
      final displayName = data['displayName']?['text'];
      final formattedAddress = data['formattedAddress'];
      
      return PlaceDetails(
        latitude: location?['latitude']?.toDouble(),
        longitude: location?['longitude']?.toDouble(),
        displayName: displayName,
        formattedAddress: formattedAddress,
      );
    } catch (e) {
      print('Error parsing place details: $e');
      return null;
    }
  }
}

// Debouncer utility
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Form validators
class FormValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your business name';
    }
    if (value.trim().length < 2) {
      return 'Business name must be at least 2 characters';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select your location';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.trim().length != 10) {
      return 'Phone number must be 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number must contain only digits';
    }
    return null;
  }
}

// Phone input field widget
class PhoneInputField extends StatefulWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final TextEditingController otpController;
  final bool otpSent;
  final Function() onSendOtp;

  const PhoneInputField({
    Key? key,
    required this.responsive,
    required this.controller,
    required this.otpController,
    required this.otpSent,
    required this.onSendOtp,
  }) : super(key: key);

  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone number input
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.otpSent ? Colors.grey.shade300 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Country code prefix
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.responsive.getWidth(12),
                  vertical: widget.responsive.getHeight(14),
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
                    fontSize: widget.responsive.getFontSize(16),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Divider
              Container(
                height: widget.responsive.getHeight(30),
                width: 1,
                color: Colors.grey.shade300,
              ),
              // Phone input
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(16),
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter mobile number",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(16),
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Colors.grey.shade600,
                      size: widget.responsive.getWidth(22),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.responsive.getHeight(16),
                      horizontal: widget.responsive.getWidth(12),
                    ),
                    errorStyle: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(0),
                      height: 0,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: FormValidator.validatePhoneNumber,
                  enabled: !widget.otpSent,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(
              top: widget.responsive.getHeight(8),
              left: widget.responsive.getWidth(16),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.roboto(
                fontSize: widget.responsive.getFontSize(12),
                color: Colors.red.shade600,
              ),
            ),
          ),

        // OTP field (visible only after OTP is sent)
        if (widget.otpSent) ...[
          SizedBox(height: widget.responsive.getHeight(20)),
          Text(
            "Enter OTP",
            style: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(16),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: widget.responsive.getHeight(8)),
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
              controller: widget.otpController,
              style: GoogleFonts.roboto(
                fontSize: widget.responsive.getFontSize(16),
                color: Colors.black87,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: "Enter 6-digit OTP",
                hintStyle: GoogleFonts.roboto(
                  fontSize: widget.responsive.getFontSize(16),
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.grey.shade600,
                  size: widget.responsive.getWidth(22),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.responsive.getHeight(16),
                  horizontal: widget.responsive.getWidth(16),
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
          SizedBox(height: widget.responsive.getHeight(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onSendOtp,
                child: Text(
                  "Resend OTP",
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(14),
                    color: Color(0xFF0033FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.responsive.getWidth(12),
                    vertical: widget.responsive.getHeight(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class HirerSignupPage extends StatefulWidget {
  const HirerSignupPage({Key? key}) : super(key: key);

  @override
  _HirerSignupPageState createState() => _HirerSignupPageState();
}

class _HirerSignupPageState extends State<HirerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _acceptedTerms = false;

  // Responsive util instance
  final ResponsiveUtil _responsive = ResponsiveUtil();

  // Debouncer for location search
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Image picker and selected image
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Location suggestions - Updated for Google Places
  List<PlaceInfo> _locationSuggestions = [];
  PlaceInfo? _selectedLocation;

  // Phone verification
  bool _otpSent = false;
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    _phoneController.text = '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  // URL launcher function
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showSnackBar('Could not open the URL: $url', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error opening URL: $e', isError: true);
    }
  }

  // Show custom snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : const Color(0xFF0033FF),
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

  @override
  Widget build(BuildContext context) {
    _responsive.init(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                )
              )
            : SignupForm(
                formKey: _formKey,
                responsive: _responsive,
                nameController: _nameController,
                businessNameController: _businessNameController,
                locationController: _locationController,
                phoneController: _phoneController,
                otpController: _otpController,
                selectedImage: _selectedImage,
                locationSuggestions: _locationSuggestions,
                otpSent: _otpSent,
                acceptedTerms: _acceptedTerms,
                onImagePicked: (File image) {
                  setState(() {
                    _selectedImage = image;
                  });
                },
                onSuggestionsFetched: (suggestions) {
                  setState(() {
                    _locationSuggestions = suggestions;
                  });
                },
                onLocationSelected: (location) {
                  setState(() {
                    _selectedLocation = location;
                    _locationController.text = location.displayName;
                    _locationSuggestions.clear(); // Clear suggestions after selection
                  });
                  GooglePlacesService.resetSession(); // Reset session after selection
                },
                onSearchLocation: (query) {
                  _searchDebouncer.run(() {
                    _fetchLocationSuggestions(query);
                  });
                },
                onTermsChanged: (value) {
                  setState(() {
                    _acceptedTerms = value;
                  });
                },
                onSendOtp: _verifyPhoneNumber,
                onSubmit: () {
                  if (_formKey.currentState!.validate()) {
                    if (!_acceptedTerms) {
                      _showSnackBar('Please accept terms and privacy policy', isError: true);
                      return;
                    }

                    if (_otpSent) {
                      _verifyOTP();
                    } else {
                      _verifyPhoneNumber();
                    }
                  }
                },
                onTermsTap: () => _launchUrl('https://heywork.in/terms'),
                onPrivacyTap: () => _launchUrl('https://heywork.in/privacy'),
              ),
      ),
    );
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }

    try {
      final suggestions = await GooglePlacesService.getAutocompleteSuggestions(query);
      if (mounted) {
        setState(() {
          _locationSuggestions = suggestions;
        });
      }
    } catch (e) {
      _showSnackBar('Error fetching locations: $e', isError: true);
    }
  }

  // Phone verification methods
  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number', isError: true);
      return;
    }

    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> phoneCheck = await RoleValidationService.checkPhoneNumberExists(phoneNumber);
      
      if (phoneCheck['exists']) {
        setState(() {
          _isLoading = false;
        });
        
        if (phoneCheck['userType'] == 'hirer') {
          RoleValidationService.showAccountExistsDialog(context, 'hirer');
          return;
        } else {
          RoleValidationService.showRoleConflictDialog(
            context, 
            phoneCheck['userType'], 
            'hirer'
          );
          return;
        }
      }

      bool shouldContinue = await RoleValidationService.showRoleRestrictionDialog(context, 'hirer');
      
      if (!shouldContinue) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              await _processUserData(userCredential.user!);
            }
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar('Auto-verification failed: $e', isError: true);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Verification failed: ${e.message}', isError: true);
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
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter the OTP', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_verificationId.isEmpty) {
        throw Exception('Invalid verification session. Please request OTP again.');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to authenticate user');
      }

      await _processUserData(user);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        _showSnackBar('Account created successfully!');
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => IndustrySelectionScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (e.toString().contains('invalid-verification-code') || 
            e.toString().contains('session-expired')) {
          RoleValidationService.showIncorrectOtpDialog(context);
        } else {
          _showSnackBar('Verification failed: ${e.toString()}', isError: true);
        }
      }
    }
  }

  Future<void> _processUserData(User user) async {
    try {
      String? imageUrl = _selectedImage != null ? await _uploadImage() : null;
      
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }
      
      Map<String, dynamic> userData = {
        'id': user.uid,
        'name': _nameController.text.isEmpty ? "User" : _nameController.text.trim(),
        'businessName': _businessNameController.text.isEmpty ? "" : _businessNameController.text.trim(),
        'location': _selectedLocation?.displayName ?? _locationController.text.trim(),
        'placeId': _selectedLocation?.placeId ?? '',
        'loggedPhoneNumber': phoneNumber,
        'profileImage': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'userType': 'hirer',
      };
      
      print('Saving user data: $userData');
      
      try {
        await FirebaseFirestore.instance
            .collection('hirers')
            .doc(user.uid)
            .set(userData, SetOptions(merge: true));
        
        print('User data saved successfully');
        return;
      } catch (firestoreError) {
        print('Firebase database error: $firestoreError');
        throw Exception('Failed to save user data. Please try again.');
      }
    } catch (e) {
      print('Error in _processUserData: $e');
      throw e;
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return null;
    }

    try {
      print('Starting optimized image upload...');
      
      final int fileSize = await _selectedImage!.length();
      print('Image file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      final uuid = Uuid();
      String fileName = '${uuid.v4()}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      
      final uploadTask = storageRef.putFile(
        _selectedImage!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'file_size': '$fileSize',
            'optimized': 'true',
          },
        ),
      );
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print('Upload: ${(progress * 100).toStringAsFixed(1)}%');
      });
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }
}

// Main signup form widget
class SignupForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final ResponsiveUtil responsive;
  final TextEditingController nameController;
  final TextEditingController businessNameController;
  final TextEditingController locationController;
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final File? selectedImage;
  final List<PlaceInfo> locationSuggestions; // Updated type
  final bool otpSent;
  final bool acceptedTerms;
  final Function(File) onImagePicked;
  final Function(List<PlaceInfo>) onSuggestionsFetched; // Updated type
  final Function(PlaceInfo) onLocationSelected; // Updated type
  final Function(String) onSearchLocation;
  final Function(bool) onTermsChanged;
  final Function() onSendOtp;
  final Function() onSubmit;
  final Function() onTermsTap;
  final Function() onPrivacyTap;

  const SignupForm({
    Key? key,
    required this.formKey,
    required this.responsive,
    required this.nameController,
    required this.businessNameController,
    required this.locationController,
    required this.phoneController,
    required this.otpController,
    required this.selectedImage,
    required this.locationSuggestions,
    required this.otpSent,
    required this.acceptedTerms,
    required this.onImagePicked,
    required this.onSuggestionsFetched,
    required this.onLocationSelected,
    required this.onSearchLocation,
    required this.onTermsChanged,
    required this.onSendOtp,
    required this.onSubmit,
    required this.onTermsTap,
    required this.onPrivacyTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: responsive.getWidth(24),
          vertical: responsive.getHeight(24),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  "Hirer Sign Up",
                  style: GoogleFonts.roboto(
                    fontSize: responsive.getFontSize(28),
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0033FF),
                  ),
                ),
              ),

              Center(
                child: Text(
                  "You are signing up as a hirer",
                  style: GoogleFonts.roboto(
                    fontSize: responsive.getFontSize(16),
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(height: responsive.getHeight(12)),

              // Profile Image
              Center(
                child: ProfileImageSelector(
                  responsive: responsive,
                  selectedImage: selectedImage,
                  onImagePicked: onImagePicked,
                ),
              ),

              // Form Fields
              LabelText(responsive: responsive, text: "Your Name"),
              SizedBox(height: responsive.getHeight(8)),
              CustomTextField(
                responsive: responsive,
                controller: nameController,
                hintText: "Enter your name",
                validator: FormValidator.validateName,
                prefixIcon: Icons.person_outline,
              ),
              SizedBox(height: responsive.getHeight(20)),

              LabelText(responsive: responsive, text: "Business Name"),
              SizedBox(height: responsive.getHeight(8)),
              CustomTextField(
                responsive: responsive,
                controller: businessNameController,
                hintText: "Enter the name of your business",
                validator: FormValidator.validateBusinessName,
                prefixIcon: Icons.business_outlined,
              ),
              SizedBox(height: responsive.getHeight(20)),

              LabelText(responsive: responsive, text: "Business Location"),
              SizedBox(height: responsive.getHeight(8)),
              LocationSelector(
                responsive: responsive,
                controller: locationController,
                suggestions: locationSuggestions,
                onSearchChanged: onSearchLocation,
                onLocationSelected: onLocationSelected,
              ),
              SizedBox(height: responsive.getHeight(20)),

              LabelText(responsive: responsive, text: "Mobile number"),
              SizedBox(height: responsive.getHeight(8)),
              PhoneInputField(
                responsive: responsive,
                controller: phoneController,
                otpController: otpController,
                otpSent: otpSent,
                onSendOtp: onSendOtp,
              ),
              SizedBox(height: responsive.getHeight(24)),

              // Terms and Privacy
              Row(
                children: [
                  SizedBox(
                    width: responsive.getWidth(24),
                    height: responsive.getWidth(24),
                    child: Checkbox(
                      value: acceptedTerms,
                      onChanged: (value) => onTermsChanged(value ?? false),
                      activeColor: Color(0xFF0033FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.getWidth(8)),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          "I agree with ",
                          style: GoogleFonts.roboto(
                            fontSize: responsive.getFontSize(14),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        GestureDetector(
                          onTap: onTermsTap,
                          child: Text(
                            "Terms",
                            style: GoogleFonts.roboto(
                              fontSize: responsive.getFontSize(14),
                              color: Color(0xFF0033FF),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        Text(
                          " and ",
                          style: GoogleFonts.roboto(
                            fontSize: responsive.getFontSize(14),
                            color: Colors.grey.shade800,
                          ),
                        ),
                        GestureDetector(
                          onTap: onPrivacyTap,
                          child: Text(
                            "Privacy Policy",
                            style: GoogleFonts.roboto(
                              fontSize: responsive.getFontSize(14),
                              color: Color(0xFF0033FF),
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.getHeight(32)),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: responsive.getHeight(54),
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0033FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    otpSent ? "Continue" : "Continue",
                    style: GoogleFonts.roboto(
                      fontSize: responsive.getFontSize(16),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: responsive.getHeight(16)),

              // Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.roboto(
                        fontSize: responsive.getFontSize(14),
                        color: Colors.grey.shade700,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(builder: (_) => HirerLoginScreen()));
                      },
                      child: Text(
                        "Log in",
                        style: GoogleFonts.roboto(
                          fontSize: responsive.getFontSize(14),
                          color: Color(0xFF0033FF),
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
    );
  }
}

// Profile image selector widget
class ProfileImageSelector extends StatefulWidget {
  final ResponsiveUtil responsive;
  final File? selectedImage;
  final Function(File) onImagePicked;

  const ProfileImageSelector({
    Key? key,
    required this.responsive,
    required this.selectedImage,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  _ProfileImageSelectorState createState() => _ProfileImageSelectorState();
}

class _ProfileImageSelectorState extends State<ProfileImageSelector> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isProcessing ? null : () => _showImagePickerDialog(context),
      child: Container(
        width: widget.responsive.getWidth(120),
        height: widget.responsive.getWidth(120),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          image: widget.selectedImage != null
              ? DecorationImage(
                  image: FileImage(widget.selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _isProcessing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: widget.responsive.getWidth(30),
                    height: widget.responsive.getWidth(30),
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Color(0xFF0033FF),
                    ),
                  ),
                  SizedBox(height: widget.responsive.getHeight(4)),
                  Text(
                    "Processing...",
                    style: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(10),
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : widget.selectedImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: widget.responsive.getWidth(32),
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(height: widget.responsive.getHeight(4)),
                      Text(
                        "Add Photo",
                        style: GoogleFonts.roboto(
                          fontSize: widget.responsive.getFontSize(12),
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Container(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: widget.responsive.getWidth(32),
                          height: widget.responsive.getWidth(32),
                          decoration: BoxDecoration(
                            color: Color(0xFF0033FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.edit,
                            size: widget.responsive.getWidth(16),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(widget.responsive.getWidth(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.responsive.getWidth(40),
                  height: widget.responsive.getHeight(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: widget.responsive.getHeight(20)),
                
                Text(
                  "Select Profile Picture",
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(18),
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: widget.responsive.getHeight(8)),
                Text(
                  "Image will be automatically optimized",
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(12),
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: widget.responsive.getHeight(24)),
                
                _buildOptionTile(
                  context: context,
                  icon: Icons.camera_alt,
                  title: "Camera",
                  subtitle: "Take a new photo",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.camera);
                  },
                ),
                
                SizedBox(height: widget.responsive.getHeight(16)),
                
                _buildOptionTile(
                  context: context,
                  icon: Icons.photo_library,
                  title: "Gallery",
                  subtitle: "Choose from library",
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndCropImage(ImageSource.gallery);
                  },
                ),
                
                SizedBox(height: widget.responsive.getHeight(20)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(widget.responsive.getWidth(16)),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: widget.responsive.getWidth(48),
              height: widget.responsive.getWidth(48),
              decoration: BoxDecoration(
                color: Color(0xFF0033FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Color(0xFF0033FF),
                size: widget.responsive.getWidth(24),
              ),
            ),
            SizedBox(width: widget.responsive.getWidth(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(16),
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: widget.responsive.getHeight(2)),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(12),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: widget.responsive.getWidth(16),
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      print('📸 Starting image selection and processing...');
      
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      print('📏 Image picked, starting crop...');

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Color(0xFF0033FF),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Color(0xFF0033FF),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            aspectRatioPresets: [CropAspectRatioPreset.square],
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        final File finalImage = File(croppedFile.path);
        final int finalSize = await finalImage.length();
        final double finalSizeMB = finalSize / 1024 / 1024;
        
        print('✅ Image processed! Final size: ${finalSizeMB.toStringAsFixed(2)} MB');
        
        widget.onImagePicked(finalImage);
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to process image. Please try again.'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

// Custom text field
class CustomTextField extends StatelessWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.responsive,
    required this.controller,
    required this.hintText,
    this.validator,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.roboto(
        fontSize: responsive.getFontSize(16),
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.roboto(
          fontSize: responsive.getFontSize(16),
          color: Colors.grey.shade500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.grey.shade600,
          size: responsive.getWidth(22),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          vertical: responsive.getHeight(16),
          horizontal: responsive.getWidth(16),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFF0033FF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
        errorStyle: GoogleFonts.roboto(
          fontSize: responsive.getFontSize(12),
          color: Colors.red.shade600,
        ),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
    );
  }
}

// Label text
class LabelText extends StatelessWidget {
  final ResponsiveUtil responsive;
  final String text;

  const LabelText({
    Key? key,
    required this.responsive,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: responsive.getFontSize(16),
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade800,
      ),
    );
  }
}

// Updated Location Selector with Google Places integration
class LocationSelector extends StatefulWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final List<PlaceInfo> suggestions;
  final Function(String) onSearchChanged;
  final Function(PlaceInfo) onLocationSelected;

  const LocationSelector({
    Key? key,
    required this.responsive,
    required this.controller,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  bool _showSuggestions = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text;
    if (query.length < 3) {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    widget.onSearchChanged(query);
    
    // Reset searching state after a delay
    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.roboto(
            fontSize: widget.responsive.getFontSize(16),
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Search for your business location",
            hintStyle: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(16),
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.grey.shade600,
              size: widget.responsive.getWidth(22),
            ),
            suffixIcon: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(widget.responsive.getWidth(14)),
                    child: SizedBox(
                      height: widget.responsive.getWidth(16),
                      width: widget.responsive.getWidth(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0033FF),
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.responsive.getHeight(16),
              horizontal: widget.responsive.getWidth(16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF0033FF), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            errorStyle: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(12),
              color: Colors.red.shade600,
            ),
          ),
          validator: FormValidator.validateLocation,
          textInputAction: TextInputAction.next,
          onTap: () {
            if (widget.controller.text.length >= 3 && widget.suggestions.isNotEmpty) {
              setState(() {
                _showSuggestions = true;
              });
            }
          },
        ),
        if (_showSuggestions && widget.suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: widget.responsive.getHeight(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: widget.responsive.getHeight(8)),
              itemCount: widget.suggestions.length > 5 ? 5 : widget.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                return InkWell(
                  onTap: () {
                    widget.onLocationSelected(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.responsive.getWidth(16),
                      vertical: widget.responsive.getHeight(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: widget.responsive.getWidth(36),
                          height: widget.responsive.getWidth(36),
                          decoration: BoxDecoration(
                            color: Color(0xFF0033FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: widget.responsive.getWidth(20),
                            color: Color(0xFF0033FF),
                          ),
                        ),
                        SizedBox(width: widget.responsive.getWidth(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.mainText ?? suggestion.displayName,
                                style: GoogleFonts.roboto(
                                  fontSize: widget.responsive.getFontSize(14),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (suggestion.secondaryText != null) ...[
                                SizedBox(height: widget.responsive.getHeight(2)),
                                Text(
                                  suggestion.secondaryText!,
                                  style: GoogleFonts.roboto(
                                    fontSize: widget.responsive.getFontSize(12),
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.north_west,
                          size: widget.responsive.getWidth(16),
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}