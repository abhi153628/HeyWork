import 'package:flutter/material.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0033FF), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.1,
                vertical: screenSize.height * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //! Logo at the top
                  Image.asset(
                    'asset/image.png', 
                    width: screenSize.width * 0.5,
                    height: screenSize.width * 0.5  ,
                
                  ),
                  
                  SizedBox(height: screenSize.height * 0.15),
                  
                  //! "What are you looking for?" text
                  Text(
                    'What are you looking for?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenSize.width * 0.043,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: screenSize.height * 0.017),
                  
                  //! "I want to work" button
                  _buildButton(
                    context: context,
                    text: 'I want to work',
                    isPrimary: true,
                    screenSize: screenSize,
                  ),
                  
                  SizedBox(height: screenSize.height * 0.02),
                  
                  //! "I want to Hire" button
                  _buildButton(
                    context: context,
                    text: 'I want to Hire',
                    isPrimary: false,
                    screenSize: screenSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required String text,
    required bool isPrimary,
    required Size screenSize,
  }) {
    return Container(
      width: double.infinity,
      height: screenSize.height * 0.069,
      margin: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.19,
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF0033FF),
          backgroundColor: isPrimary ? Colors.transparent : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white,
              width: isPrimary ? 1 : 0,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: screenSize.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}