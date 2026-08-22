import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  void initState() {
    super.initState();
    _loadCache();
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('taste_preferences_cache');
      if (cached != null) {
        final Map<String, dynamic> map = json.decode(cached);
        if (mounted) {
          setState(() {
            map.forEach((key, value) {
              if (value is int) {
                _rankings[key] = value;
              }
            });
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading taste preferences cache: $e');
    }
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('taste_preferences_cache', json.encode(_rankings));
    } catch (_) {}
  }

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
                'Select your preference for each taste category.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1 = Least prefered, 5 = Most prefered',
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
    
    String emoji = '🍽️';
    if (taste.contains('Spicy')) emoji = '🌶️';
    else if (taste.contains('Western')) emoji = '🍔';
    else if (taste.contains('Ginger')) emoji = '🫚';
    else if (taste.contains('Sweet')) emoji = '🍫';
    else if (taste.contains('Sour')) emoji = '🍋';
    else if (taste.contains('Garlic')) emoji = '🧄';
    else if (taste.contains('Ghee')) emoji = '🧈';
    else if (taste.contains('Turmeric')) emoji = '🏵️';
    else if (taste.contains('Bitter')) emoji = '🌿';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: GelatoTheme.bg,
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  taste,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: GelatoTheme.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (index) {
              int rank = index + 1;
              bool isSelected = currentRank == rank;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rankings[taste] = rank;
                  });
                  _saveCache();
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 48 : 42,
                      height: isSelected ? 48 : 42,
                      decoration: BoxDecoration(
                        color: isSelected ? GelatoTheme.blue : Colors.grey.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? GelatoTheme.blueDark : Colors.grey.shade300,
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: GelatoTheme.blueDark.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        rank.toString(),
                        style: TextStyle(
                          fontSize: isSelected ? 18 : 16,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected ? GelatoTheme.blueDark : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (rank == 1)
                      const Text('Lowest', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700))
                    else if (rank == 5)
                      const Text('Highest', style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.w700))
                    else
                      const SizedBox(height: 14),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
