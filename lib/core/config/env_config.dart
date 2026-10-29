import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Environment Configuration for Cashew Store (User App)
/// Reads values from `.env` loaded via [flutter_dotenv] with safe fallback.
class EnvConfig {
  static bool _isLoaded = false;
  static bool get isLoaded => _isLoaded;

  /// Loads `.env` file from assets. Gracefully falls back if file is missing.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
      if (kDebugMode) {
        debugPrint('🌿 EnvConfig: .env loaded successfully ($appEnv environment)');
      }
    } catch (e) {
      _isLoaded = false;
      if (kDebugMode) {
        debugPrint('⚠️ EnvConfig: .env file not found or failed to load. Using defaults: $e');
      }
    }
  }

  static String _get(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;
    return dotenv.env[key] ?? fallback;
  }

  // App & Environment
  static String get appEnv => _get('APP_ENV', 'development');
  static String get appName => _get('APP_NAME', 'Cashew Store');
  static bool get isProduction => appEnv.toLowerCase() == 'production';
  static bool get isDevelopment => !isProduction;

  // API Configuration
  static String get apiBaseUrl {
    final envUrl = _get('API_BASE_URL', '');
    if (envUrl.trim().isNotEmpty) {
      if (Platform.isAndroid && envUrl.contains('localhost')) {
        return envUrl.replaceAll('localhost', '10.0.2.2');
      }
      return envUrl.trim();
    }

    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    } else {
      return 'http://localhost:3000/api/v1';
    }
  }

  static int get apiTimeoutSeconds {
    final raw = _get('API_TIMEOUT_SECONDS', '15');
    return int.tryParse(raw) ?? 15;
  }

  // Payment Keys (Client / Publishable Only)
  static String get razorpayKeyId => _get('RAZORPAY_KEY_ID', '');
  static String get stripePublishableKey => _get('STRIPE_PUBLISHABLE_KEY', '');

  // Firebase Configuration
  static String get firebaseProjectId => _get('FIREBASE_PROJECT_ID', 'cashew-app-16075');
  static String get firebaseAppId => _get('FIREBASE_APP_ID', '');
  static String get firebaseApiKey => _get('FIREBASE_API_KEY', '');
  static String get firebaseStorageBucket => _get('FIREBASE_STORAGE_BUCKET', '');
  static String get defaultNotificationChannelId =>
      _get('DEFAULT_NOTIFICATION_CHANNEL_ID', 'cashew_store_orders');

  // Security & Feature Flags
  static bool get enableCrashlytics {
    final raw = _get('ENABLE_CRASHLYTICS', 'true');
    return raw.toLowerCase() == 'true';
  }

  static bool get enablePushNotifications {
    final raw = _get('ENABLE_PUSH_NOTIFICATIONS', 'true');
    return raw.toLowerCase() == 'true';
  }

  static bool get enableDebugLogs {
    final raw = _get('ENABLE_DEBUG_LOGS', kDebugMode.toString());
    return raw.toLowerCase() == 'true';
  }

  static String get secureStorageKeyPrefix =>
      _get('SECURE_STORAGE_KEY_PREFIX', 'cashew_store_secure_');
}
