import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heywork/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';


class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  // Responsive util instance
  final ResponsiveUtil _responsive = ResponsiveUtil();
  
  @override
  void initState() {
    super.initState();
    // Set status bar to match app theme
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive util
    _responsive.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.roboto(
            fontSize: _responsive.getFontSize(18),
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0033FF),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: _responsive.getWidth(20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _responsive.getWidth(24),
                  vertical: _responsive.getHeight(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Last Updated
                    Text(
                      "Last Updated: May 15, 2025",
                      style: GoogleFonts.roboto(
                        fontSize: _responsive.getFontSize(14),
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    SizedBox(height: _responsive.getHeight(24)),
                    
                    // Introduction
                    _buildParagraph(
                      "HeyWork ('we', 'our', or 'us') is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and website (collectively, the 'Service')."
                    ),
                    _buildParagraph(
                      "Please read this Privacy Policy carefully. By accessing or using our Service, you acknowledge that you have read, understood, and agree to be bound by all the terms of this Privacy Policy."
                    ),
                    
                    // Information We Collect
                    _buildSectionTitle("1. Information We Collect"),
                    _buildSubsectionTitle("Personal Information"),
                    _buildParagraph(
                      "When you register for an account, we may collect personally identifiable information, such as:"
                    ),
                    _buildBulletPoint("Full name"),
                    _buildBulletPoint("Email address"),
                    _buildBulletPoint("Phone number"),
                    _buildBulletPoint("Profile picture"),
                    _buildBulletPoint("Location information"),
                    _buildBulletPoint("Business information (for hirers)"),
                    _buildBulletPoint("Skills and services offered (for workers)"),
                    
                    _buildSubsectionTitle("Usage Information"),
                    _buildParagraph(
                      "We may also collect information about how you access and use our Service, such as:"
                    ),
                    _buildBulletPoint("Device information (type, model, operating system)"),
                    _buildBulletPoint("IP address and browser type"),
                    _buildBulletPoint("Usage patterns and preferences"),
                    _buildBulletPoint("Communication data with other users"),
                    _buildBulletPoint("Transaction information"),
                    
                    // How We Use Your Information
                    _buildSectionTitle("2. How We Use Your Information"),
                    _buildParagraph(
                      "We may use the information we collect for various purposes, including to:"
                    ),
                    _buildBulletPoint("Create and manage your account"),
                    _buildBulletPoint("Provide and maintain our Service"),
                    _buildBulletPoint("Connect workers with hirers"),
                    _buildBulletPoint("Process transactions and send related information"),
                    _buildBulletPoint("Send you service-related notifications"),
                    _buildBulletPoint("Respond to your comments, questions, and requests"),
                    _buildBulletPoint("Monitor usage patterns and perform analysis"),
                    _buildBulletPoint("Enhance and improve our Service"),
                    _buildBulletPoint("Protect against unauthorized access and legal liability"),
                    
                    // Sharing Your Information
                    _buildSectionTitle("3. Sharing Your Information"),
                    _buildParagraph(
                      "We may share your information in the following situations:"
                    ),
                    _buildBulletPoint("With other users as necessary for the functioning of our Service (e.g., sharing worker profiles with hirers)"),
                    _buildBulletPoint("With service providers who perform services on our behalf"),
                    _buildBulletPoint("To comply with legal obligations"),
                    _buildBulletPoint("To protect our rights, privacy, safety, or property"),
                    _buildBulletPoint("In connection with a business transaction such as a merger or acquisition"),
                    _buildBulletPoint("With your consent or at your direction"),
                    
                    // Data Security
                    _buildSectionTitle("4. Data Security"),
                    _buildParagraph(
                      "We implement appropriate technical and organizational measures to protect the security of your personal information. However, please be aware that no method of transmission over the Internet or electronic storage is 100% secure."
                    ),
                    _buildParagraph(
                      "While we strive to use commercially acceptable means to protect your personal information, we cannot guarantee its absolute security. You are responsible for maintaining the confidentiality of your account credentials."
                    ),
                    
                    // Data Retention
                    _buildSectionTitle("5. Data Retention"),
                    _buildParagraph(
                      "We retain your personal information for as long as necessary to fulfill the purposes described in this Privacy Policy, unless a longer retention period is required or permitted by law."
                    ),
                    _buildParagraph(
                      "When we no longer need to process your personal information, we will delete or anonymize it in a secure manner."
                    ),
                    
                    // Children's Privacy
                    _buildSectionTitle("6. Children's Privacy"),
                    _buildParagraph(
                      "Our Service is not intended for individuals under the age of 18. We do not knowingly collect personal information from children. If you are a parent or guardian and you believe your child has provided us with personal information, please contact us."
                    ),
                    
                    // Your Rights
                    _buildSectionTitle("7. Your Rights"),
                    _buildParagraph(
                      "Depending on your location, you may have the following rights regarding your personal information:"
                    ),
                    _buildBulletPoint("Access the personal information we have about you"),
                    _buildBulletPoint("Correct inaccurate or incomplete information"),
                    _buildBulletPoint("Delete your personal information"),
                    _buildBulletPoint("Restrict or object to our processing of your information"),
                    _buildBulletPoint("Data portability (obtaining a copy of your data)"),
                    _buildBulletPoint("Withdraw consent where processing is based on consent"),
                    
                    _buildParagraph(
                      "To exercise these rights, please contact us using the information provided below."
                    ),
                    
                    // Third-Party Links
                    _buildSectionTitle("8. Third-Party Links"),
                    _buildParagraph(
                      "Our Service may contain links to third-party websites and services that are not owned or controlled by us. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services."
                    ),
                    
                    // Changes to Privacy Policy
                    _buildSectionTitle("9. Changes to Privacy Policy"),
                    _buildParagraph(
                      "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the 'Last Updated' date. You are advised to review this Privacy Policy periodically for any changes."
                    ),
                    
                    // Contact Us
                    _buildSectionTitle("10. Contact Us"),
                    _buildParagraph(
                      "If you have any questions about this Privacy Policy, please contact us at:"
                    ),
                    _buildParagraph(
                      "Email: privacy@heywork.com\nAddress: HeyWork Technologies, 123 Main Street, Bangalore 560001, Karnataka, India"
                    ),
                    
                    SizedBox(height: _responsive.getHeight(40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: _responsive.getHeight(12),
        top: _responsive.getHeight(24),
      ),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: _responsive.getFontSize(18),
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: _responsive.getHeight(8),
        top: _responsive.getHeight(16),
      ),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: _responsive.getFontSize(16),
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: _responsive.getHeight(12)),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: _responsive.getFontSize(15),
          color: Colors.black87,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(
        left: _responsive.getWidth(16),
        bottom: _responsive.getHeight(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•",
            style: GoogleFonts.roboto(
              fontSize: _responsive.getFontSize(15),
              color: const Color(0xFF0033FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: _responsive.getWidth(8)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: _responsive.getFontSize(15),
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}