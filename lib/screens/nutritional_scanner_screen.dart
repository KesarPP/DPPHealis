import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/food_item.dart';
import '../services/ai_food_service.dart';
import '../providers/food_notifiers.dart';
import '../repositories/food_repository.dart';
import '../data/gelato_theme.dart';

class NutritionalScannerScreen extends StatefulWidget {
  final File imageFile;

  const NutritionalScannerScreen({super.key, required this.imageFile});

  @override
  State<NutritionalScannerScreen> createState() => _NutritionalScannerScreenState();
}

class _NutritionalScannerScreenState extends State<NutritionalScannerScreen> {
  bool _isLoading = true;
  FoodItem? _scannedItem;
  int _stage = 1;
  
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  String _mealType = 'Snack';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      var item = await AiFoodService().analyzeNutritionalLabel(widget.imageFile);
      if (item != null) {
        final match = await FoodRepository().findFoodByNutrition(item);
        if (match != null) {
          // Auto-fill from database if nutritional profile matches
          item = FoodItem(
            id: item.id,
            name: match.name,
            brand: match.brand,
            calories: item.calories,
            carbs: item.carbs,
            protein: item.protein,
            fat: item.fat,
            fiber: item.fiber,
            sugar: item.sugar,
            sodium: item.sodium,
            servingSize: item.servingSize,
          );
        }
      }

      if (!mounted) return;
      setState(() {
        _scannedItem = item;
        _nameController.text = item?.name ?? '';
        _brandController.text = item?.brand ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to analyze label: $e')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveAndLog() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final updatedItem = FoodItem(
        id: '', 
        name: _nameController.text.trim(),
        brand: _brandController.text.trim().isNotEmpty ? _brandController.text.trim() : null,
        calories: _scannedItem!.calories,
        carbs: _scannedItem!.carbs,
        protein: _scannedItem!.protein,
        fat: _scannedItem!.fat,
        fiber: _scannedItem!.fiber,
        sugar: _scannedItem!.sugar,
        sodium: _scannedItem!.sodium,
        servingSize: _scannedItem!.servingSize,
      );

      final savedItem = await FoodRepository().saveScannedProduct(updatedItem);
      
      if (!mounted) return;
      final notifier = context.read<FoodDiaryNotifier>();
      await notifier.logFood(savedItem, _mealType, notifier.selectedDate);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        title: const Text('Label Scanner', style: TextStyle(color: GelatoTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GelatoTheme.textDark),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: GelatoTheme.green))
          : _stage == 1 
              ? _buildStage1() 
              : _buildStage2(),
    );
  }

  Widget _buildStage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black87, width: 2),
              image: DecorationImage(
                image: FileImage(widget.imageFile),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Nutritional Info', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GelatoTheme.textDark)),
          const SizedBox(height: 8),
          if (_scannedItem?.servingSize != null)
            Text('Serving Size: ${_scannedItem!.servingSize}', style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildMacroRow('Calories', _scannedItem!.calories, 'kcal', GelatoTheme.yellow),
          _buildMacroRow('Carbs', _scannedItem!.carbs, 'g', GelatoTheme.blue),
          _buildMacroRow('Protein', _scannedItem!.protein, 'g', GelatoTheme.purple),
          _buildMacroRow('Fat', _scannedItem!.fat, 'g', GelatoTheme.orange),
          _buildMacroRow('Fiber', _scannedItem!.fiber, 'g', GelatoTheme.green),
          if (_scannedItem!.sugar != null) _buildMacroRow('Sugar', _scannedItem!.sugar!, 'g', GelatoTheme.pink),
          if (_scannedItem!.sodium != null) _buildMacroRow('Sodium', _scannedItem!.sodium!, 'mg', GelatoTheme.blueBright.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _stage = 2),
            style: ElevatedButton.styleFrom(
              backgroundColor: GelatoTheme.green,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black87, width: 2),
              ),
            ),
            child: const Text('Looks Good! Log Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, double value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 2),
          boxShadow: GelatoTheme.cardShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
            Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildStage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Save Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: GelatoTheme.textDark)),
          const SizedBox(height: 8),
          const Text('Confirm the details before logging.', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Product Name',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _brandController,
            decoration: const InputDecoration(
              labelText: 'Brand (Optional)',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _mealType,
            decoration: const InputDecoration(
              labelText: 'Meal Type',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
              DropdownMenuItem(value: 'Snack', child: Text('Snack')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _mealType = v);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveAndLog,
            style: ElevatedButton.styleFrom(
              backgroundColor: GelatoTheme.yellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black87, width: 2),
              ),
            ),
            child: _isSaving 
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
              : const Text('Save & Log', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
