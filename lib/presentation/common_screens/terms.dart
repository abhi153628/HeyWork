import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hey_work/presentation/hirer_section/signup_screen/widgets/responsive_utils.dart';


class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key: key);

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
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
          "Terms and Conditions",
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
      body: CustomScrollView(
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
                  _buildSectionTitle("1. Introduction"),
                  _buildParagraph(
                    "Welcome to HeyWork ('we', 'our', 'us'). By accessing or using our mobile application, website, and services, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not access our services."
                  ),
                  
                  // Definitions Section
                  _buildSectionTitle("2. Definitions"),
                  _buildParagraph(
                    "'Application' refers to HeyWork mobile application and website."
                  ),
                  _buildParagraph(
                    "'User', 'You', and 'Your' refers to individuals who access or use our services."
                  ),
                  _buildParagraph(
                    "'Worker' refers to individuals who offer services through our platform."
                  ),
                  _buildParagraph(
                    "'Hirer' refers to individuals or businesses seeking services through our platform."
                  ),
                  _buildParagraph(
                    "'Services' refers to the functionality, features, and offerings provided through our application."
                  ),
                  
                  // User Accounts
                  _buildSectionTitle("3. User Accounts"),
                  _buildParagraph(
                    "You must register for an account to access our services. You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account."
                  ),
                  _buildParagraph(
                    "You must provide accurate, current, and complete information during the registration process and update such information to keep it accurate, current, and complete."
                  ),
                  _buildParagraph(
                    "We reserve the right to suspend or terminate your account if any information provided during registration or thereafter proves to be inaccurate, not current, or incomplete."
                  ),
                  
                  // Services
                  _buildSectionTitle("4. Services"),
                  _buildParagraph(
                    "HeyWork provides a platform that connects workers with hirers for various services. We do not guarantee the quality, safety, or legality of services offered by workers."
                  ),
                  _buildParagraph(
                    "We are not responsible for the actions or inactions of users on our platform. All agreements between workers and hirers are solely between those parties."
                  ),
                  _buildParagraph(
                    "We reserve the right to modify, suspend, or discontinue any part of our services at any time without prior notice."
                  ),
                  
                  // User Responsibilities
                  _buildSectionTitle("5. User Responsibilities"),
                  _buildParagraph(
                    "You agree not to use our services for any illegal purposes or in violation of any local, state, national, or international law."
                  ),
                  _buildParagraph(
                    "You shall not transmit any content that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable."
                  ),
                  _buildParagraph(
                    "You shall not impersonate any person or entity or falsely state or otherwise misrepresent your affiliation with a person or entity."
                  ),
                  _buildParagraph(
                    "You shall not interfere with or disrupt the services or servers or networks connected to the services."
                  ),
                  
                  // Payment Terms
                  _buildSectionTitle("6. Payment Terms"),
                  _buildParagraph(
                    "All payments made through our platform are subject to our payment processing terms. We may charge service fees for transactions completed through our platform."
                  ),
                  _buildParagraph(
                    "Workers are responsible for paying all applicable taxes on earnings received through our platform. Hirers are responsible for paying the agreed-upon amount for services received."
                  ),
                  _buildParagraph(
                    "We reserve the right to withhold payment in cases of suspected fraud, violations of our terms, or legal requirements."
                  ),
                  
                  // Disclaimers
                  _buildSectionTitle("7. Disclaimers"),
                  _buildParagraph(
                    "OUR SERVICES ARE PROVIDED 'AS IS' AND 'AS AVAILABLE' WITHOUT ANY WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT."
                  ),
                  _buildParagraph(
                    "We do not guarantee that our services will be uninterrupted, timely, secure, or error-free. We do not guarantee the quality, accuracy, reliability, or availability of our services."
                  ),
                  
                  // Limitation of Liability
                  _buildSectionTitle("8. Limitation of Liability"),
                  _buildParagraph(
                    "TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL HEYWORK, ITS DIRECTORS, EMPLOYEES, PARTNERS, AGENTS, SUPPLIERS, OR AFFILIATES BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING WITHOUT LIMITATION, LOSS OF PROFITS, DATA, USE, GOODWILL, OR OTHER INTANGIBLE LOSSES, RESULTING FROM YOUR ACCESS TO OR USE OF OR INABILITY TO ACCESS OR USE THE SERVICES."
                  ),
                  
                  // Changes to Terms
                  _buildSectionTitle("9. Changes to Terms"),
                  _buildParagraph(
                    "We reserve the right to modify these Terms at any time. We will provide notice of significant changes by updating the 'Last Updated' date at the top of these Terms. Your continued use of our services following the posting of revised Terms means that you accept and agree to the changes."
                  ),
                  
                  // Governing Law
                  _buildSectionTitle("10. Governing Law"),
                  _buildParagraph(
                    "These Terms shall be governed by and construed in accordance with the laws of India. Any disputes arising under these Terms shall be subject to the exclusive jurisdiction of the courts in India."
                  ),
                  
                  // Contact Information
                  _buildSectionTitle("11. Contact Information"),
                  _buildParagraph(
                    "If you have any questions about these Terms, please contact us at support@heywork.com"
                  ),
                  
                  SizedBox(height: _responsive.getHeight(40)),
                ],
              ),
            ),
          ),
        ],
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
}