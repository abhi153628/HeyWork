// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:local_auth/error_codes.dart' as auth_error;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';

// class AuthProvider extends ChangeNotifier {
//   final LocalAuthentication _localAuth = LocalAuthentication();
//   bool _isBiometricAvailable = false;
//   bool _isBiometricEnabled = false;
//   final _secureStorage = const FlutterSecureStorage();
//   bool _isLoading = true;
//   bool _isPinSet = false;
//   bool _isAuthenticated = false;
//   final String _pinKey = 'user_pin';
//   final String _securityQuestionKey = 'security_question';
//   final String _securityAnswerKey = 'security_answer';

//   // Getters
//   bool get isBiometricAvailable => _isBiometricAvailable;
//   bool get isBiometricEnabled => _isBiometricEnabled;
//   bool get isLoading => _isLoading;
//   bool get isPinSet => _isPinSet;
//   bool get isAuthenticated => _isAuthenticated;

//   // Constructor
//   AuthProvider() {
//     _checkPinStatus();
//     _checkBiometricAvailability();
//     _loadBiometricPreference();
//   }

//   // Check if PIN is set
//   Future<void> _checkPinStatus() async {
//     try {
//       final pin = await _secureStorage.read(key: _pinKey);
//       _isPinSet = pin != null;
//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isPinSet = false;
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   // Load biometric preference
//   Future<void> _loadBiometricPreference() async {
//     try {
//       final isEnabled = await _secureStorage.read(key: 'biometric_enabled');
//       _isBiometricEnabled = isEnabled == 'true';
//       notifyListeners();
//     } catch (e) {
//       _isBiometricEnabled = false;
//       notifyListeners();
//     }
//   }

//   // Save biometric preference
//   Future<void> setBiometricEnabled(bool enabled) async {
//     try {
//       await _secureStorage.write(
//           key: 'biometric_enabled', value: enabled.toString());
//       _isBiometricEnabled = enabled;
//       notifyListeners();
//     } catch (e) {
//       // Handle error
//     }
//   }

//   // Check biometric availability
//   Future<void> _checkBiometricAvailability() async {
//     try {
//       final canCheckBiometrics = await _localAuth.canCheckBiometrics;
//       final isDeviceSupported = await _localAuth.isDeviceSupported();
//       final availableBiometrics = await _localAuth.getAvailableBiometrics();

//       _isBiometricAvailable = canCheckBiometrics &&
//           isDeviceSupported &&
//           availableBiometrics.isNotEmpty;
//       notifyListeners();
//     } on PlatformException catch (e) {
//       _isBiometricAvailable = false;
//       notifyListeners();
//     }
//   }

//   // Authenticate with biometrics
//   Future<bool> authenticateWithBiometrics() async {
//     try {
//       if (!_isBiometricAvailable) {
//         return false;
//       }

//       final bool didAuthenticate = await _localAuth.authenticate(
//         localizedReason: 'Authenticate to access secure notes',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: true,
//         ),
//       );

//       if (didAuthenticate) {
//         _isAuthenticated = true;
//         notifyListeners();
//       }

//       return didAuthenticate;
//     } on PlatformException catch (e) {
//       if (e.code == auth_error.notAvailable ||
//           e.code == auth_error.notEnrolled ||
//           e.code == auth_error.passcodeNotSet) {
//         _isBiometricAvailable = false;
//         notifyListeners();
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Create a secure hash of the PIN
//   String _hashPin(String pin) {
//     final bytes = utf8.encode(pin);
//     return base64.encode(bytes);
//   }

//   // Set PIN
//   Future<bool> setPin(String pin) async {
//     try {
//       if (pin.length != 4 || !RegExp(r'^[0-9]+$').hasMatch(pin)) {
//         return false;
//       }

//       final hashedPin = _hashPin(pin);
//       await _secureStorage.write(key: _pinKey, value: hashedPin);
//       _isPinSet = true;
//       _isAuthenticated = true;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Verify PIN
//   Future<bool> verifyPin(String pin) async {
//     try {
//       final storedPin = await _secureStorage.read(key: _pinKey);
//       final hashedInput = _hashPin(pin);

//       if (storedPin == hashedInput) {
//         _isAuthenticated = true;
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Set security question
//   Future<bool> setSecurityQuestion(String question, String answer) async {
//     try {
//       await _secureStorage.write(key: _securityQuestionKey, value: question);
//       final hashedAnswer = _hashPin(answer.toLowerCase().trim());
//       await _secureStorage.write(key: _securityAnswerKey, value: hashedAnswer);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Get security question
//   Future<Map<String, String?>> getSecurityQuestion() async {
//     try {
//       final question = await _secureStorage.read(key: _securityQuestionKey);
//       return {'question': question};
//     } catch (e) {
//       return {'question': null};
//     }
//   }

//   // Verify security answer
//   Future<bool> verifySecurityAnswer(String answer) async {
//     try {
//       final storedAnswer = await _secureStorage.read(key: _securityAnswerKey);
//       final hashedInput = _hashPin(answer.toLowerCase().trim());
//       return storedAnswer == hashedInput;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Reset app
//   Future<bool> resetApp() async {
//     try {
//       await _secureStorage.deleteAll();
//       _isPinSet = false;
//       _isAuthenticated = false;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   // Sign out
//   void signOut() {
//     _isAuthenticated = false;
//     notifyListeners();
//   }
// }
