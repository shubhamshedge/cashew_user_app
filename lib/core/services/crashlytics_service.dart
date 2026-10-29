import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized Firebase Crashlytics service for crash reporting, fatal & non-fatal errors,
/// breadcrumb logging, and user diagnostics.
class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// Initializes Crashlytics and hooks Flutter/Platform uncaught error handlers.
  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      final crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection (enabled for all release & debug builds by default)
      await crashlytics.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught "fatal" errors from the Flutter framework to Crashlytics
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        crashlytics.recordFlutterFatalError(details);
      };

      // Pass all uncaught asynchronous errors not handled by the Flutter framework
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _isInitialized = true;
      debugPrint('🔥 Firebase Crashlytics initialized and error handlers attached.');
    } catch (e, stack) {
      debugPrint('⚠️ Firebase Crashlytics initialization notice: $e');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
    }
  }

  /// Record non-fatal exception with optional stack trace and reason
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    try {
      if (!_isInitialized && Firebase.apps.isEmpty) return;
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
      debugPrint('📝 Logged ${fatal ? "fatal" : "non-fatal"} error to Crashlytics: $exception');
    } catch (e) {
      debugPrint('Error reporting to Crashlytics: $e');
    }
  }

  /// Add custom breadcrumb log message to appear with crash reports
  static Future<void> log(String message) async {
    try {
      if (!_isInitialized && Firebase.apps.isEmpty) return;
      await FirebaseCrashlytics.instance.log(message);
      debugPrint('💬 Crashlytics breadcrumb: $message');
    } catch (e) {
      debugPrint('Error logging breadcrumb: $e');
    }
  }

  /// Set user identifier so crashes can be correlated with specific users
  static Future<void> setUserIdentifier(String identifier) async {
    try {
      if (!_isInitialized && Firebase.apps.isEmpty) return;
      await FirebaseCrashlytics.instance.setUserIdentifier(identifier);
      debugPrint('👤 Crashlytics user identifier set: $identifier');
    } catch (e) {
      debugPrint('Error setting Crashlytics user identifier: $e');
    }
  }

  /// Clear user identifier on logout
  static Future<void> clearUserIdentifier() async {
    try {
      if (!_isInitialized && Firebase.apps.isEmpty) return;
      await FirebaseCrashlytics.instance.setUserIdentifier('');
    } catch (e) {
      debugPrint('Error clearing Crashlytics user identifier: $e');
    }
  }

  /// Set custom key-value diagnostic metadata
  static Future<void> setCustomKey(String key, Object value) async {
    try {
      if (!_isInitialized && Firebase.apps.isEmpty) return;
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      debugPrint('Error setting custom key on Crashlytics: $e');
    }
  }

  /// Trigger a test fatal crash to verify Crashlytics reporting in the Firebase console
  static void testCrash() {
    debugPrint('💥 Triggering simulated test crash via FirebaseCrashlytics.instance.crash()...');
    FirebaseCrashlytics.instance.crash();
  }

  /// Trigger a test non-fatal error report
  static Future<void> testNonFatalError() async {
    try {
      throw Exception('Cashew Store Non-Fatal Diagnostic Test Event');
    } catch (e, stack) {
      await recordError(
        e,
        stack,
        reason: 'User manual test from Profile diagnostic menu',
      );
    }
  }
}
