import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_work/presentation/authentication/role_validation_service.dart';
import 'package:hey_work/presentation/common_screens/privacy.dart';
import 'package:hey_work/presentation/common_screens/terms.dart';
import 'package:hey_work/presentation/worker_section/worker_login_page/worker_login_page.dart';
import 'package:lottie/lottie.dart';
import '../../hirer_section/common/bottom_nav_bar.dart';
import '../../hirer_section/home_page/hirer_home_page.dart';

import '../../hirer_section/signup_screen/widgets/responsive_utils.dart';
import '../bottom_navigation/bottom_nav_bar.dart';
import '../home_page/worker_home_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:image_cropper/image_cropper.dart'; // Add this import
import 'package:path/path.dart' as path; // Add this import

// Import utility classes

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
              color:
                  widget.otpSent ? Colors.grey.shade300 : Colors.grey.shade200,
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
              // Enable auto-fill for OTP codes
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
                    color: const Color(0xFF0033FF),
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

class WorkerSignupPage extends StatefulWidget {
  const WorkerSignupPage({Key? key}) : super(key: key);

  @override
  _WorkerSignupPageState createState() => _WorkerSignupPageState();
}

class _WorkerSignupPageState extends State<WorkerSignupPage> {
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

  // Location suggestions
  List<Map<String, String>> _locationSuggestions = [];
  Map<String, String>? _selectedLocation;

  // Phone verification
  bool _otpSent = false;
  String _verificationId = '';

