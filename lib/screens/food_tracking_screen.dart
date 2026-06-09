import 'package:flutter/material.dart';
import '../widgets.dart';

class FoodTrackingScreen extends StatelessWidget {
  const FoodTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Tracking')),
      body: ListView(
        children: const [
          // ── Log food ──────────────────────────────────────────
          SectionHeader('Log Food'),
          PlaceholderCard(
            icon: Icons.edit_note,
            title: 'Manual Food Entry',
            subtitle: 'Placeholder – search & log meals manually',
          ),
          PlaceholderCard(
            icon: Icons.qr_code_scanner,
            title: 'Barcode Scanner',
            subtitle: 'Placeholder – scan packaged food labels',
          ),
          PlaceholderCard(
            icon: Icons.camera_alt_outlined,
            title: 'Photo Recognition',
            subtitle: 'Placeholder – identify food from a photo',
          ),

          // ── Summary ───────────────────────────────────────────
          SectionHeader('Today\'s Nutrition'),
          PlaceholderCard(
            icon: Icons.pie_chart_outline,
            title: 'Nutrition Summary',
            subtitle: 'Placeholder – calories, carbs, fat, protein breakdown',
          ),
          PlaceholderCard(
            icon: Icons.water_drop_outlined,
            title: 'Water Intake',
            subtitle: 'Placeholder – daily hydration tracker',
          ),

          // ── History ───────────────────────────────────────────
          SectionHeader('History'),
          PlaceholderCard(
            icon: Icons.history,
            title: 'Meal History',
            subtitle: 'Placeholder – past meals & patterns',
          ),

          SizedBox(height: 24),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open quick log bottom sheet
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Food'),
      ),
    );
  }
}
