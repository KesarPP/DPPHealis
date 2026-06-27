import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import '../main.dart'; // MainShell
import '../services/ffq_calculator_service.dart';
import '../services/auth_service.dart';
import 'taste_preferences_screen.dart';
import '../data/nutrition_database.dart';

// ── FFQ Calorie breakdown result ─────────────────────────────────────────────
class FoodCalorieEntry {
  final String name;
  final String frequency;
  final String size;
  final double quantity;
  final double gramsPerDay;
  final double caloriesPerDay;

  const FoodCalorieEntry({
    required this.name,
    required this.frequency,
    required this.size,
    required this.quantity,
    required this.gramsPerDay,
    required this.caloriesPerDay,
  });
}

class CalorieResult {
  final double totalCalories;
  final List<FoodCalorieEntry> breakdown;

  const CalorieResult({required this.totalCalories, required this.breakdown});
}

// ── Data model ──────────────────────────────────────────────────────────────

class FfqItem {
  final String name;
  final String unit; // e.g. "cup", "serving", "piece"
  final List<String> sizes; // size options
  final String? imagePath; // optional asset image path

  const FfqItem({
    required this.name,
    required this.unit,
    this.sizes = const ['Small', 'Medium', 'Large'],
    this.imagePath,
  });
}

class FfqCategory {
  final String title;
  final String emoji;
  final Color color;
  final Color darkColor;
  final List<FfqItem> items;

  const FfqCategory({
    required this.title,
    required this.emoji,
    required this.color,
    required this.darkColor,
    required this.items,
  });
}

// ── All 110 items across 9 categories ────────────────────────────────────────

