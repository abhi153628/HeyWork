import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heywork/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

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

    print('🔑 Using API Key: ${GOOGLE_PLACES_API_KEY.substring(0, 10)}...');
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

// PlaceInfo class
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

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({Key? key}) : super(key: key);

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> completedJobs = [];
  Map<String, int> jobCategoryCounts = {};
  int totalJobsDone = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      print('👤 Loading user data for: ${user.uid}');
      
      // Get worker data
      final DocumentSnapshot<Map<String, dynamic>> docSnapshot = 
          await _firestore
              .collection('workers')
              .doc(user.uid)
              .get();
          
      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          userData = docSnapshot.data();
        });
        
        print('✅ Worker data loaded: ${userData?['name']}');
        
        // Load completed jobs
        await _loadCompletedJobs(user.uid);
        
      } else {
        print('❌ Worker document does not exist');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompletedJobs(String workerId) async {
    try {
      print('🔍 Loading hired jobs for worker: $workerId');
      
      // Get job applications where worker was HIRED/ACCEPTED by hirer
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: workerId)
          .get();

      print('📊 Found ${jobsSnapshot.docs.length} total job applications');

      List<Map<String, dynamic>> jobs = [];
      Map<String, int> categoryCounts = {};

      // Process each job application and show only HIRED ones
      for (var doc in jobsSnapshot.docs) {
        final applicationData = doc.data();
        final applicationStatus = applicationData['status']?.toString() ?? 'pending';
        
        print('📋 Checking application: ${applicationData['jobTitle']} - Status: $applicationStatus');

        // ONLY include jobs where worker was HIRED/ACCEPTED
        if (applicationStatus == 'accepted' || 
            applicationStatus == 'hired' || 
            applicationStatus == 'completed' || 
            applicationStatus == 'approved' ||
            applicationStatus == 'confirmed' ||
            applicationStatus == 'selected') {
          
          // Extract data safely from application
          final String jobTitle = applicationData['jobTitle']?.toString() ?? 'Unknown Job';
          final String company = applicationData['jobCompany']?.toString() ?? 'Unknown Company';
          
          // Handle location safely
          String location = 'Unknown Location';
          if (applicationData['jobLocation'] != null) {
            location = applicationData['jobLocation'].toString();
          }
          
          final String jobType = applicationData['jobType']?.toString() ?? 'part-time';
          
          // Handle budget safely
          dynamic budget = 0;
          if (applicationData['jobBudget'] != null) {
            if (applicationData['jobBudget'] is num) {
              budget = applicationData['jobBudget'];
            } else if (applicationData['jobBudget'] is String) {
              budget = int.tryParse(applicationData['jobBudget']) ?? 0;
            }
          }

          // Create job details from application data
          final jobDetails = {
            'id': doc.id,
            'jobTitle': jobTitle,
            'hirerBusinessName': company,
            'hirerLocation': location,
            'jobType': jobType,
            'description': applicationData['jobDescription']?.toString() ?? '',
            'budget': budget,
            'date': applicationData['appliedAt'] ?? Timestamp.now(),
            'createdAt': applicationData['appliedAt'] ?? Timestamp.now(),
            'jobCategory': jobTitle,
            'hirerId': applicationData['hirerId']?.toString() ?? '',
            'workerId': applicationData['workerId']?.toString() ?? '',
          };
          
          jobs.add(jobDetails);
          categoryCounts[jobTitle] = (categoryCounts[jobTitle] ?? 0) + 1;
          
          print('✅ Added hired job: $jobTitle at $company');
        }
      }

      setState(() {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = jobs.length;
        _isLoading = false;
      });

      print('📈 Final results: ${jobs.length} hired jobs loaded');

    } catch (e) {
      print('❌ Error loading hired jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildJobHistorySection() {
    return Container(
      margin: EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work History',
            style: GoogleFonts.roboto(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          
          if (completedJobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_history,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No work history yet',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Complete jobs to build your work history',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: completedJobs.length,
              itemBuilder: (context, index) {
                final job = completedJobs[index];
                
                // Format date safely
                String formattedDate = 'Unknown date';
                try {
                  if (job['date'] != null && job['date'] is Timestamp) {
                    final date = (job['date'] as Timestamp).toDate();
                    formattedDate = '${date.day}/${date.month}/${date.year}';
                  }
                } catch (e) {
                  print('Error formatting date: $e');
                }
                
                final isLastItem = index == completedJobs.length - 1;
                
                // Extract data safely
                final String jobTitle = job['jobTitle']?.toString() ?? 'Unknown Job';
                final String companyName = job['hirerBusinessName']?.toString() ?? 'Unknown Company';
                final String jobLocation = job['hirerLocation']?.toString() ?? 'Unknown Location';
                final String jobType = job['jobType']?.toString() ?? 'part-time';
                
                return Container(
                  margin: EdgeInsets.only(bottom: isLastItem ? 0 : 8.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Color(0xFF414ce4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.work,
                              color: Color(0xFF414ce4),
                              size: 24.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jobTitle,
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  companyName,
                                  style: GoogleFonts.roboto(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Flexible(
                            child: Text(
                              jobLocation,
                              style: GoogleFonts.roboto(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 50.w),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      // Show budget if available
                      if (job['budget'] != null && job['budget'] != 0) ...[
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.currency_rupee,
                              size: 16.sp,
                              color: Colors.green.shade600,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '₹${job['budget']}',
                              style: GoogleFonts.roboto(
                                fontSize: 13.sp,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  void _navigateToEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(
        userData: userData,
        onProfileUpdated: () {
          _loadUserData();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      body: _isLoading
          ? Center(
              child: SizedBox(
                      width: 140,
                      height: 140,
                      child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                    ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                children: [
                  _buildProfileHeader(),
    
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEditProfileButton(),
                        _buildExperienceSection(),
                        _buildJobHistorySection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    String name = userData?['name'] ?? 'Worker Name';
    String location = 'Location';
    
    if (userData != null && userData!.containsKey('location')) {
      final locationData = userData!['location'];
      if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
        location = locationData['placeName'] ?? 'Location';
      } else if (locationData is String) {
        location = locationData;
      }
    }
    
    final String? profileImage = userData?['profileImage'];
    
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Color(0xFF414ce4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -90.w,
            top: 140.h,
            child: Transform.rotate(
              angle: -0.99,
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Color(0xFF000ec4),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),
          Positioned(
            right: -100.w,
            bottom: 100.h,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                height: 150.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Color(0xFF5c63fc),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25.w, 
                      vertical: 15.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 35.w),
                        Text(
                          "Worker",
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => SettingsScreen()),
                          ),
                          child: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Spacer(flex: 1),

                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.r),
                      child: profileImage != null && profileImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: profileImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Center(
                                  child: SizedBox(
                        width: 140,
                        height: 140,
                        child:Lottie.asset('asset/Animation - 1748495844642 (1).json', ),
                      )
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.person,
                                  size: 50.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.person,
                                size: 50.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),

                  Spacer(flex: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontSize: 27.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 4.w),
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          location,
                          style: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _navigateToEditProfile(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF414ce4),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, size: 22.sp,color: Colors.white,),
              SizedBox(width: 8.w),
              Text(
                'EDIT PROFILE',
                style: GoogleFonts.roboto(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_outline,
                color: Color(0xFF414ce4),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Work Experience',
                style: GoogleFonts.roboto(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xFF414ce4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Color(0xFF414ce4),
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Total Works: $totalJobsDone',
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF414ce4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          if (jobCategoryCounts.isNotEmpty) ...[
            Text(
              'Experience by Category:',
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: jobCategoryCounts.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: GoogleFonts.roboto(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: EdgeInsets.all(12.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'No work history yet',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Complete your first job to see your experience here',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// EditProfileBottomSheet with Google Places API
class EditProfileBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onProfileUpdated;

  const EditProfileBottomSheet({
    Key? key,
    required this.userData,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  _EditProfileBottomSheetState createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  bool _isImageProcessing = false;
  File? _imageFile;
  String? _currentImageUrl;
  
  // Google Places API fields
  List<PlaceInfo> _locationSuggestions = [];
  PlaceInfo? _selectedLocation;
  bool _showLocationSuggestions = false;
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (widget.userData != null) {
      _nameController.text = widget.userData!['name'] ?? '';
      
      if (widget.userData!.containsKey('location')) {
        final locationData = widget.userData!['location'];
        if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
          _locationController.text = locationData['placeName'] ?? '';
        } else if (locationData is String) {
          _locationController.text = locationData;
        }
      }
      
      _currentImageUrl = widget.userData!['profileImage'];
    }
  }

  Future<void> _fetchLocationSuggestions(String query) async {
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
          _locationSuggestions = _getFallbackSuggestions(query);
        });
      }
    }
  }

  List<PlaceInfo> _getFallbackSuggestions(String query) {
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
        .where((city) => city.displayName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void _onLocationSearchChanged(String query) {
    _searchDebouncer.run(() {
      _fetchLocationSuggestions(query);
    });
  }

  void _onLocationSelected(PlaceInfo location) {
    setState(() {
      _selectedLocation = location;
      _locationController.text = location.displayName;
      _locationSuggestions.clear();
      _showLocationSuggestions = false;
    });
    GooglePlacesService.resetSession();
    FocusScope.of(context).unfocus();
  }

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
                  style: GoogleFonts.roboto(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 24.h),
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
                color: Color(0xFF414ce4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Color(0xFF414ce4),
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
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
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

  Future<void> _pickAndCropImage(ImageSource source) async {
    setState(() {
      _isImageProcessing = true;
    });

    try {
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

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: Color(0xFF414ce4),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Color(0xFF414ce4),
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
        setState(() {
          _imageFile = finalImage;
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image. Please try again.'),
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

  Future<String?> _uploadProfileImage(String userId) async {
    if (_imageFile == null) return _currentImageUrl;
    
    try {
      final uuid = Uuid();
      String fileName = '${uuid.v4()}.jpg';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName');

      final uploadTask = storageRef.putFile(
        _imageFile!,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'optimized': 'true',
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user signed in'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      final String? profileImageUrl = await _uploadProfileImage(user.uid);
      
      Map<String, dynamic> locationData;
      if (_selectedLocation != null) {
        locationData = _selectedLocation!.toMap();
      } else {
        locationData = {
          'placeId': '',
          'placeName': _locationController.text,
          'formattedAddress': _locationController.text,
        };
      }
      
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'location': locationData,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      widget.onProfileUpdated();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF414ce4),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Column(
          children: [
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Search for your location',
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF414ce4),
                ),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(12.w),
                        child: SizedBox(
                          height: 16.h,
                          width: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF414ce4),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.search,
                        color: Colors.grey.shade600,
                      ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your location';
                }
                return null;
              },
              onChanged: _onLocationSearchChanged,
              onTap: () {
                if (_locationController.text.length >= 3 && _locationSuggestions.isNotEmpty) {
                  setState(() {
                    _showLocationSuggestions = true;
                  });
                }
              },
            ),
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
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: _locationSuggestions.length > 5 ? 5 : _locationSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _locationSuggestions[index];
                    return InkWell(
                      onTap: () => _onLocationSelected(suggestion),
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
                                color: Color(0xFF414ce4).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 20.sp,
                                color: Color(0xFF414ce4),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.mainText ?? suggestion.displayName,
                                    style: GoogleFonts.roboto(
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
                                      style: GoogleFonts.roboto(
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
                              size: 16.sp,
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
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF414ce4),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                
                SizedBox(height: 20.h),
                
                Center(
                  child: GestureDetector(
                    onTap: _isImageProcessing ? null : () => _showImagePickerDialog(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60.r),
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
                                            color: Color(0xFF414ce4),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "Processing...",
                                          style: GoogleFonts.roboto(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : (_imageFile != null
                                    ? Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: _currentImageUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Container(
                                              color: Colors.grey[300],
                                              child: Center(
                                                child: SizedBox(
                                                  width: 30.w,
                                                  height: 30.w,
                                                  child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.person,
                                                size: 50.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: Column(
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
                                                  style: GoogleFonts.roboto(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))),
                          ),
                        ),
                        if (!_isImageProcessing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36.w,
                              height: 36.w,
                              decoration: BoxDecoration(
                                color: Color(0xFF414ce4),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    fillColor: Colors.grey[100],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                SizedBox(height: 16.h),
                
                _buildLocationField(),
                
                SizedBox(height: 32.h),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF414ce4),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24.h,
                            width: 24.h,
                            child: SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: Lottie.asset('asset/Animation - 1748495844642 (1).json'),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
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
    );
  }
}