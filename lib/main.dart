import 'package:flutter/material.dart';
import 'app.dart';
import 'di/injection.dart';

import 'core/config/env_config.dart';
import 'core/network/dio_client.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await EnvConfig.init();

  // Initialize Firebase Crashlytics & Uncaught Error Handlers
  await CrashlyticsService.initialize();
  
  await initDependencies();

  // Initialize Firebase Cloud Messaging & Local Notifications
  await NotificationService().initialize(apiClient: sl<DioClient>());

  runApp(const CashewStoreApp());
}
