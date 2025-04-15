import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hey_work/firebase_options.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';


// Firebase configuration



class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
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
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Your Account'),
        elevation: 0,
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProfileImageWidget(
                      selectedImage: _selectedImage,
                      onImagePicked: (File image) {
                        setState(() {
                          _selectedImage = image;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    TextFormWidget(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormWidget(
                      controller: _businessNameController,
                      label: 'Business Name',
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your business name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    LocationSearchWidget(
                      controller: _locationController,
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
                      suggestions: _locationSuggestions,
                    ),
                    SizedBox(height: 16),
                    PhoneAuthWidget(
                      phoneController: _phoneController,
                      otpController: _otpController,
                      otpSent: _otpSent,
                      onSendOtp: _verifyPhoneNumber,
                      onOtpVerified: (isVerified) {
                        if (isVerified) {
                          _submitForm();
                        }
                      },
                    ),
                    SizedBox(height: 24),
                    SubmitButtonWidget(
                      onSubmit: () {
                        if (_formKey.currentState!.validate()) {
                          if (_otpSent) {
                            _verifyOTP();
                          } else {
                            _verifyPhoneNumber();
                          }
                        }
                      },
                      label: _otpSent ? 'Create Account' : 'Send OTP',
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Phone verification methods
  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+${_phoneController.text.trim()}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _submitForm();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _verificationId = verificationId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent to your phone')),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _submitForm();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  // Form submission
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null || _selectedLocation == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields and select an image')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image to Firebase Storage
      String imageUrl = await _uploadImage(_selectedImage);
      
      // Save user data to Firestore
      await _saveUserData(imageUrl);
      
      setState(() {
        _isLoading = false;
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully!')),
      );
      
      // Navigate to next screen or home
      // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<String> _uploadImage(dynamic firebase_storage) async {
    if (_selectedImage == null) {
      throw Exception('No image selected');
    }

    final uuid = Uuid();
    String fileName = '${uuid.v4()}.jpg';
    final storageRef = firebase_storage.FirebaseStorage.instance.ref().child('profile_images/$fileName');
    final uploadTask = storageRef.putFile(_selectedImage!);
    final snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _saveUserData(String imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'id': user.uid,
      'name': _nameController.text.trim(),
      'businessName': _businessNameController.text.trim(),
      'location': {
        'placeName': _selectedLocation!['placeName'],
        'placeId': _selectedLocation!['placeId'],
        'latitude': _selectedLocation!['latitude'],
        'longitude': _selectedLocation!['longitude'],
      },
      'phoneNumber': user.phoneNumber,
      'profileImage': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// Widget Components
class ProfileImageWidget extends StatelessWidget {
  final File? selectedImage;
  final Function(File) onImagePicked;

  const ProfileImageWidget({
    Key? key,
    this.selectedImage,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          image: selectedImage != null
              ? DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: selectedImage == null
            ? Icon(
                Icons.add_a_photo,
                size: 40,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    onImagePicked(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    onImagePicked(File(image.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class TextFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;

  const TextFormWidget({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

class LocationSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(List<Map<String, String>>) onSuggestionsFetched;
  final Function(Map<String, String>) onLocationSelected;
  final List<Map<String, String>> suggestions;

  const LocationSearchWidget({
    Key? key,
    required this.controller,
    required this.onSuggestionsFetched,
    required this.onLocationSelected,
    required this.suggestions,
  }) : super(key: key);

  @override
  _LocationSearchWidgetState createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget> {
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
  
  void _onSearchChanged() async {
    final query = widget.controller.text;
    
    if (query.length < 3) {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
        });
        widget.onSuggestionsFetched([]);
      }
      return;
    }
    
    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });
    
    try {
      List<Map<String, String>> suggestions = await fetchLocationSuggestions(query);
      if (mounted) {
        widget.onSuggestionsFetched(suggestions);
        setState(() {
          _isSearching = false;
        });
      }
    } catch (e) {
      print("Location search error: $e");
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching locations: $e')),
        );
      }
    }
  }

  Future<List<Map<String, String>>> fetchLocationSuggestions(String query) async {
    // Using Open-Source API as fallback
    try {
      final osmResponse = await fetchFromOpenStreetMap(query);
      if (osmResponse.isNotEmpty) {
        return osmResponse;
      }
    } catch (e) {
      print("OpenStreetMap fallback error: $e");
    }

    // If everything fails, return mock data
    return _getMockData(query);
  }

  Future<List<Map<String, String>>> fetchFromOpenStreetMap(String query) async {
    // Using Nominatim API (OpenStreetMap's search API)
    final String url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5';
    
    // Required headers for Nominatim
    Map<String, String> headers = {
      'User-Agent': 'MyApp/1.0',  // Required for Nominatim
    };
    
    final response = await http.get(Uri.parse(url), headers: headers);
    
    print("OpenStreetMap API status: ${response.statusCode}");
    
    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);
      
      return results.map<Map<String, String>>((result) {
        return {
          'placeName': result['display_name'] ?? '',
          'placeId': result['place_id']?.toString() ?? '',
          'latitude': result['lat']?.toString() ?? '',
          'longitude': result['lon']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load from OpenStreetMap: ${response.statusCode}');
    }
  }

  // Mock data for testing when API fails
  List<Map<String, String>> _getMockData(String query) {
    print("Using mock data for query: $query");
    return [
      {
        'placeName': 'Delhi, India',
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
        'placeName': query + ' Area, India',
        'placeId': 'mock_custom',
        'latitude': '20.5937',
        'longitude': '78.9629',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          decoration: InputDecoration(
            labelText: 'Location',
            prefixIcon: Icon(Icons.location_on),
            suffixIcon: _isSearching
                ? Container(
                    width: 20,
                    height: 20,
                    padding: EdgeInsets.all(8),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a location';
            }
            return null;
          },
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
            margin: EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.suggestions.length > 5 ? 5 : widget.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                return ListTile(
                  title: Text(suggestion['placeName'] ?? ''),
                  onTap: () {
                    widget.onLocationSelected(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}



class PhoneAuthWidget extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController otpController;
  final bool otpSent;
  final Function() onSendOtp;
  final Function(bool) onOtpVerified;

  const PhoneAuthWidget({
    Key? key,
    required this.phoneController,
    required this.otpController,
    required this.otpSent,
    required this.onSendOtp,
    required this.onOtpVerified,
  }) : super(key: key);

  @override
  _PhoneAuthWidgetState createState() => _PhoneAuthWidgetState();
}

class _PhoneAuthWidgetState extends State<PhoneAuthWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            helperText: 'Format: +CountryCodeNumber (e.g. +911234567890)',
            errorText: _errorMessage,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (!value.startsWith('+')) {
              return 'Phone number must start with + and country code';
            }
            if (!RegExp(r'^\+\d{10,14}$').hasMatch(value)) {
              return 'Please enter a valid phone number';
            }
            return null;
          },
          enabled: !widget.otpSent && !_isLoading,
          onChanged: (_) {
            if (_errorMessage != null) {
              setState(() {
                _errorMessage = null;
              });
            }
          },
        ),
        if (!widget.otpSent) ...[
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Sending...'),
                      ],
                    )
                  : Text('Send OTP'),
            ),
          ),
        ],
        if (widget.otpSent) ...[
          SizedBox(height: 16),
          TextFormField(
            controller: widget.otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'OTP',
              prefixIcon: Icon(Icons.lock_outline),
              helperText: 'Enter the 6-digit code sent to your phone',
              errorText: _errorMessage,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP';
              }
              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'OTP must be 6 digits';
              }
              return null;
            },
            enabled: !_isLoading,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text('Resend OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Verifying...'),
                          ],
                        )
                      : Text('Verify'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  

  Future<void> _sendOtp() async {
    final phoneNumber = widget.phoneController.text.trim();
    
    // Validate phone number format
    if (!phoneNumber.startsWith('+')) {
      setState(() {
        _errorMessage = 'Phone number must start with + and country code';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the parent's onSendOtp method
      widget.onSendOtp();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call the parent's onSendOtp method to resend OTP
      widget.onSendOtp();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Notify parent that OTP verification was attempted
      widget.onOtpVerified(true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
      widget.onOtpVerified(false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
class SubmitButtonWidget extends StatelessWidget {
  final Function() onSubmit;
  final String label;

  const SubmitButtonWidget({
    Key? key,
    required this.onSubmit,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onSubmit,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}