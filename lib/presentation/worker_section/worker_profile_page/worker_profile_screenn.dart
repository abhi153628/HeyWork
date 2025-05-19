import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hey_work/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

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
        
        // Load completed jobs
        await _loadCompletedJobs(user.uid);
      } else {
        print('Worker document does not exist');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadCompletedJobs(String workerId) async {
    try {
      // Query for completed jobs where worker was hired
      final jobsSnapshot = await _firestore
          .collection('jobApplications')
          .where('workerId', isEqualTo: workerId)
          .where('status', isEqualTo: 'accepted')
          .get();

      List<Map<String, dynamic>> jobs = [];
      Map<String, int> categoryCounts = {};
      int totalJobs = 0;

      // Process each job application
      for (var doc in jobsSnapshot.docs) {
        final jobData = doc.data();
        final jobId = jobData['jobId'];

        // Get the actual job details
        if (jobId != null) {
          final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
          if (jobDoc.exists) {
            final fullJobData = jobDoc.data() ?? {};
            
            // Add to completed jobs list
            jobs.add({
              'id': jobDoc.id,
              ...fullJobData,
            });

            // Count job categories
            final category = fullJobData['jobCategory'] ?? 'Uncategorized';
            categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
            totalJobs++;
          }
        }
      }

      setState(() {
        completedJobs = jobs;
        jobCategoryCounts = categoryCounts;
        totalJobsDone = totalJobs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading completed jobs: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
  
  void _navigateToEditProfile(BuildContext context) {
    // Show bottom sheet for editing profile
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(
        userData: userData,
        onProfileUpdated: () {
          // Reload user data after update
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
              child: CircularProgressIndicator(
                color: const Color(0xFF414ce4),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                children: [
                  // Top curved background with profile
                  _buildProfileHeader(),

                  // Body content with consistent spacing
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Edit Profile Button
                        _buildEditProfileButton(),

                        // Experience section
                        _buildExperienceSection(),

                        // Job history with reduced gap
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
      decoration: BoxDecoration(
        color: Color(0xFF414ce4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          // Background design elements
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

          // Content
          Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              children: [
                // Back button and title
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 35.w), // For symmetry
                      Text(
                        "Worker Profile",
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

                // Profile picture
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
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF414ce4),
                                  ),
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
                            child: Icon(
                              Icons.person,
                              size: 50.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Worker name with verification icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 27.sp,
                        fontWeight: FontWeight.bold,
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

                // Location
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
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
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
          // Reduced spacing for consistency
          SizedBox(height: 12.h),
          
          // Work count with colored badge
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
          
          // Reduced spacing for consistency
          SizedBox(height: 12.h),
          
          // Job category statistics
          if (jobCategoryCounts.isNotEmpty) ...[
            Text(
              'Experience by Category:',
              style: GoogleFonts.roboto(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h), // Reduced from 12.h
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
                // Reduced padding for consistency
                padding: EdgeInsets.all(12.h), // Reduced from 16.h
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 8.h), // Reduced from 12.h
                    Text(
                      'No work history yet',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 6.h), // Reduced from 8.h
                    Text(
                      'You have no prior work experience in the app',
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

  Widget _buildJobHistorySection() {
    return Container(
      // Reduced bottom margin from 10.h to match other sections
      margin: EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Completed Jobs',
            style: GoogleFonts.roboto(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Add a small consistent gap between title and content
          SizedBox(height: 8.h),
          
          if (completedJobs.isEmpty)
            Center(
              // Reduced vertical padding from 24.h to match other sections
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 40.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No completed jobs',
                      style: GoogleFonts.roboto(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
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
              // Remove default padding
              padding: EdgeInsets.zero,
              itemCount: completedJobs.length,
              itemBuilder: (context, index) {
                final job = completedJobs[index];
                
                // Format date
                String formattedDate = 'Unknown date';
                if (job.containsKey('date') && job['date'] is Timestamp) {
                  final date = (job['date'] as Timestamp).toDate();
                  formattedDate = '${date.day}/${date.month}/${date.year}';
                }
                
                // Last item should have no bottom margin
                final isLastItem = index == completedJobs.length - 1;
                
                return Container(
                  // Reduced bottom margin from 12.h to 8.h and remove for last item
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
                                  job['title'] ?? 'Unknown Job',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  job['hirerBusinessName'] ?? 'Unknown Company',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: job['jobType'] == 'full-time'
                                  ? Colors.blue.shade100
                                  : job['jobType'] == 'part-time'
                                      ? Colors.amber.shade100
                                      : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              job['jobType'] ?? 'Unknown',
                              style: GoogleFonts.roboto(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: job['jobType'] == 'full-time'
                                    ? Colors.blue.shade800
                                    : job['jobType'] == 'part-time'
                                        ? Colors.amber.shade800
                                        : Colors.green.shade800,
                              ),
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
                          Text(
                            job['hirerLocation'] ?? 'Unknown Location',
                            style: GoogleFonts.roboto(
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Spacer(),
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
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Keep the original EditProfileBottomSheet class without changes
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

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isLoading = false;
  File? _imageFile;
  String? _currentImageUrl;
  
  // Add these new fields for location search
  List<Map<String, String>> _locationSuggestions = [];
  Map<String, String>? _selectedLocation;
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
      _phoneController.text = widget.userData!['phone'] ?? '';
      
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
  
  // Add this method for location search
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
      final suggestions = await fetchLocationSuggestions(query);
      setState(() {
        _locationSuggestions = suggestions;
        _isSearching = false;
      });
    } catch (e) {
      print('Error fetching locations: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }
  
  // Add the location API methods
  Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
    // First try cached results for faster response
    if (_cachedLocations.containsKey(query)) {
      return _cachedLocations[query]!;
    }

    // Next, check the most popular Indian cities
    List<Map<String, String>> filteredCities = _indianCities
        .where((city) => city['placeName']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredCities.isNotEmpty) {
      _cachedLocations[query] = filteredCities;
      return filteredCities;
    }

    try {
      // If no local matches, try the API
      final apiResults = await fetchFromOpenStreetMap(query);
      _cachedLocations[query] = apiResults;
      return apiResults;
    } catch (e) {
      print("OpenStreetMap API error: $e");
      return _getMockData(query);
    }
  }

  // Static cache for location results
  static Map<String, List<Map<String, String>>> _cachedLocations = {};

  // Method to fetch data from OpenStreetMap
  Future<List<Map<String, String>>> fetchFromOpenStreetMap(String query) async {
    final String url =
        'https://nominatim.openstreetmap.org/search?q=$query+india&format=json&addressdetails=1&limit=10&countrycodes=in&bounded=1';

    Map<String, String> headers = {
      'User-Agent': 'YourApp/1.0',
      'Accept-Language': 'en-US,en;q=0.9',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);

      return results.map<Map<String, String>>((result) {
        String displayName = result['display_name'] ?? '';
        Map<String, dynamic> address = result['address'] ?? {};
        
        String formattedName = '';
        List<String> addressParts = [];

        if (address.isNotEmpty) {
          if (address['city'] != null) addressParts.add(address['city']);
          else if (address['town'] != null) addressParts.add(address['town']);
          else if (address['village'] != null) addressParts.add(address['village']);
          else if (address['suburb'] != null) addressParts.add(address['suburb']);

          if (address['state_district'] != null) addressParts.add(address['state_district']);
          else if (address['county'] != null) addressParts.add(address['county']);
          
          if (address['state'] != null) addressParts.add(address['state']);
          
          formattedName = addressParts.join(', ');
        }

        if (formattedName.isEmpty) {
          List<String> nameParts = displayName.split(', ');
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
      throw Exception('Failed to load from OpenStreetMap: ${response.statusCode}');
    }
  }

  // Popular Indian cities data for quick results
  final List<Map<String, String>> _indianCities = [
    {'placeName': 'Mumbai, Maharashtra', 'placeId': 'city_mumbai', 'latitude': '19.0760', 'longitude': '72.8777'},
    {'placeName': 'Delhi, NCR', 'placeId': 'city_delhi', 'latitude': '28.7041', 'longitude': '77.1025'},
    {'placeName': 'Bangalore, Karnataka', 'placeId': 'city_bangalore', 'latitude': '12.9716', 'longitude': '77.5946'},
    {'placeName': 'Hyderabad, Telangana', 'placeId': 'city_hyderabad', 'latitude': '17.3850', 'longitude': '78.4867'},
    {'placeName': 'Chennai, Tamil Nadu', 'placeId': 'city_chennai', 'latitude': '13.0827', 'longitude': '80.2707'},
    {'placeName': 'Kolkata, West Bengal', 'placeId': 'city_kolkata', 'latitude': '22.5726', 'longitude': '88.3639'},
    {'placeName': 'Pune, Maharashtra', 'placeId': 'city_pune', 'latitude': '18.5204', 'longitude': '73.8567'},
    {'placeName': 'Ahmedabad, Gujarat', 'placeId': 'city_ahmedabad', 'latitude': '23.0225', 'longitude': '72.5714'},
    {'placeName': 'Jaipur, Rajasthan', 'placeId': 'city_jaipur', 'latitude': '26.9124', 'longitude': '75.7873'},
    {'placeName': 'Kochi, Kerala', 'placeId': 'city_kochi', 'latitude': '9.9312', 'longitude': '76.2673'},
    {'placeName': 'Goa', 'placeId': 'city_goa', 'latitude': '15.2993', 'longitude': '74.1240'},
  ];

  // Mock data for fallback
  List<Map<String, String>> _getMockData(String query) {
    return [
      {'placeName': 'Delhi, NCR, India', 'placeId': 'mock_delhi', 'latitude': '28.7041', 'longitude': '77.1025'},
      {'placeName': 'Mumbai, Maharashtra, India', 'placeId': 'mock_mumbai', 'latitude': '19.0760', 'longitude': '72.8777'},
      {'placeName': '$query Area, India', 'placeId': 'mock_custom', 'latitude': '20.5937', 'longitude': '78.9629'},
    ];
  }
  
  // Update the upload method to include location data
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
      
      // Upload new profile image if selected
      final String? profileImageUrl = await _uploadProfileImage(user.uid);
      
      // Prepare location data
      Map<String, dynamic> locationData;
      if (_selectedLocation != null) {
        locationData = {
          'placeName': _selectedLocation!['placeName'],
          'placeId': _selectedLocation!['placeId'],
          'latitude': _selectedLocation!['latitude'],
          'longitude': _selectedLocation!['longitude'],
        };
      } else {
        locationData = {'placeName': _locationController.text};
      }
      
      // Update firestore
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'location': locationData,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Notify parent about the update
      widget.onProfileUpdated();
      
      // Show success message and close bottom sheet
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
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
    Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  Future<String?> _uploadProfileImage(String userId) async {
    if (_imageFile == null) return _currentImageUrl;
    
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');
          
      final uploadTask = storageRef.putFile(_imageFile!);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }
  
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
                // Header
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
                
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
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
                            child: _imageFile != null
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
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                const Color(0xFF414ce4),
                                              ),
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
                                        child: Icon(
                                          Icons.person,
                                          size: 50.sp,
                                          color: Colors.grey[600],
                                        ),
                                      )),
                          ),
                        ),
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
                
                // Name Field
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
                
                // Phone Number Field
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
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
                    prefixIcon: Container(
                      width: 70.w,
                      alignment: Alignment.center,
                      child: Text(
                        '+91', // Country code (you can make this dynamic)
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
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
                ),
                
                SizedBox(height: 16.h),
                
                // Location Field with Search
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
                        hintText: 'Enter your location',
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
                        suffixIcon: _isSearching
                            ? Padding(
                                padding: EdgeInsets.all(12.w),
                                child: SizedBox(
                                  height: 16.h,
                                  width: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF414ce4),
                                    ),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF414ce4),
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
                                  _locationController.text = suggestion['placeName'] ?? '';
                                  _showLocationSuggestions = false;
                                });
                                FocusScope.of(context).unfocus();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 20.sp,
                                      color: Color(0xFF414ce4),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Text(
                                        suggestion['placeName'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14.sp,
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
                ),
                
                SizedBox(height: 32.h),
                
                // Save Button
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
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.5,
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