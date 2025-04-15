// /data/models/hirer/hirer_model.dart
// Purpose: Data transfer object for hirer information
// Contains methods to convert to/from JSON and Firestore documents
// Implements the Hirer entity from the domain layer


// lib/models/hirer.dart
class Hirer {
  final String uid;
  final String name;
  final String businessName;
  final String businessLocation;
  final String phoneNumber;
  final String? businessLocationId;
  final Map<String, dynamic>? locationData;
  final DateTime createdAt;

  Hirer({
    required this.uid,
    required this.name,
    required this.businessName,
    required this.businessLocation,
    required this.phoneNumber,
    this.businessLocationId,
    this.locationData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'businessName': businessName,
      'businessLocation': businessLocation,
      'phoneNumber': phoneNumber,
      'businessLocationId': businessLocationId,
      'locationData': locationData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Hirer.fromMap(Map<String, dynamic> map, String docId) {
    return Hirer(
      uid: docId,
      name: map['name'] ?? '',
      businessName: map['businessName'] ?? '',
      businessLocation: map['businessLocation'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      businessLocationId: map['businessLocationId'],
      locationData: map['locationData'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}

// lib/models/place.dart
class Place {
  final String placeId;
  final String name;
  final String formattedAddress;
  final String? state;
  final String? district;
  final String? city;
  final double? latitude;
  final double? longitude;

  Place({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    this.state,
    this.district,
    this.city,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'name': name,
      'formattedAddress': formattedAddress,
      'state': state,
      'district': district,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Place.fromMap(Map<String, dynamic> map) {
    return Place(
      placeId: map['place_id'] ?? map['placeId'] ?? '',
      name: map['name'] ?? map['placeName'] ?? '',
      formattedAddress: map['formatted_address'] ?? map['formattedAddress'] ?? '',
      state: map['state'],
      district: map['district'],
      city: map['city'],
      latitude: map['latitude'] != null ? double.parse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.parse(map['longitude'].toString()) : null,
    );
  }

  factory Place.fromAutosuggestMap(Map<String, dynamic> map) {
    return Place(
      placeId: map['placeId'] ?? '',
      name: map['placeName'] ?? '',
      formattedAddress: map['placeAddress'] ?? '',
      state: map['state'],
      district: map['district'],
      city: map['city'],
      latitude: map['latitude'] != null ? double.parse(map['latitude'].toString()) : null,
      longitude: map['longitude'] != null ? double.parse(map['longitude'].toString()) : null,
    );
  }
}