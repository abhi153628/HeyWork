import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                  size: 28.sp,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Settings title
              Text(
                "Settings",
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Settings options
              SettingsOptionsList(),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsOptionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First group
        SettingsOption(
          icon: Icons.person_outline_rounded,
          title: "Personal info",
          iconColor: Colors.blue,
          onTap: () => navigateToPage(context, PersonalInfoPage()),
        ),
        
        SettingsOption(
          icon: Icons.shield_outlined,
          title: "Privacy and security",
          iconColor: Colors.blue,
          onTap: () => navigateToPage(context, PrivacySecurityPage()),
        ),
        
        SettingsOption(
          icon: Icons.description_outlined,
          title: "Raise BBPS dispute",
          iconColor: Colors.blue,
          onTap: () => navigateToPage(context, RaiseDisputePage()),
        ),
        
        // Divider
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Divider(
            height: 1.h,
            thickness: 1.h,
            color: Colors.grey.shade200,
          ),
        ),
        
        // Second group
        SettingsOption(
          icon: Icons.help_outline_rounded,
          title: "Help & feedback",
          iconColor: Colors.blue,
          onTap: () => navigateToPage(context, HelpFeedbackPage()),
        ),
        
        SettingsOption(
          icon: Icons.logout,
          title: "Log out",
          iconColor: Colors.blue,
          onTap: () => _showLogoutDialog(context),
        ),
        
        SettingsOption(
          icon: Icons.power_settings_new_rounded,
          title: "Close account",
          iconColor: Colors.blue,
          onTap: () => _showCloseAccountDialog(context),
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

  
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Log Out",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontSize: 16.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logged out successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16.sp,
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
  
  void _showCloseAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Close Account",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to close your account? This action cannot be undone.",
            style: TextStyle(
              fontSize: 16.sp,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Account closed'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                "Close Account",
                style: TextStyle(
                  fontSize: 16.sp,
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

  const SettingsOption({
    Key? key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              child: Icon(
                icon,
                color: iconColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
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

// Dummy Pages
class PersonalInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Personal Information',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
            ProfileInfoItem(label: 'Name', value: 'John Doe'),
            ProfileInfoItem(label: 'Email', value: 'john.doe@example.com'),
            ProfileInfoItem(label: 'Phone', value: '+91 9876543210'),
            ProfileInfoItem(label: 'Date of Birth', value: '01 Jan 1990'),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {},
              child: Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
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

  const ProfileInfoItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Divider(),
        ],
      ),
    );
  }
}

class PrivacySecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy and Security'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Settings',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }
}

class RaiseDisputePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raise BBPS Dispute'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raise a Dispute',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Please fill in the details to raise a dispute for your BBPS transaction',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 24.h),
            _buildTextField('Transaction ID'),
            SizedBox(height: 16.h),
            _buildTextField('Biller Name'),
            SizedBox(height: 16.h),
            _buildTextField('Issue Description', maxLines: 4),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Dispute submitted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Submit Dispute'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
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
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.blue),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}

class HelpFeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Feedback'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help you?',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24.h),
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
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
        ],
      ),
    );
  }
}