const List<FfqCategory> kFfqCategories = [
  FfqCategory(
    title: 'Beverages',
    emoji: '☕',
    color: GelatoTheme.orange,
    darkColor: GelatoTheme.orangeDark,
    items: [
      FfqItem(name: 'Tea', unit: 'cup', sizes: ['C1 (50 ml)', 'C2 (100 ml)', 'C3 (200 ml)'], imagePath: 'assets/images/ffq/beverages/tea.png'),
      FfqItem(name: 'Coffee', unit: 'cup', sizes: ['C1 (50 ml)', 'C2 (100 ml)', 'C3 (200 ml)'], imagePath: 'assets/images/ffq/beverages/coffee.png'),
      FfqItem(name: 'Fruit juice', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/fruit_juice.png'),
      FfqItem(name: 'Vegetable juice', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/vegetable_juice.png'),
      FfqItem(name: 'Sweetened soft drinks', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/soft_drink_sweet.png'),
      FfqItem(name: 'Unsweetened (diet) soft drinks', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/soft_drink_diet.png'),
      FfqItem(name: 'Wine', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/wine.png'),
      FfqItem(name: 'Other alcoholic drinks', unit: 'glass', sizes: ['G1 (100 ml)', 'G2 (200 ml)', 'G3 (300 ml)'], imagePath: 'assets/images/ffq/beverages/alcoholic_drinks.png'),
    ],
  ),
  FfqCategory(
    title: 'Dairy & Milk Products',
    emoji: '🥛',
    color: GelatoTheme.blue,
    darkColor: GelatoTheme.blueDark,
    items: [
      FfqItem(name: 'Milk', unit: 'cup', sizes: ['C1 (50 ml)', 'C2 (100 ml)', 'C3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/milk.png'),
      FfqItem(name: 'Curd', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/curd.png'),
      FfqItem(name: 'Kadi', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/kadi.png'),
      FfqItem(name: 'Raita', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/raita.png'),
      FfqItem(name: 'Buttermilk', unit: 'cup', sizes: ['C1 (50 ml)', 'C2 (100 ml)', 'C3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/buttermilk.png'),
      FfqItem(name: 'Khoa / milk sweets (solid)', unit: 'piece', sizes: ['N1 (25 g)', 'N2 (50 g)', 'N3 (100 g)'], imagePath: 'assets/images/ffq/dairy_milk/milk_sweet_solid.png'),
      FfqItem(name: 'Milk sweets (liquid)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/milksweets.png'),
      FfqItem(name: 'Ice creams', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/dairy_milk/icecreams.png'),
    ],
  ),
  FfqCategory(
    title: 'Cereals, Breads & Preparations',
    emoji: '🍞',
    color: GelatoTheme.yellow,
    darkColor: GelatoTheme.yellowDark,
    items: [
      FfqItem(name: 'Biscuits', unit: 'piece', sizes: ['Small (1 piece)', 'Medium (2 pieces)', 'Large (4 pieces)'], imagePath: 'assets/images/ffq/cereals_breads_prep/biscuits.png'),
      FfqItem(name: 'White bread', unit: 'sponge_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/cereals_breads_prep/whitebread.png'),
      FfqItem(name: 'Whole wheat bread', unit: 'sponge_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/cereals_breads_prep/brownbread.png'),
      FfqItem(name: 'Pav', unit: 'sponge_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/cereals_breads_prep/pav.png'),
      FfqItem(name: 'Pav bhaji', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/cereals_breads_prep/pavbhaji.png'),
      FfqItem(name: 'Sandwich', unit: 'piece', sizes: ['Small (half)', 'Medium (1 full)', 'Large (2 full)'], imagePath: 'assets/images/ffq/cereals_breads_prep/sandwich.png'),
      FfqItem(name: 'Nan', unit: 'piece', sizes: ['Small (1 nan)', 'Medium (1.5 nan)', 'Large (2 nan)'], imagePath: 'assets/images/ffq/cereals_breads_prep/nan.png'),
      FfqItem(name: 'Chapati', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/chapati.png'),
      FfqItem(name: 'Stuffed paratha', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/stuffed_paratha.png'),
      FfqItem(name: 'Deep fried wheat breads', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/deep_fried_wheat_breads.png'),
      FfqItem(name: 'Bhakri (jowar, bajra, nachni)', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/bhakri.png'),
      FfqItem(name: 'Rice bhakri', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/rice_bhakri.png'),
      FfqItem(name: 'Idli', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/idli.png'),
      FfqItem(name: 'Dosa', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/dosa.png'),
      FfqItem(name: 'Papad', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/cereals_breads_prep/papad.png'),
      FfqItem(name: 'Rice (plain)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/cereals_breads_prep/rice_plain.png'),
      FfqItem(name: 'Rice preparations', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/cereals_breads_prep/rice.png'),
      FfqItem(name: 'Poha', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/cereals_breads_prep/poha.png'),
      FfqItem(name: 'Upma', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/cereals_breads_prep/upma.png'),
    ],
  ),
  FfqCategory(
    title: 'Pulses & Legumes',
    emoji: '🌱',
    color: GelatoTheme.green,
    darkColor: GelatoTheme.greenDark,
    items: [
      FfqItem(name: 'Dal preparations', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/pulses_legumes/dal_preparations.png'),
      FfqItem(name: 'Wet pulses (dry curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/pulses_legumes/dry_pulses.png'),
      FfqItem(name: 'Wet pulses (gravy curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/pulses_legumes/wet_pulses.png'),
    ],
  ),
  FfqCategory(
    title: 'Vegetables',
    emoji: '🥦',
    color: GelatoTheme.green,
    darkColor: GelatoTheme.greenDark,
    items: [
      FfqItem(name: 'Green leafy vegetables (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_all_leafy_veg.png'),
      FfqItem(name: 'Green leafy vegetables (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_all_leafy_veg.png'),
      FfqItem(name: 'Gourd (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_all_gourd.png'),
      FfqItem(name: 'Gourd (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_all_gourd.png'),
      FfqItem(name: 'Brinjal (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_brinjal.png'),
      FfqItem(name: 'Brinjal (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_brinjal.png'),
      FfqItem(name: 'Cauliflower (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_cauliflower.png'),
      FfqItem(name: 'Cauliflower (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_cauliflower.png'),
      FfqItem(name: 'Drumsticks (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_drumstick.png'),
      FfqItem(name: 'Drumsticks (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_drumsticks.png'),
      FfqItem(name: 'Green peas (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_green_peas_.png'),
      FfqItem(name: 'Green peas (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_green_peas_.png'),
      FfqItem(name: 'Potato (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_potato.png'),
      FfqItem(name: 'Potato (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_potato_.png'),
      FfqItem(name: 'Yams (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_yams.png'),
      FfqItem(name: 'Green beans', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/all_green_beans.png'),
      FfqItem(name: 'Lady finger', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/lady_finger.png'),
      FfqItem(name: 'Other vegetables (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/dry_other_veg.png'),
      FfqItem(name: 'Other vegetables (wet)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/wet_otherveg.png'),
      FfqItem(name: 'Onion bhaji', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/onion_bhaji.png'),
      FfqItem(name: 'Green chillies(Raw/Fried)', unit: 'piece', sizes: ['Small (1)'], imagePath: 'assets/images/ffq/vegetables/greenchillies.png'),
      FfqItem(name: 'Garlic ', unit: 'piece', sizes: ['Small (1)'], imagePath: 'assets/images/ffq/vegetables/garlic.png'),
      FfqItem(name: 'Onion (raw)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/onion(raw).png'),
      FfqItem(name: 'Carrot (raw)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/carrot(raw).png'),
      FfqItem(name: 'Cabbage (raw)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/vegetables/cabbage(raw).png'),
    ],
  ),
  FfqCategory(
    title: 'Meat, Fish & Eggs',
    emoji: '🍖',
    color: GelatoTheme.pink,
    darkColor: GelatoTheme.pinkDark,
    items: [
      FfqItem(name: 'Egg (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/dry_egg.png'),
      FfqItem(name: 'Egg (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/wet_egg.png'),
      FfqItem(name: 'Chicken (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/dry_chicken.png'),
      FfqItem(name: 'Chicken (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/wet_chicken.png'),
      FfqItem(name: 'Mutton (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/dry_mutton.png'),
      FfqItem(name: 'Mutton (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/wet_mutton.png'),
      FfqItem(name: 'Fresh Fish/prawns (dry)', unit: 'sponge_set', sizes: ['S(small)', 'M(medium)', 'L(large)'], imagePath: 'assets/images/ffq/meat_fish_eggs/dry_fish.png'),
      FfqItem(name: 'Fresh Fish/prawns (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/wetfish.png'),
      FfqItem(name: 'Crab (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/dry_crab.png'),
      FfqItem(name: 'Crab (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/wet_crab.png'),
      FfqItem(name: 'Dry fish/prawns (dry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/sukkat.png'),
      FfqItem(name: 'Dry fish/prawns (wet/curry)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/meat_fish_eggs/sukkat_rassa.png'),
    ],
  ),
  FfqCategory(
    title: 'Condiments & Side Items',
    emoji: '🧂',
    color: GelatoTheme.orange,
    darkColor: GelatoTheme.orangeDark,
    items: [
      FfqItem(name: 'Salad', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/condiments_sideitems/salad.png'),
      FfqItem(name: 'Pickle', unit: 'spoon_set', sizes: ['S1 (5 ml)', 'S2 (10 ml)', 'S3 (15 ml)'], imagePath: 'assets/images/ffq/condiments_sideitems/pickle.png'),
      FfqItem(name: 'Chutney', unit: 'spoon_set', sizes: ['S1 (5 ml)', 'S2 (10 ml)', 'S3 (15 ml)'], imagePath: 'assets/images/ffq/condiments_sideitems/chutney.png'),
    ],
  ),
  FfqCategory(
    title: 'Snacks & Sweets',
    emoji: '🍬',
    color: GelatoTheme.pink,
    darkColor: GelatoTheme.pinkDark,
    items: [
      FfqItem(name: 'Namkeen', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/snacks_sweets/namkins.png'),
      FfqItem(name: 'Deep fried snacks (Vada/Samosa)', unit: 'piece', sizes: ['Small (1)', 'Medium (2)', 'Large (3)'], imagePath: 'assets/images/ffq/snacks_sweets/deep_fried_snacks.png'),
      FfqItem(name: 'Chaat (Pani puri / Bhel puri)', unit: 'piece', sizes: ['Small', 'Medium', 'Large'], imagePath: 'assets/images/ffq/snacks_sweets/chaat.png'),
      FfqItem(name: 'Puranpoli', unit: 'flat_surface_set', sizes: ['F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8'], imagePath: 'assets/images/ffq/snacks_sweets/puranpoli.png'),
      FfqItem(name: 'Other sweets (solid)', unit: 'piece', sizes: ['Small (1)', 'Medium (2)', 'Large (3)'], imagePath: 'assets/images/ffq/snacks_sweets/other_sweets_solid_.png'),
      FfqItem(name: 'Other sweets (liquid/soft)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/snacks_sweets/othersweets.png'),
      FfqItem(name: 'Nuts', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/snacks_sweets/nuts.png'),
      FfqItem(name: 'Puffed grains / Popcorn', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/snacks_sweets/puffedgrains.png'),
    ],
  ),
  FfqCategory(
    title: 'Fruits',
    emoji: '🍎',
    color: GelatoTheme.pink,
    darkColor: GelatoTheme.pinkDark,
    items: [
      FfqItem(name: 'Orange', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/orange.png'),
      FfqItem(name: 'Mango', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/mango.png'),
      FfqItem(name: 'Guava', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/guava.png'),
      FfqItem(name: 'Sweet lime', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/sweet_lime.png'),
      FfqItem(name: 'Amla', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/amla.png'),
      FfqItem(name: 'Banana', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/banana.png'),
      FfqItem(name: 'Apple', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/apple.png'),
      FfqItem(name: 'Fig', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/fig.png'),
      FfqItem(name: 'Berries', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/berries.png'),
      FfqItem(name: 'Apricot', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/apricot.png'),
      FfqItem(name: 'Cashew fruit', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/cashewfruit.png'),
      FfqItem(name: 'Chikoo', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/chikoo.png'),
      FfqItem(name: 'Litchi', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/litchi.png'),
      FfqItem(name: 'Custard apple', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/custrad_apple.png'),
      FfqItem(name: 'Plums', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/plums.png'),
      FfqItem(name: 'Peach', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/peach.png'),
      FfqItem(name: 'Pineapple', unit: 'ball_set', sizes: ['S (small)', 'M (medium)', 'L (large)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/pineapple.png'),
      FfqItem(name: 'Papaya', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/papaya.png'),
      FfqItem(name: 'Jackfruit', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/jackfruit.png'),
      FfqItem(name: 'Grapes', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/grapes.png'),
      FfqItem(name: 'Pomegranate', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/pomogranate__seasonal_.png'),
      FfqItem(name: 'Melons', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/melons__seasonal_.png'),
      FfqItem(name: 'All other fruits (salad)', unit: 'bowl', sizes: ['K1 (100 ml)', 'K2 (150 ml)', 'K3 (200 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/all_other_fruits.png'),
      FfqItem(name: 'Lemon', unit: 'spoon_set', sizes: ['S1 (5 ml)', 'S2 (10 ml)', 'S3 (15 ml)'], imagePath: 'assets/images/ffq/fruits_seasonal_regular/lemon_sour_.png'),
    ],
  ),
];

// ── Answer data ───────────────────────────────────────────────────────────────

class FfqAnswer {
  String frequency; // Never / Daily / Per Week / Per Month
  int timesPerDay;
  String size;
  double quantityAtTime;
  String? selectedVariety;

  FfqAnswer({
    this.frequency = 'Never',
    this.timesPerDay = 1,
    this.size = 'Medium',
    this.quantityAtTime = 1.0,
    this.selectedVariety,
  });
}

// ── Main Screen ───────────────────────────────────────────────────────────────

class FoodAnalysisScreen extends StatefulWidget {
  const FoodAnalysisScreen({super.key});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  // Which category is expanded (null = none)
  int? _expandedCategoryIndex;

  // Answers keyed by "CategoryTitle||ItemName"
  final Map<String, FfqAnswer> _answers = {};

  String _answerKey(FfqCategory cat, FfqItem item) => '${cat.title}||${item.name}';

  bool _isItemAnswered(FfqCategory cat, FfqItem item) {
    return _answers.containsKey(_answerKey(cat, item));
  }

  int _categoryAnsweredCount(FfqCategory cat) {
    return cat.items.where((item) => _isItemAnswered(cat, item)).length;
  }

  int get _totalAnswered => _answers.length;

  int get _totalItems {
    int t = 0;
    for (final c in kFfqCategories) {
      t += c.items.length;
    }
    return t;
  }

  void _openItemQuestionnaire(FfqCategory cat, FfqItem item) {
    final key = _answerKey(cat, item);
    final existing = _answers[key];
    final answer = FfqAnswer(
      frequency: existing?.frequency ?? 'Never',
      timesPerDay: existing?.timesPerDay ?? 1,
      size: existing?.size ?? (item.sizes.length > 1 ? item.sizes[1] : item.sizes[0]),
      quantityAtTime: existing?.quantityAtTime ?? 1.0,
      selectedVariety: existing?.selectedVariety,
    );

    // Compute global question number (1-based flat index)
    int questionNo = 1;
    outer:
    for (final c in kFfqCategories) {
      for (final i in c.items) {
        if (c.title == cat.title && i.name == item.name) break outer;
        questionNo++;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (dialogContext) => _ItemQuestionnaireScreen(
          category: cat,
          item: item,
          initialAnswer: answer,
          questionNumber: questionNo,
          totalQuestions: _totalItems,
          onSave: (saved, goToNext) {
            setState(() {
              _answers[key] = saved;
              FfqCalculatorService().saveAnswer(item.name, saved);
            });
            
            Navigator.pop(dialogContext);

            if (goToNext) {
              final allItems = <MapEntry<FfqCategory, FfqItem>>[];
              for (var c in kFfqCategories) {
                for (var i in c.items) {
                  allItems.add(MapEntry(c, i));
                }
              }
              int currentIndex = allItems.indexWhere((e) => e.value.name == item.name);
              if (currentIndex != -1 && currentIndex + 1 < allItems.length) {
                final nextEntry = allItems[currentIndex + 1];
                Future.microtask(() {
                  _openItemQuestionnaire(nextEntry.key, nextEntry.value);
                });
              } else {
                _openTastePreferences();
              }
            }
          },
        ),
      ),
    );
  }

  void _openTastePreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TastePreferencesScreen(
          onComplete: () {
            Navigator.pop(context); // Pop TastePreferencesScreen
            _completeAnalysis();
          },
        ),
      ),
    );
  }

  void _finishFFQ() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  /// Quick validation test — pre-fills 3 known items and checks the formula.
  /// Expected total: ~845 kcal (see comments below).
  void _runQuickTest() {
    final svc = FfqCalculatorService();
    svc.clear();

    // Test item 1: Rice (plain)
    // Daily × 1 time × K1 (100g) × qty 1
    // Expected: (117.19/100) × 100 × 1 × 1 = 117.19 kcal
    svc.saveAnswer('Rice (plain)', FfqAnswer(
      frequency: 'Daily',
      timesPerDay: 1,
      size: 'K1 (100 ml)',
      quantityAtTime: 1.0,
    ));

    // Test item 2: Chapati
    // Daily × 3 times × F4 (60g) × qty 2
    // Expected: (202.31/100) × 60 × 2 × 3 = 728.3 kcal
    svc.saveAnswer('Chapati', FfqAnswer(
      frequency: 'Daily',
      timesPerDay: 3,
      size: 'F4',
      quantityAtTime: 2.0,
    ));

    // Test item 3: Tea
    // Per Week × 7 times × C2 (100g) × qty 1
    // Expected: (16.14/100) × 100 × 1 × (7/7) = 16.14 kcal
    svc.saveAnswer('Tea', FfqAnswer(
      frequency: 'Per Week',
      timesPerDay: 7,
      size: 'C2 (100 ml)',
      quantityAtTime: 1.0,
    ));

    // Expected total: 117.19 + 728.3 + 16.14 = ~861.6 kcal
    final CalorieResult result = svc.calculateDailyCaloriesWithBreakdown();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🧪 Quick Validation Test', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _testRow('Rice (plain)',    'Expected: 117 kcal', result.breakdown.firstWhere((e) => e.name == 'Rice (plain)', orElse: () => const FoodCalorieEntry(name:'',frequency:'',size:'',quantity:0,gramsPerDay:0,caloriesPerDay:0)).caloriesPerDay),
            _testRow('Chapati',         'Expected: 728 kcal', result.breakdown.firstWhere((e) => e.name == 'Chapati', orElse: () => const FoodCalorieEntry(name:'',frequency:'',size:'',quantity:0,gramsPerDay:0,caloriesPerDay:0)).caloriesPerDay),
            _testRow('Tea',             'Expected: 16 kcal',  result.breakdown.firstWhere((e) => e.name == 'Tea', orElse: () => const FoodCalorieEntry(name:'',frequency:'',size:'',quantity:0,gramsPerDay:0,caloriesPerDay:0)).caloriesPerDay),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total (Expected ~862):', style: TextStyle(fontWeight: FontWeight.w900)),
                Text('${result.totalCalories.toStringAsFixed(1)} kcal',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: (result.totalCalories - 861.6).abs() < 5 ? Colors.green : Colors.red,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              (result.totalCalories - 861.6).abs() < 5 ? '✅ Formula is CORRECT!' : '❌ Formula output is unexpected!',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: (result.totalCalories - 861.6).abs() < 5 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold, color: GelatoTheme.purpleDark)),
          ),
        ],
      ),
    );
  }

  Widget _testRow(String name, String expected, double actual) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              Text(expected, style: const TextStyle(fontSize: 10, color: GelatoTheme.textLight)),
            ],
          )),
          Text('${actual.toStringAsFixed(1)} kcal',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }

  void _completeAnalysis() {
    final CalorieResult result = FfqCalculatorService().calculateDailyCaloriesWithBreakdown();
    final double totalCalories = result.totalCalories;
    final List<FoodCalorieEntry> topItems = result.breakdown.take(5).toList();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Analysis Complete', style: TextStyle(fontWeight: FontWeight.w900)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${totalCalories.toStringAsFixed(2)} kcal / day',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: GelatoTheme.purpleDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Estimated Daily Caloric Intake',
                  style: TextStyle(fontSize: 12, color: GelatoTheme.textLight, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Top Contributors:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                ),
                const SizedBox(height: 8),
                ...topItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
                            Text('${item.frequency}  •  ${item.size}  •  ×${item.quantity.toStringAsFixed(1)}',
                                style: const TextStyle(fontSize: 10, color: GelatoTheme.textLight)),
                          ],
                        ),
                      ),
                      Text('${item.caloriesPerDay.toStringAsFixed(2)} kcal',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.purpleDark)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _finishFFQ();
              },
              child: const Text('OK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: GelatoTheme.purpleDark)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = _totalAnswered / _totalItems;

    return Scaffold(
      backgroundColor: GelatoTheme.green.withValues(alpha: 0.3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Food Frequency Questionnaire',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FutureBuilder<UserProfileData>(
              future: AuthService().getUserProfileData(),
              builder: (context, snapshot) {
                final profile = snapshot.data;
                final displayName = profile?.displayName ?? 'Janice Pattice';
                final localPath = profile?.localImagePath;

                ImageProvider? imageProvider;
                if (localPath != null) {
                  imageProvider = FileImage(File(localPath));
                }

                String getInitials(String name) {
                  if (name.isEmpty) return 'JP';
                  final parts = name.trim().split(' ');
                  if (parts.length > 1) {
                    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                  }
                  return parts[0][0].toUpperCase();
                }
                final initials = getInitials(displayName);

                final String bgName = profile?.profileBgColor ?? 'pink';
                Color avatarBgColor = GelatoTheme.pink;
                Color avatarFgColor = GelatoTheme.pinkDark;

                switch (bgName) {
                  case 'pink':
                    avatarBgColor = GelatoTheme.pink;
                    avatarFgColor = GelatoTheme.pinkDark;
                    break;
                  case 'green':
                    avatarBgColor = GelatoTheme.green;
                    avatarFgColor = GelatoTheme.greenDark;
                    break;
                  case 'yellow':
                    avatarBgColor = GelatoTheme.yellow;
                    avatarFgColor = GelatoTheme.yellowDark;
                    break;
                  case 'blue':
                    avatarBgColor = GelatoTheme.blue;
                    avatarFgColor = GelatoTheme.blueDark;
                    break;
                  case 'purple':
                    avatarBgColor = GelatoTheme.purple;
                    avatarFgColor = GelatoTheme.purpleDark;
                    break;
                  case 'orange':
                    avatarBgColor = GelatoTheme.orange;
                    avatarFgColor = GelatoTheme.orangeDark;
                    break;
                }

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: avatarBgColor,
                    foregroundImage: imageProvider,
                    onForegroundImageError: imageProvider != null
                        ? (exception, stackTrace) {}
                        : null,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: avatarFgColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
              ),
            ),
            Column(
              children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Food Analysis of last 30 days',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: GelatoTheme.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_totalAnswered / $_totalItems',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: GelatoTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: GelatoTheme.purpleBright,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Category list ─────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kFfqCategories.length,
                itemBuilder: (context, catIdx) {
                  final cat = kFfqCategories[catIdx];
                  final isExpanded = _expandedCategoryIndex == catIdx;
                  final answered = _categoryAnsweredCount(cat);
                  final total = cat.items.length;
                  final allDone = answered == total;

                  return _CategoryCard(
                    category: cat,
                    isExpanded: isExpanded,
                    answeredCount: answered,
                    totalCount: total,
                    allDone: allDone,
                    onHeaderTap: () {
                      setState(() {
                        _expandedCategoryIndex = isExpanded ? null : catIdx;
                      });
                    },
                    onItemTap: (item) => _openItemQuestionnaire(cat, item),
                    answers: _answers,
                    answerKeyBuilder: _answerKey,
                  );
                },
              ),
            ),

            // ── Bottom bar ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: const BoxDecoration(
                color: GelatoTheme.bg,
                border: Border(top: BorderSide(color: Colors.black12, width: 1.0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _finishFFQ,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: GelatoTheme.textLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: GelatoTheme.cardShadow,
                        ),
                        child: ElevatedButton(
                          onPressed: _openTastePreferences,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GelatoTheme.purple,
                            foregroundColor: GelatoTheme.purpleDark,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: const BorderSide(color: Colors.black, width: 2.0),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Complete Analysis',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  const _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const double gridSize = 16.0;
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += gridSize) {
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) => oldDelegate.color != color;
}

// ── Category Card (expandable) ────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final FfqCategory category;
  final bool isExpanded;
  final int answeredCount;
  final int totalCount;
  final bool allDone;
  final VoidCallback onHeaderTap;
  final void Function(FfqItem) onItemTap;
  final Map<String, FfqAnswer> answers;
  final String Function(FfqCategory, FfqItem) answerKeyBuilder;

  const _CategoryCard({
    required this.category,
    required this.isExpanded,
    required this.answeredCount,
    required this.totalCount,
    required this.allDone,
    required this.onHeaderTap,
    required this.onItemTap,
    required this.answers,
    required this.answerKeyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: allDone ? category.color.withValues(alpha: 0.4) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: allDone ? category.darkColor : Colors.black,
          width: allDone ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(category.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: allDone ? category.darkColor : GelatoTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Mini progress dots row
                        Row(
                          children: [
                            Text(
                              '$answeredCount / $totalCount completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: allDone
                                    ? category.darkColor.withValues(alpha: 0.8)
                                    : GelatoTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  allDone
                      ? Icon(Icons.check_circle_rounded, color: category.darkColor, size: 22)
                      : AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: GelatoTheme.textLight, size: 26),
                        ),
                ],
              ),
            ),
          ),

          // ── Sub-items (expanded) ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState:
                isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(height: 1, color: Colors.black12),
                ...category.items.map((item) {
                  final key = answerKeyBuilder(category, item);
                  final answered = answers.containsKey(key);
                  final ans = answers[key];
                  return InkWell(
                    onTap: () => onItemTap(item),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: answered ? category.color.withValues(alpha: 0.25) : Colors.transparent,
                        border: const Border(
                          bottom: BorderSide(color: Colors.black12, width: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: answered ? category.color : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: answered ? category.darkColor : Colors.black26,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: answered
                                ? Icon(Icons.check, color: category.darkColor, size: 14)
                                : const Icon(Icons.add, color: GelatoTheme.textLight, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: answered ? category.darkColor : GelatoTheme.textDark,
                                  ),
                                ),
                                if (answered && ans != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    ans.frequency == 'Never'
                                        ? 'Never consumed'
                                        : '${ans.frequency}  •  ${ans.size}  •  ×${ans.quantityAtTime.toStringAsFixed(1)} ${item.unit}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: category.darkColor.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: GelatoTheme.textLight, size: 20),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-item Questionnaire Screen ─────────────────────────────────────────────

class _ItemQuestionnaireScreen extends StatefulWidget {
  final FfqCategory category;
  final FfqItem item;
  final FfqAnswer initialAnswer;
  final int questionNumber;
  final int totalQuestions;
  final void Function(FfqAnswer, bool) onSave;

  const _ItemQuestionnaireScreen({
    required this.category,
    required this.item,
    required this.initialAnswer,
    required this.questionNumber,
    required this.totalQuestions,
    required this.onSave,
  });

  @override
  State<_ItemQuestionnaireScreen> createState() => _ItemQuestionnaireScreenState();
}

class _ItemQuestionnaireScreenState extends State<_ItemQuestionnaireScreen> {
  late String _frequency;
  late int _timesPerDay;
  late String _size;
  late double _quantity;
  String? _selectedVariety;
  List<FoodVariety> _availableVarieties = [];

  // Used only when unit == 'piece' — free-text number input
  late final TextEditingController _pieceController;

  final List<String> _frequencies = ['Never', 'Daily', 'Per Week', 'Per Month'];

  bool get _isPieceUnit => widget.item.unit == 'piece';

  @override
  void initState() {
    super.initState();
    _frequency = widget.initialAnswer.frequency;
    _timesPerDay = widget.initialAnswer.timesPerDay;
    _size = 'piece'; // not used for piece items
    _quantity = widget.initialAnswer.quantityAtTime;
    _pieceController = TextEditingController(
      text: _quantity > 0 ? _quantity.toStringAsFixed(0) : '1',
    );
    // ensure size is valid for non-piece items
    if (!_isPieceUnit) {
      _size = widget.initialAnswer.size;
      if (!widget.item.sizes.contains(_size)) {
        _size = widget.item.sizes[widget.item.sizes.length > 1 ? 1 : 0];
      }
    }

    _selectedVariety = widget.initialAnswer.selectedVariety;
    final cleanFoodName = widget.item.name.toLowerCase().trim();
    List<FoodVariety> matchingVarieties = [];
    for (final group in kMajorFoodGroups) {
      for (final item in group.items) {
        final cleanItemName = item.name.toLowerCase().replaceAll(RegExp(r'^\d+\)\s*'), '').trim();
        if (cleanItemName.isNotEmpty && (cleanItemName.contains(cleanFoodName) || cleanFoodName.contains(cleanItemName))) {
          matchingVarieties.addAll(item.varieties);
        }
      }
    }
    final uniqueVarieties = <String, FoodVariety>{};
    for (final v in matchingVarieties) {
      uniqueVarieties[v.name] = v;
    }
    _availableVarieties = uniqueVarieties.values.toList();
    if (_availableVarieties.isNotEmpty && _selectedVariety == null) {
      _selectedVariety = _availableVarieties.first.name;
    }
  }

  @override
  void dispose() {
    _pieceController.dispose();
    super.dispose();
  }

  bool get _isNever => _frequency == 'Never';

  void _save(bool goToNext) {
    // For piece items, read the typed number from the controller
    final double qty = _isPieceUnit
        ? (double.tryParse(_pieceController.text.trim()) ?? 1.0).clamp(1, 999)
        : _quantity;
    widget.onSave(FfqAnswer(
      frequency: _frequency,
      timesPerDay: _timesPerDay,
      size: _isPieceUnit ? 'piece' : _size,
      quantityAtTime: qty,
      selectedVariety: _selectedVariety,
    ), goToNext);
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final item = widget.item;

    return Scaffold(
      backgroundColor: GelatoTheme.bg,
      appBar: AppBar(
        backgroundColor: GelatoTheme.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GelatoTheme.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${cat.emoji}  ${cat.title}',
          style: const TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Progress strip ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${widget.questionNumber} of ${widget.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: GelatoTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: (widget.questionNumber / widget.totalQuestions).clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: cat.darkColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name hero
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cat.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 0,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Show food photo if available, else fall back to emoji
                          if (item.imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                item.imagePath!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    Text(cat.emoji, style: const TextStyle(fontSize: 40)),
                              ),
                            )
                          else
                            Text(cat.emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 10),
                          Text(
                            item.name.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: cat.darkColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Q0 – Specific Variety Dropdown (if available)
                    if (_availableVarieties.isNotEmpty) ...[
                      _SectionLabel(
                        text: 'Select specific variety of ${item.name}:',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 0,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedVariety ?? _availableVarieties.first.name,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: GelatoTheme.textDark),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            style: const TextStyle(
                              color: GelatoTheme.textDark,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedVariety = val);
                              }
                            },
                            items: _availableVarieties.map((v) {
                              return DropdownMenuItem<String>(
                                value: v.name,
                                child: Text(
                                  v.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Q1 – Frequency
                    _SectionLabel(
                      text: 'How often did you have ${item.name} in the last 30 days?',
                    ),
                    const SizedBox(height: 10),
                    _FrequencySelector(
                      selected: _frequency,
                      options: _frequencies,
                      activeColor: cat.color,
                      activeDarkColor: cat.darkColor,
                      onChanged: (v) => setState(() => _frequency = v),
                    ),
                    const SizedBox(height: 20),

                    // Q2 – Times per day (hidden if Never)
                    AnimatedOpacity(
                      opacity: _isNever ? 0.3 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: IgnorePointer(
                        ignoring: _isNever,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(
                              text: _frequency == 'Per Week'
                                  ? 'How many times per week?'
                                  : _frequency == 'Per Month'
                                      ? 'How many times per month?'
                                      : 'How many times per day?',
                            ),
                            const SizedBox(height: 10),
                            _StepperControl(
                              value: _timesPerDay.toDouble(),
                              min: 1,
                              max: 20,
                              step: 1,
                              color: cat.color,
                              darkColor: cat.darkColor,
                              onChanged: (v) => setState(() => _timesPerDay = v.toInt()),
                            ),
                            const SizedBox(height: 20),
                            // Q3 – Size selector (non-piece) OR piece count input
                            if (_isPieceUnit) ...[
                              const _SectionLabel(
                                text: 'How many pieces did you eat at a time?',
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: cat.darkColor, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 0,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.numbers_rounded, color: cat.darkColor, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: _pieceController,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          hintText: 'e.g. 2',
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'pieces',
                                      style: TextStyle(
                                        color: cat.darkColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ] else ...[
                              _SectionLabel(text: 'What size ${item.unit} did you use?'),
                              const SizedBox(height: 10),
                              if (item.unit == 'cup')
                                _CupSizeSlider(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'bowl')
                                _BowlSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'glass')
                                _GlassSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'flat_surface_set')
                                _FlatSurfaceSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('apple') && !item.name.toLowerCase().contains('pineapple') && !item.name.toLowerCase().contains('custard'))
                                _BallSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('guava'))
                                _GuavaSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('banana'))
                                _BananaSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('litchi'))
                                _LitchiSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('orange'))
                                _OrangeSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('mango'))
                                _MangoSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'sponge_set' || item.name.toLowerCase().contains('bread') || item.name.toLowerCase().contains('pav'))
                                _BreadSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('peach'))
                                _PeachSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('pineapple'))
                                _PineappleSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('sweet lime'))
                                _SweetLimeSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('amla'))
                                _AmlaSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('fig'))
                                _FigSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'ball_set' && item.name.toLowerCase().contains('berries'))
                                _BerriesSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else if (item.unit == 'spoon_set' || item.unit == 'spoon' || item.unit == 'tbsp' || item.unit == 'tsp' || item.unit == 'teaspoon' || item.unit == 'tablespoon')
                                _SpoonSizeSelector(
                                  selected: _size,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                )
                              else
                                _SizeSelector(
                                  selected: _size,
                                  options: item.sizes,
                                  activeColor: cat.color,
                                  activeDarkColor: cat.darkColor,
                                  onChanged: (v) => setState(() => _size = v),
                                ),
                              const SizedBox(height: 20),
                              _SectionLabel(
                                text: 'How many ${item.unit}s did you have at a time?',
                              ),
                              const SizedBox(height: 10),
                              _StepperControl(
                                value: _quantity,
                                min: 0.5,
                                max: 20,
                                step: 0.5,
                                color: cat.color,
                                darkColor: cat.darkColor,
                                onChanged: (v) => setState(() => _quantity = v),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Save / Next button ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              decoration: const BoxDecoration(
                color: GelatoTheme.bg,
                border: Border(top: BorderSide(color: Colors.black12)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: GelatoTheme.cardShadow,
                ),
                child: ElevatedButton(
                  onPressed: () => _save(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cat.color,
                    foregroundColor: cat.darkColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: cat.darkColor, width: 2.0),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.questionNumber < widget.totalQuestions ? 'SAVE & NEXT' : 'SAVE & FINISH',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w900,
        color: GelatoTheme.textDark,
        height: 1.4,
      ),
    );
  }
}

class _FrequencySelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _FrequencySelector({
    required this.selected,
    required this.options,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSel = selected == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSel ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? activeDarkColor : Colors.black26,
                width: isSel ? 2.0 : 1.5,
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: activeDarkColor.withValues(alpha: 0.2),
                        blurRadius: 0,
                        offset: const Offset(2, 2),
                      )
                    ]
                  : [],
            ),
            child: Text(
              opt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isSel ? activeDarkColor : GelatoTheme.textLight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SizeSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _SizeSelector({
    required this.selected,
    required this.options,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSel = selected == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSel ? activeColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSel ? activeDarkColor : Colors.black26,
                width: isSel ? 2.0 : 1.5,
              ),
              boxShadow: isSel
                  ? [
                      BoxShadow(
                        color: activeDarkColor.withValues(alpha: 0.2),
                        blurRadius: 0,
                        offset: const Offset(2, 2),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSel ? activeDarkColor : Colors.white,
                    border: Border.all(
                      color: isSel ? activeDarkColor : Colors.black38,
                      width: 2,
                    ),
                  ),
                  child: isSel
                      ? const Icon(Icons.check, color: Colors.white, size: 11)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isSel ? activeDarkColor : GelatoTheme.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CupSizeSlider extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _CupSizeSlider({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Cups data: {label: height, width, ml}
    final cups = [
      {'label': '50 ml',  'height': 60.0, 'width': 45.0, 'ml': 50},
      {'label': '100 ml', 'height': 90.0, 'width': 60.0, 'ml': 100},
      {'label': '200 ml', 'height': 120.0, 'width': 75.0, 'ml': 200},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: cups.map((cup) {
          final label = cup['label'] as String;
          final height = cup['height'] as double;
          final width = cup['width'] as double;
          final ml = cup['ml'] as int;
          
          final sizeString = label;
          final isSel = selected == sizeString || selected.contains(ml.toString());

          return GestureDetector(
            onTap: () => onChanged(sizeString),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: isSel ? activeColor : const Color(0xFFF2E6D8), // Kraft paper color
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                      border: Border.all(
                        color: isSel ? activeDarkColor : Colors.black45,
                        width: isSel ? 2.5 : 1.0,
                      ),
                      boxShadow: isSel ? [
                        BoxShadow(color: activeDarkColor.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 3))
                      ] : [],
                    ),
                    child: Stack(
                      children: [
                        // Corrugated vertical lines
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            (width / 4).floor(),
                            (index) => Container(
                              width: 1,
                              color: Colors.black12,
                            ),
                          ),
                        ),
                        // Top Rim
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSel ? activeDarkColor.withValues(alpha: 0.2) : Colors.white,
                              border: const Border(bottom: BorderSide(color: Colors.black26)),
                            ),
                          ),
                        ),
                        // Green bottom stripe (like the image)
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 12,
                            color: isSel ? activeDarkColor.withValues(alpha: 0.8) : const Color(0xFF2C5E48), // Dark green stripe
                            child: Center(
                              child: Container(
                                height: 2,
                                width: width * 0.6,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BowlSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _BowlSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bowls = [
      {'label': 'Small Bowl\n100 ml', 'height': 45.0, 'width': 65.0, 'ml': 100},
      {'label': 'Medium Bowl\n150 ml', 'height': 55.0, 'width': 85.0, 'ml': 150},
      {'label': 'Large Bowl\n200 ml', 'height': 70.0, 'width': 105.0, 'ml': 200},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bowls.map((bowl) {
          final label = bowl['label'] as String;
          final height = bowl['height'] as double;
          final width = bowl['width'] as double;
          final ml = bowl['ml'] as int;
          
          final sizeString = '$ml ml';
          final isSel = selected == sizeString || selected.contains(ml.toString());

          return GestureDetector(
            onTap: () => onChanged(sizeString),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(width, height),
                        painter: _SingleBowlPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBowlPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleBowlPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final cx = w / 2;
    final cy = h / 2;
    final bw = w;
    final bh = h;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final liquidColor = Color.lerp(const Color(0xFF0F2537).withValues(alpha: 0.2), activeDarkColor.withValues(alpha: 0.5), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final liquidLinePaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Bowl base shape
    final bowlPath = Path();
    bowlPath.moveTo(cx - bw / 2, cy - bh / 2);
    bowlPath.quadraticBezierTo(cx - bw / 2.2, cy + bh / 2, cx - bw / 4, cy + bh / 2);
    bowlPath.lineTo(cx + bw / 4, cy + bh / 2);
    bowlPath.quadraticBezierTo(cx + bw / 2.2, cy + bh / 2, cx + bw / 2, cy - bh / 2);
    
    canvas.drawPath(bowlPath, fillPaint);
    canvas.drawPath(bowlPath, outlinePaint);

    // Top rim ellipse
    final rimRect = Rect.fromCenter(center: Offset(cx, cy - bh / 2), width: bw + 4, height: bh * 0.3);
    canvas.drawOval(rimRect, fillPaint);
    canvas.drawOval(rimRect, outlinePaint);

    // Inner rim ring
    final innerRimRect = Rect.fromCenter(center: Offset(cx, cy - bh / 2), width: bw * 0.85, height: bh * 0.2);
    canvas.drawOval(innerRimRect, outlinePaint);

    // Liquid line inside
    final liquidRect = Rect.fromCenter(center: Offset(cx, cy - bh * 0.1), width: bw * 0.75, height: bh * 0.15);
    canvas.drawArc(liquidRect, 0, 3.14159, false, liquidLinePaint);
    canvas.drawArc(liquidRect, 3.14159, 3.14159, false, liquidLinePaint);
  }

  @override
  bool shouldRepaint(covariant _SingleBowlPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _SpoonSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _SpoonSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final spoons = [
      {'label': '5 ml', 'height': 75.0, 'width': 26.0, 'ml': 5},
      {'label': '10 ml', 'height': 110.0, 'width': 38.0, 'ml': 10},
      {'label': '15 ml', 'height': 145.0, 'width': 54.0, 'ml': 15},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: spoons.map((spoon) {
          final label = spoon['label'] as String;
          final height = spoon['height'] as double;
          final width = spoon['width'] as double;
          final ml = spoon['ml'] as int;
          
          final sizeString = '$ml ml';
          final isSel = selected == sizeString || selected.contains(ml.toString());

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(sizeString),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return CustomPaint(
                          size: Size(width, height),
                          painter: _SingleSpoonPainter(
                            animationValue: value,
                            activeColor: activeColor,
                            activeDarkColor: activeDarkColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                        color: isSel ? activeDarkColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleSpoonPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleSpoonPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    // Flawless, single continuous path for the entire spoon outline
    final spoonPath = Path();
    spoonPath.moveTo(w * 0.5, 0.0);
    
    // Left side of bowl (smooth ellipse down to the neck)
    spoonPath.cubicTo(
      w * 0.0, 0.0, 
      w * 0.0, h * 0.4, 
      w * 0.28, h * 0.45
    );
    // Left neck (smooth inward curve)
    spoonPath.cubicTo(
      w * 0.38, h * 0.48, 
      w * 0.38, h * 0.55, 
      w * 0.35, h * 0.65
    );
    // Left handle (straight flare to the bottom)
    spoonPath.lineTo(w * 0.30, h * 0.94);
    
    // Bottom round
    spoonPath.cubicTo(
      w * 0.30, h * 1.02, 
      w * 0.70, h * 1.02, 
      w * 0.70, h * 0.94
    );
    
    // Right handle (straight up)
    spoonPath.lineTo(w * 0.65, h * 0.65);
    
    // Right neck (smooth outward curve to bowl)
    spoonPath.cubicTo(
      w * 0.62, h * 0.55, 
      w * 0.62, h * 0.48, 
      w * 0.72, h * 0.45
    );
    // Right side of bowl (smooth ellipse to top center)
    spoonPath.cubicTo(
      w * 1.0, h * 0.4, 
      w * 1.0, 0.0, 
      w * 0.5, 0.0
    );
    spoonPath.close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(spoonPath, fillPaint);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(spoonPath, outlinePaint);

    // Inner sketch lines to perfectly match the sketch aesthetic
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Concentric ovals in the head
    canvas.drawOval(Rect.fromLTRB(w * 0.15, h * 0.05, w * 0.85, h * 0.40), sketchPaint);
    canvas.drawOval(Rect.fromLTRB(w * 0.25, h * 0.10, w * 0.75, h * 0.35), sketchPaint);
    canvas.drawOval(Rect.fromLTRB(w * 0.35, h * 0.15, w * 0.65, h * 0.30), sketchPaint);

    // Inner contour line on the handle
    final handleInner = Path();
    handleInner.moveTo(w * 0.35, h * 0.48);
    handleInner.cubicTo(
      w * 0.43, h * 0.55, 
      w * 0.43, h * 0.65, 
      w * 0.38, h * 0.92
    );
    handleInner.cubicTo(
      w * 0.38, h * 0.98, 
      w * 0.62, h * 0.98, 
      w * 0.62, h * 0.92
    );
    handleInner.cubicTo(
      w * 0.57, h * 0.65, 
      w * 0.57, h * 0.55, 
      w * 0.65, h * 0.48
    );
    canvas.drawPath(handleInner, sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleSpoonPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _GlassSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _GlassSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final glasses = [
      {'label': 'Small Glass\n100 ml', 'height': 55.0, 'width': 40.0, 'ml': 100},
      {'label': 'Medium Glass\n200 ml', 'height': 75.0, 'width': 50.0, 'ml': 200},
      {'label': 'Large Glass\n300 ml', 'height': 95.0, 'width': 60.0, 'ml': 300},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: glasses.map((glass) {
          final label = glass['label'] as String;
          final height = glass['height'] as double;
          final width = glass['width'] as double;
          final ml = glass['ml'] as int;
          
          final sizeString = '$ml ml';
          final isSel = selected == sizeString || selected.contains(ml.toString());

          return GestureDetector(
            onTap: () => onChanged(sizeString),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(width, height),
                        painter: _SingleGlassPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleGlassPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleGlassPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    
    final topWidth = w;
    final bottomWidth = w * 0.85;
    
    final topY = h * 0.1;
    final topHeight = h * 0.12;
    
    final bottomY = h * 0.95;
    final bottomHeight = h * 0.1;
    
    final baseInnerY = h * 0.85;
    final baseInnerHeight = h * 0.1;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final liquidColor = Color.lerp(const Color(0xFF0F2537).withValues(alpha: 0.2), activeDarkColor.withValues(alpha: 0.5), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final liquidLinePaint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final glassPath = Path();
    glassPath.moveTo(cx - topWidth/2, topY); // Left top
    glassPath.lineTo(cx - bottomWidth/2, bottomY); // Left bottom
    // Bottom curve (front)
    glassPath.quadraticBezierTo(cx, bottomY + bottomHeight/2, cx + bottomWidth/2, bottomY); 
    glassPath.lineTo(cx + topWidth/2, topY); // Right top
    // Top curve (back)
    glassPath.quadraticBezierTo(cx, topY - topHeight/2, cx - topWidth/2, topY);
    
    canvas.drawPath(glassPath, fillPaint);
    canvas.drawPath(glassPath, outlinePaint);
    
    // Draw front of top rim
    final topRimPath = Path();
    topRimPath.moveTo(cx - topWidth/2, topY);
    topRimPath.quadraticBezierTo(cx, topY + topHeight/2, cx + topWidth/2, topY);
    canvas.drawPath(topRimPath, outlinePaint);

    // Draw front of base inner rim
    final baseInnerWidth = w * 0.87;
    final baseInnerPath = Path();
    baseInnerPath.moveTo(cx - baseInnerWidth/2, baseInnerY);
    baseInnerPath.quadraticBezierTo(cx, baseInnerY + baseInnerHeight/2, cx + baseInnerWidth/2, baseInnerY);
    canvas.drawPath(baseInnerPath, outlinePaint);
    
    // Liquid line inside
    final liquidY = h * 0.35;
    final liquidWidth = w * 0.93;
    final liquidHeight = h * 0.1;
    final liquidPath = Path();
    liquidPath.moveTo(cx - liquidWidth/2, liquidY);
    liquidPath.quadraticBezierTo(cx, liquidY + liquidHeight/2, cx + liquidWidth/2, liquidY);
    liquidPath.quadraticBezierTo(cx, liquidY - liquidHeight/2, cx - liquidWidth/2, liquidY);
    canvas.drawPath(liquidPath, liquidLinePaint);

    // Sketch lines (vertical shading)
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
      
    final rightShadingX1 = cx + bottomWidth * 0.35;
    final rightShadingX2 = cx + bottomWidth * 0.42;
    canvas.drawLine(Offset(rightShadingX1, topY + topHeight/2 + 5), Offset(rightShadingX1, baseInnerY + 2), sketchPaint);
    canvas.drawLine(Offset(rightShadingX2, topY + topHeight/2 + 2), Offset(rightShadingX2, baseInnerY), sketchPaint);
    
    final leftShadingX = cx - bottomWidth * 0.35;
    canvas.drawLine(Offset(leftShadingX, topY + topHeight/2 + 5), Offset(leftShadingX, baseInnerY + 2), sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleGlassPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _BallSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _BallSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleBallPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBallPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleBallPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final applePath = Path();
    
    final topDipY = h * 0.15;
    applePath.moveTo(cx, topDipY);
    
    applePath.cubicTo(
      cx + w * 0.15, h * 0.05, 
      cx + w * 0.5, h * 0.05, 
      cx + w * 0.5, cy
    );
    
    final bottomDipY = h * 0.95;
    applePath.cubicTo(
      cx + w * 0.5, h * 0.95, 
      cx + w * 0.15, h, 
      cx, bottomDipY
    );
    
    applePath.cubicTo(
      cx - w * 0.15, h, 
      cx - w * 0.5, h * 0.95, 
      cx - w * 0.5, cy
    );
    
    applePath.cubicTo(
      cx - w * 0.5, h * 0.05, 
      cx - w * 0.15, h * 0.05, 
      cx, topDipY
    );
    
    applePath.close();

    canvas.drawPath(applePath, fillPaint);
    canvas.drawPath(applePath, outlinePaint);
    
    final stemPath = Path();
    stemPath.moveTo(cx, topDipY + h * 0.05);
    stemPath.quadraticBezierTo(cx + w * 0.05, topDipY - h * 0.15, cx + w * 0.15, topDipY - h * 0.2);
    stemPath.lineTo(cx + w * 0.18, topDipY - h * 0.2);
    stemPath.quadraticBezierTo(cx + w * 0.08, topDipY - h * 0.15, cx + w * 0.03, topDipY + h * 0.03);
    
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint);

    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleBallPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _GuavaSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _GuavaSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleGuavaPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleGuavaPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleGuavaPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final guavaPath = Path();
    
    final topDipX = cx;
    final topDipY = h * 0.2;
    
    guavaPath.moveTo(topDipX, topDipY);
    
    // Top right
    guavaPath.cubicTo(
      cx + w * 0.25, h * 0.1,
      cx + w * 0.45, h * 0.3,
      cx + w * 0.45, h * 0.55
    );
    // Bottom right
    guavaPath.cubicTo(
      cx + w * 0.45, h * 0.8,
      cx + w * 0.25, h * 0.9,
      cx + w * 0.05, h * 0.95
    );
    
    // Crown (bottom center)
    guavaPath.lineTo(cx + w * 0.03, h * 0.98);
    guavaPath.lineTo(cx, h * 0.95);
    guavaPath.lineTo(cx - w * 0.03, h * 0.98);
    guavaPath.lineTo(cx - w * 0.05, h * 0.95);
    
    // Bottom left
    guavaPath.cubicTo(
      cx - w * 0.25, h * 0.9,
      cx - w * 0.45, h * 0.8,
      cx - w * 0.45, h * 0.55
    );
    // Top left
    guavaPath.cubicTo(
      cx - w * 0.45, h * 0.3,
      cx - w * 0.25, h * 0.1,
      topDipX, topDipY
    );
    
    guavaPath.close();

    canvas.drawPath(guavaPath, fillPaint);
    canvas.drawPath(guavaPath, outlinePaint);
    
    final stemPath = Path();
    stemPath.moveTo(cx - w * 0.02, topDipY + h * 0.02);
    stemPath.quadraticBezierTo(cx + w * 0.05, topDipY - h * 0.15, cx + w * 0.15, topDipY - h * 0.2);
    stemPath.lineTo(cx + w * 0.18, topDipY - h * 0.2);
    stemPath.quadraticBezierTo(cx + w * 0.08, topDipY - h * 0.15, cx + w * 0.02, topDipY + h * 0.02);
    
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint);

    final leafPath = Path();
    leafPath.moveTo(cx, topDipY - h * 0.1);
    leafPath.quadraticBezierTo(cx - w * 0.2, topDipY - h * 0.15, cx - w * 0.35, topDipY + h * 0.05);
    leafPath.quadraticBezierTo(cx - w * 0.1, topDipY + h * 0.1, cx + w * 0.05, topDipY - h * 0.05);
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint);
    
    final veinPath = Path();
    veinPath.moveTo(cx, topDipY - h * 0.1);
    veinPath.quadraticBezierTo(cx - w * 0.1, topDipY - h * 0.02, cx - w * 0.33, topDipY + h * 0.04);
    canvas.drawPath(veinPath, sketchPaint);

    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleGuavaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _BananaSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _BananaSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleBananaPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBananaPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleBananaPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final topX = cx + w * 0.25; // 0.75w
    final topY = h * 0.2;       // 0.2h
    
    final bottomX = cx - w * 0.35; // 0.15w
    final bottomY = h * 0.85;      // 0.85h

    final bananaPath = Path();
    bananaPath.moveTo(topX, topY);
    
    // Outer right curve
    bananaPath.cubicTo(
      cx + w * 0.4, h * 0.3, // 0.9w, 0.3h
      cx + w * 0.2, h * 0.9, // 0.7w, 0.9h
      bottomX, bottomY
    );
    
    // Tip
    bananaPath.lineTo(bottomX - w * 0.03, bottomY + h * 0.02);
    bananaPath.lineTo(bottomX - w * 0.05, bottomY - h * 0.02);
    
    // Inner left curve
    bananaPath.cubicTo(
      cx, h * 0.8, // 0.5w, 0.8h
      cx + w * 0.2, h * 0.4, // 0.7w, 0.4h
      topX - w * 0.1, topY + h * 0.05 // 0.65w, 0.25h
    );
    
    // Stem
    bananaPath.lineTo(topX - w * 0.07, topY - h * 0.05);
    bananaPath.lineTo(topX - w * 0.02, topY - h * 0.05);
    
    bananaPath.lineTo(topX, topY);
    bananaPath.close();

    canvas.drawPath(bananaPath, fillPaint);
    canvas.drawPath(bananaPath, outlinePaint);
    
    // Stem texture
    canvas.drawLine(Offset(topX - w * 0.08, topY), Offset(topX + w * 0.01, topY - h * 0.02), outlinePaint);
    
    // Ridges
    final ridge1 = Path();
    ridge1.moveTo(topX - w * 0.03, topY + h * 0.03);
    ridge1.cubicTo(
      cx + w * 0.35, h * 0.35, 
      cx + w * 0.15, h * 0.85, 
      bottomX - w * 0.02, bottomY - h * 0.01
    );
    canvas.drawPath(ridge1, outlinePaint..strokeWidth = 0.8);
    
    final ridge2 = Path();
    ridge2.moveTo(topX - w * 0.06, topY + h * 0.06);
    ridge2.cubicTo(
      cx + w * 0.25, h * 0.4, 
      cx + w * 0.05, h * 0.8, 
      bottomX - w * 0.04, bottomY - h * 0.02
    );
    canvas.drawPath(ridge2, sketchPaint);

    // Leaf attached to stem
    final leafPath = Path();
    leafPath.moveTo(topX - w * 0.05, topY + h * 0.05);
    leafPath.quadraticBezierTo(
      cx - w * 0.05, topY - h * 0.05, 
      cx - w * 0.2, topY + h * 0.1 
    );
    leafPath.quadraticBezierTo(
      cx, topY + h * 0.2, 
      topX - w * 0.06, topY + h * 0.08
    );
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint);
    
    final veinPath = Path();
    veinPath.moveTo(topX - w * 0.05, topY + h * 0.05);
    veinPath.quadraticBezierTo(
      cx - w * 0.05, topY + h * 0.05,
      cx - w * 0.18, topY + h * 0.1 
    );
    canvas.drawPath(veinPath, sketchPaint);
    
    // Ground line
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth=0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleBananaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _LitchiSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _LitchiSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleLitchiPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleLitchiPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleLitchiPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.05;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final litchiPath = Path();
    final int numBumps = 24;
    final double baseRadius = w * 0.38;
    final double bumpHeight = w * 0.03;
    
    litchiPath.moveTo(cx, cy - baseRadius);
    
    for (int i = 1; i <= numBumps; i++) {
      double angle1 = (i - 0.5) * (2 * math.pi / numBumps) - math.pi / 2;
      double angle2 = i * (2 * math.pi / numBumps) - math.pi / 2;
      
      double cpX = cx + (baseRadius + bumpHeight) * math.cos(angle1);
      double cpY = cy + (baseRadius + bumpHeight) * math.sin(angle1);
      
      double endX = cx + baseRadius * math.cos(angle2);
      double endY = cy + baseRadius * math.sin(angle2);
      
      litchiPath.quadraticBezierTo(cpX, cpY, endX, endY);
    }
    litchiPath.close();

    canvas.drawPath(litchiPath, fillPaint);
    canvas.drawPath(litchiPath, outlinePaint);
    
    final stemPath = Path();
    stemPath.moveTo(cx - w * 0.02, cy - baseRadius + h * 0.01);
    stemPath.quadraticBezierTo(
      cx + w * 0.05, cy - baseRadius - h * 0.1, 
      cx + w * 0.15, cy - baseRadius - h * 0.15
    );
    stemPath.lineTo(cx + w * 0.18, cy - baseRadius - h * 0.13);
    stemPath.quadraticBezierTo(
      cx + w * 0.08, cy - baseRadius - h * 0.08, 
      cx + w * 0.02, cy - baseRadius + h * 0.02
    );
    
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint);
    
    final leafPath = Path();
    double leafAttachX = cx + w * 0.05;
    double leafAttachY = cy - baseRadius - h * 0.08;
    
    leafPath.moveTo(leafAttachX, leafAttachY);
    leafPath.quadraticBezierTo(
      cx - w * 0.1, cy - baseRadius - h * 0.2, 
      cx - w * 0.45, cy - baseRadius - h * 0.05
    );
    leafPath.quadraticBezierTo(
      cx - w * 0.1, cy - baseRadius + h * 0.05, 
      leafAttachX - w * 0.02, leafAttachY + h * 0.02
    );
    
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint);
    
    final veinPath = Path();
    veinPath.moveTo(leafAttachX, leafAttachY);
    veinPath.quadraticBezierTo(
      cx - w * 0.1, cy - baseRadius - h * 0.05, 
      cx - w * 0.4, cy - baseRadius - h * 0.04
    );
    canvas.drawPath(veinPath, sketchPaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleLitchiPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _OrangeSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _OrangeSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleOrangePainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleOrangePainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleOrangePainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 - h * 0.05;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
      
    final dotPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final baseRadius = w * 0.38;
    final orangePath = Path();
    orangePath.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: baseRadius));

    canvas.drawPath(orangePath, fillPaint);
    canvas.drawPath(orangePath, outlinePaint);
    
    // Stem scar (navel)
    final navelX = cx;
    final navelY = cy - baseRadius * 0.8;
    
    for (int i = 0; i < 5; i++) {
      double angle = i * (2 * math.pi / 5) - math.pi / 2;
      double innerR = w * 0.01;
      double outerR = w * 0.05;
      
      canvas.drawLine(
        Offset(navelX + innerR * math.cos(angle), navelY + innerR * math.sin(angle)),
        Offset(navelX + outerR * math.cos(angle), navelY + outerR * math.sin(angle)),
        sketchPaint..strokeWidth = 1.0
      );
    }
    
    // Ground line
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleOrangePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _MangoSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _MangoSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 45.0, 'id': 'S'},
      {'label': 'Medium', 'width': 65.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleMangoPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleMangoPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleMangoPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 - h * 0.05;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
      
    final H_top = h * 0.45;
    final H_bottom = h * 0.32;
    final W = w * 0.36;

    final mangoPath = Path();
    mangoPath.moveTo(0, -H_top);
    
    // Quadrant 1: Top to Right
    mangoPath.cubicTo(
      W * 0.55, -H_top, 
      W, -H_top * 0.55, 
      W, 0
    );
    
    // Quadrant 2: Right to Bottom
    mangoPath.cubicTo(
      W, H_bottom * 0.55, 
      W * 0.55, H_bottom, 
      0, H_bottom
    );
    
    // Quadrant 3: Bottom to Left
    mangoPath.cubicTo(
      -W * 0.55, H_bottom, 
      -W, H_bottom * 0.55, 
      -W, 0
    );
    
    // Quadrant 4: Left to Top
    mangoPath.cubicTo(
      -W, -H_top * 0.55, 
      -W * 0.55, -H_top, 
      0, -H_top
    );
    mangoPath.close();

    final stemPath = Path();
    stemPath.moveTo(-w * 0.02, -H_top + h * 0.02);
    stemPath.quadraticBezierTo(-w * 0.01, -H_top - h * 0.04, w * 0.02, -H_top - h * 0.05);
    stemPath.lineTo(w * 0.04, -H_top - h * 0.02);
    stemPath.quadraticBezierTo(w * 0.02, -H_top, w * 0.02, -H_top + h * 0.02);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(math.pi / 6); // 30 degrees tilt

    canvas.drawPath(mangoPath, fillPaint);
    canvas.drawPath(mangoPath, outlinePaint);
    
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint);
    
    canvas.restore();
    
    // Ground line
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleMangoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _BreadSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _BreadSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleBreadPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBreadPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleBreadPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 - h * 0.05;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final creasePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.fill;

    final outerPath = Path();
    
    final flTopX = cx - w * 0.35;
    final flTopY = cy - h * 0.08;
    
    outerPath.moveTo(flTopX, flTopY);
    
    outerPath.cubicTo(
      cx - w * 0.35, cy - h * 0.35,
      cx - w * 0.05, cy - h * 0.38,
      cx + w * 0.20, cy - h * 0.30
    );
    outerPath.cubicTo(
      cx + w * 0.32, cy - h * 0.26,
      cx + w * 0.38, cy - h * 0.15,
      cx + w * 0.35, cy - h * 0.05
    );
    
    final brBottomX = cx + w * 0.35;
    final brBottomY = cy + h * 0.30;
    outerPath.quadraticBezierTo(
      cx + w * 0.36, cy + h * 0.15,
      brBottomX, brBottomY
    );
    
    final frBottomX = cx + w * 0.10;
    final frBottomY = cy + h * 0.38;
    outerPath.quadraticBezierTo(
      cx + w * 0.25, cy + h * 0.36,
      frBottomX, frBottomY
    );
    
    final flBottomX = cx - w * 0.32;
    final flBottomY = cy + h * 0.32;
    outerPath.quadraticBezierTo(
      cx - w * 0.15, cy + h * 0.37,
      flBottomX, flBottomY
    );
    
    outerPath.quadraticBezierTo(
      cx - w * 0.35, cy + h * 0.12,
      flTopX, flTopY
    );
    
    outerPath.close();

    canvas.drawPath(outerPath, fillPaint);
    canvas.drawPath(outerPath, outlinePaint);
    
    final frTopX = cx + w * 0.10;
    final frTopY = cy - h * 0.12;
    final frontDivider = Path();
    frontDivider.moveTo(flTopX, flTopY);
    frontDivider.quadraticBezierTo(
      cx - w * 0.15, cy - h * 0.04,
      frTopX, frTopY
    );
    canvas.drawPath(frontDivider, outlinePaint);

    final verticalDivider = Path();
    verticalDivider.moveTo(frTopX, frTopY);
    verticalDivider.quadraticBezierTo(
      cx + w * 0.08, cy + h * 0.15,
      frBottomX, frBottomY
    );
    canvas.drawPath(verticalDivider, outlinePaint);

    final rightDivider = Path();
    rightDivider.moveTo(frTopX, frTopY);
    rightDivider.quadraticBezierTo(
      cx + w * 0.25, cy - h * 0.09,
      cx + w * 0.35, cy - h * 0.05
    );
    canvas.drawPath(rightDivider, outlinePaint);

    final c1 = Path();
    c1.moveTo(cx - w * 0.26, cy - h * 0.10);
    c1.quadraticBezierTo(cx - w * 0.23, cy - h * 0.18, cx - w * 0.14, cy - h * 0.24);
    c1.quadraticBezierTo(cx - w * 0.19, cy - h * 0.18, cx - w * 0.26, cy - h * 0.10);
    c1.close();
    canvas.drawPath(c1, creasePaint);

    final c2 = Path();
    c2.moveTo(cx - w * 0.12, cy - h * 0.12);
    c2.quadraticBezierTo(cx - w * 0.05, cy - h * 0.23, cx + w * 0.04, cy - h * 0.28);
    c2.quadraticBezierTo(cx - w * 0.01, cy - h * 0.21, cx - w * 0.12, cy - h * 0.12);
    c2.close();
    canvas.drawPath(c2, creasePaint);

    final c3 = Path();
    c3.moveTo(cx + w * 0.02, cy - h * 0.13);
    c3.quadraticBezierTo(cx + w * 0.10, cy - h * 0.24, cx + w * 0.20, cy - h * 0.27);
    c3.quadraticBezierTo(cx + w * 0.13, cy - h * 0.21, cx + w * 0.02, cy - h * 0.13);
    c3.close();
    canvas.drawPath(c3, creasePaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleBreadPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _PeachSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _PeachSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SinglePeachPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SinglePeachPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SinglePeachPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final baseRadius = w * 0.31;
    final peachPath = Path();
    
    peachPath.moveTo(cx, cy - baseRadius * 0.95);
    peachPath.cubicTo(
      cx + baseRadius * 1.15, cy - baseRadius * 0.9,
      cx + baseRadius * 1.15, cy + baseRadius * 0.9,
      cx, cy + baseRadius
    );
    peachPath.cubicTo(
      cx - baseRadius * 1.15, cy + baseRadius * 0.9,
      cx - baseRadius * 1.15, cy - baseRadius * 0.9,
      cx, cy - baseRadius * 0.95
    );
    peachPath.close();

    canvas.drawPath(peachPath, fillPaint);
    canvas.drawPath(peachPath, outlinePaint);
    
    final cleftPath = Path();
    cleftPath.moveTo(cx, cy - baseRadius * 0.95);
    cleftPath.quadraticBezierTo(
      cx - baseRadius * 0.25, cy,
      cx - baseRadius * 0.1, cy + baseRadius * 0.8
    );
    canvas.drawPath(cleftPath, outlinePaint..strokeWidth = 0.8);
    
    final stemPath = Path();
    stemPath.moveTo(cx, cy - baseRadius * 0.92);
    stemPath.quadraticBezierTo(
      cx + w * 0.03, cy - baseRadius - h * 0.10,
      cx + w * 0.06, cy - baseRadius - h * 0.12
    );
    canvas.drawPath(stemPath, outlinePaint..strokeWidth = 1.2);

    final leafPath = Path();
    leafPath.moveTo(cx + w * 0.03, cy - baseRadius - h * 0.06);
    leafPath.quadraticBezierTo(
      cx + w * 0.18, cy - baseRadius - h * 0.15,
      cx + w * 0.28, cy - baseRadius - h * 0.06
    );
    leafPath.quadraticBezierTo(
      cx + w * 0.16, cy - baseRadius - h * 0.01,
      cx + w * 0.03, cy - baseRadius - h * 0.06
    );
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint..strokeWidth = 0.8);
    
    final veinPath = Path();
    veinPath.moveTo(cx + w * 0.03, cy - baseRadius - h * 0.06);
    veinPath.quadraticBezierTo(
      cx + w * 0.16, cy - baseRadius - h * 0.08,
      cx + w * 0.26, cy - baseRadius - h * 0.06
    );
    canvas.drawPath(veinPath, sketchPaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SinglePeachPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _PineappleSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _PineappleSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SinglePineapplePainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SinglePineapplePainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SinglePineapplePainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final bodyPath = Path();
    final bodyW = w * 0.36;
    final bodyH = h * 0.42;
    final bodyTopY = cy - bodyH / 2;
    final bodyBottomY = cy + bodyH / 2;
    
    bodyPath.moveTo(cx, bodyTopY);
    bodyPath.cubicTo(
      cx + bodyW * 0.6, bodyTopY,
      cx + bodyW * 0.65, bodyBottomY,
      cx, bodyBottomY
    );
    bodyPath.cubicTo(
      cx - bodyW * 0.65, bodyBottomY,
      cx - bodyW * 0.6, bodyTopY,
      cx, bodyTopY
    );
    bodyPath.close();

    final crownPath = Path();
    final cH = h * 0.30;
    
    // Symmetrical 5-leaf crown
    crownPath.moveTo(cx - w * 0.10, bodyTopY);
    
    // Outer Left Leaf
    crownPath.quadraticBezierTo(cx - w * 0.20, bodyTopY - cH * 0.3, cx - w * 0.16, bodyTopY - cH * 0.6);
    crownPath.quadraticBezierTo(cx - w * 0.10, bodyTopY - cH * 0.3, cx - w * 0.06, bodyTopY);
    
    // Inner Left Leaf
    crownPath.quadraticBezierTo(cx - w * 0.14, bodyTopY - cH * 0.5, cx - w * 0.09, bodyTopY - cH * 0.9);
    crownPath.quadraticBezierTo(cx - w * 0.05, bodyTopY - cH * 0.4, cx - w * 0.03, bodyTopY);
    
    // Center Leaf
    crownPath.quadraticBezierTo(cx - w * 0.04, bodyTopY - cH * 0.6, cx, bodyTopY - cH * 1.1);
    crownPath.quadraticBezierTo(cx + w * 0.04, bodyTopY - cH * 0.6, cx + w * 0.03, bodyTopY);
    
    // Inner Right Leaf
    crownPath.quadraticBezierTo(cx + w * 0.05, bodyTopY - cH * 0.4, cx + w * 0.09, bodyTopY - cH * 0.9);
    crownPath.quadraticBezierTo(cx + w * 0.14, bodyTopY - cH * 0.5, cx + w * 0.06, bodyTopY);
    
    // Outer Right Leaf
    crownPath.quadraticBezierTo(cx + w * 0.10, bodyTopY - cH * 0.3, cx + w * 0.16, bodyTopY - cH * 0.6);
    crownPath.quadraticBezierTo(cx + w * 0.20, bodyTopY - cH * 0.3, cx + w * 0.10, bodyTopY);
    
    crownPath.close();

    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    canvas.save();
    canvas.clipPath(bodyPath);
    for (int row = 1; row <= 5; row++) {
      double y = bodyTopY + bodyH * (row / 6.0);
      double rowW = bodyW * math.sin(row * math.pi / 6.0);
      int cols = row + 1;
      for (int col = 0; col < cols; col++) {
        double pct = col / (cols - 1.0);
        double x = cx - rowW * 0.65 + rowW * 1.30 * pct;
        
        final arc = Path();
        arc.moveTo(x - w * 0.035, y);
        arc.quadraticBezierTo(x, y + h * 0.02, x + w * 0.035, y);
        canvas.drawPath(arc, outlinePaint..strokeWidth = 0.8);
      }
    }
    canvas.restore();

    canvas.drawPath(crownPath, fillPaint);
    canvas.drawPath(crownPath, outlinePaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SinglePineapplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _SweetLimeSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _SweetLimeSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleSweetLimePainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleSweetLimePainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleSweetLimePainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final baseRadius = w * 0.31;
    final limePath = Path();
    final r = baseRadius;
    
    limePath.moveTo(cx + w * 0.05, cy - r + h * 0.015);
    limePath.cubicTo(
      cx + r, cy - r * 0.8,
      cx + r * 1.05, cy + r * 0.8,
      cx, cy + r
    );
    limePath.cubicTo(
      cx - r * 1.05, cy + r * 0.8,
      cx - r, cy - r * 0.8,
      cx - w * 0.05, cy - r + h * 0.015
    );
    limePath.quadraticBezierTo(
      cx, cy - r - h * 0.015,
      cx + w * 0.05, cy - r + h * 0.015
    );
    limePath.close();

    canvas.drawPath(limePath, fillPaint);
    canvas.drawPath(limePath, outlinePaint);
    
    final stemY = cy - r - h * 0.01;
    final starPath = Path();
    final starR = w * 0.035;
    
    for (int i = 0; i < 5; i++) {
      double angle1 = i * (2 * math.pi / 5) - math.pi / 2;
      double angle2 = (i + 0.5) * (2 * math.pi / 5) - math.pi / 2;
      
      double x1 = cx + starR * math.cos(angle1);
      double y1 = stemY + starR * math.sin(angle1);
      double x2 = cx + (starR * 0.5) * math.cos(angle2);
      double y2 = stemY + (starR * 0.5) * math.sin(angle2);
      
      if (i == 0) {
        starPath.moveTo(x1, y1);
      } else {
        starPath.lineTo(x1, y1);
      }
      starPath.lineTo(x2, y2);
    }
    starPath.close();
    
    canvas.drawPath(starPath, fillPaint);
    canvas.drawPath(starPath, outlinePaint..strokeWidth = 1.0);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleSweetLimePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _AmlaSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _AmlaSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleAmlaPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleAmlaPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleAmlaPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final baseRadius = w * 0.31;
    
    // 1. Outer Circle
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: baseRadius));
    
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);

    // 2. Vertical segment lines/grooves
    final segmentsPath = Path();
    // Center line
    segmentsPath.moveTo(cx, cy - baseRadius);
    segmentsPath.lineTo(cx, cy + baseRadius);
    
    // Inner left curve (longitude line)
    segmentsPath.moveTo(cx, cy - baseRadius);
    segmentsPath.cubicTo(
      cx - baseRadius * 0.4, cy - baseRadius * 0.5,
      cx - baseRadius * 0.4, cy + baseRadius * 0.5,
      cx, cy + baseRadius
    );
    
    // Outer left curve (far left longitude)
    segmentsPath.moveTo(cx, cy - baseRadius);
    segmentsPath.cubicTo(
      cx - baseRadius * 0.75, cy - baseRadius * 0.5,
      cx - baseRadius * 0.75, cy + baseRadius * 0.5,
      cx, cy + baseRadius
    );
    
    // Inner right curve (longitude line)
    segmentsPath.moveTo(cx, cy - baseRadius);
    segmentsPath.cubicTo(
      cx + baseRadius * 0.4, cy - baseRadius * 0.5,
      cx + baseRadius * 0.4, cy + baseRadius * 0.5,
      cx, cy + baseRadius
    );
    
    // Outer right curve (far right longitude)
    segmentsPath.moveTo(cx, cy - baseRadius);
    segmentsPath.cubicTo(
      cx + baseRadius * 0.75, cy - baseRadius * 0.5,
      cx + baseRadius * 0.75, cy + baseRadius * 0.5,
      cx, cy + baseRadius
    );
    
    canvas.drawPath(segmentsPath, outlinePaint..strokeWidth = strokeWidth * 0.75);



    // 5. Stem at the top
    final stemPath = Path();
    stemPath.moveTo(cx - w * 0.02, cy - baseRadius + h * 0.015);
    stemPath.quadraticBezierTo(
      cx - w * 0.03, cy - baseRadius - h * 0.04,
      cx - w * 0.06, cy - baseRadius - h * 0.05
    );
    stemPath.lineTo(cx - w * 0.04, cy - baseRadius - h * 0.07);
    stemPath.quadraticBezierTo(
      cx - w * 0.01, cy - baseRadius - h * 0.05,
      cx + w * 0.01, cy - baseRadius + h * 0.01
    );
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint..strokeWidth = 1.0);

    // 6. Leaf at the top right
    final leafPath = Path();
    leafPath.moveTo(cx - w * 0.01, cy - baseRadius - h * 0.03);
    leafPath.quadraticBezierTo(
      cx + w * 0.15, cy - baseRadius - h * 0.12,
      cx + w * 0.28, cy - baseRadius - h * 0.06
    );
    leafPath.quadraticBezierTo(
      cx + w * 0.12, cy - baseRadius - h * 0.01,
      cx - w * 0.01, cy - baseRadius - h * 0.03
    );
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint..strokeWidth = 0.8);

    final veinPath = Path();
    veinPath.moveTo(cx - w * 0.01, cy - baseRadius - h * 0.03);
    veinPath.quadraticBezierTo(
      cx + w * 0.14, cy - baseRadius - h * 0.07,
      cx + w * 0.26, cy - baseRadius - h * 0.06
    );
    canvas.drawPath(veinPath, sketchPaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleAmlaPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _FigSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _FigSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleFigPainter(
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleFigPainter extends CustomPainter {
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleFigPainter({
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final r = w * 0.32;
    final neckX = cx;
    final neckY = cy - h * 0.25;
    final baseY = cy + r * 0.8;

    // 1. Smooth Pear-shaped body (wider neck)
    final figPath = Path();
    figPath.moveTo(neckX - w * 0.09, neckY);
    figPath.cubicTo(
      cx - w * 0.12, cy - h * 0.12,
      cx - r, cy - h * 0.02,
      cx - r, cy + h * 0.08
    );
    figPath.cubicTo(
      cx - r, cy + r * 0.9,
      cx + r, cy + r * 0.9,
      cx + r, cy + h * 0.08
    );
    figPath.cubicTo(
      cx + r, cy - h * 0.02,
      cx + w * 0.12, cy - h * 0.12,
      cx + w * 0.09, neckY
    );
    figPath.close();

    canvas.drawPath(figPath, fillPaint);
    canvas.drawPath(figPath, outlinePaint);

    // 2. Vertical grooves/lines
    final grooves = Path();
    // Center line
    grooves.moveTo(cx, neckY);
    grooves.lineTo(cx, baseY);
    
    // Left groove
    grooves.moveTo(cx - w * 0.04, neckY);
    grooves.cubicTo(
      cx - w * 0.09, cy - h * 0.10,
      cx - w * 0.24, cy,
      cx - w * 0.18, baseY - h * 0.04
    );
    
    // Right groove
    grooves.moveTo(cx + w * 0.04, neckY);
    grooves.cubicTo(
      cx + w * 0.09, cy - h * 0.10,
      cx + w * 0.24, cy,
      cx + w * 0.18, baseY - h * 0.04
    );
    canvas.drawPath(grooves, outlinePaint..strokeWidth = strokeWidth * 0.75);

    // 5. Stem at the top
    final stemPath = Path();
    stemPath.moveTo(cx - w * 0.04, neckY + h * 0.01);
    stemPath.quadraticBezierTo(cx - w * 0.03, neckY - h * 0.08, cx + w * 0.04, neckY - h * 0.09);
    stemPath.lineTo(cx + w * 0.07, neckY - h * 0.07);
    stemPath.quadraticBezierTo(cx + w * 0.02, neckY - h * 0.06, cx + w * 0.04, neckY + h * 0.01);
    canvas.drawPath(stemPath, fillPaint);
    canvas.drawPath(stemPath, outlinePaint..strokeWidth = 1.0);

    // 6. Lobed leaf attached on the left shoulder of the body
    final leafPath = Path();
    final attachX = cx - w * 0.05;
    final attachY = neckY + h * 0.04;
    leafPath.moveTo(attachX, attachY);
    
    // Top lobe
    leafPath.cubicTo(
      cx - w * 0.15, attachY - h * 0.10,
      cx - w * 0.28, attachY - h * 0.10,
      cx - w * 0.28, attachY - h * 0.03
    );
    // Indent between top and middle lobe
    leafPath.quadraticBezierTo(cx - w * 0.22, attachY - h * 0.02, cx - w * 0.24, attachY);
    
    // Middle lobe (longest, pointing left)
    leafPath.cubicTo(
      cx - w * 0.35, attachY - h * 0.05,
      cx - w * 0.45, attachY + h * 0.05,
      cx - w * 0.38, attachY + h * 0.10
    );
    // Indent between middle and bottom lobe
    leafPath.quadraticBezierTo(cx - w * 0.28, attachY + h * 0.06, cx - w * 0.26, attachY + h * 0.09);
    
    // Bottom lobe
    leafPath.cubicTo(
      cx - w * 0.30, attachY + h * 0.16,
      cx - w * 0.15, attachY + h * 0.18,
      attachX, attachY
    );
    leafPath.close();

    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, outlinePaint..strokeWidth = 0.8);
    
    final veinPath = Path();
    veinPath.moveTo(attachX, attachY);
    veinPath.quadraticBezierTo(cx - w * 0.20, attachY + h * 0.02, cx - w * 0.35, attachY + h * 0.05);
    canvas.drawPath(veinPath, sketchPaint);
    
    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleFigPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _BerriesSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _BerriesSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final balls = [
      {'label': 'Small', 'width': 35.0, 'id': 'S'},
      {'label': 'Medium', 'width': 60.0, 'id': 'M'},
      {'label': 'Large', 'width': 85.0, 'id': 'L'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: balls.map((ball) {
          final label = ball['label'] as String;
          final sizeVal = ball['width'] as double;
          final id = ball['id'] as String;
          
          final isSel = selected.startsWith(id);

          return GestureDetector(
            onTap: () => onChanged('$id (${label.toLowerCase()})'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: isSel ? 1.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (context, value, child) {
                      return CustomPaint(
                        size: Size(sizeVal, sizeVal),
                        painter: _SingleBerriesPainter(
                          sizeId: id,
                          animationValue: value,
                          activeColor: activeColor,
                          activeDarkColor: activeDarkColor,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                      color: isSel ? activeDarkColor : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleBerriesPainter extends CustomPainter {
  final String sizeId;
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleBerriesPainter({
    required this.sizeId,
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2 + h * 0.08;

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final strokeWidth = 1.5 + (1.0 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    if (sizeId == 'S') {
      // --- Small Berry (Redcurrant / Cherry style) ---
      final r = w * 0.33;
      
      // Draw bottom calyx crown
      final crownPath = Path();
      crownPath.moveTo(cx - w * 0.08, cy + r - h * 0.02);
      crownPath.lineTo(cx - w * 0.08, cy + r + h * 0.05);
      crownPath.lineTo(cx - w * 0.03, cy + r + h * 0.01);
      crownPath.lineTo(cx, cy + r + h * 0.06);
      crownPath.lineTo(cx + w * 0.03, cy + r + h * 0.01);
      crownPath.lineTo(cx + w * 0.08, cy + r + h * 0.05);
      crownPath.lineTo(cx + w * 0.08, cy + r - h * 0.02);
      
      canvas.drawPath(crownPath, fillPaint);
      canvas.drawPath(crownPath, outlinePaint..strokeWidth = 1.0);

      // Draw main body
      canvas.drawCircle(Offset(cx, cy), r, fillPaint);
      canvas.drawCircle(Offset(cx, cy), r, outlinePaint..strokeWidth = strokeWidth);

      // Draw curved stem at the top
      final stemPath = Path();
      stemPath.moveTo(cx, cy - r);
      stemPath.quadraticBezierTo(cx + w * 0.02, cy - r - h * 0.15, cx + w * 0.15, cy - r - h * 0.20);
      canvas.drawPath(stemPath, outlinePaint..strokeWidth = strokeWidth * 0.8);
      
    } else if (sizeId == 'M') {
      // --- Medium Berry (Raspberry cluster style) ---
      final r = w * 0.08;
      
      // Define rows of drupelets from back-to-front (top-to-bottom)
      // Row 1 (top-most back layer)
      final row1 = [
        Offset(cx - w * 0.16, cy - h * 0.16),
        Offset(cx - w * 0.06, cy - h * 0.19),
        Offset(cx + w * 0.06, cy - h * 0.19),
        Offset(cx + w * 0.16, cy - h * 0.16),
      ];
      
      // Row 2
      final row2 = [
        Offset(cx - w * 0.22, cy - h * 0.08),
        Offset(cx - w * 0.11, cy - h * 0.10),
        Offset(cx, cy - h * 0.11),
        Offset(cx + w * 0.11, cy - h * 0.10),
        Offset(cx + w * 0.22, cy - h * 0.08),
      ];
      
      // Row 3
      final row3 = [
        Offset(cx - w * 0.24, cy),
        Offset(cx - w * 0.12, cy - h * 0.02),
        Offset(cx, cy - h * 0.03),
        Offset(cx + w * 0.12, cy - h * 0.02),
        Offset(cx + w * 0.24, cy),
      ];
      
      // Row 4
      final row4 = [
        Offset(cx - w * 0.20, cy + h * 0.08),
        Offset(cx - w * 0.10, cy + h * 0.06),
        Offset(cx, cy + h * 0.05),
        Offset(cx + w * 0.10, cy + h * 0.06),
        Offset(cx + w * 0.20, cy + h * 0.08),
      ];
      
      // Row 5
      final row5 = [
        Offset(cx - w * 0.14, cy + h * 0.15),
        Offset(cx - w * 0.05, cy + h * 0.13),
        Offset(cx + w * 0.05, cy + h * 0.13),
        Offset(cx + w * 0.14, cy + h * 0.15),
      ];
      
      // Row 6 (bottom-most front)
      final row6 = [
        Offset(cx - w * 0.07, cy + h * 0.22),
        Offset(cx + w * 0.07, cy + h * 0.22),
        Offset(cx, cy + h * 0.26),
      ];

      // Draw Row 1
      for (final p in row1) {
        canvas.drawCircle(p, r, fillPaint);
        canvas.drawCircle(p, r, outlinePaint);
      }

      // Hollow opening at the top
      final hollowRect = Rect.fromCenter(
        center: Offset(cx, cy - h * 0.15),
        width: w * 0.20,
        height: h * 0.07,
      );
      canvas.drawOval(hollowRect, fillPaint..color = Colors.white);
      canvas.drawOval(hollowRect, outlinePaint);
      fillPaint.color = fillColor; // restore tint

      // Draw Row 2, 3, 4, 5, 6 in order (back to front layer masking)
      final remainingRows = [row2, row3, row4, row5, row6];
      for (final row in remainingRows) {
        for (final p in row) {
          canvas.drawCircle(p, r, fillPaint);
          canvas.drawCircle(p, r, outlinePaint);
        }
      }

    } else {
      // --- Large Berry (Blueberry style) ---
      final r = w * 0.38;
      
      // Main body
      canvas.drawCircle(Offset(cx, cy), r, fillPaint);
      canvas.drawCircle(Offset(cx, cy), r, outlinePaint);

      // Star scalloped calyx ring at the top
      final crownPath = Path();
      final cyCrown = cy - r * 0.65;
      final rxCrown = w * 0.14;
      final ryCrown = h * 0.07;
      
      for (int i = 0; i < 5; i++) {
        double angle = i * (2 * math.pi / 5) - math.pi / 2;
        double x1 = cx + rxCrown * math.cos(angle);
        double y1 = cyCrown + ryCrown * math.sin(angle);
        
        double angleNext = (i + 1) * (2 * math.pi / 5) - math.pi / 2;
        double x2 = cx + rxCrown * math.cos(angleNext);
        double y2 = cyCrown + ryCrown * math.sin(angleNext);
        
        double angleMid = (i + 0.5) * (2 * math.pi / 5) - math.pi / 2;
        double xMid = cx + (rxCrown * 1.35) * math.cos(angleMid);
        double yMid = cyCrown + (ryCrown * 1.35) * math.sin(angleMid);
        
        if (i == 0) {
          crownPath.moveTo(x1, y1);
        }
        crownPath.quadraticBezierTo(xMid, yMid, x2, y2);
      }
      crownPath.close();
      canvas.drawPath(crownPath, fillPaint);
      canvas.drawPath(crownPath, outlinePaint..strokeWidth = strokeWidth * 0.8);
      
      // Calyx center dot
      canvas.drawCircle(Offset(cx, cyCrown), w * 0.02, outlinePaint..strokeWidth = 1.0);
    }

    canvas.drawLine(Offset(cx - w * 0.6, h), Offset(cx + w * 0.6, h), sketchPaint..strokeWidth = 0.6);
  }

  @override
  bool shouldRepaint(covariant _SingleBerriesPainter oldDelegate) {
    return oldDelegate.sizeId != sizeId ||
           oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor;
  }
}

class _FlatSurfaceSizeSelector extends StatelessWidget {
  final String selected;
  final Color activeColor;
  final Color activeDarkColor;
  final ValueChanged<String> onChanged;

  const _FlatSurfaceSizeSelector({
    required this.selected,
    required this.activeColor,
    required this.activeDarkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = [
      {'label': '4', 'width': 13.0, 'id': 'F9'},
      {'label': '8', 'width': 26.0, 'id': 'F8'},
      {'label': '11.5', 'width': 38.0, 'id': 'F7'},
      {'label': '14.5', 'width': 48.0, 'id': 'F6'},
      {'label': '16', 'width': 53.0, 'id': 'F5'},
      {'label': '18', 'width': 60.0, 'id': 'F4'},
      {'label': '19.5', 'width': 65.0, 'id': 'F3'},
      {'label': '21', 'width': 70.0, 'id': 'F2'},
      {'label': '22.5', 'width': 75.0, 'id': 'F1'},
    ];

    int selIndex = surfaces.indexWhere((s) => selected == s['id'] || selected.startsWith(s['id'] as String));
    if (selIndex == -1) selIndex = 4; // Default to F5

    final selectedSurface = surfaces[selIndex];
    final label = selectedSurface['label'] as String;
    final width = selectedSurface['width'] as double;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 0,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                child: CustomPaint(
                  size: const Size(80, 24),
                  painter: _SingleFlatSurfacePainter(
                    surfaceWidth: width,
                    animationValue: 1.0,
                    activeColor: activeColor,
                    activeDarkColor: activeDarkColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: activeDarkColor,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeDarkColor,
              inactiveTrackColor: activeDarkColor.withValues(alpha: 0.2),
              thumbColor: activeDarkColor,
              overlayColor: activeDarkColor.withValues(alpha: 0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: selIndex.toDouble(),
              min: 0,
              max: (surfaces.length - 1).toDouble(),
              divisions: surfaces.length - 1,
              onChanged: (val) {
                onChanged(surfaces[val.toInt()]['id'] as String);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleFlatSurfacePainter extends CustomPainter {
  final double surfaceWidth;
  final double animationValue;
  final Color activeColor;
  final Color activeDarkColor;

  _SingleFlatSurfacePainter({
    required this.surfaceWidth,
    required this.animationValue,
    required this.activeColor,
    required this.activeDarkColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    
    final drawW = surfaceWidth;
    final drawH = 6.0 + (surfaceWidth / 75.0) * 8.0; 
    
    final cy = h - drawH/2 - 4; 

    final outlineColor = Color.lerp(const Color(0xFF0F2537), activeDarkColor, animationValue)!;
    final fillColor = Color.lerp(Colors.white, activeColor.withValues(alpha: 0.2), animationValue)!;
    final shadowAlpha = 0.4 * animationValue;
    final strokeWidth = 1.0 + (0.5 * animationValue);

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
      
    final sketchPaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final topY = cy - drawH/2;
    final bottomY = cy + drawH/2;
    final rx = drawW/2;
    final ry = drawH * 0.6; 

    final bodyPath = Path();
    bodyPath.moveTo(cx - rx, topY);
    bodyPath.lineTo(cx - rx, bottomY);
    bodyPath.quadraticBezierTo(cx, bottomY + ry, cx + rx, bottomY);
    bodyPath.lineTo(cx + rx, topY);
    bodyPath.quadraticBezierTo(cx, topY - ry, cx - rx, topY);
    
    canvas.drawPath(bodyPath, fillPaint);
    canvas.drawPath(bodyPath, outlinePaint);
    
    final topRect = Rect.fromCenter(center: Offset(cx, topY), width: drawW, height: ry * 2);
    canvas.drawOval(topRect, fillPaint);
    canvas.drawOval(topRect, outlinePaint);
    
    for (int i = 1; i <= 6; i++) {
      double xOffset = rx * 0.75 * (i/6);
      
      double ellipseY = ry * 0.8 * (1 - (xOffset/rx)*(xOffset/rx));
      
      canvas.drawLine(
        Offset(cx + xOffset, topY + ellipseY), 
        Offset(cx + xOffset, bottomY + ellipseY), 
        sketchPaint
      );
      canvas.drawLine(
        Offset(cx - xOffset, topY + ellipseY), 
        Offset(cx - xOffset, bottomY + ellipseY), 
        sketchPaint
      );
    }
    
    canvas.drawLine(Offset(cx - drawW/2 - 15, h - 2), Offset(cx + drawW/2 + 15, h - 2), sketchPaint);
  }

  @override
  bool shouldRepaint(covariant _SingleFlatSurfacePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || 
           oldDelegate.activeColor != activeColor ||
           oldDelegate.activeDarkColor != activeDarkColor ||
           oldDelegate.surfaceWidth != surfaceWidth;
  }
}

class _StepperControl extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final Color color;
  final Color darkColor;
  final ValueChanged<double> onChanged;

  const _StepperControl({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.darkColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDec = value > min;
    final canInc = value < max;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _StepBtn(
            icon: Icons.remove,
            enabled: canDec,
            color: color,
            darkColor: darkColor,
            onTap: () => onChanged((value - step).clamp(min, max)),
          ),
          Expanded(
            child: Text(
              value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: darkColor,
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add,
            enabled: canInc,
            color: color,
            darkColor: darkColor,
            onTap: () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final Color color;
  final Color darkColor;
  final VoidCallback onTap;

  const _StepBtn({
    required this.icon,
    required this.enabled,
    required this.color,
    required this.darkColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? darkColor : Colors.black26,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled ? darkColor : GelatoTheme.textMuted,
        ),
      ),
    );
  }
}
