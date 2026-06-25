import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../screens/idrs_score_card_screen.dart';
import '../screens/gpaq_score_card_screen.dart';
import '../screens/weigh_in_screen.dart';
import '../screens/food_analysis_screen.dart';
import '../screens/handouts_screen.dart';
import '../data/handouts_data.dart';

class UserSideDrawer extends StatelessWidget {
  const UserSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: GelatoTheme.bg,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  const Icon(Icons.person, color: GelatoTheme.purpleDark, size: 32),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'User Menu',
                      style: TextStyle(
                        fontSize: 20,
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
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
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
                  _buildDrawerItem(
                    context,
                    icon: Icons.library_books,
                    title: 'Handouts Library',
                    bgColor: GelatoTheme.purple,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HandoutsScreen(
                            title: 'Handouts Library',
                            handouts: ndppHandouts,
                          ),
                        ),
                      );
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

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color bgColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16.0, right: 16.0),
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
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: GelatoTheme.textDark,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
