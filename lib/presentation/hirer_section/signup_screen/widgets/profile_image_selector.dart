import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_utils.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImageSelector extends StatelessWidget {
  final ResponsiveUtil responsive;
  final File? selectedImage;
  final Function(File) onImagePicked;

  const ProfileImageSelector({
    Key? key,
    required this.responsive,
    required this.selectedImage,
    required this.onImagePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        width: responsive.getWidth(120),
        height: responsive.getWidth(120),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                size: responsive.getWidth(40),
                color: Colors.grey.shade500,
              )
            : null,
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: responsive.getHeight(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  "Select Profile Picture",
                  style: GoogleFonts.roboto(
                    fontSize: responsive.getFontSize(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.getHeight(20)),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(responsive.getWidth(8)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: const Color(0xFF2020F0),
                    ),
                  ),
                  title: Text(
                    "Gallery",
                    style: GoogleFonts.roboto(
                      fontSize: responsive.getFontSize(16),
                    ),
                  ),
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
                  leading: Container(
                    padding: EdgeInsets.all(responsive.getWidth(8)),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: const Color(0xFF2020F0),
                    ),
                  ),
                  title: Text(
                    "Camera",
                    style: GoogleFonts.roboto(
                      fontSize: responsive.getFontSize(16),
                    ),
                  ),
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
          ),
        );
      },
    );
  }
}
