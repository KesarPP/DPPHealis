import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class FaqContactScreen extends StatelessWidget {
  const FaqContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        title: const Text('FAQs & Contact', style: TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.w800)),
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: GelatoTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Us Section
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: Icons.email_rounded,
              title: 'Email',
              subtitle: 'dppapp@healis.org', // Assuming the user meant @ instead of . for the email
              color: GelatoTheme.blue,
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_rounded,
              title: 'Phone',
              subtitle: '+1 (800) 123-4567',
              color: GelatoTheme.green,
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.access_time_rounded,
              title: 'Support Hours',
              subtitle: 'Monday–Friday, 9:00 AM–5:00 PM',
              color: GelatoTheme.yellow,
            ),
            
            const SizedBox(height: 32),
            
            // FAQs Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              question: 'How do I log my meals?',
              answer: 'You can log your meals from the dashboard by tapping the "+" icon or going to the Food Frequency (FFQ) section.',
            ),
            _buildFaqItem(
              question: 'What does my Diabetes Risk Score mean?',
              answer: 'Your Diabetes Risk Score indicates your risk based on your age, waist circumference, physical activity, and family history of diabetes.',
            ),
            _buildFaqItem(
              question: 'Can I sync with my smartwatch?',
              answer: 'Yes! We support syncing with Health Connect and Apple Health. You can enable this in your profile settings.',
            ),
            _buildFaqItem(
              question: 'When do I complete the final assessment?',
              answer: 'The final assessment will unlock at the final week of your program.',
            ),
            _buildFaqItem(
              question: 'How do I reset my password?',
              answer: 'You can reset your password from the login screen by tapping "Forgot Password" and following the instructions sent to your email.',
            ),
            _buildFaqItem(
              question: 'Can I edit an incorrect entry?',
              answer: 'Yes, you can edit your recent entries from the dashboard by tapping on the entry and selecting the edit option.',
            ),
            _buildFaqItem(
              question: 'What happens if I miss a weekly assessment?',
              answer: 'Don\'t worry! You can complete missed assessments at any time from the assessment tab. We recommend catching up as soon as possible to stay on track.',
            ),
            _buildFaqItem(
              question: 'How do I report a technical problem?',
              answer: 'If you experience any technical issues, please contact our support team using the email or phone number listed above.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: GelatoTheme.cardRadius,
          border: GelatoTheme.cardBorder,
          boxShadow: GelatoTheme.cardShadow,
        ),
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              question,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
            ),
            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            children: [
              Text(
                answer,
                style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500, color: GelatoTheme.textLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
