import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_service_mobile.dart' if (dart.library.js) 'notification_service_web.dart' as platform;

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  NotificationService._();

  static final NotificationService _instance = NotificationService._();

  factory NotificationService() {
    return _instance;
  }

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission();
    
    if (!kIsWeb) {
      // Mobile-specific initialization
      await platform.initializeLocalNotifications();
    }
    
    print('Notification service initialized for ${kIsWeb ? 'web' : 'mobile'}');
  }
}