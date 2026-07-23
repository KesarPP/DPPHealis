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
              question: 'How is my IDRS score calculated?',
              answer: 'Your IDRS score is calculated based on your age, waist circumference, physical activity, and family history of diabetes.',
            ),
            _buildFaqItem(
              question: 'Can I sync with my smartwatch?',
              answer: 'Yes! We support syncing with Health Connect and Apple Health. You can enable this in your profile settings.',
            ),
            _buildFaqItem(
              question: 'When is the endline assessment?',
              answer: 'The endline assessment will unlock at the final week of your program.',
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
