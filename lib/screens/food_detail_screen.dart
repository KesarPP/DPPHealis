import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../models/food_item.dart';
import '../providers/food_notifiers.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;
  final String mealType;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.mealType,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;

  void _increment() {
    setState(() {
      _quantity++;
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  String _getTodayDate() {
    return DateTime.now().toIso8601String().split('T')[0];
  }

  void _addToDiary() {
    context.read<FoodDiaryNotifier>().logFood(
      widget.food, 
      widget.mealType, 
      _getTodayDate(),
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity x ${widget.food.name} to ${widget.mealType}!', style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: GelatoTheme.greenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Pop back twice to get to the dashboard (pop the detail screen, pop the search screen)
    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final totalCals = food.calories * _quantity;
    final totalCarbs = food.carbs * _quantity;
    final totalProtein = food.protein * _quantity;
    final totalFat = food.fat * _quantity;
    final totalFiber = food.fiber * _quantity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Food Details',
          style: TextStyle(
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Basic Info
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: GelatoTheme.yellow.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.restaurant, size: 48, color: GelatoTheme.yellowDark),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            food.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: GelatoTheme.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${totalCals.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: GelatoTheme.greenDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Quantity Selector
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuantityButton(Icons.remove, _decrement, _quantity > 1),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildQuantityButton(Icons.add, _increment, true),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Macro Breakdown
                    const Text(
                      'Nutritional Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.black87, width: 1.5),
                        boxShadow: [
                          BoxShadow(color: GelatoTheme.blue.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildProgressBar('Carbs', totalCarbs, 60, GelatoTheme.orange),
                          _buildProgressBar('Protein', totalProtein, 40, GelatoTheme.purple),
                          _buildProgressBar('Fat', totalFat, 20, GelatoTheme.yellow),
                          _buildProgressBar('Fiber', totalFiber, 15, GelatoTheme.green),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Add Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addToDiary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GelatoTheme.pink,
                    foregroundColor: GelatoTheme.textDark,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.black87, width: 1.5),
                    ),
                  ),
                  child: Text(
                    'Add $_quantity to ${widget.mealType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(color: enabled ? Colors.black87 : Colors.grey, width: 1.5),
          boxShadow: enabled ? [
            const BoxShadow(color: Colors.black26, blurRadius: 0, offset: Offset(2, 2)),
          ] : null,
        ),
        child: Icon(icon, color: enabled ? GelatoTheme.textDark : Colors.grey, size: 28),
      ),
    );
  }

  Widget _buildProgressBar(String label, double current, double limit, Color color) {
    double progress = limit > 0 ? current / limit : 0;
    if (progress > 1.0) progress = 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GelatoTheme.textDark))),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                color: color,
                minHeight: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 65, child: Text('${current.toStringAsFixed(1)}g / ${limit.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GelatoTheme.textDark), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
