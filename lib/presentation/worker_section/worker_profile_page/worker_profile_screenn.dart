import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({Key? key}) : super(key: key);

  @override
  _WorkerProfilePageState createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> jobsPosted = [];
  
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
          await FirebaseFirestore.instance
              .collection('workers')
              .doc(user.uid)
              .get();
          
      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          userData = docSnapshot.data();
        });
        
        // Also fetch jobs posted by this worker
        await _loadWorkerJobs(user.uid);
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
  
  Future<void> _loadWorkerJobs(String workerId) async {
    try {
      // Assuming jobs are stored in a 'jobs' collection with a 'workerId' field
      final QuerySnapshot<Map<String, dynamic>> jobsSnapshot = 
          await FirebaseFirestore.instance
              .collection('jobs')
              .where('workerId', isEqualTo: workerId)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();
          
      List<Map<String, dynamic>> jobs = [];
      for (var doc in jobsSnapshot.docs) {
        jobs.add({
          'id': doc.id,
          ...doc.data(),
        });
      }
      
      setState(() {
        jobsPosted = jobs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading worker jobs: $e');
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
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFBB0000),
              ),
            )
          : Column(
              children: [
                // Top curved red background with profile
                ProfileHeaderSection(
                  userData: userData,
                  onBackPressed: () => _navigateBack(context),
                ),

                // Edit Profile Button
                EditProfileButton(
                  onPressed: () => _navigateToEditProfile(context),
                ),
                
                // Jobs Posted Section
                if (jobsPosted.isNotEmpty)
                  JobsPostedSection(jobs: jobsPosted),
                
                // If no jobs, show message
                if (jobsPosted.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        "No jobs posted yet",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

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

// Update the EditProfileBottomSheet class to replace the location field with location API integration
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
class ProfileHeaderSection extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback onBackPressed;
  
  const ProfileHeaderSection({
    Key? key, 
    required this.userData,
    required this.onBackPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Extract user data with fallbacks for null values
    final String name = userData != null && userData!.containsKey('name') 
        ? userData!['name'] as String? ?? 'Worker Name'
        : 'Worker Name';
    
    final String businessName = userData != null && userData!.containsKey('businessName') 
        ? userData!['businessName'] as String? ?? name
        : name;
    
    String location = 'Location';
    if (userData != null) {
      if (userData!.containsKey('location')) {
        final locationData = userData!['location'];
        if (locationData is Map<String, dynamic> && locationData.containsKey('placeName')) {
          location = locationData['placeName'] as String? ?? 'Location';
        } else if (locationData is String) {
          location = locationData;
        }
      }
    }
    
    final String? profileImage = userData != null && userData!.containsKey('profileImage') 
        ? userData!['profileImage'] as String?
        : null;
    
    return Container(
      width: double.infinity,
      height: 380.h,
      decoration: BoxDecoration(
        color: const Color(0xFF414ce4),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Stack(
        children: [
          // Shadow circle behind profile picture
          Positioned(
            left: 115.w,
            top: 115.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFc4c4c4)),
            ),
          ),
          
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
                  color: Color(0xFF000ec4),
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
                  color: Color(0xFF5c63fc),
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ),

          // Content
          Column(
            children: [
              // Back button and menu
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 40.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: onBackPressed,
                      child: Container(
                        width: 35.w,
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.red,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    Text(
                      "Worker",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ],
                ),
              ),

              // Profile picture with actual data
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 3,
                      offset: Offset(-4, 1),
                      spreadRadius: 1
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(70.r),
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

              // Business name with verification icon
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
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

              SizedBox(height: 8.h),

              SizedBox(height: 4.h),

              // Location
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
    );
  }
}

class EditProfileButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const EditProfileButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 50.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              "Edit Your Profile",
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JobsPostedSection extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;
  
  const JobsPostedSection({
    Key? key,
    required this.jobs,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            // Header with "View All" option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Jobs Posted",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to all jobs page
                  },
                  child: Text(
                    "View All",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Job Cards list
            Expanded(
              child: ListView.builder(
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final Map<String, dynamic> job = jobs[index];
                  
                 // Calculate time difference for "posted X time ago"
                  String postedTime = "Unknown time ago";
                  if (job.containsKey('createdAt') && job['createdAt'] != null) {
                    if (job['createdAt'] is Timestamp) {
                      final Timestamp timestamp = job['createdAt'] as Timestamp;
                      final DateTime now = DateTime.now();
                      final Duration difference = now.difference(timestamp.toDate());
                      
                      if (difference.inMinutes < 60) {
                        postedTime = "${difference.inMinutes} minutes ago";
                      } else if (difference.inHours < 24) {
                        postedTime = "${difference.inHours} hours ago";
                      } else {
                        postedTime = "${difference.inDays} days ago";
                      }
                    }
                  }
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: JobCard(
                      title: job.containsKey('title') ? job['title'] as String? ?? 'Untitled Job' : 'Untitled Job',
                      company: job.containsKey('company') ? job['company'] as String? ?? 'Company Name' : 'Company Name',
                      location: job.containsKey('location') ? job['location'] as String? ?? 'Unknown Location' : 'Unknown Location',
                      salary: job.containsKey('salary') ? job['salary'] as String? ?? 'Salary not specified' : 'Salary not specified',
                      postedTime: postedTime,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String postedTime;

  const JobCard({
    Key? key,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.postedTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Posted time
          Text(
            "Posted $postedTime",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 12.h),

          // Job title and company icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      company,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Location with icon
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Salary with icon
          Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 18.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 8.w),
              Text(
                salary,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
                        