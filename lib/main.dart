import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/food_tracking_screen.dart';
import 'screens/activity_fitness_screen.dart';
import 'screens/sessions_screen.dart';
import 'screens/profile_screen.dart';
import 'data/gelato_theme.dart';

void main() {
  runApp(const DPPApp());
}

class DPPApp extends StatelessWidget {
  const DPPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes Prevention Program',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Main shell with Bottom Navigation ───────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    FoodTrackingScreen(),
    ActivityFitnessScreen(),
    SessionsScreen(),
    ProfileScreen(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_outlined),
      selectedIcon: Icon(Icons.restaurant),
      label: 'Food',
    ),
    NavigationDestination(
      icon: Icon(Icons.directions_run_outlined),
      selectedIcon: Icon(Icons.directions_run),
      label: 'Activity',
    ),
    NavigationDestination(
      icon: Icon(Icons.play_circle_outline),
      selectedIcon: Icon(Icons.play_circle),
      label: 'Sessions',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    Color activeTextColor;
    switch (_selectedIndex) {
      case 0:
        indicatorColor = GelatoTheme.pink;
        activeTextColor = GelatoTheme.pinkDark;
        break;
      case 1:
        indicatorColor = GelatoTheme.green;
        activeTextColor = GelatoTheme.greenDark;
        break;
      case 2:
        indicatorColor = GelatoTheme.orange;
        activeTextColor = GelatoTheme.orangeDark;
        break;
      case 3:
        indicatorColor = GelatoTheme.purple;
        activeTextColor = GelatoTheme.purpleDark;
        break;
      case 4:
        indicatorColor = GelatoTheme.blue;
        activeTextColor = GelatoTheme.blueDark;
        break;
      default:
        indicatorColor = Colors.grey[300]!;
        activeTextColor = Colors.black;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      floatingActionButton: _selectedIndex < 4
          ? Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: FloatingActionButton.extended(
                heroTag: null,
                onPressed: () {},
                backgroundColor: const Color(0xFFDCCCEC),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFBCA6D7), width: 1.5),
                ),
                icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF4A1E63), size: 18),
                label: const Text(
                  'Ask AI Coach',
                  style: TextStyle(
                    color: Color(0xFF4A1E63),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: indicatorColor,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: activeTextColor, size: 24);
            }
            return const IconThemeData(color: Color(0xFF64748B), size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(
                fontWeight: FontWeight.w900,
                color: activeTextColor,
                fontSize: 12,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: _destinations,
        ),
      ),
    );
  }
}
