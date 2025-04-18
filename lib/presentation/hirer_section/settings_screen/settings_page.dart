import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size to calculate responsive sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive values without using ScreenUtil
    double horizontalPadding = screenWidth * 0.04; // approximately 16.w
    double verticalPadding = screenHeight * 0.02; // approximately 16.h
    double standardSpacing = screenHeight * 0.02; // approximately 16.h
    double smallSpacing = screenHeight * 0.01; // approximately 8.h
    double borderRadius = 12.0; // fixed radius without .r
    double iconSize = screenWidth * 0.06; // approximately 24.sp but responsive
    double titleFontSize = screenWidth * 0.08; // approximately 32.sp
    double normalFontSize = screenWidth * 0.04; // approximately 16.sp
    double smallFontSize = screenWidth * 0.035; // approximately 14.sp

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              GestureDetector(
                onTap: () {
                  // Navigate back
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.close,
                  size: iconSize,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: standardSpacing),
              
              // Settings title
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: standardSpacing * 1.5),
              
              // Settings options
              SettingsOptionsList(
                horizontalPadding: horizontalPadding,
                verticalPadding: verticalPadding,
                standardSpacing: standardSpacing,
                smallSpacing: smallSpacing,
                borderRadius: borderRadius,
                iconSize: iconSize,
                normalFontSize: normalFontSize,
                smallFontSize: smallFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsOptionsList extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final double standardSpacing;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;
  final double smallFontSize;

  const SettingsOptionsList({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.standardSpacing,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
    required this.smallFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First group
        SettingsOption(
          icon: Icons.person_outline_rounded,
          title: "Personal info",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => navigateToPage(context, PersonalInfoPage(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            standardSpacing: standardSpacing,
            smallSpacing: smallSpacing,
            borderRadius: borderRadius,
            iconSize: iconSize,
            normalFontSize: normalFontSize,
            smallFontSize: smallFontSize,
          )),
        ),
        
        SettingsOption(
          icon: Icons.shield_outlined,
          title: "Privacy and security",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => navigateToPage(context, PrivacySecurityPage(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            standardSpacing: standardSpacing,
            smallSpacing: smallSpacing,
            borderRadius: borderRadius,
            iconSize: iconSize,
            normalFontSize: normalFontSize,
            smallFontSize: smallFontSize,
          )),
        ),
        
        SettingsOption(
          icon: Icons.description_outlined,
          title: "Raise BBPS dispute",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => navigateToPage(context, RaiseDisputePage(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            standardSpacing: standardSpacing,
            smallSpacing: smallSpacing,
            borderRadius: borderRadius,
            iconSize: iconSize,
            normalFontSize: normalFontSize,
            smallFontSize: smallFontSize,
          )),
        ),
        
        // Divider
        Padding(
          padding: EdgeInsets.symmetric(vertical: standardSpacing),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),
        ),
        
        // Second group
        SettingsOption(
          icon: Icons.help_outline_rounded,
          title: "Help & feedback",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => navigateToPage(context, HelpFeedbackPage(
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            standardSpacing: standardSpacing,
            smallSpacing: smallSpacing,
            borderRadius: borderRadius,
            iconSize: iconSize,
            normalFontSize: normalFontSize,
            smallFontSize: smallFontSize,
          )),
        ),
        
        SettingsOption(
          icon: Icons.logout,
          title: "Log out",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => _showLogoutDialog(context, normalFontSize, smallFontSize),
        ),
        
        SettingsOption(
          icon: Icons.power_settings_new_rounded,
          title: "Close account",
          iconColor: Colors.blue,
          horizontalPadding: horizontalPadding,
          verticalPadding: verticalPadding,
          smallSpacing: smallSpacing,
          borderRadius: borderRadius,
          iconSize: iconSize,
          normalFontSize: normalFontSize,
          onTap: () => _showCloseAccountDialog(context, normalFontSize, smallFontSize),
        ),
      ],
    );
  }
  
  void navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  
  void _showLogoutDialog(BuildContext context, double normalFontSize, double smallFontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Log Out",
            style: TextStyle(
              fontSize: normalFontSize * 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontSize: normalFontSize,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: normalFontSize,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: normalFontSize,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showCloseAccountDialog(BuildContext context, double normalFontSize, double smallFontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Close Account",
            style: TextStyle(
              fontSize: normalFontSize * 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to close your account? This action cannot be undone.",
            style: TextStyle(
              fontSize: normalFontSize,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: normalFontSize,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account closed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                "Close Account",
                style: TextStyle(
                  fontSize: normalFontSize,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final double horizontalPadding;
  final double verticalPadding;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;

  const SettingsOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
        margin: EdgeInsets.only(bottom: smallSpacing),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(horizontalPadding * 0.125),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            ),
            SizedBox(width: horizontalPadding),
            Text(
              title,
              style: TextStyle(
                fontSize: normalFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy Pages with responsive parameters
class PersonalInfoPage extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final double standardSpacing;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;
  final double smallFontSize;

  const PersonalInfoPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.standardSpacing,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
    required this.smallFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Information',
              style: TextStyle(
                fontSize: normalFontSize * 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: standardSpacing * 1.5),
            ProfileInfoItem(
              label: 'Name', 
              value: 'John Doe',
              smallFontSize: smallFontSize,
              normalFontSize: normalFontSize,
              smallSpacing: smallSpacing,
            ),
            ProfileInfoItem(
              label: 'Email', 
              value: 'john.doe@example.com',
              smallFontSize: smallFontSize,
              normalFontSize: normalFontSize,
              smallSpacing: smallSpacing,
            ),
            ProfileInfoItem(
              label: 'Phone', 
              value: '+91 9876543210',
              smallFontSize: smallFontSize,
              normalFontSize: normalFontSize,
              smallSpacing: smallSpacing,
            ),
            ProfileInfoItem(
              label: 'Date of Birth', 
              value: '01 Jan 1990',
              smallFontSize: smallFontSize,
              normalFontSize: normalFontSize,
              smallSpacing: smallSpacing,
            ),
            SizedBox(height: standardSpacing * 1.5),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: smallSpacing * 1.5),
                minimumSize: Size(double.infinity, verticalPadding * 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final double smallFontSize;
  final double normalFontSize;
  final double smallSpacing;

  const ProfileInfoItem({
    Key? key,
    required this.label,
    required this.value,
    required this.smallFontSize,
    required this.normalFontSize,
    required this.smallSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: smallSpacing * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: smallFontSize,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: smallSpacing / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: normalFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: smallSpacing),
          const Divider(),
        ],
      ),
    );
  }
}

class PrivacySecurityPage extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final double standardSpacing;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;
  final double smallFontSize;

  const PrivacySecurityPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.standardSpacing,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
    required this.smallFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy and Security'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: normalFontSize * 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: standardSpacing * 1.5),
            _buildSecurityOption(
              'Change Password',
              'Update your password regularly',
              Icons.lock_outline,
            ),
            _buildSecurityOption(
              'Two-Factor Authentication',
              'Add an extra layer of security',
              Icons.security,
            ),
            _buildSecurityOption(
              'Login Activity',
              'Check your recent login sessions',
              Icons.access_time,
            ),
            _buildSecurityOption(
              'Privacy Settings',
              'Manage who can see your information',
              Icons.visibility,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption(String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: smallSpacing * 2),
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: iconSize),
          SizedBox(width: horizontalPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: normalFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: smallSpacing / 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: smallFontSize,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: iconSize * 0.67, color: Colors.grey),
        ],
      ),
    );
  }
}

