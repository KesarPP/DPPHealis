import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../models/food_item.dart';
import '../models/food_log.dart';
import '../providers/food_notifiers.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem food;
  final String mealType;
  final LoggedFood? existingLog;
  final bool isFromScanner;

  const FoodDetailScreen({
    super.key,
    required this.food,
    required this.mealType,
    this.existingLog,
    this.isFromScanner = false,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  double _quantity = 1.0;
  double _defaultGrams = 100.0;
  double _selectedGrams = 100.0;
  
  final List<double> _gramOptions = [20.0, 50.0, 100.0, 150.0, 200.0];
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    
    if (widget.existingLog != null) {
      _quantity = widget.existingLog!.quantity;
      _defaultGrams = widget.existingLog!.defaultGrams;
      _selectedGrams = widget.existingLog!.selectedGrams;
    } else {
      _defaultGrams = _parseServingSize(widget.food.servingSize);
      // Ensure default grams is in our options, otherwise fallback to 100g
      if (!_gramOptions.contains(_defaultGrams)) {
        _defaultGrams = 100.0;
      }
      _selectedGrams = _defaultGrams;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  double _parseServingSize(String? servingSize) {
    if (servingSize == null || servingSize.isEmpty) return 100.0;
    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(servingSize);
    if (match != null) {
      return double.tryParse(match.group(0) ?? '') ?? 100.0;
    }
    return 100.0;
  }

  void _increment() {
    if (_quantity < 5.0) {
      setState(() {
        _quantity += 0.5;
      });
    }
  }

  void _decrement() {
    if (_quantity > 0.5) {
      setState(() {
        _quantity -= 0.5;
      });
    }
  }

  String _getSelectedDate() {
    return context.read<FoodDiaryNotifier>().selectedDate;
  }

  Future<void> _addToDiary() async {
    try {
      if (widget.existingLog != null) {
        await context.read<FoodDiaryNotifier>().removeFood(widget.existingLog!, _getSelectedDate());
      }
      
      await context.read<FoodDiaryNotifier>().logFood(
        widget.food, 
        widget.mealType, 
        _getSelectedDate(),
        quantity: _quantity,
        selectedGrams: _selectedGrams,
        defaultGrams: _defaultGrams,
      );

      if (!mounted) return;
      
      if (widget.existingLog != null || widget.isFromScanner) {
        // If we were editing or coming directly from the scanner, just pop back to the tracker
        Navigator.pop(context);
      } else {
        // Pop back twice to get to the dashboard (pop the detail screen, pop the search screen)
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving to database: $e', style: const TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pageController == null) {
      final initialIndex = _gramOptions.indexOf(_defaultGrams);
      _pageController = PageController(
        viewportFraction: 0.33,
        initialPage: initialIndex != -1 ? initialIndex : 2,
      );
    }
    
    final food = widget.food;
    final multiplier = _defaultGrams > 0 ? (_selectedGrams / _defaultGrams) * _quantity : _quantity;
    final totalCals = food.calories * multiplier;
    final totalCarbs = food.carbs * multiplier;
    final totalProtein = food.protein * multiplier;
    final totalFat = food.fat * multiplier;
    final totalFiber = food.fiber * multiplier;

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
                              '${food.calories.toStringAsFixed(0)} kcal (per ${_defaultGrams.toStringAsFixed(0)}g)',
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
                    const SizedBox(height: 32),
                    
                    // Portion Selector
                    // Portion Selector
                    Center(
                      child: Text(
                        '${_getBowlName(_selectedGrams)} (${_selectedGrams.toStringAsFixed(0)}g)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GelatoTheme.blue.withValues(alpha: 0.2),
                              border: Border.all(color: GelatoTheme.blue, width: 2),
                            ),
                          ),
                          PageView.builder(
                            controller: _pageController!,
                            itemCount: _gramOptions.length,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedGrams = _gramOptions[index];
                              });
                            },
                            itemBuilder: (context, index) {
                              final isSelected = _gramOptions[index] == _selectedGrams;
                              return Center(
                                child: Text(
                                  '${_gramOptions[index].toInt()}',
                                  style: TextStyle(
                                    fontSize: isSelected ? 24 : 18,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                    color: isSelected ? GelatoTheme.textDark : Colors.black45,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Quantity Selector
                    const Center(
                      child: Text(
                        'Quantity (Multiplier)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildQuantityButton(Icons.remove, _decrement, _quantity > 0.5),
                        const SizedBox(width: 24),
                        SizedBox(
                          width: 65,
                          child: Text(
                            _quantity == _quantity.roundToDouble() ? _quantity.toInt().toString() : _quantity.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: GelatoTheme.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildQuantityButton(Icons.add, _increment, _quantity < 5.0),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Total: ${(_selectedGrams * _quantity).toStringAsFixed(0)}g -> ${totalCals.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.greenDark,
                        ),
                      ),
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
                    '${widget.existingLog != null ? 'Update' : 'Add'} ${_quantity == _quantity.roundToDouble() ? _quantity.toInt().toString() : _quantity.toString()} to ${widget.mealType}',
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

  String _getBowlName(double grams) {
    if (grams == 20.0) return 'Small Scoop';
    if (grams == 50.0) return 'Small Bowl';
    if (grams == 100.0) return 'Medium Bowl';
    if (grams == 150.0) return 'Large Bowl';
    if (grams == 200.0) return 'Extra Large Bowl';
    return 'Portion Size';
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
