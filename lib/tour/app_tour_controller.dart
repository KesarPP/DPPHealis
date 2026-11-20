import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../screens/food_tracking_screen.dart';
import '../screens/activity_fitness_screen.dart';
import 'app_tour_models.dart';
import 'app_tour_steps_data.dart';
import 'app_tour_overlay.dart';
import 'app_tour_welcome_dialog.dart';
import 'app_tour_level_unlock_dialog.dart';
import 'app_tour_completion_dialog.dart';

class AppTourController {
  AppTourController._();
  static final AppTourController instance = AppTourController._();

  static const String _tourCompletedKey = 'has_completed_app_tour';

  bool _isActive = false;
  int _currentStepIndex = 0;
  OverlayEntry? _overlayEntry;

  // Track auxiliary pushed screens
  bool _isFoodTrackingPushed = false;
  bool _isActivityPushed = false;

  bool get isActive => _isActive;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => AppTourStepsData.steps.length;

  Future<bool> hasSeenTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tourCompletedKey) ?? false;
  }

  Future<void> markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tourCompletedKey, true);
  }

  /// Launch the tour from the beginning
  void startTour(BuildContext context, {bool showWelcome = true}) {
    // 1. Immediately switch to the Puzzle Map screen (Tab 0)
    MainShellState.instance?.selectedIndex = 0;
    _currentStepIndex = 0;
    _isFoodTrackingPushed = false;
    _isActivityPushed = false;

    final targetContext = DPPApp.navigatorKey.currentContext ?? context;

    if (showWelcome) {
      showDialog(
        context: targetContext,
        barrierDismissible: false,
        builder: (dialogCtx) => AppTourWelcomeDialog(
          onStart: () {
            Navigator.pop(dialogCtx);
            // Delay slightly so the dialog route finishes its pop animation cleanly
            Future.delayed(const Duration(milliseconds: 250), () {
              final activeCtx = DPPApp.navigatorKey.currentContext ?? targetContext;
              _beginStepSequence(activeCtx);
            });
          },
          onSkip: () {
            Navigator.pop(dialogCtx);
            markTourCompleted();
          },
        ),
      );
    } else {
      _beginStepSequence(targetContext);
    }
  }

  void _beginStepSequence(BuildContext context) {
    _isActive = true;
    _currentStepIndex = 0;
    // Ensure we are firmly on the Puzzle Map
    MainShellState.instance?.selectedIndex = 0;

    Future.delayed(const Duration(milliseconds: 100), () {
      final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
      _showCurrentOverlay(activeCtx);
    });
  }

  void _showCurrentOverlay([BuildContext? context]) {
    final targetContext = context ?? DPPApp.navigatorKey.currentContext;
    if (targetContext == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (!_isActive) return;

    final currentStep = AppTourStepsData.steps[_currentStepIndex];

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => AppTourOverlay(
        step: currentStep,
        currentIndex: _currentStepIndex,
        totalSteps: totalSteps,
        onNext: () {
          final activeCtx = DPPApp.navigatorKey.currentContext ?? overlayContext;
          nextStep(activeCtx);
        },
        onBack: () {
          final activeCtx = DPPApp.navigatorKey.currentContext ?? overlayContext;
          previousStep(activeCtx);
        },
        onSkip: () {
          final activeCtx = DPPApp.navigatorKey.currentContext ?? overlayContext;
          skipTour(activeCtx);
        },
        isLastStep: _currentStepIndex == totalSteps - 1,
      ),
    );

    try {
      final overlay = Navigator.of(targetContext, rootNavigator: true).overlay;
      if (overlay != null) {
        overlay.insert(_overlayEntry!);
      }
    } catch (e) {
      debugPrint("AppTour: overlay insert error: $e");
    }
  }

  void nextStep(BuildContext context) {
    if (!_isActive) return;

    // 1. Moving from Puzzle shortcuts (index 2) -> Journal (index 3)
    if (_currentStepIndex == 2) {
      MainShellState.instance?.selectedIndex = 1; // Tab 1: Journal
      _currentStepIndex++;
      Future.delayed(const Duration(milliseconds: 150), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // 2. Moving from Journal end (index 8) -> Level Unlock Blueprint
    if (_currentStepIndex == 8) {
      _overlayEntry?.remove();
      _overlayEntry = null;

      MainShellState.instance?.selectedIndex = 0; // Return to Map

      final targetContext = DPPApp.navigatorKey.currentContext ?? context;
      showDialog(
        context: targetContext,
        barrierDismissible: false,
        builder: (dialogCtx) => AppTourLevelUnlockDialog(
          onNext: () {
            Navigator.pop(dialogCtx);
            _currentStepIndex = 9; // First step of Meal Logging
            Future.delayed(const Duration(milliseconds: 250), () {
              final activeCtx = DPPApp.navigatorKey.currentContext ?? targetContext;
              _pushFoodTrackingScreen(activeCtx);
            });
          },
          onBack: () {
            Navigator.pop(dialogCtx);
            MainShellState.instance?.selectedIndex = 1;
            _currentStepIndex = 8;
            Future.delayed(const Duration(milliseconds: 250), () {
              final activeCtx = DPPApp.navigatorKey.currentContext ?? targetContext;
              _showCurrentOverlay(activeCtx);
            });
          },
          onSkip: () {
            Navigator.pop(dialogCtx);
            skipTour(targetContext);
          },
        ),
      );
      return;
    }

    // 3. Moving from Meal Logging end (index 17) -> Activity Screen
    if (_currentStepIndex == 17) {
      if (_isFoodTrackingPushed) {
        Navigator.of(context).maybePop();
        _isFoodTrackingPushed = false;
      }
      _currentStepIndex = 18; // First step of Activity
      Future.delayed(const Duration(milliseconds: 250), () {
        final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
        _pushActivityFitnessScreen(activeCtx);
      });
      return;
    }

    // 4. Moving from Activity end (index 26) -> Dashboard
    if (_currentStepIndex == 26) {
      if (_isActivityPushed) {
        Navigator.of(context).maybePop();
        _isActivityPushed = false;
      }
      MainShellState.instance?.selectedIndex = 2; // Tab 2: Dashboard
      _currentStepIndex = 27; // First step of Dashboard
      Future.delayed(const Duration(milliseconds: 250), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // 5. Moving from Dashboard end (index 31) -> User Menu
    if (_currentStepIndex == 31) {
      Scaffold.of(context).openEndDrawer();
      _currentStepIndex = 32; // User Menu
      Future.delayed(const Duration(milliseconds: 250), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // 6. Moving from User Menu end (index 37) -> Leaderboard
    if (_currentStepIndex == 37) {
      Navigator.of(context).maybePop(); // Close drawer
      MainShellState.instance?.selectedIndex = 3; // Tab 3: Leaderboard
      _currentStepIndex = 38;
      Future.delayed(const Duration(milliseconds: 250), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // 7. Moving from Leaderboard end (index 40) -> AI Coach
    if (_currentStepIndex == 40) {
      MainShellState.instance?.selectedIndex = 4; // Tab 4: AI Coach
      _currentStepIndex = 41;
      Future.delayed(const Duration(milliseconds: 150), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // 8. Completed last step of AI Coach (index 43) -> Final Congratulations!
    if (_currentStepIndex >= totalSteps - 1) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isActive = false;

      final targetContext = DPPApp.navigatorKey.currentContext ?? context;
      showDialog(
        context: targetContext,
        barrierDismissible: false,
        builder: (dialogCtx) => AppTourCompletionDialog(
          onFinish: () {
            Navigator.pop(dialogCtx);
            markTourCompleted();
            MainShellState.instance?.selectedIndex = 0; // Return to Map
          },
        ),
      );
      return;
    }

    // Standard increment on same screen
    _currentStepIndex++;
    _showCurrentOverlay(context);
  }

  void previousStep(BuildContext context) {
    if (!_isActive || _currentStepIndex <= 0) return;

    // Moving back from Journal start (index 3) -> Puzzle map
    if (_currentStepIndex == 3) {
      MainShellState.instance?.selectedIndex = 0;
      _currentStepIndex = 2;
      Future.delayed(const Duration(milliseconds: 150), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // Moving back from Meal Logging start (index 9) -> Level Unlock Blueprint
    if (_currentStepIndex == 9) {
      if (_isFoodTrackingPushed) {
        Navigator.of(context).maybePop();
        _isFoodTrackingPushed = false;
      }
      _overlayEntry?.remove();
      _overlayEntry = null;

      final targetContext = DPPApp.navigatorKey.currentContext ?? context;
      showDialog(
        context: targetContext,
        barrierDismissible: false,
        builder: (dialogCtx) => AppTourLevelUnlockDialog(
          onNext: () {
            Navigator.pop(dialogCtx);
            _currentStepIndex = 9;
            Future.delayed(const Duration(milliseconds: 250), () {
              final activeCtx = DPPApp.navigatorKey.currentContext ?? targetContext;
              _pushFoodTrackingScreen(activeCtx);
            });
          },
          onBack: () {
            Navigator.pop(dialogCtx);
            MainShellState.instance?.selectedIndex = 1;
            _currentStepIndex = 8;
            Future.delayed(const Duration(milliseconds: 250), () {
              final activeCtx = DPPApp.navigatorKey.currentContext ?? targetContext;
              _showCurrentOverlay(activeCtx);
            });
          },
          onSkip: () {
            Navigator.pop(dialogCtx);
            skipTour(targetContext);
          },
        ),
      );
      return;
    }

    // Moving back from Activity start (index 18) -> Meal Logging
    if (_currentStepIndex == 18) {
      if (_isActivityPushed) {
        Navigator.of(context).maybePop();
        _isActivityPushed = false;
      }
      _currentStepIndex = 17;
      Future.delayed(const Duration(milliseconds: 250), () {
        final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
        _pushFoodTrackingScreen(activeCtx);
      });
      return;
    }

    // Moving back from Dashboard start (index 27) -> Activity
    if (_currentStepIndex == 27) {
      _currentStepIndex = 26;
      Future.delayed(const Duration(milliseconds: 250), () {
        final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
        _pushActivityFitnessScreen(activeCtx);
      });
      return;
    }

    // Moving back from User Menu start (index 32) -> Dashboard
    if (_currentStepIndex == 32) {
      Navigator.of(context).maybePop(); // Close drawer
      _currentStepIndex = 31;
      Future.delayed(const Duration(milliseconds: 250), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // Moving back from Leaderboard start (index 38) -> User Menu
    if (_currentStepIndex == 38) {
      MainShellState.instance?.selectedIndex = 2;
      Scaffold.of(context).openEndDrawer();
      _currentStepIndex = 37;
      Future.delayed(const Duration(milliseconds: 250), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    // Moving back from AI Coach start (index 41) -> Leaderboard
    if (_currentStepIndex == 41) {
      MainShellState.instance?.selectedIndex = 3;
      _currentStepIndex = 40;
      Future.delayed(const Duration(milliseconds: 150), () {
        _showCurrentOverlay(context);
      });
      return;
    }

    _currentStepIndex--;
    _showCurrentOverlay(context);
  }

  void skipTour(BuildContext context) {
    _isActive = false;
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (_isFoodTrackingPushed || _isActivityPushed) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      _isFoodTrackingPushed = false;
      _isActivityPushed = false;
    }

    markTourCompleted();
    MainShellState.instance?.selectedIndex = 0;
  }

  void _pushFoodTrackingScreen(BuildContext context) {
    _isFoodTrackingPushed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FoodTrackingScreen()),
    ).then((_) {
      _isFoodTrackingPushed = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_isActive) {
          final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
          _showCurrentOverlay(activeCtx);
        }
      });
    });
  }

  void _pushActivityFitnessScreen(BuildContext context) {
    _isActivityPushed = true;
    _overlayEntry?.remove();
    _overlayEntry = null;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActivityFitnessScreen()),
    ).then((_) {
      _isActivityPushed = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (_isActive) {
          final activeCtx = DPPApp.navigatorKey.currentContext ?? context;
          _showCurrentOverlay(activeCtx);
        }
      });
    });
  }
}
