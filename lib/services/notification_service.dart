import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';
import 'package:moon_motorcycle_redesign/services/api_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }

  void showLoginNotification() {
    _showAndSaveNotification('Welcome Back!', 'You have successfully logged in.');
  }

  void showBookingApprovedNotification() {
    _showAndSaveNotification('Booking Approved!', 'Your motorcycle booking has been approved.');
  }

  Future<void> _showAndSaveNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      platformChannelSpecifics,
    );

    final userId = _authService.currentUserId;
    if (userId != null) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/users/$userId/notifications'),
          headers: {
            'Content-Type': 'application/json',
            if (_authService.token != null) 'Authorization': 'Bearer ${_authService.token}',
          },
          body: jsonEncode({
            'title': title,
            'body': body,
          }),
        );
      } catch (e) {
        print('Error saving notification: $e');
      }
    }
  }
}
