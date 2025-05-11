// // lib/widgets/custom_text_field.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:hey_work/data/data_sources/remote/firebase_auth_hirer.dart';
// import 'package:hey_work/data/modals/hirer/hirer_modal.dart';
// import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';

// class CustomTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String? Function(String?)? validator;
//   final ResponsiveUtil responsiveUtil;
//   final TextInputType? keyboardType;
//   final String? prefixText;
//   final Widget? suffixIcon;
//   final int? maxLength;
//   final bool obscureText;
//   final List<TextInputFormatter>? inputFormatters;
//   final Function(String)? onChanged;

//   const CustomTextField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     required this.validator,
//     required this.responsiveUtil,
//     this.keyboardType,
//     this.prefixText,
//     this.suffixIcon,
//     this.maxLength,
//     this.obscureText = false,
//     this.inputFormatters,
//     this.onChanged,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       maxLength: maxLength,
//       obscureText: obscureText,
//       inputFormatters: inputFormatters,
//       onChanged: onChanged,
//       style: TextStyle(
//         fontSize: responsiveUtil.getFontSize(14),
//         color: Colors.black87,
//       ),
//       decoration: InputDecoration(
//         hintText: hintText,
//         prefixText: prefixText,
//         suffixIcon: suffixIcon,
//         filled: true,
//         fillColor: const Color(0xFFEEEEF2),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: responsiveUtil.getWidth(16),
//           vertical: responsiveUtil.getHeight(16),
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: BorderSide.none,
//         ),
//         hintStyle: TextStyle(
//           color: Colors.grey[600],
//           fontSize: responsiveUtil.getFontSize(14),
//         ),
//         errorStyle: TextStyle(
//           fontSize: responsiveUtil.getFontSize(12),
//           color: Colors.red,
//         ),
//         counterText: "",
//       ),
//       validator: validator,
//     );
//   }
// }

// class LocationBottomSheet extends StatefulWidget {
//   final LocationService locationService;
//   final ResponsiveUtil responsiveUtil;

//   const LocationBottomSheet({
//     Key? key,
//     required this.locationService,
//     required this.responsiveUtil,
//   }) : super(key: key);

//   @override
//   State<LocationBottomSheet> createState() => _LocationBottomSheetState();
// }

// class _LocationBottomSheetState extends State<LocationBottomSheet> {
//   final TextEditingController _searchController = TextEditingController();
//   final _debouncer = Debouncer(milliseconds: 500);

//   List<Place> _places = [];
//   bool _isLoading = false;
//   bool _hasError = false;
//   String _searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _debouncer.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     final query = _searchController.text.trim();
//     if (query != _searchQuery) {
//       _searchQuery = query;
//       _debouncer.run(() {
//         _searchPlaces(query);
//       });
//     }
//   }

//   Future<void> _searchPlaces(String query) async {
//     if (query.length < 2) {
//       setState(() {
//         _places = [];
//         _isLoading = false;
//         _hasError = false;
//       });
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final places = await widget.locationService.searchPlaces(query);

