// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/signup_screen.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/label_text.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/location_selector.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/phone_number_widget.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/profile_image_selector.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/text_field.dart';

// class SignupForm extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final ResponsiveUtil responsive;
//   final TextEditingController nameController;
//   final TextEditingController businessNameController;
//   final TextEditingController locationController;
//   final TextEditingController phoneController;
//   final TextEditingController otpController;
//   final File? selectedImage;
//   final List<Map<String, String>> locationSuggestions;
//   final bool otpSent;
//   final bool acceptedTerms;
//   final Function(File) onImagePicked;
//   final Function(List<Map<String, String>>) onSuggestionsFetched;
//   final Function(Map<String, String>) onLocationSelected;
//   final Function(String) onSearchLocation;
//   final Function(bool) onTermsChanged;
//   final Function() onSendOtp;
//   final Function() onSubmit;

//   const SignupForm({
//     Key? key,
//     required this.formKey,
//     required this.responsive,
//     required this.nameController,
//     required this.businessNameController,
//     required this.locationController,
//     required this.phoneController,
//     required this.otpController,
//     required this.selectedImage,
//     required this.locationSuggestions,
//     required this.otpSent,
//     required this.acceptedTerms,
//     required this.onImagePicked,
//     required this.onSuggestionsFetched,
//     required this.onLocationSelected,
//     required this.onSearchLocation,
//     required this.onTermsChanged,
//     required this.onSendOtp,
//     required this.onSubmit,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//       ),
//       child: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         padding: EdgeInsets.symmetric(
//           horizontal: responsive.getWidth(24),
//           vertical: responsive.getHeight(24),
//         ),
//         child: Form(
//           key: formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               Center(
//                 child: Text(
//                   "Hirer Sign Up",
//                   style: GoogleFonts.roboto(
//                     fontSize: responsive.getFontSize(28),
//                     fontWeight: FontWeight.w700,
//                     color: const Color(0xFF2020F0),
//                   ),
//                 ),
//               ),
        
//               Center(
//                 child: Text(
//                   "You are signing up as a hirer",
//                   style: GoogleFonts.roboto(
//                     fontSize: responsive.getFontSize(16),
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//               ),
//               SizedBox(height: responsive.getHeight(12)),
              
//               // Profile Image
//               Center(
//                 child: ProfileImageSelector(
//                   responsive: responsive,
//                   selectedImage: selectedImage,
//                   onImagePicked: onImagePicked,
//                 ),
//               ),
          
              
//               // Form Fields
//               LabelText(responsive: responsive, text: "Your Name"),
//               SizedBox(height: responsive.getHeight(8)),
//               CustomTextField(
//                 responsive: responsive,
//                 controller: nameController,
//                 hintText: "Enter your name",
//                 validator: FormValidator.validateName,
//                 prefixIcon: Icons.person_outline,
//               ),
//               SizedBox(height: responsive.getHeight(20)),
              
//               LabelText(responsive: responsive, text: "Business Name"),
//               SizedBox(height: responsive.getHeight(8)),
//               CustomTextField(
//                 responsive: responsive,
//                 controller: businessNameController,
//                 hintText: "Enter the name of your business",
//                 validator: FormValidator.validateBusinessName,
//                 prefixIcon: Icons.business_outlined,
//               ),
//               SizedBox(height: responsive.getHeight(20)),
              
//               LabelText(responsive: responsive, text: "Business Location"),
//               SizedBox(height: responsive.getHeight(8)),
//               LocationSelector(
//                 responsive: responsive,
//                 controller: locationController,
//                 suggestions: locationSuggestions,
//                 onSearchChanged: onSearchLocation,
//                 onLocationSelected: onLocationSelected,
//               ),
//               SizedBox(height: responsive.getHeight(20)),
              
//               LabelText(responsive: responsive, text: "Mobile number"),
//               SizedBox(height: responsive.getHeight(8)),
//               PhoneInputField(
//                 responsive: responsive,
//                 controller: phoneController,
//                 otpController: otpController,
//                 otpSent: otpSent,
//                 onSendOtp: onSendOtp,
//               ),
//               SizedBox(height: responsive.getHeight(24)),
              
//               // Terms and Privacy
//               Row(
//                 children: [
//                   SizedBox(
//                     width: responsive.getWidth(24),
//                     height: responsive.getWidth(24),
//                     child: Checkbox(
//                       value: acceptedTerms,
//                       onChanged: (value) => onTermsChanged(value ?? false),
//                       activeColor: const Color(0xFF2020F0),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: responsive.getWidth(8)),
//                   Text(
//                     "I agree with ",
//                     style: GoogleFonts.roboto(
//                       fontSize: responsive.getFontSize(14),
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to Terms page
//                     },
//                     child: Text(
//                       "Terms",
//                       style: GoogleFonts.roboto(
//                         fontSize: responsive.getFontSize(14),
//                         color: const Color(0xFF2020F0),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     " and ",
//                     style: GoogleFonts.roboto(
//                       fontSize: responsive.getFontSize(14),
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       // Navigate to Privacy page
//                     },
//                     child: Text(
//                       "Privacy",
//                       style: GoogleFonts.roboto(
//                         fontSize: responsive.getFontSize(14),
//                         color: const Color(0xFF2020F0),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: responsive.getHeight(32)),
              
//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 height: responsive.getHeight(54),
//                 child: ElevatedButton(
//                   onPressed: onSubmit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF2020F0),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     elevation: 0,
//                   ),
//                   child: Text(
//                     otpSent ? "Continue" : "Continue",
//                     style: GoogleFonts.roboto(
//                       fontSize: responsive.getFontSize(16),
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: responsive.getHeight(16)),
              
//               // Login Link
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account? ",
//                       style: GoogleFonts.roboto(
//                         fontSize: responsive.getFontSize(14),
//                         color: Colors.grey.shade700,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         // Navigate to login page
//                       },
//                       child: Text(
//                         "Log in",
//                         style: GoogleFonts.roboto(
//                           fontSize: responsive.getFontSize(14),
//                           color: const Color(0xFF2020F0),
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
