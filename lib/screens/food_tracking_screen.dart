import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/gelato_theme.dart';
import '../data/handouts_data.dart';
import 'insights_screen.dart';
import 'handouts_screen.dart';
import 'food_search_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/food_notifiers.dart';
import '../models/food_log.dart';
import '../models/food_item.dart';
import '../services/ai_food_service.dart';
import '../services/auth_service.dart';
import 'nutritional_scanner_screen.dart';
import 'food_detail_screen.dart';

class FoodTrackingScreen extends StatefulWidget {
  const FoodTrackingScreen({super.key});

  @override
  State<FoodTrackingScreen> createState() => _FoodTrackingScreenState();
}

class _FoodTrackingScreenState extends State<FoodTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<FoodDiaryNotifier>();
      notifier.loadLogForDate(notifier.selectedDate);
      notifier.loadAllLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF5E5), // Very light light green
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildBanner(context),
                  const SizedBox(height: 24),
                  _buildQuickActionsRow(context),
                  const SizedBox(height: 24),
                  const _WeeklyCalendar(),
                  const SizedBox(height: 24),
                  _buildCalorieGoalCard(context),
                  const SizedBox(height: 24),
                  _buildMealCards(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black87, width: 1.5),
              boxShadow: [
                BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.2), blurRadius: 0, offset: const Offset(4, 4)),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/meals_banner.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: -1.5,
            right: -1.5,
            child: GestureDetector(
              onTap: () {
                _showLegendDialog(context);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: GelatoTheme.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.black87, width: 1.5),
                    left: BorderSide(color: Colors.black87, width: 1.5),
                  ),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2, left: 2),
                    child: Icon(Icons.info_outline, size: 18, color: GelatoTheme.textDark),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionCard(context, 'Insight', Icons.show_chart_rounded, GelatoTheme.purple),
          const SizedBox(width: 8),
          _buildQuickActionCard(context, 'Label Scanner', Icons.document_scanner, GelatoTheme.yellow),
          const SizedBox(width: 8),
          _buildQuickActionCard(context, 'Resources', Icons.menu_book_rounded, GelatoTheme.blue),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (title == 'Insight') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InsightsScreen()));
          } else if (title == 'Label Scanner') {
            _openLabelScanner(context);
          } else if (title == 'Resources') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HandoutsScreen(title: 'Food Resources', handouts: foodHandouts)));
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(3, 3)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: GelatoTheme.textDark),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GelatoTheme.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meal Logging — Quick Guide',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: GelatoTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to your Meal Logging screen! 💚\n\nKeep track of your meals, calories, and nutrition throughout the day. The more you log, the better we can understand your eating habits and personalize your guidance.',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('🍽️ Your 5 Meals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'Log Breakfast, Snack 1, Lunch, Snack 2 & Dinner each day.\n\nTry to complete all 5 so we can get a clearer picture of your daily eating habits. ✨\n\nTap the ⓘ on the Breakfast card to learn how meal logging works.',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('💡 Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'Get a quick look at your calories, nutrition & eating patterns.\nTap to explore your progress in more detail!',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('📦 Label Scanner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'Scan a packaged food\'s nutrition label to quickly view its calories and nutrients and add it to your meal.',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('📚 Resources', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'Need a little guidance? Explore tips on healthy meals, balanced choices, portion control & motivation. 🌿',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('📅 Calendar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'Keep an eye on your meal-logging journey!\n\n💛 Today — Current date\n🧡 Orange — Some meals logged\n💚 Green — All 5 meals logged\n\nTap the calendar to view your monthly progress and check what you logged on previous days. You can remove existing items, but new items can\'t be added to past dates.\n\nLet’s keep those days green! 💚',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                        const SizedBox(height: 16),
                        const Text('🎯 Today’s Goal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                        const SizedBox(height: 4),
                        const Text(
                          'See your personalized calorie target, how much you\'ve eaten, and how much you have left.\n\nYour numbers update automatically as you add or remove food.',
                          style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, color: GelatoTheme.textDark)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLabelScanner(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NutritionalScannerScreen(imageFile: File(pickedFile.path)),
        ),
      );
    }
  }

  Widget _buildCalorieGoalCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<FoodDiaryNotifier>(
        builder: (context, notifier, child) {
          final totalCalories = notifier.dailyLog?.totalCalories ?? 0.0;
          final goal = notifier.calorieGoal;
          final left = goal - totalCalories;
          final progress = totalCalories / goal;
          
          String motivationText = 'Keep it up! You are doing great.';
          if (progress > 1.0) {
            motivationText = "You've exceeded your goal!";
          } else if (progress > 0.8) {
            motivationText = "Almost there!";
          }
          
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black87, width: 1.5),
              boxShadow: [
                BoxShadow(color: GelatoTheme.yellow.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Today\'s Goal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                      const SizedBox(height: 8),
                      Text('${totalCalories.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} kcal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GelatoTheme.textDark.withValues(alpha: 0.7))),
                      const SizedBox(height: 12),
                      Text(motivationText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GelatoTheme.textDark)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress > 1 ? 1.0 : progress,
                        strokeWidth: 8,
                        backgroundColor: GelatoTheme.green.withValues(alpha: 0.2),
                        color: GelatoTheme.green,
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(left > 0 ? left.toStringAsFixed(0) : '0', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                            Text('left', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GelatoTheme.textDark.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<FoodDiaryNotifier>(
        builder: (context, notifier, child) {
          final log = notifier.dailyLog;
          final String todayStr = DateTime.now().toIso8601String().split('T')[0];
          final bool isEditable = notifier.selectedDate == todayStr;
          
          List<LoggedFood> getItems(String mealType) {
            return log?.entries.where((e) => e.mealType == mealType).toList() ?? [];
          }

          return Column(
            children: [
              _ExpandableMealCard(
                title: 'Breakfast',
                color: GelatoTheme.yellow,
                items: getItems('Breakfast'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Snack 1',
                color: GelatoTheme.orange,
                items: getItems('Snack 1')..addAll(getItems('Snack')),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Lunch',
                color: GelatoTheme.green,
                items: getItems('Lunch'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Snack 2',
                color: GelatoTheme.pink,
                items: getItems('Snack 2'),
                isEditable: isEditable,
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Dinner',
                color: GelatoTheme.blue,
                items: getItems('Dinner'),
                isEditable: isEditable,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeeklyCalendar extends StatefulWidget {
  const _WeeklyCalendar();

  @override
  State<_WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<_WeeklyCalendar> {
  late PageController _pageController;
  late DateTime _currentWeekStart;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _today.subtract(Duration(days: _today.weekday % 7));
    _pageController = PageController(initialPage: 1000);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(int pageIndex) {
    int offsetWeeks = pageIndex - 1000;
    return _currentWeekStart.add(Duration(days: offsetWeeks * 7));
  }

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final completedDays = foodNotifier.completedDays;
    final selectedDate = foodNotifier.selectedDate;
    
    // Check if the selected date specifically is completed
    bool todayHasAllMeals = completedDays[selectedDate] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) => const _MonthlyCalendarOverlay(),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: GelatoTheme.pink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
            ],
          ),
          child: Column(
          children: [
            // Month Year Header
            Container(
              decoration: const BoxDecoration(
                color: GelatoTheme.green,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                border: Border(bottom: BorderSide(color: Colors.black87, width: 1.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: const Icon(Icons.chevron_left, color: GelatoTheme.textDark),
                  ),
                  AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      int currentPage = _pageController.hasClients ? _pageController.page?.round() ?? 1000 : 1000;
                      DateTime weekStart = _getWeekStart(currentPage);
                      DateTime midWeek = weekStart.add(const Duration(days: 3));
                      String monthName = _months[midWeek.month - 1];
                      return Text(
                        '$monthName ${midWeek.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: GelatoTheme.textDark,
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: const Icon(Icons.chevron_right, color: GelatoTheme.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Static Days of the week
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                Container(
                  width: 44,
                  alignment: Alignment.center,
                  child: Text(
                    day, 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.textDark.withValues(alpha: 0.7)),
                  ),
                )
              ).toList(),
            ),
            const SizedBox(height: 12),
            // PageView for weeks
            SizedBox(
              height: 40,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  DateTime weekStart = _getWeekStart(index);
                  return _buildWeekRow(weekStart, completedDays);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildWeekRow(DateTime weekStart, Map<String, bool> completedDays) {
    DateTime? signUpTime;
    final authService = AuthService();
    if (authService.isFirebaseInitialized) {
      signUpTime = authService.currentUser?.metadata.creationTime;
    }
    DateTime? signUpDate;
    if (signUpTime != null) {
      signUpDate = DateTime(signUpTime.year, signUpTime.month, signUpTime.day);
    }
    DateTime todayDate = DateTime(_today.year, _today.month, _today.day);
    final foodNotifier = context.read<FoodDiaryNotifier>();
    final selectedDate = foodNotifier.selectedDate;
    final loggedMealsCountMap = foodNotifier.loggedMealsCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        DateTime date = weekStart.add(Duration(days: i));
        String dateString = date.toIso8601String().split('T')[0];
        DateTime currentDay = DateTime(date.year, date.month, date.day);
        
        bool isToday = currentDay.isAtSameMomentAs(todayDate);
        bool isSelected = dateString == selectedDate;
        bool isFuture = currentDay.isAfter(todayDate);
        bool isBeforeSignUp = signUpDate != null && currentDay.isBefore(signUpDate);
        
        int mealsCount = loggedMealsCountMap[dateString] ?? 0;
        bool showRedDot = !isFuture && !isBeforeSignUp && mealsCount == 0 && !isToday;

        Color circleColor = Colors.transparent;
        if (isSelected) {
          circleColor = const Color(0xFFFFF59D); // Yellow
        } else if (!isFuture && !isBeforeSignUp) {
          if (mealsCount >= 5) {
            circleColor = GelatoTheme.green;
          } else if (mealsCount > 0) {
            circleColor = const Color(0xFFFFCC80); // Orange
          }
        }

        return GestureDetector(
          onTap: () {
            if (!isFuture) {
              context.read<FoodDiaryNotifier>().setSelectedDate(dateString);
            }
          },
          child: Container(
            width: 44,
            alignment: Alignment.center,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: circleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                            color: isSelected ? Colors.black87 : (isBeforeSignUp ? GelatoTheme.textDark.withValues(alpha: 0.3) : GelatoTheme.textDark),
                          ),
                        ),
                      ),
                    ),
                  if (showRedDot)
                    Positioned(
                      bottom: -2,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ExpandableMealCard extends StatefulWidget {
  final String title;
  final Color color;
  final List<LoggedFood> items;
  final bool isEditable;

  const _ExpandableMealCard({
    required this.title,
    required this.color,
    required this.items,
    this.isEditable = true,
  });

  @override
  State<_ExpandableMealCard> createState() => _ExpandableMealCardState();
}

class _ExpandableMealCardState extends State<_ExpandableMealCard> {
  bool _isExpanded = false;
  bool _isScanning = false;

  Future<void> _scanFood() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() => _isScanning = true);
      
      try {
        final result = await AiFoodService().identifyFood(File(pickedFile.path));
        
        if (!mounted) return;
        setState(() => _isScanning = false);

        if (result != null && result.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodSearchScreen(
                mealType: widget.title,
                initialSearchQuery: result,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not identify food. Please try again or search manually.')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _carbs = 0;
    double _protein = 0;
    double _fat = 0;
    double _fiber = 0;

    for (var item in widget.items) {
      _carbs += item.food.carbs * item.effectiveMultiplier;
      _protein += item.food.protein * item.effectiveMultiplier;
      _fat += item.food.fat * item.effectiveMultiplier;
      _fiber += item.food.fiber * item.effectiveMultiplier;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black87, width: 1.5),
          boxShadow: [
            BoxShadow(color: widget.color.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: GelatoTheme.textDark),
                  ),
                  if (widget.isEditable) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isScanning ? null : _scanFood,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.2),
                        ),
                        child: _isScanning 
                            ? const SizedBox(
                                width: 20, 
                                height: 20, 
                                child: CircularProgressIndicator(strokeWidth: 2, color: GelatoTheme.textDark)
                              )
                            : const Icon(Icons.camera_alt_outlined, size: 20, color: GelatoTheme.textDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodSearchScreen(mealType: widget.title),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black87, width: 1.2),
                        ),
                        child: const Icon(Icons.add, size: 20, color: GelatoTheme.textDark),
                      ),
                    ),
                    if (widget.title == 'Breakfast') ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Welcome to Meal Logging!',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GelatoTheme.textDark),
                                    ),
                                    const SizedBox(height: 16),
                                    Flexible(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Each meal card helps you record and manage the food you eat throughout the day. The same features are available across all 5 meal cards.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('⌄ View Your Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Tap the down arrow to expand the meal card and view the food items you\'ve logged along with their calorie and nutrient details.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('📷 Scan Your Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Use the camera icon to scan your plate. Our food recognition feature identifies the food items present and helps add them to your meal automatically.\n\nRemember to check and adjust the quantity after scanning for more accurate nutrition information.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('＋ Add Food Manually', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Tap the + icon to manually add the food items you\'ve eaten.\n\nThis is useful when you prefer to enter your meal yourself or when a food item cannot be identified by the scanner.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('− Remove Food', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Once food has been added to your meal, a − icon appears beside the item.\n\nTap it to remove a food item if it was added by mistake or you no longer want it included in your meal.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('⚖️ Adjust Your Quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Already logged a food item but had a different portion?\n\nTap the logged food item to edit the quantity you actually consumed. Updating the quantity helps keep your calorie and nutrient calculations more accurate.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text('🎯 Keep Your Meals Accurate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Try to log all 5 meals each day and enter the quantities as accurately as possible. The more complete your food log is, the better we can understand your eating patterns and support your health goals.',
                                              style: TextStyle(fontSize: 14, color: GelatoTheme.textDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.bold, color: GelatoTheme.textDark)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black87, width: 1.2),
                          ),
                          child: const Icon(Icons.info_outline, size: 20, color: GelatoTheme.textDark),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const Divider(color: Colors.black12, height: 1),
            
            // Empty State
            if (widget.items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No food added yet.', style: TextStyle(color: GelatoTheme.textDark.withValues(alpha: 0.5), fontWeight: FontWeight.w600)),
              )
            else
              // Items
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: widget.items.map((item) => _buildFoodItemRow(context, item)).toList(),
                ),
              ),
              
            // Expandable Macros
            ClipRect(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                heightFactor: _isExpanded ? 1.0 : 0.0,
                child: _buildMacros(_carbs, _protein, _fat, _fiber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemRow(BuildContext context, LoggedFood item) {
    final food = item.food;
    final qty = item.quantity;
    final totalCals = food.calories * item.effectiveMultiplier;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              food: food,
              mealType: item.mealType,
              existingLog: item,
            ),
          ),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qty != 1.0 || item.selectedGrams != item.defaultGrams ? '${food.name} (x${qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString()} of ${item.selectedGrams.toStringAsFixed(0)}g)' : food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                const SizedBox(height: 2),
                Text('C:${(food.carbs * item.effectiveMultiplier).toStringAsFixed(1)}g, P:${(food.protein * item.effectiveMultiplier).toStringAsFixed(1)}g, F:${(food.fat * item.effectiveMultiplier).toStringAsFixed(1)}g', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GelatoTheme.textDark.withValues(alpha: 0.6))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${totalCals.toStringAsFixed(0)} kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: GelatoTheme.textDark)),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  final date = context.read<FoodDiaryNotifier>().selectedDate;
                  context.read<FoodDiaryNotifier>().removeFood(item, date);
                },
                child: const Icon(Icons.remove_circle_outline, color: GelatoTheme.pinkDark, size: 20),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildMacros(double carbs, double protein, double fat, double fiber) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 12),
          _buildProgressBar('Carbs', carbs, 60, GelatoTheme.orange),
          _buildProgressBar('Protein', protein, 40, GelatoTheme.purple),
          _buildProgressBar('Fat', fat, 20, GelatoTheme.yellow),
          _buildProgressBar('Fiber', fiber, 15, GelatoTheme.green),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, double current, double limit, Color color) {
    double progress = limit > 0 ? current / limit : 0;
    if (progress > 1.0) progress = 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 65, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GelatoTheme.textDark))),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.2),
                color: color,
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 65, child: Text('${current.toStringAsFixed(1)}g / ${limit.toStringAsFixed(0)}g', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: GelatoTheme.textDark), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  _DotsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 20.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MonthlyCalendarOverlay extends StatefulWidget {
  const _MonthlyCalendarOverlay();

  @override
  State<_MonthlyCalendarOverlay> createState() => _MonthlyCalendarOverlayState();
}

class _MonthlyCalendarOverlayState extends State<_MonthlyCalendarOverlay> {
  late DateTime _currentMonth;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: GelatoTheme.pink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black87, width: 1.5),
            boxShadow: [
              BoxShadow(color: GelatoTheme.green.withValues(alpha: 0.5), blurRadius: 0, offset: const Offset(4, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  color: GelatoTheme.green,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                  border: Border(bottom: BorderSide(color: Colors.black87, width: 1.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
                        });
                      },
                      child: const Icon(Icons.chevron_left, color: GelatoTheme.textDark),
                    ),
                    Text(
                      '${_months[_currentMonth.month - 1]} ${_currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
                        });
                      },
                      child: const Icon(Icons.chevron_right, color: GelatoTheme.textDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Days Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => 
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      day, 
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: GelatoTheme.textDark.withValues(alpha: 0.7)),
                    ),
                  )
                ).toList(),
              ),
              const SizedBox(height: 12),
              // Grid
              _buildMonthGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final foodNotifier = context.watch<FoodDiaryNotifier>();
    final completedDays = foodNotifier.completedDays;
    final loggedMealsCountMap = foodNotifier.loggedMealsCount;

    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday;
    // Dart DateTime.weekday: 1=Mon, 7=Sun. We want Sun=0, Mon=1.
    int emptyPrefixDays = firstWeekday == 7 ? 0 : firstWeekday;

    List<Widget> dayWidgets = [];
    for (int i = 0; i < emptyPrefixDays; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    DateTime? signUpTime;
    final authService = AuthService();
    if (authService.isFirebaseInitialized) {
      signUpTime = authService.currentUser?.metadata.creationTime;
    }
    DateTime? signUpDate;
    if (signUpTime != null) {
      signUpDate = DateTime(signUpTime.year, signUpTime.month, signUpTime.day);
    }
    DateTime todayDate = DateTime(_today.year, _today.month, _today.day);
    final selectedDate = foodNotifier.selectedDate;

    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, i);
      String dateString = date.toIso8601String().split('T')[0];
      
      bool isToday = date.isAtSameMomentAs(todayDate);
      bool isSelected = dateString == selectedDate;
      bool isFuture = date.isAfter(todayDate);
      bool isBeforeSignUp = signUpDate != null && date.isBefore(signUpDate);
      
      int mealsCount = loggedMealsCountMap[dateString] ?? 0;
      bool showRedDot = !isFuture && !isBeforeSignUp && mealsCount == 0 && !isToday;

      Color circleColor = Colors.transparent;
      if (isSelected) {
        circleColor = const Color(0xFFFFF59D); // Yellow
      } else if (!isFuture && !isBeforeSignUp) {
        if (mealsCount >= 5) {
          circleColor = GelatoTheme.green;
        } else if (mealsCount > 0) {
          circleColor = const Color(0xFFFFCC80); // Orange
        }
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            if (!isFuture) {
              context.read<FoodDiaryNotifier>().setSelectedDate(dateString);
              Navigator.pop(context);
            }
          },
          child: Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$i',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected ? Colors.black87 : (isBeforeSignUp ? GelatoTheme.textDark.withValues(alpha: 0.3) : GelatoTheme.textDark),
                      ),
                    ),
                  ),
                ),
              if (showRedDot)
                Positioned(
                  bottom: -2,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }
}
