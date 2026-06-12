import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GelatoTheme.textDark),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Insights & Trends',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 16),
            _buildMockGraphCard('Weekly Calorie Intake', GelatoTheme.blue),
            const SizedBox(height: 16),
            _buildMockGraphCard('Macronutrient Split', GelatoTheme.purple),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GelatoTheme.green,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Weekly Average',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1,850 kcal/day',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.greenDark,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroStat('Carbs', '180g'),
              _buildMacroStat('Protein', '110g'),
              _buildMacroStat('Fat', '65g'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMacroStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: GelatoTheme.textDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: GelatoTheme.textDark.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMockGraphCard(String title, Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: [
          BoxShadow(color: themeColor.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          // A simple mock bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildMockBar(80, themeColor),
              _buildMockBar(120, themeColor),
              _buildMockBar(90, themeColor),
              _buildMockBar(150, themeColor),
              _buildMockBar(100, themeColor),
              _buildMockBar(140, themeColor),
              _buildMockBar(60, themeColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) => 
              Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark.withValues(alpha: 0.5),
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBar(double height, Color color) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black87, width: 1.2),
      ),
    );
  }
}
