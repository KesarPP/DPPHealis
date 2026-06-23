import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/food_log.dart';
import 'dart:io' show Platform;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  final Map<String, List<int>> _mealTimes = {
    'Breakfast': [7, 9],
    'Snack 1': [11, 12],
    'Lunch': [14, 16],
    'Snack 2': [18, 19],
    'Dinner': [21, 23],
  };

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInitialize = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidInitialize,
      iOS: darwinInitialize,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  int _generateId(DateTime date, String mealType, int timeIndex) {
    // Unique ID based on date, meal, and the time slot index
    int dateHash = (date.year - 2024) * 400 + date.month * 32 + date.day;
    int mealIndex = _mealTimes.keys.toList().indexOf(mealType);
    return (dateHash * 100) + (mealIndex * 10) + timeIndex;
  }

  Future<void> scheduleMealReminders(DailyFoodLog? todayLog) async {
    if (!_initialized) await init();

    DateTime now = DateTime.now();
    
    // We schedule for the next 7 days to ensure notifications work even if the app isn't opened
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      DateTime targetDate = now.add(Duration(days: dayOffset));
      
      for (var entry in _mealTimes.entries) {
        String mealType = entry.key;
        List<int> hours = entry.value;
        
        // Check if meal is logged for TODAY
        bool isLoggedToday = false;
        if (dayOffset == 0 && todayLog != null) {
          isLoggedToday = todayLog.entries.any((e) => e.mealType == mealType);
        }
        
        for (int i = 0; i < hours.length; i++) {
          int hour = hours[i];
          int id = _generateId(targetDate, mealType, i);
          
          DateTime scheduleTime = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, 0);
          
          // If the time has passed, or if the meal was already logged today, cancel the notification
          if (scheduleTime.isBefore(now) || isLoggedToday) {
            await _plugin.cancel(id: id);
            continue;
          }
          
          // Otherwise, schedule it exactly
          await _plugin.zonedSchedule(
            id: id,
            title: 'Time for $mealType!',
            body: 'Don\'t forget to log your $mealType to keep your streak going.',
            scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
            notificationDetails: const NotificationDetails(
              android: AndroidNotificationDetails(
                'meal_reminders_channel',
                'Meal Reminders',
                channelDescription: 'Reminders to log your meals',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          );
        }
      }
    }
  }
}
