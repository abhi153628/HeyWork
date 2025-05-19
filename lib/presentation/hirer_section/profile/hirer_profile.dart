import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hey_work/presentation/hirer_section/settings_screen/settings_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added import for CachedNetworkImage

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
          location = userData['location'] ?? "Your Location";
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
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
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
                          "Hirer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
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
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
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
                      Text(
                        businessName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

                  // Location - Using real data
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
          _locationController.text = userData['location'] ?? '';
          
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
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Update Profile Picture",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFBB0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Color(0xFFBB0000),
                    ),
                  ),
                  title: Text(
                    "Gallery",
                    style: GoogleFonts.poppins(fontSize: 16.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Color(0xFFBB0000).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFFBB0000),
                    ),
                  ),
                  title: Text(
                    "Camera",
                    style: GoogleFonts.poppins(fontSize: 16.sp),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 80,
                    );
                    if (image != null) {
                      setState(() {
                        _selectedImage = File(image.path);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 void _showIndustriesBottomSheet() {
  // Create controller inside StatefulBuilder to properly handle disposal
  // Do NOT dispose this controller in the .then() callback
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext builderContext) {
      // Create the controller in the builder scope so it's tied to this specific bottom sheet instance
      final searchController = TextEditingController();
      
      // Industry data model - using Map instead of custom class
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
        // The rest of your industries...
      ];

      List<Map<String, dynamic>> filteredIndustries = List.from(industryList);
      
      return StatefulBuilder(
        builder: (context, setModalState) {
          // Function to filter industries within the StatefulBuilder scope
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
          
          // Calculate bottom padding to account for keyboard
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          
          return Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Container(
              // Fixed height percentage with maximum constraint
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
                  mainAxisSize: MainAxisSize.min, // Important
                  children: [
                    // Handle
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      height: 5.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    
                    // Title for clarity
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

                    // Search field
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

                    // List of industries - IMPORTANT: Wrap in Expanded
                    Expanded(
                      child: ListView.builder(
                        // Remove scrollController to avoid potential issues
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
                              // Update selection state
                              setModalState(() {
                                for (var item in industryList) {
                                  item['isSelected'] = false;
                                }
                                industry['isSelected'] = true;
                              });
                              
                              // Update parent controller
                              setState(() {
                                _industryController.text = industry['name']?.toString() ?? '';
                              });
                              
                              // Close the bottom sheet
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
                    
                    // Bottom padding
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
  // Do NOT dispose the controller here, as it will cause "used after being disposed" error
} 
  Future<String?> _uploadImage() async {
    if (_selectedImage == null) {
      // No new image selected, return the current URL
      return _currentImageUrl;
    }

    try {
      // Generate a unique filename
      final uuid = Uuid();
      String fileName = 'profile_${_userId}_${uuid.v4()}.jpg';
      
      // Reference to storage location
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');
      
      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'userId': _userId ?? 'unknown'},
      );
      
      // Start upload
      final uploadTask = storageRef.putFile(_selectedImage!, metadata);
      
      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() => null);
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return _currentImageUrl; // Return existing URL on failure
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
      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Upload image if selected
      String? imageUrl = await _uploadImage();
      
      // Format phone number
      String phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isNotEmpty && !phoneNumber.startsWith('+')) {
        phoneNumber = '+91$phoneNumber';
      }
      
      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': _nameController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'location': _locationController.text.trim(),
        'UpdatingPhoneNumber': phoneNumber,
        'industry': _industryController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Only update image if we have a new one
      if (imageUrl != null) {
        updateData['profileImage'] = imageUrl;
      }
      
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('hirers')
          .doc(user.uid)
          .update(updateData);
      
      // Success
      Navigator.pop(context);
      widget.onProfileUpdated();
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
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
    // Calculate bottom padding for keyboard
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
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 8.h),
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text(
                  "Edit Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFBB0000),
                  ),
                ),
              ),
              
              // Form content in scrollable area
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, bottomInset + 20.h),
                  physics: BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                // Profile image
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
                                    child: _selectedImage != null
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
                                            : Icon(
                                                Icons.person,
                                                size: 50.w,
                                                color: Colors.grey.shade400,
                                              ),
                                  ),
                                ),
                                
                                // Edit icon overlay
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
                                      Icons.edit,
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
                        
                        // Industry Field - Clickable field that opens bottom sheet
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
                        
                        // Location Field
                        EditFormField(
                          label: "Location",
                          controller: _locationController,
                          hint: "Enter your business location",
                          icon: Icons.location_on_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Phone Number Field (with prefix)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
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
                                  // Country code prefix
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 14.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10.r),
                                        bottomLeft: Radius.circular(10.r),
                                      ),
                                    ),
                                    child: Text(
                                      "+91",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  
                                  // Divider
                                  Container(
                                    height: 30.h,
                                    width: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                  
                                  // Phone input
                                  Expanded(
                                    child: TextFormField(
                                      controller: _phoneController,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16.sp,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter mobile number",
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.phone_android,
                                          color: Colors.grey.shade600,
                                          size: 22.w,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 16.h,
                                          horizontal: 12.w,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 32.h),
                        
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
                              "Update Profile",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16.h),
                        
                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          height: 54.h,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
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