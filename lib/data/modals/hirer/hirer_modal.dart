// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String businessName;
  final String location;
  final String phoneNumber;
  final String? profileImage;
  final DateTime? createdAt;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.businessName,
    required this.location,
    required this.phoneNumber,
    this.profileImage,
    this.createdAt,
    required this.userType,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'businessName': businessName,
      'location': location,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt ?? DateTime.now(),
      'userType': userType,
    };
  }

  // Create UserModel from Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      businessName: map['businessName'] ?? '',
      location: map['location'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'],
      createdAt: map['createdAt']?.toDate(),
      userType: map['userType'] ?? 'hirer',
    );
  }
}