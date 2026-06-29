import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';

class TastePreferencesScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TastePreferencesScreen({super.key, required this.onComplete});

  @override
  State<TastePreferencesScreen> createState() => _TastePreferencesScreenState();
}

class _TastePreferencesScreenState extends State<TastePreferencesScreen> {
  final List<String> _tastes = [
    'Spicy Food',
    'Western Food (burgers, pizza, fries)',
    'Ginger taste',
    'Sweets (including chocolate)',
    'Sour Taste (e.g., tamarind, lime juice)',
    'Garlic taste',
    'Ghee/ Butter/ Cream (malai)',
    'Turmeric taste',
    'Bitter taste (e.g., bitter gourd)'
  ];

  final Map<String, int> _rankings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GelatoTheme.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Taste Preferences',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Compared to other people you know, how would you rank your desire for?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1 = Lowest, 5 = Most',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GelatoTheme.textLight,
                ),
              ),
              const SizedBox(height: 20),
              
              ..._tastes.map((taste) => _buildTasteRow(taste)),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GelatoTheme.purple,
                    foregroundColor: GelatoTheme.purpleDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Colors.black, width: 2.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Complete Interview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasteRow(String taste) {
    int currentRank = _rankings[taste] ?? 3;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taste,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              int rank = index + 1;
              bool isSelected = currentRank == rank;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rankings[taste] = rank;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? GelatoTheme.blue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? GelatoTheme.blueDark : Colors.black26,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    rank.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? GelatoTheme.blueDark : GelatoTheme.textLight,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
