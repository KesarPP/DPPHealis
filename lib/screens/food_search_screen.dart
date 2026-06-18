import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../providers/food_notifiers.dart';
import '../models/food_item.dart';

class FoodSearchScreen extends StatefulWidget {
  final String mealType;

  const FoodSearchScreen({super.key, required this.mealType});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  void _logFood(BuildContext context, FoodItem food) {
    context.read<FoodDiaryNotifier>().logFood(food, widget.mealType, _getTodayDate());
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${food.name} to ${widget.mealType}!', style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: GelatoTheme.greenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    Navigator.pop(context); // Go back to the dashboard after adding
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add to ${widget.mealType}',
          style: const TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GelatoTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<FoodSearchNotifier>().search(val);
              },
              decoration: InputDecoration(
                hintText: 'Search for food...',
                hintStyle: TextStyle(
                  color: GelatoTheme.textDark.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w700,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: GelatoTheme.textDark),
                filled: true,
                fillColor: GelatoTheme.blue.withValues(alpha: 0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black87, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.black87, width: 2.0),
                ),
              ),
              style: const TextStyle(
                color: GelatoTheme.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Consumer<FoodSearchNotifier>(
              builder: (context, notifier, child) {
                if (notifier.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: GelatoTheme.greenDark),
                  );
                }

                if (notifier.results.isEmpty && _searchController.text.trim().isNotEmpty) {
                  return const Center(
                    child: Text(
                      'No foods found. Try another search.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }

                if (_searchController.text.trim().isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fastfood_rounded, size: 48, color: GelatoTheme.textDark.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        const Text(
                          'Search results will appear here.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: notifier.results.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.black12, height: 1),
                  itemBuilder: (context, index) {
                    final food = notifier.results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      title: Text(
                        food.name, 
                        style: const TextStyle(fontWeight: FontWeight.w800, color: GelatoTheme.textDark, fontSize: 15),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '${food.calories.toStringAsFixed(0)} kcal • C: ${food.carbs.toStringAsFixed(1)}g • P: ${food.protein.toStringAsFixed(1)}g • F: ${food.fat.toStringAsFixed(1)}g', 
                          style: TextStyle(color: GelatoTheme.textDark.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GelatoTheme.green.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: GelatoTheme.greenDark, size: 20),
                      ),
                      onTap: () => _logFood(context, food),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
