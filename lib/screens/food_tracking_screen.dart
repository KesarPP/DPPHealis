import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/gelato_theme.dart';
import '../data/handouts_data.dart';
import 'insights_screen.dart';
import 'handouts_screen.dart';
import 'food_search_screen.dart';
import '../providers/food_notifiers.dart';
import '../models/food_log.dart';

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
      final today = DateTime.now().toIso8601String().split('T')[0];
      context.read<FoodDiaryNotifier>().loadLogForDate(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GelatoTheme.green.withValues(alpha: 0.4),
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
      child: Container(
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
          _buildQuickActionCard(context, 'Barcode Scanner', Icons.qr_code_scanner_rounded, GelatoTheme.yellow),
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

  Widget _buildCalorieGoalCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Consumer<FoodDiaryNotifier>(
        builder: (context, notifier, child) {
          final totalCalories = notifier.dailyLog?.totalCalories ?? 0.0;
          final goal = 2000.0;
          final left = goal - totalCalories;
          final progress = totalCalories / goal;
          
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
                      const Text('Keep it up! You are doing great.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: GelatoTheme.textDark)),
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
          
          List<LoggedFood> getItems(String mealType) {
            return log?.entries.where((e) => e.mealType == mealType).toList() ?? [];
          }

          return Column(
            children: [
              _ExpandableMealCard(
                title: 'Breakfast',
                color: GelatoTheme.yellow,
                items: getItems('Breakfast'),
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Lunch',
                color: GelatoTheme.green,
                items: getItems('Lunch'),
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Snack',
                color: GelatoTheme.orange,
                items: getItems('Snack'),
              ),
              const SizedBox(height: 16),
              _ExpandableMealCard(
                title: 'Dinner',
                color: GelatoTheme.blue,
                items: getItems('Dinner'),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  return _buildWeekRow(weekStart);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekRow(DateTime weekStart) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        DateTime date = weekStart.add(Duration(days: i));
        
        bool isToday = date.year == _today.year && date.month == _today.month && date.day == _today.day;
        // Mocking complete/incomplete based on some deterministic logic
        bool isComplete = date.isBefore(_today) && (date.day % 3 != 0); 
        bool isIncomplete = date.isBefore(_today) && (date.day % 3 == 0); 

        return Container(
          width: 44,
          alignment: Alignment.center,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isToday ? GelatoTheme.green : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                          color: isToday ? Colors.black87 : (isComplete ? GelatoTheme.textDark.withValues(alpha: 0.3) : GelatoTheme.textDark),
                        ),
                      ),
                    ),
                  ),
                  if (isComplete && !isToday)
                    const Icon(Icons.check, size: 24, color: GelatoTheme.greenDark),
                ],
              ),
              const SizedBox(height: 4),
              if (isIncomplete && !isToday)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: GelatoTheme.orangeDark,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 4),
            ],
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

  const _ExpandableMealCard({
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  State<_ExpandableMealCard> createState() => _ExpandableMealCardState();
}

class _ExpandableMealCardState extends State<_ExpandableMealCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    double _carbs = 0;
    double _protein = 0;
    double _fat = 0;
    double _fiber = 0;

    for (var item in widget.items) {
      _carbs += item.food.carbs * item.quantity;
      _protein += item.food.protein * item.quantity;
      _fat += item.food.fat * item.quantity;
      _fiber += item.food.fiber * item.quantity;
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black87, width: 1.2),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, size: 20, color: GelatoTheme.textDark),
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
    final totalCals = food.calories * qty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(qty > 1 ? '${food.name} (x$qty)' : food.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GelatoTheme.textDark)),
                const SizedBox(height: 2),
                Text('C:${(food.carbs * qty).toStringAsFixed(1)}g, P:${(food.protein * qty).toStringAsFixed(1)}g, F:${(food.fat * qty).toStringAsFixed(1)}g', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GelatoTheme.textDark.withValues(alpha: 0.6))),
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
                  final today = DateTime.now().toIso8601String().split('T')[0];
                  context.read<FoodDiaryNotifier>().removeFood(item, today);
                },
                child: const Icon(Icons.remove_circle_outline, color: GelatoTheme.pinkDark, size: 20),
              ),
            ],
          ),
        ],
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
