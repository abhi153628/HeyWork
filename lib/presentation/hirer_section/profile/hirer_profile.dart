import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heywork/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart'; // Add this import
// Add these imports at the top of your file
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// Google Places API Service - ADD THIS NEW CLASS
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
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(requestBody),
    );

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

// Data models - ADD THESE NEW CLASSES
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

  Map<String, dynamic> toMap() {
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

class HirerProfilePage extends StatefulWidget {
  const HirerProfilePage({Key? key}) : super(key: key);

  @override
  _HirerProfilePageState createState() => _HirerProfilePageState();
}

class _HirerProfilePageState extends State<HirerProfilePage> {
  // Function to refresh the profile data
  void refreshProfile() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top curved red background with profile
          ProfileHeaderSection(refreshCallback: refreshProfile),

          // Edit Profile Button
          EditProfileButton(refreshCallback: refreshProfile),
          
          // Jobs Posted Section
     
        ],
      ),
    );
  }
}

class ProfileHeaderSection extends StatelessWidget {
  final Function refreshCallback;
  
  const ProfileHeaderSection({
    Key? key,
    required this.refreshCallback,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('hirers')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          return docSnapshot.data();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        // Default values in case data isn't loaded yet
        String businessName = "Loading...";
        String ownerName = "";
        String location = "";
        String profileImage = "";
        
        // Update values if data is available
        if (snapshot.connectionState == ConnectionState.done && 
            snapshot.hasData && 
            snapshot.data != null) {
          final userData = snapshot.data!;
          businessName = userData['businessName'] ?? "Your Business";
          ownerName = userData['name'] ?? "Your Name";
          
          // Handle location data properly
          if (userData.containsKey('location')) {
            final locationData = userData['location'];
            if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
              location = locationData['placeName'] ?? "Your Location";
            } else if (locationData is String) {
              location = locationData;
            } else {
              location = "Your Location";
            }
          } else {
            location = "Your Location";
          }
          
          profileImage = userData['profileImage'] ?? "";
        }
        
        return Container(
          width: double.infinity,
          height: 380.h,
          decoration: BoxDecoration(
            color: const Color(0xFFBB0000),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          child: Stack(
            children: [
             
              // Background design elements - slightly transparent shapes
              Positioned(
                left: -90.w,
                top: 140.h,
                child: Transform.rotate(
                  angle: -0.99, // Rotate counter-clockwise (in radians)
                  child: Container(
                    height: 150.h,
                    width: 150.w, // optional, if you want symmetry
                    decoration: BoxDecoration(
                      color: Color(0xFFd74346),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -100.w,
                bottom: 165.h,
                child: Transform.rotate(
                  angle: 0.5, // Rotate clockwise (in radians)
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      color: Color(0xFFf10004),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  //! A P P -  B A R
                  // Back button and menu
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      SizedBox(width: 35.w), 
                        Center(
                          child: Text(
                            "Hirer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>  SettingsScreen(),
              )),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile picture - Using real data with modifications
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Shadow removed as requested
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(70.r),
                      child: profileImage.isNotEmpty 
                          ? CachedNetworkImage(
                              imageUrl: profileImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    )
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 60.sp,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 60.sp,
                              color: Colors.white,
                            ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Business name with verification icon - Using real data
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          businessName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 5,),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  // Owner name - Using real data
                  Text(
                    ownerName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),

                  SizedBox(height: 4.h),

            
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                         Icon(Icons.location_on,color: Colors.white,size: 20,),SizedBox(width: 3,),
                         
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// This is a stub for the EditProfilePage
// You would need to implement this page to allow editing profile data
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  // For image picking
  File? _selectedImage;
  String? _currentImageUrl;
  
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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('hirers')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          final userData = docSnapshot.data()!;
          _nameController.text = userData['name'] ?? '';
          _businessNameController.text = userData['businessName'] ?? '';
          _locationController.text = userData['location'] ?? '';
          _currentImageUrl = userData['profileImage'];
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Here you would implement methods for:
  // 1. Image picking
  // 2. Updating the user data in Firestore
  // 3. Form validation
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFBB0000),
        leading: Icon(Icons.cancel,color: Colors.black,),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile image picker would go here
                    // Form fields for name, business name, location would go here
                    // Save button would go here
                  ],
                ),
              ),
            ),
    );
  }
}

class EditProfileButton extends StatelessWidget {
  final Function refreshCallback;
  
  const EditProfileButton({
    Key? key,
    required this.refreshCallback,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GestureDetector(
        onTap: () {
          // Show edit profile bottom sheet instead of navigating
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Important for full-height sheet
            backgroundColor: Colors.transparent,
            builder: (context) => EditProfileBottomSheet(
              onProfileUpdated: () {
                // Refresh the profile data when returning
                refreshCallback();
              },
            ),
          );
        },
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit),
              Text(
                "Edit Your Profile",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Debouncer class for location search
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

// Enhanced EditProfileBottomSheet with image cropping and compression
class EditProfileBottomSheet extends StatefulWidget {
  final Function onProfileUpdated;

  const EditProfileBottomSheet({
    Key? key,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileBottomSheetState createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isImageProcessing = false;
  
  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _industryController = TextEditingController();
  
  // For image picking
  File? _selectedImage;
  String? _currentImageUrl;
  
  // Firestore document ID
  String? _userId;
  
  // Location search fields - Updated for Google Places API
  List<PlaceInfo> _locationSuggestions = [];
  PlaceInfo? _selectedLocation;
  bool _showLocationSuggestions = false;
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _industryController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userId = user.uid;
        final docSnapshot = await FirebaseFirestore.instance
            .collection('hirers')
            .doc(user.uid)
            .get();
        
        if (docSnapshot.exists) {
          final userData = docSnapshot.data()!;
          _nameController.text = userData['name'] ?? '';
          _businessNameController.text = userData['businessName'] ?? '';
          
          // Handle location data properly
          if (userData.containsKey('location')) {
            final locationData = userData['location'];
            if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
              _locationController.text = locationData['placeName'] ?? '';
            } else if (locationData is String) {
              _locationController.text = locationData;
            }
          }
          
          // Format phone number (remove +91 prefix for display)
          String phone = userData['phoneNumber'] ?? '';
          if (phone.startsWith('+91')) {
            phone = phone.substring(3);
          }
          _phoneController.text = phone;
          
          _industryController.text = userData['industry'] ?? '';
          _currentImageUrl = userData['profileImage'];
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showSnackBar('Failed to load profile data');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Location search methods - Updated for Google Places API
  Future<void> _searchLocation(String query) async {
    if (query.length < 3) {
      setState(() {
        _locationSuggestions = [];
        _showLocationSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showLocationSuggestions = true;
    });

    try {
      final suggestions = await GooglePlacesService.getAutocompleteSuggestions(query);
      if (mounted) {
        setState(() {
          _locationSuggestions = suggestions;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error fetching locations: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }
  
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        margin: EdgeInsets.all(10.w),
      ),
    );
  }
  
  // Enhanced image picker with crop and compression
  void _showImagePickerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  "Update Profile Picture",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Image will be automatically optimized",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 24.h),

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

                SizedBox(height: 16.h),

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

                SizedBox(height: 20.h),
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
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Color(0xFFBB0000).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Color(0xFFBB0000),
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.w,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced image picker with cropping functionality
  Future<void> _pickAndCropImage(ImageSource source) async {
    setState(() {
      _isImageProcessing = true;
    });

    try {
      print('📸 Starting image selection and processing...');

      // Pick image with built-in compression
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 75,
      );

      if (pickedFile == null) {
        setState(() {
          _isImageProcessing = false;
        });
        return;
      }

      print('📏 Image picked, starting crop...');

      // Crop with additional compression
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Color(0xFFBB0000),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Color(0xFFBB0000),
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

        setState(() {
          _selectedImage = finalImage;
        });
      }
    } catch (e) {
      print('❌ Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to process image. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageProcessing = false;
        });
      }
    }
  }

  void _showIndustriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builderContext) {
        final searchController = TextEditingController();
        
        final List<Map<String, dynamic>> industryList = [
          {'name': 'Restaurants & Food Services', 'isSelected': _industryController.text == 'Restaurants & Food Services'},
          {'name': 'Hospitality & Hotels', 'isSelected': _industryController.text == 'Hospitality & Hotels'},
          {'name': 'Warehouse & Logistics', 'isSelected': _industryController.text == 'Warehouse & Logistics'},
          {'name': 'Cleaning & Facility Services', 'isSelected': _industryController.text == 'Cleaning & Facility Services'},
          {'name': 'Retail & Stores', 'isSelected': _industryController.text == 'Retail & Stores'},
          {'name': 'Packing & Moving Services', 'isSelected': _industryController.text == 'Packing & Moving Services'},
          {'name': 'Event Management & Catering', 'isSelected': _industryController.text == 'Event Management & Catering'},
          {'name': 'Construction & Civil Work', 'isSelected': _industryController.text == 'Construction & Civil Work'},
          {'name': 'Transport & Delivery', 'isSelected': _industryController.text == 'Transport & Delivery'},
          {'name': 'Mechanic & Repair Services', 'isSelected': _industryController.text == 'Mechanic & Repair Services'},
          {'name': 'Home Services', 'isSelected': _industryController.text == 'Home Services'},
          {'name': 'Beauty & Wellness', 'isSelected': _industryController.text == 'Beauty & Wellness'},
          {'name': 'Healthcare Support', 'isSelected': _industryController.text == 'Healthcare Support'},
          {'name': 'Security Services', 'isSelected': _industryController.text == 'Security Services'},
          {'name': 'Agriculture & Farming', 'isSelected': _industryController.text == 'Agriculture & Farming'},
          {'name': 'Manufacturing', 'isSelected': _industryController.text == 'Manufacturing'},
        ];

        List<Map<String, dynamic>> filteredIndustries = List.from(industryList);
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            void filterIndustries(String query) {
              setModalState(() {
                if (query.isEmpty) {
                  filteredIndustries = List.from(industryList);
                } else {
                  filteredIndustries = industryList
                      .where((industry) => industry['name']
                          .toString()
                          .toLowerCase()
                          .contains(query.toLowerCase()))
                      .toList();
                }
              });
            }
            
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            
            return Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.h),
                        height: 5.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          "Select Industry",
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFBB0000),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search industry type',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 16.w,
                            ),
                          ),
                          onChanged: filterIndustries,
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: filteredIndustries.length,
                          itemBuilder: (context, index) {
                            final industry = filteredIndustries[index];
                            final isSelected = industry['isSelected'] == true;
                            
                            return ListTile(
                              title: Text(
                                industry['name']?.toString() ?? '',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected ? Color(0xFFBB0000) : Colors.black87,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                setModalState(() {
                                  for (var item in industryList) {
                                    item['isSelected'] = false;
                                  }
                                  industry['isSelected'] = true;
                                });
                                
                                setState(() {
                                  _industryController.text = industry['name']?.toString() ?? '';
                                });
                                
                                Navigator.of(context).pop();
                              },
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Color(0xFFBB0000),
                                      size: 24.sp,
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Enhanced image upload method with compression
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      return _currentImageUrl;
    }

    try {
      print('Starting optimized image upload...');

      final int fileSize = await _selectedImage!.length();
      print('Image file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');

      final uuid = Uuid();
      String fileName = '${uuid.v4()}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName');

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
      return _currentImageUrl;
    }
  }
  
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      String? imageUrl = await _uploadImage();
      
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }
      
      // Prepare location data for Google Places API
      Map<String, dynamic> locationData;
      if (_selectedLocation != null) {
        locationData = _selectedLocation!.toMap();
      } else {
        locationData = {'placeName': _locationController.text.trim()};
      }
      
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'location': locationData,
        'UpdatingPhoneNumber': phoneNumber,
        'industry': _industryController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (imageUrl != null) {
        updateData['profileImage'] = imageUrl;
      }
      
      await FirebaseFirestore.instance
          .collection('hirers')
          .doc(user.uid)
          .update(updateData);
      
      Navigator.pop(context);
      widget.onProfileUpdated();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Color(0xFFBB0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      _showSnackBar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: _isLoading
        ? Center(child: CircularProgressIndicator(color: Color(0xFFBB0000)))
        : Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBB0000),
                      ),
                    ),
                    SizedBox(width: 190),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close)
                    )
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, bottomInset + 20.h),
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image with cropping
                        Center(
                          child: GestureDetector(
                            onTap: _isImageProcessing ? null : () => _showImagePickerDialog(context),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100.w,
                                  height: 100.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.r),
                                    child: _isImageProcessing
                                        ? Container(
                                            color: Colors.grey[300],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    color: Color(0xFFBB0000),
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  "Processing...",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10.sp,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : (_selectedImage != null
                                            ? Image.file(
                                                _selectedImage!,
                                                fit: BoxFit.cover,
                                              )
                                            : _currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                                ? CachedNetworkImage(
                                                    imageUrl: _currentImageUrl!,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context, url) => Center(
                                                      child: CircularProgressIndicator(
                                                        color: Color(0xFFBB0000),
                                                      ),
                                                    ),
                                                    errorWidget: (context, url, error) => Icon(
                                                      Icons.person,
                                                      size: 50.w,
                                                      color: Colors.grey.shade400,
                                                    ),
                                                  )
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.add_a_photo,
                                                        size: 32.w,
                                                        color: Colors.grey.shade500,
                                                      ),
                                                      SizedBox(height: 4.h),
                                                      Text(
                                                        "Add Photo",
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12.sp,
                                                          color: Colors.grey.shade600,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                  ),
                                ),
                                
                                if (!_isImageProcessing)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Color(0xFFBB0000),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16.w,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Your Name Field
                        EditFormField(
                          label: "Your Name",
                          controller: _nameController,
                          hint: "Enter your full name",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Business Name Field
                        EditFormField(
                          label: "Business Name",
                          controller: _businessNameController,
                          hint: "Enter your business name",
                          icon: Icons.business_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your business name';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Industry Field
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Industry",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            InkWell(
                              onTap: _showIndustriesBottomSheet,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                                      child: Icon(
                                        Icons.category_outlined,
                                        color: Colors.grey.shade600,
                                        size: 22.w,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _industryController.text.isEmpty
                                            ? "Select your industry"
                                            : _industryController.text,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          color: _industryController.text.isEmpty
                                              ? Colors.grey.shade500
                                              : Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(16.w),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Location Field with Google Places API
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Location",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Column(
                              children: [
                                TextFormField(
                                  controller: _locationController,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Search for your business location",
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.grey.shade600,
                                      size: 22.w,
                                    ),
                                    suffixIcon: _isSearching
                                        ? Padding(
                                            padding: EdgeInsets.all(12.w),
                                            child: SizedBox(
                                              height: 16.h,
                                              width: 16.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Color(0xFFBB0000),
                                                ),
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
                                      vertical: 16.h,
                                      horizontal: 16.w,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(color: Color(0xFFBB0000).withOpacity(0.5), width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(color: Colors.red.shade300, width: 1),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
                                    ),
                                    errorStyle: GoogleFonts.poppins(
                                      fontSize: 12.sp,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your location';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _searchDebouncer.run(() {
                                      _searchLocation(value);
                                    });
                                  },
                                  onTap: () {
                                    if (_locationController.text.length >= 3) {
                                      setState(() {
                                        _showLocationSuggestions = true;
                                      });
                                    }
                                  },
                                ),
                                // Location suggestions with Google Places API
                                if (_showLocationSuggestions && _locationSuggestions.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.only(top: 4.h),
                                    constraints: BoxConstraints(maxHeight: 200.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.symmetric(vertical: 8.h),
                                      itemCount: _locationSuggestions.length > 5 ? 5 : _locationSuggestions.length,
                                      itemBuilder: (context, index) {
                                        final suggestion = _locationSuggestions[index];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedLocation = suggestion;
                                              _locationController.text = suggestion.displayName;
                                              _showLocationSuggestions = false;
                                            });
                                            GooglePlacesService.resetSession();
                                            FocusScope.of(context).unfocus();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16.w,
                                              vertical: 12.h,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 36.w,
                                                  height: 36.w,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFBB0000).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8.r),
                                                  ),
                                                  child: Icon(
                                                    Icons.location_on,
                                                    size: 20.sp,
                                                    color: Color(0xFFBB0000),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        suggestion.mainText ?? suggestion.displayName,
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14.sp,
                                                          fontWeight: FontWeight.w500,
                                                          color: Colors.grey.shade800,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      if (suggestion.secondaryText != null) ...[
                                                        SizedBox(height: 2.h),
                                                        Text(
                                                          suggestion.secondaryText!,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12.sp,
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
                                                  size: 16.w,
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
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 24.h),
                        
                        // Update Button
                        SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFBB0000),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Save Changes",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
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
// Reusable form field widget
class EditFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  
  const EditFormField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(
              icon,
              color: Colors.grey.shade600,
              size: 22.w,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Color(0xFFBB0000).withOpacity(0.5), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            errorStyle: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.red.shade600,
            ),
          ),
          validator: validator,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}