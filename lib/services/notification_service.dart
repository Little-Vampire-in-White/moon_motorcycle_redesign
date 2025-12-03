import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moon_motorcycle_redesign/services/auth_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> init() async {
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showAndSaveNotification(message.notification!);
      }
    });
    return fcmToken;
  }

  Future<void> requestPermission() async {
    await _firebaseMessaging.requestPermission();
  }

  void showLoginNotification() {
    _showAndSaveNotification(const RemoteNotification(
      title: 'Welcome Back!',
      body: 'You have successfully logged in.',
    ));
  }

  void showBookingApprovedNotification() {
    _showAndSaveNotification(const RemoteNotification(
      title: 'Booking Approved!',
      body: 'Your motorcycle booking has been approved.',
    ));
  }

  Future<void> _showAndSaveNotification(RemoteNotification notification) async {
    // Show the notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // channel id
      'High Importance Notifications', // channel name
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode, // Use a unique id for each notification
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );

    // Save the notification to Firestore
    final user = _authService.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
        'title': notification.title,
        'body': notification.body,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    }
  }
}
