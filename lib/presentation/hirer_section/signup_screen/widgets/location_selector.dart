import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_utils.dart';

class LocationSelector extends StatefulWidget {
  final ResponsiveUtil responsive;
  final TextEditingController controller;
  final List<Map<String, String>> suggestions;
  final Function(String) onSearchChanged;
  final Function(Map<String, String>) onLocationSelected;

  const LocationSelector({
    Key? key,
    required this.responsive,
    required this.controller,
    required this.suggestions,
    required this.onSearchChanged,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _LocationSelectorState createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
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

  void _onSearchChanged() {
    final query = widget.controller.text;
    if (query.length < 3) {
      if (_showSuggestions) {
        setState(() {
          _showSuggestions = false;
        });
      }
      return;
    }

    setState(() {
      _isSearching = true;
      _showSuggestions = true;
    });

    widget.onSearchChanged(query);
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          style: GoogleFonts.roboto(
            fontSize: widget.responsive.getFontSize(16),
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: "Select location of business",
            hintStyle: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(16),
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.grey.shade600,
              size: widget.responsive.getWidth(22),
            ),
            suffixIcon: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(widget.responsive.getWidth(14)),
                    child: SizedBox(
                      height: widget.responsive.getWidth(16),
                      width: widget.responsive.getWidth(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF2020F0),
                      ),
                    ),
                  )
                : Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                  ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              vertical: widget.responsive.getHeight(16),
              horizontal: widget.responsive.getWidth(16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade300, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
            ),
            errorStyle: GoogleFonts.roboto(
              fontSize: widget.responsive.getFontSize(12),
              color: Colors.red.shade600,
            ),
          ),
          validator: FormValidator.validateLocation,
          textInputAction: TextInputAction.next,
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
            margin: EdgeInsets.only(top: widget.responsive.getHeight(4)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  vertical: widget.responsive.getHeight(8)),
              itemCount:
                  widget.suggestions.length > 5 ? 5 : widget.suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = widget.suggestions[index];
                return InkWell(
                  onTap: () {
                    widget.onLocationSelected(suggestion);
                    setState(() {
                      _showSuggestions = false;
                    });
                    FocusScope.of(context).unfocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: widget.responsive.getWidth(16),
                      vertical: widget.responsive.getHeight(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: widget.responsive.getWidth(20),
                          color: const Color(0xFF2020F0),
                        ),
                        SizedBox(width: widget.responsive.getWidth(12)),
                        Expanded(
                          child: Text(
                            suggestion['placeName'] ?? '',
                            style: GoogleFonts.roboto(
                              fontSize: widget.responsive.getFontSize(14),
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
