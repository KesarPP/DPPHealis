import 'package:flutter/material.dart';
import '../data/gelato_theme.dart';
import 'app_tour_models.dart';

class AppTourStepsData {
  AppTourStepsData._();

  static const List<TourStep> steps = [
    // =============================================================
    // Screen 2: Puzzle Map (Tab 0)
    // Entire screen visible, explanations at bottom
    // =============================================================
    TourStep(
      id: 'puzzle_intro',
      sectionLabel: 'Puzzle Map',
      title: 'Welcome to your Puzzle Map! 🧩',
      body: 'This is where your health journey unfolds. Each block represents a level that brings you one step closer to building healthier habits.',
      screenType: TourScreenType.puzzles,
      cardColor: GelatoTheme.green,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'puzzle_levels',
      sectionLabel: 'Puzzle Map',
      title: 'Your journey is divided into weekly levels!',
      body: 'Complete weekly activities to unlock new levels and advance your journey!',
      screenType: TourScreenType.puzzles,
      cardColor: GelatoTheme.yellow,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'puzzle_shortcuts',
      sectionLabel: 'Puzzle Map',
      title: 'Your daily health activities are just a tap away!',
      body: 'Use these shortcuts to quickly log your meals and record your physical activities.',
      screenType: TourScreenType.puzzles,
      cardColor: GelatoTheme.pink,
      arrowDirection: ArrowDirection.bottom,
      topFraction: 0.40,
      spotlightFraction: Rect.fromLTWH(0.04, 0.70, 0.92, 0.16),
    ),

    // =============================================================
    // Screen 3: Health Journal (Tab 1)
    // Blocks kept at bottom not covering the page, no arrows
    // =============================================================
    TourStep(
      id: 'journal_intro',
      sectionLabel: 'Health Journal',
      title: 'Welcome to your Health Journal! 📖',
      body: 'This is your weekly learning space with educational sessions and activities designed to help you make healthier choices.',
      screenType: TourScreenType.journal,
      cardColor: GelatoTheme.blue,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'journal_video',
      sectionLabel: 'Health Journal',
      title: 'Start your weekly learning journey here! 🎥',
      body: 'Watch your session video to learn about important topics related to healthy eating, physical activity, and diabetes prevention.',
      screenType: TourScreenType.journal,
      cardColor: GelatoTheme.purple,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'journal_notes',
      sectionLabel: 'Health Journal',
      title: 'Want to revisit something you learned? 📝',
      body: 'Swipe to explore your session notes and revise important tips anytime.',
      screenType: TourScreenType.journal,
      cardColor: GelatoTheme.yellow,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'journal_quiz',
      sectionLabel: 'Health Journal',
      title: 'Time to test what you’ve learned! 💡',
      body: 'Taking your weekly quiz is essential to test your knowledge and move forward!',
      screenType: TourScreenType.journal,
      cardColor: GelatoTheme.green,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'journal_weigh_in',
      sectionLabel: 'Health Journal',
      title: 'Track your progress, one week at a time! ⚖️',
      body: 'Recording your weight every week helps us track your progress over time.',
      screenType: TourScreenType.journal,
      cardColor: GelatoTheme.pink,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),

    // =============================================================
    // Screen 5: Meal Logging
    // Calendar box perfectly sized and fitted around calendar
    // =============================================================
    TourStep(
      id: 'meals_intro',
      sectionLabel: 'Meal Logging',
      title: 'Welcome to your Meal Logging screen! 🥗',
      body: 'Keep track of your meals, calories, and nutrition throughout the day across all five meal slots.',
      screenType: TourScreenType.mealLogging,
      cardColor: GelatoTheme.pink,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'meals_insights',
      sectionLabel: 'Meal Logging',
      title: 'Welcome to your Insights! 💡',
      body: 'Explore nutrition patterns, calorie trends, macronutrient breakdowns, and your nutrition score to make informed food choices.',
      screenType: TourScreenType.mealLogging,
      cardColor: GelatoTheme.blue,
      arrowDirection: ArrowDirection.top,
      topFraction: 0.42,
      spotlightFraction: Rect.fromLTWH(0.04, 0.28, 0.29, 0.10),
    ),
    TourStep(
      id: 'meals_calendar',
      sectionLabel: 'Meal Logging',
      title: 'Keep an eye on your logging journey! 🟢',
      body: 'Track your daily logging progress using the calendar. Green indicates all five meals logged, while orange indicates some meals logged.',
      screenType: TourScreenType.mealLogging,
      cardColor: GelatoTheme.yellow,
      arrowDirection: ArrowDirection.top,
      topFraction: 0.63,
      spotlightFraction: Rect.fromLTWH(0.035, 0.38, 0.93, 0.21),
    ),

    // =============================================================
    // Screen 6: Physical Activity
    // Clean: Intro, Connecting & Syncing, Tracking Info
    // =============================================================
    TourStep(
      id: 'activity_intro',
      sectionLabel: 'Activity',
      title: 'Welcome to your Activity screen! 🏃',
      body: 'This is where you can monitor your physical activity and track your progress towards your weekly fitness goals.',
      screenType: TourScreenType.activity,
      cardColor: GelatoTheme.orange,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'activity_connect_sync',
      sectionLabel: 'Activity',
      title: 'Connect & Sync Your Fitness Data 🔗',
      body: 'Connect your Google Fit or Health Connect account to automatically sync your daily steps, active minutes, and workouts with the app.',
      screenType: TourScreenType.activity,
      cardColor: GelatoTheme.blue,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'activity_tracking_info',
      sectionLabel: 'Activity',
      title: 'Track Your Daily Activity 📊',
      body: 'Monitor your movement, stay consistent, and work towards at least 150 minutes of moderate activity each week to prevent diabetes!',
      screenType: TourScreenType.activity,
      cardColor: GelatoTheme.green,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),

    // =============================================================
    // Screen 7: Dashboard (Tab 2)
    // Small size, bottom anchored, show arrow to User Menu
    // =============================================================
    TourStep(
      id: 'dashboard_intro',
      sectionLabel: 'Dashboard',
      title: 'Welcome to your Dashboard! 📊',
      body: 'Your personal health overview all in one place. Keep track of your weight, activity, energy balance, and daily missions!',
      screenType: TourScreenType.dashboard,
      cardColor: GelatoTheme.blue,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
    TourStep(
      id: 'dashboard_menu',
      sectionLabel: 'Dashboard',
      title: 'Access your User Menu 📋',
      body: 'Tap your profile icon at the top right to access assessments, weekly records, and FAQs.',
      screenType: TourScreenType.dashboard,
      cardColor: GelatoTheme.yellow,
      arrowDirection: ArrowDirection.top,
      topFraction: 0.18,
      spotlightFraction: Rect.fromLTWH(0.80, 0.04, 0.16, 0.08),
    ),

    // =============================================================
    // Screen 8: User Menu Drawer Showcase
    // Block & arrows removed so user can see the open menu!
    // =============================================================
    TourStep(
      id: 'menu_drawer_showcase',
      sectionLabel: 'User Menu',
      title: 'User Menu',
      body: '',
      screenType: TourScreenType.userMenu,
      cardColor: GelatoTheme.green,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),

    // =============================================================
    // Screen 9: Leaderboard (Tab 3)
    // Small size, bottom anchored
    // =============================================================
    TourStep(
      id: 'leaderboard_intro',
      sectionLabel: 'Leaderboard',
      title: 'Welcome to the Leaderboard! 🏆',
      body: 'A little friendly competition makes your journey even more exciting! Log meals and activities to earn points and climb the ranks.',
      screenType: TourScreenType.leaderboard,
      cardColor: GelatoTheme.green,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),

    // =============================================================
    // Screen 10: AI Coach (Tab 4)
    // Small size, bottom anchored
    // =============================================================
    TourStep(
      id: 'ai_coach_intro',
      sectionLabel: 'AI Coach',
      title: 'Meet your AI Coach! 🤖',
      body: 'Have questions about healthy eating, physical activity, or diabetes prevention? Your AI Coach is here 24/7 to help.',
      screenType: TourScreenType.aiCoach,
      cardColor: GelatoTheme.purple,
      arrowDirection: ArrowDirection.none,
      topFraction: 0.70,
      spotlightFraction: null,
    ),
  ];
}