//       if (mounted) {
//         setState(() {
//           _places = places;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error searching places: $e');
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   void _selectPlace(Place place) {
//     Navigator.pop(context, place);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ResponsiveUtil responsiveUtil = widget.responsiveUtil;

//     return Container(
//       height: responsiveUtil.getHeight(600),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Header
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: responsiveUtil.getWidth(16),
//               vertical: responsiveUtil.getHeight(16),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Select Location',
//                   style: TextStyle(
//                     fontSize: responsiveUtil.getFontSize(18),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: const Icon(Icons.close),
//                   padding: EdgeInsets.zero,
//                   constraints: const BoxConstraints(),
//                 ),
//               ],
//             ),
//           ),

//           // Search bar
//           Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: responsiveUtil.getWidth(16),
//               vertical: responsiveUtil.getHeight(8),
//             ),
//             child: TextField(
//               controller: _searchController,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: 'Search for location...',
//                 prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                 filled: true,
//                 fillColor: const Color(0xFFEEEEF2),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: responsiveUtil.getWidth(16),
//                   vertical: responsiveUtil.getHeight(12),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: BorderSide.none,
//                 ),
//                 hintStyle: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: responsiveUtil.getFontSize(14),
//                 ),
//               ),
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(14),
//               ),
//             ),
//           ),

//           // Results
//           Expanded(
//             child: _buildResultsWidget(responsiveUtil),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultsWidget(ResponsiveUtil responsiveUtil) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_hasError) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: responsiveUtil.getWidth(48),
//               color: Colors.red,
//             ),
//             responsiveUtil.verticalSpace(16),
//             Text(
//               'Something went wrong',
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(16),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             responsiveUtil.verticalSpace(8),
//             ElevatedButton(
//               onPressed: () => _searchPlaces(_searchQuery),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2020F0),
//               ),
//               child: const Text(
//                 'Try Again',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_places.isEmpty && _searchQuery.length >= 2) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.location_off,
//               size: responsiveUtil.getWidth(48),
//               color: Colors.grey,
//             ),
//             responsiveUtil.verticalSpace(16),
//             Text(
//               'No locations found',
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(16),
//                 color: Colors.grey[600],
//               ),
//             ),
//             responsiveUtil.verticalSpace(8),
//             Text(
//               'Try a different search term',
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(14),
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_searchQuery.length < 2) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.location_on_outlined,
//               size: responsiveUtil.getWidth(48),
//               color: const Color(0xFF2020F0),
//             ),
//             responsiveUtil.verticalSpace(16),
//             Text(
//               'Search for a location',
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(16),
//                 color: Colors.grey[600],
//               ),
//             ),
//             responsiveUtil.verticalSpace(8),
//             Text(
//               'Enter at least 2 characters',
//               style: TextStyle(
//                 fontSize: responsiveUtil.getFontSize(14),
//                 color: Colors.grey[500],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       itemCount: _places.length,
//       padding: EdgeInsets.only(
//         top: responsiveUtil.getHeight(8),
//       ),
//       itemBuilder: (context, index) {
//         final place = _places[index];
//         return ListTile(
//           title: Text(
//             place.name,
//             style: TextStyle(
//               fontSize: responsiveUtil.getFontSize(14),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           subtitle: Text(
//             place.formattedAddress,
//             style: TextStyle(
//               fontSize: responsiveUtil.getFontSize(12),
//               color: Colors.grey[600],
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//           leading: const Icon(
//             Icons.location_on,
//             color: Color(0xFF2020F0),
//           ),
//           onTap: () => _selectPlace(place),
//           contentPadding: EdgeInsets.symmetric(
//             horizontal: responsiveUtil.getWidth(16),
//             vertical: responsiveUtil.getHeight(4),
//           ),
//         );
//       },
//     );
//   }
// }

// class OTPInputField extends StatelessWidget {
//   final TextEditingController controller;
//   final Function(String) onCompleted;
//   final ResponsiveUtil responsiveUtil;
//   final int length;

//   const OTPInputField({
//     Key? key,
//     required this.controller,
//     required this.onCompleted,
//     required this.responsiveUtil,
//     this.length = 6,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: responsiveUtil.getWidth(16)),
//       child: TextField(
//         controller: controller,
//         keyboardType: TextInputType.number,
//         maxLength: length,
//         style: TextStyle(
//           fontSize: responsiveUtil.getFontSize(24),
//           fontWeight: FontWeight.bold,
//           letterSpacing: responsiveUtil.getWidth(8),
//           color: const Color(0xFF2020F0),
//         ),
//         textAlign: TextAlign.center,
//         decoration: InputDecoration(
//           counterText: "",
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide.none,
//           ),
//           fillColor: const Color(0xFFEEEEF2),
//           filled: true,
//           hintText: '• • • • • •',
//           hintStyle: TextStyle(
//             fontSize: responsiveUtil.getFontSize(24),
//             letterSpacing: responsiveUtil.getWidth(8),
//             color: Colors.grey[400],
//           ),
//           contentPadding: EdgeInsets.symmetric(
//             vertical: responsiveUtil.getHeight(16),
//             horizontal: responsiveUtil.getWidth(16),
//           ),
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(length),
//         ],
//         onChanged: (value) {
//           if (value.length == length) {
//             onCompleted(value);
//           }
//         },
//       ),
//     );
//   }
// }

// class CustomButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//   final bool isLoading;
//   final bool isEnabled;
//   final ResponsiveUtil responsiveUtil;

//   const CustomButton({
//     Key? key,
//     required this.text,
//     required this.onPressed,
//     required this.responsiveUtil,
//     this.isLoading = false,
//     this.isEnabled = true,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: (isLoading || !isEnabled) ? null : onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isEnabled
//               ? const Color(0xFF2020F0)
//               : const Color(0xFF2020F0).withOpacity(0.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: EdgeInsets.symmetric(
//             vertical: responsiveUtil.getHeight(16),
//           ),
//           elevation: 0,
//         ),
//         child: isLoading
//             ? SizedBox(
//                 height: responsiveUtil.getHeight(20),
//                 width: responsiveUtil.getHeight(20),
//                 child: const CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   strokeWidth: 2,
//                 ),
//               )
//             : Text(
//                 text,
//                 style: TextStyle(
//                   fontSize: responsiveUtil.getFontSize(16),
//                   fontWeight: FontWeight.w500,
//                   color: Colors.white,
//                 ),
//               ),
//       ),
//     );
//   }
// }
