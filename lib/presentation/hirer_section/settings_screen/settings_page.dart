import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hey_work/presentation/common_screens/log_sign.dart';
import 'package:hey_work/presentation/hirer_section/profile/hirer_profile.dart';
import 'package:hey_work/presentation/hirer_section/settings_screen/faqs_screen.dart';
import 'package:hey_work/presentation/services/authentication_services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);
  AuthService service = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: screenWidth * 0.055,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings sections
            _buildSettingsSection(
              context: context,
              title: "Account & Privacy",
              options: [
                SettingsOptionData(
                  icon: Icons.shield_outlined,
                  title: "Privacy & Security",
                  subtitle: "Manage your privacy settings",
                  onTap: () => _launchURL('https://heywork.in/privacy'),
                ),
                SettingsOptionData(
                  icon: Icons.description_outlined,
                  title: "Terms & Conditions",
                  subtitle: "View app terms and policies",
                  onTap: () => _launchURL('https://heywork.in/terms'),
                ),
              ],
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.025),

            _buildSettingsSection(
              context: context,
              title: "Support",
              options: [
                SettingsOptionData(
                  icon: Icons.help_outline_rounded,
                  title: "Help & Feedback",
                  subtitle: "Get help or send us feedback",
                  onTap: () => _navigateToPage(
                    context,
                    HelpFeedbackPage(),
                  ),
                ),
                SettingsOptionData(
                  icon: Icons.support_agent_outlined,
                  title: "Contact Support",
                  subtitle: "Reach out to our support team",
                  onTap: () => _showContactSupportDialog(context, screenWidth),
                ),
              ],
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.025),

            _buildSettingsSection(
              context: context,
              title: "Account Actions",
              options: [
                SettingsOptionData(
                  icon: Icons.logout_rounded,
                  title: "Sign Out",
                  subtitle: "Sign out of your account",
                  onTap: () => _showModernLogoutDialog(context, screenWidth),
                  isDestructive: true,
                ),
              ],
              screenWidth: screenWidth,
            ),

            SizedBox(height: screenHeight * 0.04),

            // App version footer
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.015,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  "HeyWork v1.0.0",
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URLs
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      // You can show a snackbar or dialog to inform the user about the error
    }
  }

  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<SettingsOptionData> options,
    required double screenWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: options.asMap().entries.map((entry) {
              int index = entry.key;
              SettingsOptionData option = entry.value;
              bool isLast = index == options.length - 1;
              
              return _buildModernSettingsOption(
                option: option,
                screenWidth: screenWidth,
                isLast: isLast,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSettingsOption({
    required SettingsOptionData option,
    required double screenWidth,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: option.onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
          bottom: Radius.circular(isLast ? 16 : 0),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            border: !isLast
                ? Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade100,
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: option.isDestructive
                      ? Colors.red.shade50
                      : Color(0xFF0033FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option.icon,
                  color: option.isDestructive
                      ? Colors.red.shade600
                      : Color(0xFF0033FF),
                  size: screenWidth * 0.055,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color: option.isDestructive 
                            ? Colors.red.shade600 
                            : Colors.black87,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      SizedBox(height: 2),
                      Text(
                        option.subtitle!,
                        style: TextStyle(
                          fontSize: screenWidth * 0.032,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: screenWidth * 0.04,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showModernLogoutDialog(BuildContext context, double screenWidth) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade600,
                    size: screenWidth * 0.08,
                  ),
                ),

                SizedBox(height: screenWidth * 0.04),

                // Title
                Text(
                  "Sign Out",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: screenWidth * 0.02),

                // Description
                Text(
                  "Are you sure you want to sign out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: screenWidth * 0.06),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          service.signOutAndNavigateToLogin(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactSupportDialog(BuildContext context, double screenWidth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF0033FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: Color(0xFF0033FF),
                    size: screenWidth * 0.08,
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                Text(
                  "Contact Support",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Text(
                  "Choose how you'd like to reach out to our support team",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: screenWidth * 0.06),
                
                // Support options
                _buildSupportOption(
                  icon: Icons.email_outlined,
                  title: "Email Support",
                  subtitle: "help.heywork@gmail.com",
                  onTap: () {
                    Navigator.pop(context);
                    _launchURL('mailto:help.heywork@gmail.com');
                  },
                  screenWidth: screenWidth,
                ),
                SizedBox(height: 12),
                _buildSupportOption(
                  icon: Icons.phone_outlined,
                  title: "Call Support",
                  subtitle: "+91 9778756394",
                  onTap: () {
                    Navigator.pop(context);
                    _launchURL('tel:+919778756394');
                  },
                  screenWidth: screenWidth,
                ),
                
                SizedBox(height: screenWidth * 0.04),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Color(0xFF0033FF),
                size: screenWidth * 0.055,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.032,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: screenWidth * 0.04,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsOptionData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  SettingsOptionData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}

// Updated Help & Feedback Page with functionality
class HelpFeedbackPage extends StatelessWidget {
  const HelpFeedbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Help & Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              'Choose from the options below to get the help you need',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            
            _buildHelpOption(
              context: context,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              icon: Icons.question_answer_outlined,
              onTap: () => _navigateToPage(context, FAQsPage()),
              screenWidth: screenWidth,
            ),
            
            _buildHelpOption(
              context: context,
              title: 'Report a Problem',
              subtitle: 'Let us know if something isn\'t working',
              icon: Icons.error_outline,
              onTap: () => _openGmailCompose(context, 'Problem Report - HeyWork App'),
              screenWidth: screenWidth,
            ),
            
            _buildHelpOption(
              context: context,
              title: 'Send Feedback',
              subtitle: 'Help us improve our app',
              icon: Icons.thumbs_up_down_outlined,
              onTap: () => _openGmailCompose(context, 'Feedback - HeyWork App'),
              screenWidth: screenWidth,
            ),
            
            _buildHelpOption(
              context: context,
              title: 'Account Deletion Request',
              subtitle: 'Request for account deletion',
              icon: Icons.delete_forever_outlined,
              onTap: () => _launchURL(context, 'https://www.heywork.in/Data-Delete-Request'),
              screenWidth: screenWidth,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open. Please contact help.heywork@gmail.com directly.'),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _openGmailCompose(BuildContext context, String subject) async {
    try {
      // First try to open Gmail app directly
      String gmailAppUrl = "googlegmail://co?to=help.heywork@gmail.com&subject=${Uri.encodeComponent(subject)}";
      final Uri gmailUri = Uri.parse(gmailAppUrl);
      
      if (await canLaunchUrl(gmailUri)) {
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
        _showSuccessMessage(context, "Opening Gmail app...");
        return;
      }
    } catch (e) {
      print('Gmail app not available: $e');
    }
    
    try {
      // Second try: Use mailto with Gmail preference
      String mailtoUrl = "mailto:help.heywork@gmail.com?subject=${Uri.encodeComponent(subject)}";
      final Uri mailtoUri = Uri.parse(mailtoUrl);
      
      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri, mode: LaunchMode.externalApplication);
        _showSuccessMessage(context, "Opening email app...");
        return;
      }
    } catch (e) {
      print('Mailto failed: $e');
    }
    
    try {
      // Third try: Gmail web interface as fallback
      String gmailWebUrl = "https://mail.google.com/mail/?view=cm&to=help.heywork@gmail.com&su=${Uri.encodeComponent(subject)}";
      final Uri webUri = Uri.parse(gmailWebUrl);
      
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        _showSuccessMessage(context, "Opening Gmail in browser...");
        return;
      }
    } catch (e) {
      print('Gmail web failed: $e');
    }
    
    // If all methods fail
    _showErrorMessage(context);
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Color(0xFFFF0033FF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to open email app',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text('Please email us manually at: help.heywork@gmail.com'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Copy Email',
          textColor: Colors.white,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: 'help.heywork@gmail.com'));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email copied to clipboard!'),
                backgroundColor: Colors.green.shade600,
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHelpOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDestructive 
                        ? Colors.red.shade50 
                        : Color(0xFF0033FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive 
                        ? Colors.red.shade600 
                        : Color(0xFF0033FF),
                    size: screenWidth * 0.06,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: screenWidth * 0.042,
                          fontWeight: FontWeight.w600,
                          color: isDestructive 
                              ? Colors.red.shade600 
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: screenWidth * 0.04,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

