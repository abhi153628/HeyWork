// Professional FAQs Page
import 'package:flutter/material.dart';

class FAQsPage extends StatefulWidget {
  const FAQsPage({Key? key}) : super(key: key);

  @override
  State<FAQsPage> createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: "How do I delete my HeyWork account?",
      answer: "You can request account and data deletion by filling out the form in the help and feedback section.",
    ),
    FAQItem(
      question: "Do I have to pay anything to use HeyWork?",
      answer: "For now, HeyWork is completely free for both hirers and workers. You can post jobs, apply, and connect without any charges. In the future, we may introduce small fees for premium features.",
    ),
    FAQItem(
      question: "How do I know if a worker or hirer is genuine?",
      answer: "HeyWork shows workers' job history and ratings from past hirers. We encourage both parties to verify details and communicate clearly before starting work.",
    ),
    FAQItem(
      question: "What if I didn't get paid after completing a job?",
      answer: "HeyWork only connects people—we don't handle payments. If a dispute occurs, you can report the hirer via the app and we'll take necessary action, but we can't guarantee payment.",
    ),
    FAQItem(
      question: "Why is my location needed?",
      answer: "We use your location to show jobs (for workers) or workers (for hirers) that are nearby. This helps keep hiring fast, local, and relevant.",
    ),
    FAQItem(
      question: "Who can use HeyWork?",
      answer: "HeyWork is open to anyone aged 18 and above. It's designed for businesses looking to hire staff and individuals seeking part-time or full-time blue-collar jobs.",
    ),
    FAQItem(
      question: "Who can I contact for support?",
      answer: "You can reach our support team at help.heywork@gmail.com or call +91 9778756394. We're here to help with any questions or issues you may have while using HeyWork.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
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
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0033FF).withOpacity(0.1),
                    Color(0xFF0033FF).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF0033FF).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF0033FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.help_center_outlined,
                      color: Color(0xFF0033FF),
                      size: screenWidth * 0.08,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find answers to common questions below or contact our support team.',
                          style: TextStyle(
                            fontSize: screenWidth * 0.032,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            Text(
              'Common Questions',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            SizedBox(height: screenWidth * 0.04),
            
            ...faqs.map((faq) => _buildFAQItem(faq, screenWidth)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq, double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenWidth * 0.02,
          ),
          childrenPadding: EdgeInsets.only(
            left: screenWidth * 0.04,
            right: screenWidth * 0.04,
            bottom: screenWidth * 0.04,
          ),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF0033FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.help_outline,
              color: Color(0xFF0033FF),
              size: screenWidth * 0.05,
            ),
          ),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: screenWidth * 0.038,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Icon(
            faq.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Color(0xFF0033FF),
            size: screenWidth * 0.06,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              faq.isExpanded = expanded;
            });
          },
          children: [
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}