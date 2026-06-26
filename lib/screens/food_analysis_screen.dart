import 'dart:io';
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
    double currentValue = 100.0;
    final match = RegExp(r'\(([\d.]+)\s*(g|ml)\)').firstMatch(selected);
    if (match != null) {
      currentValue = double.tryParse(match.group(1)!) ?? 100.0;
    } else if (selected.contains('50')) {
      currentValue = 50.0;
    } else if (selected.contains('200')) {
      currentValue = 200.0;
    }
    if (currentValue < 50.0) currentValue = 50.0;
    if (currentValue > 200.0) currentValue = 200.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 1.5),
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
          // ── SELECTED PORTION Typography ──
          const Text(
            'SELECTED PORTION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: GelatoTheme.textLight,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${currentValue.toInt()} ml',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: activeDarkColor,
            ),
          ),
          const SizedBox(height: 24),

          // ── Cup UI (Exactly the image provided by the user) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              'assets/images/cups_slidebar.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback display if the image file is not yet placed in assets
                return Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '[assets/images/cups_slidebar.png]\n(Please place your cups image here)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // ── Flexible Touch Slidebar ──
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeDarkColor,
              inactiveTrackColor: Colors.black12,
              thumbColor: activeDarkColor,
              overlayColor: activeDarkColor.withValues(alpha: 0.2),
              valueIndicatorColor: activeDarkColor,
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 26),
            ),
            child: Slider(
              value: currentValue,
              min: 50,
              max: 200,
              divisions: 150, // Flexible 1 ml steps from 50 to 200 ml
              onChanged: (val) {
                onChanged('Cup (${val.toInt()} ml)');
              },
            ),
          ),
        ],
      ),
    );
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
