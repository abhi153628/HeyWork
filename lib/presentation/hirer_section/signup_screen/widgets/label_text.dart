// Label text
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';

class LabelText extends StatelessWidget {
  final ResponsiveUtil responsive;
  final String text;

  const LabelText({
    Key? key,
    required this.responsive,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: responsive.getFontSize(16),
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade800,
      ),
    );
  }
}
