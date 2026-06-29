import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/food_log.dart';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dpp_app/services/auth_service.dart';
import 'dart:async';
import 'chat_service.dart';

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
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

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
          final List<Map<String, String>> messages = [
            {'title': '🍳 Rise & Dine!', 'body':'Your body is ready for its next dose of energy.Grab a healthy bite.'},
            {'title': 'Your future self sent a request 📨', 'body': 'Please log that meal before we forget what it was'},
            {'title': '$mealType? Is Calling 📞', 'body':' Don\'t leave it on read. Your body deserves a proper meal.'},
            {'title': 'Time to refuel! ⛽', 'body': 'Did you eat $mealType yet? Log it to stay on track. You got this! 💪'},
           {'title': '⭐ Achievement unlocked: Responsible Human', 'body': 'Now log in your meal $mealType to maintain the title.'},
            {'title': 'Is it $mealType o\'clock? ⏰', 'body': 'Your stomach might be full, but your food diary is empty! Let\'s fix that. 🍎'},
           {'title': '🍳 BREAKING: Your stomach filed a complaint', 'body': 'Apparently it hasn\'t been fed yet. Care to settle this dispute?'},
            {'title': 'Nom nom nom... 😋', 'body': 'We know you had $mealType. Give us the details! Keep the consistency going! 🔥'},
           {'title': '🚨 Evidence needed', 'body': 'Did food happen today? Our records are suspiciously empty.'},
            {'title': 'Fuel for the machine! 🤖', 'body': 'Log your $mealType and show us what you\'re made of today. Let\'s gooo! ✨'},
          ];
          final msg = messages[id % messages.length];

          await _plugin.zonedSchedule(
            id: id,
            title: msg['title'],
            body: msg['body'],
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

  Future<void> scheduleAssessmentReminder() async {
    if (!_initialized) await init();

    await _plugin.show(
      id: 999, // Unique ID for this reminder
      title: 'Health Assessments Missing',
      body: 'Please complete your IDRS and GPAQ assessments to unlock personalized insights.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'assessment_channel',
          'Assessment Reminders',
          channelDescription: 'Reminders to complete health assessments',
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
    );
  }

  Future<void> scheduleWeeklyWeighInReminder(DateTime lastWeighIn) async {
    if (!_initialized) await init();

    DateTime scheduleTime = lastWeighIn.add(const Duration(minutes: 30));
    
    if (scheduleTime.isBefore(DateTime.now())) {
      return;
    }

    await _plugin.zonedSchedule(
      id: 888, // Unique ID for weigh-in
      title: 'Weekly Weigh-In Time!',
      body: 'It has been a week since your last weigh-in. Tap to log your progress!',
      scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'weigh_in_channel',
          'Weigh-In Reminders',
          channelDescription: 'Reminders to log your weekly weight',
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

  // --- Chat Notifications ---
  
  static String? _currentUserId;
  static String? _currentUserRole;

  void startChatListener() async {
    if (!_initialized) await init();

    final user = AuthService().currentUser;
    if (user == null) return;
    _currentUserId = user.uid;

    _currentUserRole = await AuthService().getUserRole();

    if (_currentUserRole == 'coach') {
      _listenToCoachChats();
    } else {
      _listenToPatientChats();
    }
  }

  bool _isCoachOnline = true;
  StreamSubscription? _coachStatusSub;

  void _listenToCoachChats() {
    _coachStatusSub?.cancel();
    _coachStatusSub = ChatService.getCoachOnlineStatusStream(_currentUserId!).listen((isOnline) {
      final wasOffline = !_isCoachOnline;
      _isCoachOnline = isOnline;
      
      if (wasOffline && isOnline) {
        _triggerMissedCoachNotifications();
      }
    });

    FirebaseFirestore.instance
        .collection('Coachuserchats')
        .where('coachId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      
      if (!_isCoachOnline) return;

      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          
          final unreadByCoach = data['unreadByCoach'] as int? ?? 0;
          final lastMessageText = data['lastMessageText'] as String? ?? '';
          
          print('DEBUG: _listenToCoachChats - unreadByCoach: $unreadByCoach');

          if (unreadByCoach > 0) {
            _getUserName(data['patientId']).then((name) {
              print('DEBUG: _listenToCoachChats - showing notification for coach');
              _showChatNotification(
                id: (change.doc.id.hashCode.abs() % 100000),
                title: 'You have a message from $name',
                body: lastMessageText,
              );
            }).catchError((e) {
              print('DEBUG: _listenToCoachChats - error: $e');
            });
          }
        }
      }
    });
  }

  void _triggerMissedCoachNotifications() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Coachuserchats')
        .where('coachId', isEqualTo: _currentUserId)
        .where('unreadByCoach', isGreaterThan: 0)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lastMessageText = data['lastMessageText'] as String? ?? '';
      
      _getUserName(data['patientId']).then((name) {
        _showChatNotification(
          id: (doc.id.hashCode.abs() % 100000),
          title: 'You have a message from $name',
          body: lastMessageText,
        );
      });
    }
  }

  void _listenToPatientChats() {
    FirebaseFirestore.instance
        .collection('Coachuserchats')
        .where('patientId', isEqualTo: _currentUserId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified || change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          if (data == null) continue;
          
          final unreadByPatient = data['unreadByPatient'] as int? ?? 0;
          final lastMessageText = data['lastMessageText'] as String? ?? '';
          
          print('DEBUG: _listenToPatientChats - unreadByPatient: $unreadByPatient');

          if (unreadByPatient > 0) {
            print('DEBUG: _listenToPatientChats - showing notification for patient');
            _showChatNotification(
              id: (change.doc.id.hashCode.abs() % 100000),
              title: 'You have a message from coach',
              body: lastMessageText,
            );
          }
        }
      }
    });
  }

  Future<void> _showChatNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_channel',
          'Chat Messages',
          channelDescription: 'Notifications for incoming chat messages',
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
    );
  }

  Future<String> _getUserName(String? uid) async {
    if (uid == null) return 'Patient';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['name'] ?? 'Patient';
    } catch (e) {
      return 'Patient';
    }
  }
}
