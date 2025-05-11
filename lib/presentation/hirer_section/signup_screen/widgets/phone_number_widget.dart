// Phone input field widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_utils.dart';

class PhoneInputField extends StatefulWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final TextEditingController otpController;
  final bool otpSent;
  final Function() onSendOtp;

  const PhoneInputField({
    Key? key,
    required this.responsive,
    required this.controller,
    required this.otpController,
    required this.otpSent,
    required this.onSendOtp,
  }) : super(key: key);

  @override
  _PhoneInputFieldState createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Phone number input
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  widget.otpSent ? Colors.grey.shade300 : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Country code prefix
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.responsive.getWidth(12),
                  vertical: widget.responsive.getHeight(14),
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Text(
                  "+91",
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(16),
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              // Divider
              Container(
                height: widget.responsive.getHeight(30),
                width: 1,
                color: Colors.grey.shade300,
              ),

              // Phone input
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(16),
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter mobile number",
                    hintStyle: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(16),
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: Icon(
                      Icons.phone_android,
                      color: Colors.grey.shade600,
                      size: widget.responsive.getWidth(22),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: widget.responsive.getHeight(16),
                      horizontal: widget.responsive.getWidth(12),
                    ),
                    errorStyle: GoogleFonts.roboto(
                      fontSize: widget.responsive.getFontSize(0),
                      height: 0,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: FormValidator.validatePhoneNumber,
                  enabled: !widget.otpSent,
                  onChanged: (_) {
                    if (_errorMessage != null) {
                      setState(() {
                        _errorMessage = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: EdgeInsets.only(
              top: widget.responsive.getHeight(8),
              left: widget.responsive.getWidth(16),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.roboto(
                fontSize: widget.responsive.getFontSize(12),
                color: Colors.red.shade600,
              ),
            ),
          ),

        // OTP field (visible only after OTP is sent)
        if (widget.otpSent) ...[
          SizedBox(height: widget.responsive.getHeight(20)),
          Text(
            "Enter OTP",
            style: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(16),
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: widget.responsive.getHeight(8)),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: TextFormField(
              controller: widget.otpController,
              style: GoogleFonts.roboto(
                fontSize: widget.responsive.getFontSize(16),
                color: Colors.black87,
                letterSpacing: 2,
              ),
              decoration: InputDecoration(
                hintText: "Enter 6-digit OTP",
                hintStyle: GoogleFonts.roboto(
                  fontSize: widget.responsive.getFontSize(16),
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.grey.shade600,
                  size: widget.responsive.getWidth(22),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.responsive.getHeight(16),
                  horizontal: widget.responsive.getWidth(16),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the OTP';
                }
                if (value.length != 6) {
                  return 'OTP must be 6 digits';
                }
                return null;
              },
              textAlign: TextAlign.left,
              // Enable auto-fill for OTP codes
              autofillHints: const [AutofillHints.oneTimeCode],
            ),
          ),
          SizedBox(height: widget.responsive.getHeight(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onSendOtp,
                child: Text(
                  "Resend OTP",
                  style: GoogleFonts.roboto(
                    fontSize: widget.responsive.getFontSize(14),
                    color: const Color(0xFF2020F0),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.responsive.getWidth(12),
                    vertical: widget.responsive.getHeight(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
