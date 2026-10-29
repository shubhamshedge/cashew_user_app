import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';

/// Top-level background message handler required by Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Background Firebase init notice: $e');
  }
  debugPrint('📬 Handling FCM background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title ?? message.data['title']}');
  debugPrint('Body: ${message.notification?.body ?? message.data['body']}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  bool _isLocalInitialized = false;
  bool _isFirebaseInitialized = false;
  bool get isInitialized => _isLocalInitialized;

  // Notification Channel Constants
  static const String ordersChannelId = 'cashew_store_orders';
  static const String ordersChannelName = 'Orders & Delivery Updates';
  static const String ordersChannelDesc = 'Alerts for order confirmation, dispatch, out for delivery and completed deliveries.';

  static const String promosChannelId = 'cashew_store_promos';
  static const String promosChannelName = 'Offers & Promotions';
  static const String promosChannelDesc = 'Exclusive discounts, coupons, and seasonal cashew offers.';

  /// Safe getter for FirebaseMessaging instance
  FirebaseMessaging? get _fcm {
    if (!_isFirebaseInitialized && Firebase.apps.isEmpty) return null;
    try {
      return FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('FirebaseMessaging.instance notice: $e');
      return null;
    }
  }

  /// Initialize Local Notification channels & Firebase Messaging
  Future<void> initialize({DioClient? apiClient}) async {
    // 1. Setup Local Notification channels first (guaranteed to work regardless of Firebase state)
    try {
      await _initializeLocalNotifications();
      _isLocalInitialized = true;
      debugPrint('✅ Local notifications initialized successfully');
    } catch (e) {
      debugPrint('Local notifications init error: $e');
    }

    // 2. Initialize Firebase Core
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _isFirebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('Firebase.initializeApp notice (operating with local simulator): $e');
    }

    // 3. Request User Permissions (iOS & Android 13+)
    await requestPermissions();

    // 4. Setup FCM listeners if Firebase is active
    if (_isFirebaseInitialized && _fcm != null) {
      try {
        _setupMessageHandlers();
        await _retrieveAndSyncToken(apiClient);
      } catch (e) {
        debugPrint('FCM handlers setup notice: $e');
      }
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android Notification Channels
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            ordersChannelId,
            ordersChannelName,
            description: ordersChannelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );

        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            promosChannelId,
            promosChannelName,
            description: promosChannelDesc,
            importance: Importance.defaultImportance,
            playSound: true,
            showBadge: true,
          ),
        );
      }
    }
  }

  /// Request permissions for iOS and Android 13+ (POST_NOTIFICATIONS)
  Future<void> requestPermissions() async {
    // Android 13+ permission via local notifications
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Android notification permission error: $e');
      }
    }

    // iOS and FCM permissions
    if (_fcm != null) {
      try {
        final settings = await _fcm!.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
        debugPrint('FCM permission status: ${settings.authorizationStatus}');
      } catch (e) {
        debugPrint('FCM permission notice: $e');
      }
    }
  }

  /// Set up Firebase foreground, background, and notification tap handlers
  void _setupMessageHandlers() {
    if (_fcm == null) return;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground messages (display as a heads-up banner)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Foreground FCM Message Received: ${message.messageId}');
        _handleForegroundMessage(message);
      });

      // App opened from background by tapping notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🚀 Notification clicked from background: ${message.data}');
        _handleNotificationPayload(message.data);
      });

      // Check if app was launched from a terminated state via notification
      _fcm!.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          debugPrint('🚀 App launched from terminated state via notification: ${message.data}');
          _handleNotificationPayload(message.data);
        }
      });
    } catch (e) {
      debugPrint('Error setting up message handlers: $e');
    }
  }

  /// Handle incoming foreground messages and show banner notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'Cashew Store';
    final body = notification?.body ?? message.data['body'] ?? '';
    final channel = (message.data['type'] == 'PROMOTION') ? promosChannelId : ordersChannelId;

    await showLocalNotification(
      id: message.hashCode,
      title: title,
      body: body,
      channelId: channel,
      payload: jsonEncode(message.data),
    );
  }

  /// Display a heads-up local banner notification (works on Android & iOS)
  Future<void> showLocalNotification({
    int? id,
    required String title,
    required String body,
    String channelId = ordersChannelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == promosChannelId ? promosChannelName : ordersChannelName,
      channelDescription: channelId == promosChannelId ? promosChannelDesc : ordersChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Retrieve FCM token and optionally send to backend
  Future<String?> _retrieveAndSyncToken(DioClient? apiClient) async {
    if (_fcm == null) return null;
    try {
      _fcmToken = await _fcm!.getToken();
      debugPrint('🔑 FCM Device Token: $_fcmToken');

      if (_fcmToken != null && apiClient != null) {
        await syncTokenWithBackend(apiClient, _fcmToken!);
      }

      _fcm!.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 FCM Token refreshed: $newToken');
        if (apiClient != null) {
          syncTokenWithBackend(apiClient, newToken);
        }
      });

      return _fcmToken;
    } catch (e) {
      debugPrint('FCM getToken notice: $e');
      return null;
    }
  }

  /// Send device token to backend server
  Future<void> syncTokenWithBackend(DioClient apiClient, String token) async {
    try {
      final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
      await apiClient.post(
        '/notifications/device-token',
        data: {
          'token': token,
          'platform': platform,
          'deviceLabel': '${Platform.operatingSystem} device',
        },
      );
      debugPrint('Device token synced with backend');
    } catch (e) {
      debugPrint('Sync device token notice: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleNotificationPayload(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  void _handleNotificationPayload(Map<String, dynamic> data) {
    debugPrint('🔔 Navigating based on notification payload: $data');
  }

  // =========================================================================
  // The 6 Specific Notification Events
  // =========================================================================

  /// 1. Order Confirmed
  Future<void> showOrderConfirmedNotification({required String orderNumber}) async {
    await showLocalNotification(
      title: 'Order Confirmed 🎉',
      body: 'Your order #$orderNumber has been confirmed.',
      channelId: ordersChannelId,
      payload: jsonEncode({'type': 'ORDER_CONFIRMED', 'orderNumber': orderNumber}),
    );
  }

  /// 2. Payment Successful
  Future<void> showPaymentSuccessfulNotification({String? orderNumber}) async {
    await showLocalNotification(
      title: 'Payment Successful 💳',
      body: 'Payment received successfully.',
      channelId: ordersChannelId,
      payload: jsonEncode({'type': 'PAYMENT_SUCCESS', 'orderNumber': orderNumber}),
    );
  }

  /// 3. Order Dispatched
  Future<void> showOrderDispatchedNotification({String? orderNumber}) async {
    await showLocalNotification(
      title: 'Order Dispatched 📦',
      body: 'Your cashew order is on its way.',
      channelId: ordersChannelId,
      payload: jsonEncode({'type': 'ORDER_DISPATCHED', 'orderNumber': orderNumber}),
    );
  }

  /// 4. Out for Delivery
  Future<void> showOutForDeliveryNotification({String? orderNumber}) async {
    await showLocalNotification(
      title: 'Out for Delivery 🚚',
      body: 'Your order will arrive soon.',
      channelId: ordersChannelId,
      payload: jsonEncode({'type': 'OUT_FOR_DELIVERY', 'orderNumber': orderNumber}),
    );
  }

  /// 5. Order Delivered
  Future<void> showOrderDeliveredNotification({String? orderNumber}) async {
    await showLocalNotification(
      title: 'Order Delivered ✅',
      body: 'Your order has been delivered.',
      channelId: ordersChannelId,
      payload: jsonEncode({'type': 'ORDER_DELIVERED', 'orderNumber': orderNumber}),
    );
  }

  /// 6. Promotional Offer
  Future<void> showPromotionalOfferNotification({String? offerText, String? code}) async {
    await showLocalNotification(
      title: 'Special Offer 🎁',
      body: offerText ?? 'Get 10% off your next order.',
      channelId: promosChannelId,
      payload: jsonEncode({'type': 'PROMOTION', 'code': code ?? 'CASHEW10'}),
    );
  }
}