class RaiseDisputePage extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final double standardSpacing;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;
  final double smallFontSize;

  const RaiseDisputePage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.standardSpacing,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
    required this.smallFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raise BBPS Dispute'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raise a Dispute',
              style: TextStyle(
                fontSize: normalFontSize * 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: standardSpacing),
            Text(
              'Please fill in the details to raise a dispute for your BBPS transaction',
              style: TextStyle(
                fontSize: smallFontSize,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: standardSpacing * 1.5),
            _buildTextField('Transaction ID'),
            SizedBox(height: standardSpacing),
            _buildTextField('Biller Name'),
            SizedBox(height: standardSpacing),
            _buildTextField('Issue Description', maxLines: 4),
            SizedBox(height: standardSpacing * 1.5),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dispute submitted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: smallSpacing * 1.5),
                minimumSize: Size(double.infinity, verticalPadding * 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: const Text('Submit Dispute'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: smallFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: smallSpacing),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.67),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.67),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius * 0.67),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.all(horizontalPadding),
          ),
        ),
      ],
    );
  }
}

class HelpFeedbackPage extends StatelessWidget {
  final double horizontalPadding;
  final double verticalPadding;
  final double standardSpacing;
  final double smallSpacing;
  final double borderRadius;
  final double iconSize;
  final double normalFontSize;
  final double smallFontSize;

  const HelpFeedbackPage({
    Key? key,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.standardSpacing,
    required this.smallSpacing,
    required this.borderRadius,
    required this.iconSize,
    required this.normalFontSize,
    required this.smallFontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: normalFontSize * 1.25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: standardSpacing * 1.5),
            _buildHelpOption(
              'FAQs',
              'Find answers to common questions',
              Icons.question_answer_outlined,
            ),
            _buildHelpOption(
              'Contact Support',
              'Get in touch with our customer service team',
              Icons.support_agent_outlined,
            ),
            _buildHelpOption(
              'Report a Problem',
              'Let us know if something isn\'t working',
              Icons.error_outline,
            ),
            _buildHelpOption(
              'Send Feedback',
              'Help us improve our app',
              Icons.thumbs_up_down_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, String subtitle, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: smallSpacing * 2),
      padding: EdgeInsets.all(horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: iconSize),
          SizedBox(width: horizontalPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: normalFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: smallSpacing / 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: smallFontSize,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: iconSize * 0.67, color: Colors.grey),
        ],
      ),
    );
  }
}