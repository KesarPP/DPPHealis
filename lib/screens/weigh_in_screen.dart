import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/gelato_theme.dart';
import '../services/notification_service.dart';

class _WeighInEntry {
  final double weight;
  final DateTime date;
  final List<String> moods;

  _WeighInEntry({
    required this.weight,
    required this.date,
    required this.moods,
  });
}

class WeighInScreen extends StatefulWidget {
  const WeighInScreen({super.key});

  @override
  State<WeighInScreen> createState() => _WeighInScreenState();
}

class _WeighInScreenState extends State<WeighInScreen> {
  List<_WeighInEntry> _history = [];
  bool _isLoadingHistory = true;

  double get _goalWeight {
    if (_history.isEmpty) return 70.0;
    
    final double baselineWeight = _history.first.weight;
    final double baselineBMI = baselineWeight / (_height * _height);
    
    if (baselineBMI < 18.5) {
      // Underweight. Goal is to reach a healthy BMI of 18.5
      return 18.5 * (_height * _height);
    } else if (baselineBMI >= 18.5 && baselineBMI < 25.0) {
      // Normal weight. Goal is to maintain weight
      return baselineWeight;
    } else {
      // Overweight/Obese. NDPP CDC guidelines recommend 5% weight loss of starting weight
      return baselineWeight * 0.95;
    }
  }
  
  String get _goalDescription {
    if (_history.isEmpty) return 'Goal';
    final double baselineBMI = _history.first.weight / (_height * _height);
    if (baselineBMI < 18.5) return 'Reach Healthy BMI';
    if (baselineBMI >= 18.5 && baselineBMI < 25.0) return 'Maintain Weight';
    return '5% Weight Loss Goal';
  }
  
  double _height = 1.77; // in meters, for BMI computation

  // Controller state for logging new weight
  double _loggedWeight = 78.4;
  final List<String> _availableMoods = [
    'Energetic',
    'Bloated',
    'Great',
    'Tired',
    'Focused',
    'Stressed'
  ];
  final List<String> _selectedMoods = [];

