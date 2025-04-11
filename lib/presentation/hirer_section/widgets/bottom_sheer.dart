import 'package:flutter/material.dart';

class JobPostModalBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Divider at the top
          Container(
            width: 60,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Color(0xFF1A73E8), // Dark blue color
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          // Title
          Text(
            "Post a job to reach workers around you.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          // Subtitle
          SizedBox(height: 10),
          Text(
            "Browse through the applicants and choose the perfect fit.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B6B6B), // Grayish text color
            ),
            textAlign: TextAlign.center,
          ),

          // Buttons
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Handle Part Time Worker button press
              Navigator.pop(context); // Close the modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1A73E8), // Dark blue color
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "PART TIME WORKER",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {
              // Handle Full Time Worker button press
              Navigator.pop(context); // Close the modal
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF1A73E8)), // Dark blue color
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "FULL TIME WORKER",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A73E8), // Dark blue color
              ),
            ),
          ),
        ],
      ),
    );
  }
}