  @override
  void initState() {
    super.initState();
    // Add +91 as default country code for India
    _phoneController.text = '';
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
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
          mode: LaunchMode.externalApplication, // Forces external browser
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
    // Initialize responsive util
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
                    _locationController.text = location['placeName'] ?? '';
                  });
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
                      _showSnackBar('Please accept terms and privacy policy',
                          isError: true);
                      return;
                    }

                    if (_otpSent) {
                      _verifyOTP();
                    } else {
                      _verifyPhoneNumber();
                    }
                  }
                },
                // Pass the URL launcher function
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
      final suggestions = await fetchLocationSuggestions(query);
      setState(() {
        _locationSuggestions = suggestions;
      });
    } catch (e) {
      _showSnackBar('Error fetching locations: $e', isError: true);
    }
  }

  // Location API methods
  // Cached location data for faster results
  static Map<String, List<Map<String, String>>> _cachedLocations = {};

  // Indian cities data for quick results
  final List<Map<String, String>> _indianCities = [
    {
      'placeName': 'Mumbai, Maharashtra',
      'placeId': 'city_mumbai',
      'latitude': '19.0760',
      'longitude': '72.8777'
    },
    {
      'placeName': 'Delhi, NCR',
      'placeId': 'city_delhi',
      'latitude': '28.7041',
      'longitude': '77.1025'
    },
    {
      'placeName': 'Bangalore, Karnataka',
      'placeId': 'city_bangalore',
      'latitude': '12.9716',
      'longitude': '77.5946'
    },
    {
      'placeName': 'Hyderabad, Telangana',
      'placeId': 'city_hyderabad',
      'latitude': '17.3850',
      'longitude': '78.4867'
    },
    {
      'placeName': 'Chennai, Tamil Nadu',
      'placeId': 'city_chennai',
      'latitude': '13.0827',
      'longitude': '80.2707'
    },
    {
      'placeName': 'Kolkata, West Bengal',
      'placeId': 'city_kolkata',
      'latitude': '22.5726',
      'longitude': '88.3639'
    },
    {
      'placeName': 'Pune, Maharashtra',
      'placeId': 'city_pune',
      'latitude': '18.5204',
      'longitude': '73.8567'
    },
    {
      'placeName': 'Ahmedabad, Gujarat',
      'placeId': 'city_ahmedabad',
      'latitude': '23.0225',
      'longitude': '72.5714'
    },
    {
      'placeName': 'Jaipur, Rajasthan',
      'placeId': 'city_jaipur',
      'latitude': '26.9124',
      'longitude': '75.7873'
    },
    {
      'placeName': 'Lucknow, Uttar Pradesh',
      'placeId': 'city_lucknow',
      'latitude': '26.8467',
      'longitude': '80.9462'
    },
    {
      'placeName': 'Kanpur, Uttar Pradesh',
      'placeId': 'city_kanpur',
      'latitude': '26.4499',
      'longitude': '80.3319'
    },
    {
      'placeName': 'Nagpur, Maharashtra',
      'placeId': 'city_nagpur',
      'latitude': '21.1458',
      'longitude': '79.0882'
    },
    {
      'placeName': 'Visakhapatnam, Andhra Pradesh',
      'placeId': 'city_visakhapatnam',
      'latitude': '17.6868',
      'longitude': '83.2185'
    },
    {
      'placeName': 'Bhopal, Madhya Pradesh',
      'placeId': 'city_bhopal',
      'latitude': '23.2599',
      'longitude': '77.4126'
    },
    {
      'placeName': 'Patna, Bihar',
      'placeId': 'city_patna',
      'latitude': '25.5941',
      'longitude': '85.1376'
    },
    {
      'placeName': 'Vadodara, Gujarat',
      'placeId': 'city_vadodara',
      'latitude': '22.3072',
      'longitude': '73.1812'
    },
    {
      'placeName': 'Ghaziabad, Uttar Pradesh',
      'placeId': 'city_ghaziabad',
      'latitude': '28.6692',
      'longitude': '77.4538'
    },
    {
      'placeName': 'Ludhiana, Punjab',
      'placeId': 'city_ludhiana',
      'latitude': '30.9010',
      'longitude': '75.8573'
    },
    {
      'placeName': 'Agra, Uttar Pradesh',
      'placeId': 'city_agra',
      'latitude': '27.1767',
      'longitude': '78.0081'
    },
    {
      'placeName': 'Nashik, Maharashtra',
      'placeId': 'city_nashik',
      'latitude': '19.9975',
      'longitude': '73.7898'
    },
    {
      'placeName': 'Ranchi, Jharkhand',
      'placeId': 'city_ranchi',
      'latitude': '23.3441',
      'longitude': '85.3096'
    },
    {
      'placeName': 'Faridabad, Haryana',
      'placeId': 'city_faridabad',
      'latitude': '28.4089',
      'longitude': '77.3178'
    },
    {
      'placeName': 'Indore, Madhya Pradesh',
      'placeId': 'city_indore',
      'latitude': '22.7196',
      'longitude': '75.8577'
    },
    {
      'placeName': 'Rajkot, Gujarat',
      'placeId': 'city_rajkot',
      'latitude': '22.3039',
      'longitude': '70.8022'
    },
    {
      'placeName': 'Guwahati, Assam',
      'placeId': 'city_guwahati',
      'latitude': '26.1445',
      'longitude': '91.7362'
    },
    {
      'placeName': 'Chandigarh, Punjab & Haryana',
      'placeId': 'city_chandigarh',
      'latitude': '30.7333',
      'longitude': '76.7794'
    },
    {
      'placeName': 'Hubli-Dharwad, Karnataka',
      'placeId': 'city_hubli',
      'latitude': '15.3647',
      'longitude': '75.1240'
    },
    {
      'placeName': 'Jodhpur, Rajasthan',
      'placeId': 'city_jodhpur',
      'latitude': '26.2389',
      'longitude': '73.0243'
    },
    {
      'placeName': 'Srinagar, Jammu & Kashmir',
      'placeId': 'city_srinagar',
      'latitude': '34.0837',
      'longitude': '74.7973'
    },
    {
      'placeName': 'Coimbatore, Tamil Nadu',
      'placeId': 'city_coimbatore',
      'latitude': '11.0168',
      'longitude': '76.9558'
    },
    {
      'placeName': 'Goa',
      'placeId': 'city_goa',
      'latitude': '15.2993',
      'longitude': '74.1240'
    },
    {
      'placeName': 'Kochi, Kerala',
      'placeId': 'city_kochi',
      'latitude': '9.9312',
      'longitude': '76.2673'
    },
    {
      'placeName': 'Thiruvananthapuram, Kerala',
      'placeId': 'city_trivandrum',
      'latitude': '8.5241',
      'longitude': '76.9366'
    },
    {
      'placeName': 'Haridwar, Uttarakhand',
      'placeId': 'city_haridwar',
      'latitude': '29.9457',
      'longitude': '78.1642'
    },
    {
      'placeName': 'Hampi, Karnataka',
      'placeId': 'city_hampi',
      'latitude': '15.3350',
      'longitude': '76.4600'
    },
    {
      'placeName': 'Haldwani, Uttarakhand',
      'placeId': 'city_haldwani',
      'latitude': '29.2183',
      'longitude': '79.5130'
    },
    {
      'placeName': 'Hapur, Uttar Pradesh',
      'placeId': 'city_hapur',
      'latitude': '28.7304',
      'longitude': '77.7806'
    },
    {
      'placeName': 'Hardoi, Uttar Pradesh',
      'placeId': 'city_hardoi',
      'latitude': '27.3989',
      'longitude': '80.1313'
    },
  ];

  Future<List<Map<String, String>>> fetchLocationSuggestions(
      String query) async {
    if (query.length < 2) {
      return [];
    }

    query = query.toLowerCase();

    // First check cache for faster response
    if (_cachedLocations.containsKey(query)) {
      return _cachedLocations[query]!;
    }

    // Next, check local Indian cities data for quick results
    List<Map<String, String>> filteredCities = _indianCities
        .where((city) => city['placeName']!.toLowerCase().contains(query))
        .toList();

    // If we have local results, return them immediately
    if (filteredCities.isNotEmpty) {
      // Cache the results
      _cachedLocations[query] = filteredCities;
      return filteredCities;
    }

    // If no local matches or we want more results, try API
    try {
      final apiResults = await fetchFromOpenStreetMap(query);

      // Cache these results too
      _cachedLocations[query] = apiResults;

      return apiResults;
    } catch (e) {
      print("OpenStreetMap API error: $e");
      // Return basic results if API fails
      return _getMockData(query);
    }
  }

  Future<List<Map<String, String>>> fetchFromOpenStreetMap(String query) async {
    // Optimize query for Indian locations
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$query+india&format=json&addressdetails=1&limit=10&countrycodes=in&bounded=1';

    Map<String, String> headers = {
      'User-Agent': 'HeyWork/1.0',
      'Accept-Language': 'en-US,en;q=0.9',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);

      return results.map<Map<String, String>>((result) {
        String displayName = result['display_name'] ?? '';

        // Optimize display name for better readability
        Map<String, dynamic> address = result['address'] ?? {};
        String formattedName = '';

        if (address.isNotEmpty) {
          // Build a clean formatted address
          List<String> addressParts = [];

          // Get the most relevant part first (city, town, village, etc.)
          if (address['city'] != null) {
            addressParts.add(address['city']);
          } else if (address['town'] != null) {
            addressParts.add(address['town']);
          } else if (address['village'] != null) {
            addressParts.add(address['village']);
          } else if (address['suburb'] != null) {
            addressParts.add(address['suburb']);
          } else if (address['neighbourhood'] != null) {
            addressParts.add(address['neighbourhood']);
          }

          // Add district/county if available
          if (address['state_district'] != null) {
            addressParts.add(address['state_district']);
          } else if (address['county'] != null) {
            addressParts.add(address['county']);
          } else if (address['district'] != null) {
            addressParts.add(address['district']);
          }

          // Always add state
          if (address['state'] != null) {
            addressParts.add(address['state']);
          }

          formattedName = addressParts.join(', ');
        }

        // If we couldn't create a nice formatted name, fall back to the original with some cleaning
        if (formattedName.isEmpty) {
          List<String> nameParts = displayName.split(', ');
          // Take first part, add the state if available (usually second to last), and add "India"
          formattedName = nameParts.length > 3
              ? '${nameParts[0]}, ${nameParts[nameParts.length - 3]}, India'
              : displayName.replaceAll(', India', '') + ', India';
        }

        return {
          'placeName': formattedName,
          'placeId': result['place_id']?.toString() ?? '',
          'latitude': result['lat']?.toString() ?? '',
          'longitude': result['lon']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception(
          'Failed to load from OpenStreetMap: ${response.statusCode}');
    }
  }

  // Mock data for testing
  List<Map<String, String>> _getMockData(String query) {
    return [
      {
        'placeName': 'Delhi, NCR, India',
        'placeId': 'mock_delhi',
        'latitude': '28.7041',
        'longitude': '77.1025',
      },
      {
        'placeName': 'Mumbai, Maharashtra, India',
        'placeId': 'mock_mumbai',
        'latitude': '19.0760',
        'longitude': '72.8777',
      },
      {
        'placeName': 'Kolkata, West Bengal, India',
        'placeId': 'mock_kolkata',
        'latitude': '22.5726',
        'longitude': '88.3639',
      },
      {
        'placeName': 'Chennai, Tamil Nadu, India',
        'placeId': 'mock_chennai',
        'latitude': '13.0827',
        'longitude': '80.2707',
      },
      {
        'placeName': '$query Area, India',
        'placeId': 'mock_custom',
        'latitude': '20.5937',
        'longitude': '78.9629',
      },
    ];
  }

  // Replace the _verifyPhoneNumber method in WorkerSignupPage with this:

  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      _showSnackBar('Please enter your phone number', isError: true);
      return;
    }

    // Format phone number to ensure it starts with +91
    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = '+91$phoneNumber';
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if phone number already exists
      Map<String, dynamic> phoneCheck =
          await RoleValidationService.checkPhoneNumberExists(phoneNumber);

      if (phoneCheck['exists']) {
        setState(() {
          _isLoading = false;
        });

        if (phoneCheck['userType'] == 'worker') {
          // Same role account already exists
          RoleValidationService.showAccountExistsDialog(context, 'worker');
          return;
        } else {
          // Different role account exists
          RoleValidationService.showRoleConflictDialog(
              context, phoneCheck['userType'], 'worker');
          return;
        }
      }

      // Show role restriction confirmation dialog
      bool shouldContinue = await RoleValidationService.showRoleRestrictionDialog(
          context, 'worker');

      if (!shouldContinue) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Proceed with Firebase phone verification
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (mainly on Android)
          try {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            if (userCredential.user != null) {
              setState(() {
                _isLoading = false;
              });

              // Process user data and navigate
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

          // Handle specific error types
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.message != null &&
              e.message!.contains('BILLING_NOT_ENABLED')) {
            errorMessage =
                'Authentication service is temporarily unavailable. Please try again later or contact support.';
          } else if (e.code == 'too-many-requests') {
            errorMessage =
                'Too many attempts from this device. Please try again later.';
          } else if (e.code == 'app-not-authorized') {
            errorMessage =
                'App not authorized to use Firebase Authentication. Contact developer.';
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

  // Also update the _verifyOTP method:
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

      // Create the credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      // Sign in with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to authenticate user: No user returned');
      }

      // Process the user data directly after successful authentication
      await _processUserData(user);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show proper error dialog for incorrect OTP
        if (e.toString().contains('invalid-verification-code') ||
            e.toString().contains('session-expired')) {
          RoleValidationService.showIncorrectOtpDialog(context);
        } else {
          _showSnackBar('Verification failed. Please try again.', isError: true);
        }
      }
    }
  }

  // Don't forget to import the RoleValidationService at the top:
  // import 'package:hey_work/presentation/services/role_validation_service.dart';Replace your _processUserData with this simplified version for debugging

  // Fix 1: Process User Data Method
  Future<void> _processUserData(User user) async {
    try {
      print('Processing data for user: ${user.uid}');

      // Upload image if available
      String? imageUrl;
      // In _processUserData method - Fix image upload logic
      if (_selectedImage != null) {
        try {
          imageUrl = await _uploadImage();
          print('Image uploaded successfully: $imageUrl');
        } catch (e) {
          print('Error uploading image: $e');
          // Continue without image if upload fails
        }
      }

      // Create a comprehensive user data map with null checks
      Map<String, dynamic> userData = {
        'id': user.uid,
        'name': _nameController.text.isNotEmpty
            ? _nameController.text.trim()
            : "User",
        'location': _selectedLocation != null
            ? _selectedLocation!['placeName']
            : _locationController.text.isNotEmpty
                ? _locationController.text.trim()
                : "",
        'loginPhoneNumber': _phoneController.text.isNotEmpty
            ? "+91${_phoneController.text.trim()}"
            : "",
        'userType': 'worker',
        'profileImage': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print('Saving worker data: $userData');

      // Save to Firestore with better error handling - using 'workers' collection
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      print('Worker data saved successfully');

      // Update UI state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        _showSnackBar('Account created successfully!');

        // Navigate to home page
        print('Navigating to home page');

        if (mounted) {
          // Use a try-catch to handle any potential navigation errors
          try {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const WorkerMainScreen()));
          } catch (e) {
            print('Navigation error: $e');
            _showSnackBar(
                'Error navigating to home page. Please restart the app.',
                isError: true);
          }
        }
      }
    } catch (e) {
      print('Error processing user data: $e');
      print(StackTrace.current);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error saving user data: $e', isError: true);
      }
    }
  }

  // Enhanced image upload method with compression
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return null;
    }

    try {
      print('Starting optimized image upload...');

      // Get file size
      final int fileSize = await _selectedImage!.length();
      print('Image file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      // Generate unique filename
      final uuid = Uuid();
      String fileName = '${uuid.v4()}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName');

      // Upload with metadata
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

      // Monitor progress
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Please fill all required fields and accept terms',
          isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current user - this is the critical part that's failing
      User? currentUser = FirebaseAuth.instance.currentUser;

      // Better error handling for null user
      if (currentUser == null) {
        print('ERROR: Current user is null after OTP verification');

        // Try to sign in again with phone credential if user is null
        try {
          // Try to sign in again with phone credential if user is null
          PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationId,
            smsCode: _otpController.text.trim(),
          );

          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          currentUser = userCredential.user;

          if (currentUser == null) {
            throw Exception(
                'Failed to authenticate user after multiple attempts');
          }

          print('Successfully authenticated user on retry: ${currentUser.uid}');
        } catch (authError) {
          print('Authentication retry error: $authError');
          throw Exception(
              'Authentication failed. Please try again with a new OTP.');
        }
      }

      print('Processing signup for user: ${currentUser.uid}');

      // Process user data
      await _processUserData(currentUser);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error in form submission: $e');
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  // Improve the _saveUserData method to ensure proper data handling
  Future<void> _saveUserData(User user, String? imageUrl) async {
    try {
      // Create comprehensive user data with proper validation
      Map<String, dynamic> userData = {
        'id': user.uid,
        'name': _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : "Unnamed Worker",
        'businessName': _businessNameController.text.trim(),
        'location': _selectedLocation != null
            ? _selectedLocation
            : {'placeName': _locationController.text.trim()},
        'loginPhoneNumber': _phoneController.text.trim().startsWith('+')
            ? _phoneController.text.trim()
            : '+91${_phoneController.text.trim()}',
        'profileImage': imageUrl,
        'userType': 'worker',
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Try to write to both workers collection and users collection
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      // Also save to a general users collection for easier auth checks
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'userType': 'worker',
        'profileImage': imageUrl,
        'name': userData['name'],
        'lastUpdated': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));

      print('Worker data saved successfully to both collections');
    } catch (e) {
      print('Error saving user data: $e');
      throw e;
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
  final List<Map<String, String>> locationSuggestions;
  final bool otpSent;
  final bool acceptedTerms;
  final Function(File) onImagePicked;
  final Function(List<Map<String, String>>) onSuggestionsFetched;
  final Function(Map<String, String>) onLocationSelected;
  final Function(String) onSearchLocation;
  final Function(bool) onTermsChanged;
  final Function() onSendOtp;
  final Function() onSubmit;
  final Function() onTermsTap; // Add this
  final Function() onPrivacyTap; // Add this

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
    required this.onTermsTap, // Add this
    required this.onPrivacyTap, // Add this
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
                  "Worker Sign Up",
                  style: GoogleFonts.roboto(
                    fontSize: responsive.getFontSize(28),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0033FF),
                  ),
                ),
              ),

              Center(
                child: Text(
                  "You are signing up as a worker",
                  style: GoogleFonts.roboto(
                    fontSize: responsive.getFontSize(16),
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              SizedBox(height: responsive.getHeight(36)),

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

              LabelText(responsive: responsive, text: "Your Location"),
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

              // Terms and Privacy - Updated section
              Row(
                children: [
                  SizedBox(
                    width: responsive.getWidth(24),
                    height: responsive.getWidth(24),
                    child: Checkbox(
                      value: acceptedTerms,
                      onChanged: (value) => onTermsChanged(value ?? false),
                      activeColor: const Color(0xFF0033FF),
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
                          onTap: onTermsTap, // Use the callback
                          child: Text(
                            "Terms",
                            style: GoogleFonts.roboto(
                              fontSize: responsive.getFontSize(14),
                              color: const Color(0xFF0033FF),
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
                          onTap: onPrivacyTap, // Use the callback
                          child: Text(
                            "Privacy Policy",
                            style: GoogleFonts.roboto(
                              fontSize: responsive.getFontSize(14),
                              color: const Color(0xFF0033FF),
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
                    backgroundColor: const Color(0xFF0033FF),
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => WorkerLoginScreen()));
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

// Enhanced Profile image selector widget with cropping functionality
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
                      Container(), // Empty container for the image background
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
                // Handle bar
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

                // Camera Option
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

                // Gallery Option
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

      // Pick image with built-in compression
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024, // Optimal size for profile pics
        maxHeight: 1024, // Optimal size for profile pics
        imageQuality: 75, // Good compression (75% quality)
      );

      if (pickedFile == null) {
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      print('📏 Image picked, starting crop...');

      // Crop with additional compression
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80, // Additional compression
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

        print(
            '✅ Image processed! Final size: ${finalSizeMB.toStringAsFixed(2)} MB');

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
          borderSide: BorderSide(color: const Color(0xFF0033FF), width: 1.5),
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

class LocationSelector extends StatefulWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final List<Map<String, String>> suggestions;
  final Function(String) onSearchChanged;
  final Function(Map<String, String>) onLocationSelected;

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
    setState(() {
      _isSearching = false;
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
            hintText: "Select location of business",
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
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Lottie.asset(
                            'asset/Animation - 1748495844642 (1).json'),
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
              borderSide:
                  BorderSide(color: const Color(0xFF0033FF), width: 1.5),
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
            if (widget.controller.text.length >= 3) {
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
              padding:
                  EdgeInsets.symmetric(vertical: widget.responsive.getHeight(8)),
              itemCount: widget.suggestions.length > 5
                  ? 5
                  : widget.suggestions.length,
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
                        Icon(
                          Icons.location_on,
                          size: widget.responsive.getWidth(20),
                          color: const Color(0xFF0033FF),
                        ),
                        SizedBox(width: widget.responsive.getWidth(12)),
                        Expanded(
                          child: Text(
                            suggestion['placeName'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: widget.responsive.getFontSize(14),
                              color: Colors.grey.shade800,
                            ),
                          ),
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