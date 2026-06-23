import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../screens/risk_assessment_result_screen.dart';
import '../screens/gpaq_results_screen.dart';
import '../screens/food_analysis_screen.dart';
import '../screens/handouts_screen.dart';
import '../data/handouts_data.dart';

class UserSideDrawer extends StatelessWidget {
  const UserSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
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
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RiskAssessmentResultScreen(
                            age: 45,
                            isMan: false,
                            waist: 85.0,
                            height: 65.0,
                            weight: 70.0,
                            parentDiabetic: 0,
                            siblingDiabetic: 0,
                            hasHighBP: 0,
                            prescribedBPMedication: 0,
                            exerciseLevel: 2,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.directions_run,
                    title: 'GPAQ Score Card',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GPAQResultsScreen(
                            workVigorous: false,
                            workVigorousDays: 0,
                            workVigorousMinutes: 0,
                            workModerate: false,
                            workModerateDays: 0,
                            workModerateMinutes: 0,
                            travel: false,
                            travelDays: 0,
                            travelMinutes: 0,
                            recVigorous: false,
                            recVigorousDays: 0,
                            recVigorousMinutes: 0,
                            recModerate: false,
                            recModerateDays: 0,
                            recModerateMinutes: 0,
                            sedentaryMinutes: 0,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.restaurant_menu,
                    title: 'Food Frequency Questionnaire (FFQ)',
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

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: GelatoTheme.purpleDark),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: GelatoTheme.textDark,
        ),
      ),
      onTap: onTap,
    );
  }
}