  // Active chart tooltip selection
  int? _selectedPointIndex;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        double fetchedHeight = 1.77;
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data.containsKey('height')) {
            fetchedHeight = (data['height'] as num).toDouble() / 100.0; // cm to m
          }
        }

        final qs = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .orderBy('date', descending: false)
            .get();

        if (qs.docs.isNotEmpty) {
          final fetchedHistory = qs.docs.map((doc) {
            final data = doc.data();
            final timestamp = data['date'] as Timestamp?;
            final date = timestamp?.toDate() ?? DateTime.now();
            final weight = (data['weight'] ?? 0.0).toDouble();
            final moodsList = data['moods'] as List<dynamic>? ?? [];
            final moods = moodsList.map((e) => e.toString()).toList();
            return _WeighInEntry(weight: weight, date: date, moods: moods);
          }).toList();
          
          setState(() {
            _history = fetchedHistory;
            _height = fetchedHeight;
            _isLoadingHistory = false;
            _loggedWeight = _history.last.weight;
            _selectedPointIndex = _history.length - 1;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }

    // Fallback to dummy data if error or empty
    if (mounted) {
      setState(() {
        _history = [
          _WeighInEntry(weight: 82.5, date: DateTime.now().subtract(const Duration(days: 42)), moods: ['Tired']),
          _WeighInEntry(weight: 81.8, date: DateTime.now().subtract(const Duration(days: 35)), moods: ['Focused']),
          _WeighInEntry(weight: 81.2, date: DateTime.now().subtract(const Duration(days: 28)), moods: ['Bloated']),
          _WeighInEntry(weight: 80.5, date: DateTime.now().subtract(const Duration(days: 21)), moods: ['Great', 'Energetic']),
          _WeighInEntry(weight: 79.8, date: DateTime.now().subtract(const Duration(days: 14)), moods: ['Focused']),
          _WeighInEntry(weight: 79.0, date: DateTime.now().subtract(const Duration(days: 7)), moods: ['Energetic']),
          _WeighInEntry(weight: 78.4, date: DateTime.now(), moods: ['Great']),
        ];
        _isLoadingHistory = false;
        _loggedWeight = _history.last.weight;
        _selectedPointIndex = _history.length - 1;
      });
    }
  }

  double get _currentWeight => _history.isNotEmpty ? _history.last.weight : 70.0;
  double get _startingWeight => _history.isNotEmpty ? _history.first.weight : 70.0;
  double get _totalLost => _startingWeight - _currentWeight;
  double get _bmi => _currentWeight / (_height * _height);

  bool get _canLogWeight {
    if (_history.isEmpty) return true;
    final lastDate = _history.last.date;
    final now = DateTime.now();
    
    final lastMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    
    return nowMidnight.difference(lastMidnight).inDays >= 7;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _getBMICategoryColor(double bmi) {
    if (bmi >= 18.5 && bmi < 25.0) return GelatoTheme.greenDark;
    if (bmi >= 25.0 && bmi < 30.0) return GelatoTheme.orangeDark;
    return Colors.red;
  }

  void _recordWeighIn() {
    HapticFeedback.vibrate();
    
    final now = DateTime.now();
    setState(() {
      _history.add(_WeighInEntry(
        weight: double.parse(_loggedWeight.toStringAsFixed(1)),
        date: now,
        moods: List.from(_selectedMoods),
      ));
      // Reset logging controls
      _selectedMoods.clear();
      _selectedPointIndex = _history.length - 1;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final weightToSave = double.parse(_loggedWeight.toStringAsFixed(1));
        
        // Update current weight in user document
        FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'currentWeight': weightToSave,
          'lastWeighInDate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Add to history subcollection
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('weight_history')
            .add({
          'weight': weightToSave,
          'date': FieldValue.serverTimestamp(),
          'moods': List.from(_history.last.moods),
        });
      }
    } catch (e) {
      debugPrint('Error saving weight: $e');
    }

    // Schedule notification for next week
    NotificationService().scheduleWeeklyWeighInReminder(now);

    // Show celebration dialog
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebration',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
        );
        final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeIn),
        );

        return FadeTransition(
          opacity: opacity,
          child: ScaleTransition(
            scale: scale,
            child: _CelebrationDialog(
              weightLost: _totalLost,
              currentWeight: _currentWeight,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingHistory) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F8),
        body: Center(
          child: CircularProgressIndicator(color: GelatoTheme.purpleDark),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: GelatoTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Weekly Weigh-In',
          style: TextStyle(
            color: GelatoTheme.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.8,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DotsPainter(color: Colors.black87.withValues(alpha: 0.04)),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Stats Grid Cards
                  _buildStatsGrid(),
                  const SizedBox(height: 16),

                  // Chart Card
                  _buildChartCard(),
                  const SizedBox(height: 16),

                  // Logger Card or Wait Message
                  if (_canLogWeight)
                    _buildLoggerCard()
                  else
                    _buildWaitMessageCard(),
                  const SizedBox(height: 16),

                  // History Section Title
                  const Text(
                    'Weigh-In History',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // History List
                  _buildHistoryList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final lostText = _totalLost >= 0
        ? '-${_totalLost.toStringAsFixed(1)} kg'
        : '+${(-_totalLost).toStringAsFixed(1)} kg';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _buildStatTile(
          title: 'CURRENT WEIGHT',
          value: '${_currentWeight.toStringAsFixed(1)} kg',
          subtitle: 'Last logged today',
          color: GelatoTheme.pink,
          textColor: GelatoTheme.pinkDark,
        ),
        _buildStatTile(
          title: 'TOTAL LOST',
          value: lostText,
          subtitle: 'From starting weight',
          color: GelatoTheme.green,
          textColor: GelatoTheme.greenDark,
        ),
        _buildStatTile(
          title: 'WEIGHT GOAL',
          value: '${_goalWeight.toStringAsFixed(1)} kg',
          subtitle: '${(_currentWeight - _goalWeight).toStringAsFixed(1)} kg left',
          color: GelatoTheme.blue,
          textColor: GelatoTheme.blueDark,
        ),
        _buildStatTile(
          title: 'BMI STATUS',
          value: _bmi.toStringAsFixed(1),
          subtitle: _getBMICategory(_bmi),
          color: GelatoTheme.yellow,
          textColor: _getBMICategoryColor(_bmi),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: textColor.withValues(alpha: 0.75),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart_rounded, color: GelatoTheme.purpleDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Weight Trend',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_goalWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.purpleDark,
                    ),
                  ),
                  Text(
                    _goalDescription,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: GelatoTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Painter Chart
          LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final chartWidth = constraints.maxWidth;
                  final stepX = _history.length > 1 ? chartWidth / (_history.length - 1) : chartWidth;
                  int index = 0;
                  if (_history.length > 1) {
                    index = (details.localPosition.dx / stepX).round().clamp(0, _history.length - 1);
                  }
                  setState(() {
                    _selectedPointIndex = index;
                  });
                },
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _WeightChartPainter(
                      entries: _history,
                      selectedPointIndex: _selectedPointIndex,
                      goalWeight: _goalWeight,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Chart Details/Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 2,
                    color: GelatoTheme.purpleDark,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Goal Weight Line',
                    style: TextStyle(fontSize: 10, color: GelatoTheme.textLight, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const Text(
                'Tap chart points to inspect weight values',
                style: TextStyle(
                  fontSize: 9.5,
                  color: GelatoTheme.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitMessageCard() {
    if (_history.isEmpty) return const SizedBox.shrink();
    
    final lastDate = _history.last.date;
    final now = DateTime.now();
    final lastMidnight = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final nowMidnight = DateTime(now.year, now.month, now.day);
    final daysPassed = nowMidnight.difference(lastMidnight).inDays;
    final daysLeft = 7 - daysPassed;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GelatoTheme.green,
        borderRadius: GelatoTheme.cardRadius,
        border: Border.all(color: GelatoTheme.greenDark, width: 1.5),
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, color: GelatoTheme.greenDark, size: 48),
          const SizedBox(height: 12),
          const Text(
            'All set for this week!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: GelatoTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your next weigh-in will unlock in $daysLeft day${daysLeft == 1 ? '' : 's'}. Focus on your daily goals until then!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: GelatoTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: GelatoTheme.cardRadius,
        border: GelatoTheme.cardBorder,
        boxShadow: GelatoTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.scale_rounded, color: GelatoTheme.orangeDark, size: 20),
              SizedBox(width: 8),
              Text(
                "Log Today's Weight",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: GelatoTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Numeric Display Box
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: GelatoTheme.orange,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    _loggedWeight.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.orangeDark,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: GelatoTheme.orangeDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Custom Ruler/Slider
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 28),
                color: GelatoTheme.orangeDark,
                onPressed: () {
                  setState(() {
                    _loggedWeight = (_loggedWeight - 0.1).clamp(25.0, 150.0);
                  });
                },
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: GelatoTheme.orangeDark,
                    inactiveTrackColor: GelatoTheme.orange.withValues(alpha: 0.4),
                    trackHeight: 6.0,
                    thumbColor: GelatoTheme.orange,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayColor: GelatoTheme.orange.withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                  ),
                  child: Slider(
                    value: _loggedWeight,
                    min: 25.0,
                    max: 150.0,
                    onChanged: (val) {
                      setState(() {
                        _loggedWeight = val;
                      });
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                color: GelatoTheme.orangeDark,
                onPressed: () {
                  setState(() {
                    _loggedWeight = (_loggedWeight + 0.1).clamp(25.0, 150.0);
                  });
                },
              ),
            ],
          ),
          
          // Slider ruler indicators
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 46),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('25 kg', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GelatoTheme.textMuted)),
                Text('85 kg', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GelatoTheme.textMuted)),
                Text('150 kg', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GelatoTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Mood Selection Chips
          const Text(
            'How do you feel this week?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: GelatoTheme.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableMoods.map((mood) {
              final isSelected = _selectedMoods.contains(mood);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedMoods.remove(mood);
                    } else {
                      _selectedMoods.add(mood);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? GelatoTheme.purple : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? GelatoTheme.purpleDark : Colors.black26,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    mood,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? GelatoTheme.purpleDark : GelatoTheme.textLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _recordWeighIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: GelatoTheme.orangeDark,
              shadowColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black, width: 2.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Record Weekly Weigh-In',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Show logs in reverse chronological order
    final reversedList = _history.reversed.toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reversedList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final entry = reversedList[index];
        final bool hasPrevious = index < reversedList.length - 1;
        final double? prevWeight = hasPrevious ? reversedList[index + 1].weight : null;
        final double? diff = prevWeight != null ? entry.weight - prevWeight : null;

        String changeText = '';
        Color changeColor = GelatoTheme.textLight;
        if (diff != null) {
          if (diff == 0.0) {
            changeText = 'No change';
          } else if (diff < 0) {
            changeText = '${diff.toStringAsFixed(1)} kg';
            changeColor = GelatoTheme.greenDark;
          } else {
            changeText = '+${diff.toStringAsFixed(1)} kg';
            changeColor = Colors.redAccent;
          }
        } else {
          changeText = 'Baseline';
        }

        final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        final dateStr = '${months[entry.date.month - 1]} ${entry.date.day}, ${entry.date.year}';
        final weekNum = _history.indexOf(entry) + 1;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular Week Indicator
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: GelatoTheme.blue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'W$weekNum',
                    style: const TextStyle(
                      color: GelatoTheme.blueDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Date & Moods
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: GelatoTheme.textDark,
                      ),
                    ),
                    if (entry.moods.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: entry.moods.map((mood) {
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GelatoTheme.purple.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mood,
                              style: const TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                                color: GelatoTheme.purpleDark,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Weight & Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    changeText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<_WeighInEntry> entries;
  final int? selectedPointIndex;
  final double goalWeight;

  _WeightChartPainter({
    required this.entries,
    required this.selectedPointIndex,
    required this.goalWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // Weights info
    final weights = entries.map((e) => e.weight).toList();
    final maxWeightOrig = entries.map((e) => e.weight).reduce(math.max);
    final minWeightOrig = entries.map((e) => e.weight).reduce(math.min);
    
    // Ensure we don't divide by zero if max and min are equal
    final maxWeight = math.max(maxWeightOrig, goalWeight + 5.0);
    final minWeight = math.min(minWeightOrig, goalWeight - 5.0);
    final double range = maxWeight - minWeight;

    // Gridlines (draw 4 horizontal gridlines)
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 3; i++) {
      final y = 20.0 + (height - 40.0) * i / 3.0;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Goal Weight Line
    final goalY = 20.0 + (height - 40.0) * (1.0 - (goalWeight - minWeight) / range);
    final goalLinePaint = Paint()
      ..color = GelatoTheme.purpleDark.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    // Draw goal dashed/solid line
    canvas.drawLine(Offset(0, goalY), Offset(width, goalY), goalLinePaint);

    // Compute coordinate points
    final points = <Offset>[];
    
    if (entries.length == 1) {
      // If only one entry, draw it in the center
      final x = width / 2;
      final y = 20.0 + (height - 40.0) * (1.0 - (entries[0].weight - minWeight) / range);
      points.add(Offset(x, y));
    } else {
      final stepX = width / (entries.length - 1);
      for (int i = 0; i < entries.length; i++) {
        final x = i * stepX;
        final y = 20.0 + (height - 40.0) * (1.0 - (entries[i].weight - minWeight) / range);
        points.add(Offset(x, y));
      }
    }

    // Draw area under curve with a beautiful soft pink gradient
    if (points.length > 1) {
      final fillPath = Path();
      fillPath.moveTo(points.first.dx, height);
      fillPath.lineTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final p = points[i];
        final prev = points[i - 1];
        final cx = (prev.dx + p.dx) / 2;
        final cy = (prev.dy + p.dy) / 2;
        fillPath.quadraticBezierTo(prev.dx, prev.dy, cx, cy);
      }
      fillPath.lineTo(points.last.dx, points.last.dy);
      fillPath.lineTo(points.last.dx, height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GelatoTheme.pink.withValues(alpha: 0.35),
            GelatoTheme.pink.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(0, 0, width, height))
        ..style = PaintingStyle.fill;
      canvas.drawPath(fillPath, fillPaint);

      // Draw the main curve line (thick purple)
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final p = points[i];
        final prev = points[i - 1];
        final cx = (prev.dx + p.dx) / 2;
        final cy = (prev.dy + p.dy) / 2;
        linePath.quadraticBezierTo(prev.dx, prev.dy, cx, cy);
      }
      linePath.lineTo(points.last.dx, points.last.dy);

      final curvePaint = Paint()
        ..color = GelatoTheme.pinkBright
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(linePath, curvePaint);
    }

    // Draw dots at each point
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final isSelected = selectedPointIndex == i;

      final dotBgPaint = Paint()
        ..color = isSelected ? GelatoTheme.yellow : Colors.white
        ..style = PaintingStyle.fill;
      final dotStrokePaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(p, isSelected ? 7.0 : 5.0, dotBgPaint);
      canvas.drawCircle(p, isSelected ? 7.0 : 5.0, dotStrokePaint);
    }

    // Draw dashed marker line and tooltip if a point is selected
    if (selectedPointIndex != null && selectedPointIndex! < points.length) {
      final selIdx = selectedPointIndex!;
      final p = points[selIdx];
      final entry = entries[selIdx];

      // Vertical dashed line
      final dashPaint = Paint()
        ..color = Colors.black45
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      double curY = p.dy + 8.0;
      while (curY < height) {
        canvas.drawLine(Offset(p.dx, curY), Offset(p.dx, math.min(curY + 4.0, height)), dashPaint);
        curY += 8.0;
      }
      
      curY = p.dy - 8.0;
      while (curY > 0) {
        canvas.drawLine(Offset(p.dx, curY), Offset(p.dx, math.max(curY - 4.0, 0)), dashPaint);
        curY -= 8.0;
      }

      // Draw Tooltip text box
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final dateStr = '${months[entry.date.month - 1]} ${entry.date.day}';
      final weightStr = '${entry.weight.toStringAsFixed(1)} kg';

      final tpWeight = TextPainter(
        text: TextSpan(
          text: weightStr,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tpDate = TextPainter(
        text: TextSpan(
          text: dateStr,
          style: const TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final double tooltipW = math.max(tpWeight.width, tpDate.width) + 16.0;
      final double tooltipH = tpWeight.height + tpDate.height + 8.0;

      // Adjust X so it doesn't clip off left or right
      double tooltipX = p.dx - tooltipW / 2;
      if (tooltipX < 4.0) tooltipX = 4.0;
      if (tooltipX + tooltipW > width - 4.0) tooltipX = width - tooltipW - 4.0;

      // Draw tooltip above the dot
      final double tooltipY = p.dy - tooltipH - 12.0;

      // Tooltip Card
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH),
        const Radius.circular(8),
      );

      final cardBgPaint = Paint()
        ..color = GelatoTheme.textDark
        ..style = PaintingStyle.fill;
      final cardBorderPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawRRect(rect, cardBgPaint);
      canvas.drawRRect(rect, cardBorderPaint);

      // Draw text
      tpWeight.paint(canvas, Offset(tooltipX + 8.0, tooltipY + 4.0));
      tpDate.paint(canvas, Offset(tooltipX + 8.0, tooltipY + 4.0 + tpWeight.height));
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.entries.length != entries.length ||
        oldDelegate.selectedPointIndex != selectedPointIndex;
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

class _CelebrationDialog extends StatefulWidget {
  final double weightLost;
  final double currentWeight;

  const _CelebrationDialog({
    required this.weightLost,
    required this.currentWeight,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Create random confetti particles
    final rand = math.Random();
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        color: [
          GelatoTheme.pink,
          GelatoTheme.green,
          GelatoTheme.yellow,
          GelatoTheme.blue,
          GelatoTheme.purple,
          GelatoTheme.orange
        ][rand.nextInt(6)],
        angle: rand.nextDouble() * 2 * math.pi,
        speed: rand.nextDouble() * 4 + 2,
        radius: rand.nextDouble() * 3 + 2,
        x: 0,
        y: 0,
      ));
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Confetti particles
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ConfettiPainter(
                  particles: _particles,
                  progress: _sparkleController.value,
                ),
              );
            },
          ),
          
          // Dialogue Box
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: GelatoTheme.cardRadius,
                border: GelatoTheme.cardBorder,
                boxShadow: GelatoTheme.cardShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon Box
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: GelatoTheme.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2.0),
                      boxShadow: [
                        BoxShadow(
                          color: GelatoTheme.greenDark.withValues(alpha: 0.3),
                          blurRadius: 0,
                          offset: const Offset(3, 3),
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: GelatoTheme.greenDark,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Celebration title
                  const Text(
                    'Weigh-In Logged! 🎉',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: GelatoTheme.textDark,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Motivation phrase
                  const Text(
                    "You're making incredible progress. Consistent tracking is key to mastering your health journey!",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: GelatoTheme.textLight,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Highlight card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GelatoTheme.purple.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text(
                              'Weight Lost',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GelatoTheme.purpleDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '-${widget.weightLost.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.purpleDark),
                            ),
                          ],
                        ),
                        Container(width: 1.5, height: 32, color: Colors.black12),
                        Column(
                          children: [
                            const Text(
                              'Current Weight',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GelatoTheme.purpleDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.currentWeight.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GelatoTheme.purpleDark),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Awesome button to close
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GelatoTheme.textDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.black, width: 2.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 3,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'Keep Crushing It!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final Color color;
  final double angle;
  final double speed;
  final double radius;
  double x;
  double y;

  _Particle({
    required this.color,
    required this.angle,
    required this.speed,
    required this.radius,
    required this.x,
    required this.y,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 100);

    for (final p in particles) {
      // Move particle outwards with gravity drift
      final double distance = p.speed * progress * 150.0;
      final double dx = distance * math.cos(p.angle);
      // add quadratic vertical drop (gravity)
      final double dy = distance * math.sin(p.angle) + (progress * progress * 220.0);

      final pos = Offset(center.dx + dx, center.dy + dy);

      final paint = Paint()
        ..color = p.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(pos, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
