import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../screens/idrs_score_card_screen.dart';
import '../screens/gpaq_score_card_screen.dart';
import '../screens/weigh_in_screen.dart';
import '../screens/food_analysis_screen.dart';
import '../screens/handouts_screen.dart';
import '../data/handouts_data.dart';
import '../screens/trophy_collection_screen.dart';
import '../screens/faq_contact_screen.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class UserSideDrawer extends StatelessWidget {
  const UserSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 320,
      backgroundColor: GelatoTheme.bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const Icon(Icons.person, color: GelatoTheme.purpleDark, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'User Menu',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: GelatoTheme.textLight),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader('1. Baseline'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.assignment,
                    title: 'IDRS Score Card',
                    bgColor: GelatoTheme.pink,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IdrsScoreCardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Food Frequency (FFQ)',
                    bgColor: GelatoTheme.blue,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FoodAnalysisScreen()),
                      );
                    },
                  ),
                  
                  _buildSectionHeader('2. Weekly'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.directions_run,
                    title: 'GPAQ Score Card',
                    bgColor: GelatoTheme.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GpaqScoreCardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weekly Weigh-In',
                    bgColor: GelatoTheme.yellow,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WeighInScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSectionHeader('3. Endline'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.flag,
                    title: 'Endline Assessment',
                    bgColor: GelatoTheme.purple,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Endline assessment coming soon!')),
                      );
                    },
                  ),

                  _buildSectionHeader('4. Support'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'FAQs & Contact Us',
                    bgColor: GelatoTheme.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FaqContactScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSectionHeader('5. Account'),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    bgColor: const Color(0xFFE2E8F0),
                    onTap: () async {
                      Navigator.pop(context);
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 12.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: GelatoTheme.textLight,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color bgColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 16.0, right: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: GelatoTheme.cardRadius,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: GelatoTheme.cardRadius,
            border: GelatoTheme.cardBorder,
            boxShadow: GelatoTheme.cardShadow,
          ),
          child: ListTile(
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(icon, color: Colors.black, size: 18),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
