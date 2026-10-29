import 'package:flutter_test/flutter_test.dart';
import 'package:cashew_store/core/services/crashlytics_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CrashlyticsService unit tests', () {
    test('CrashlyticsService instance can be created and checked', () {
      final service = CrashlyticsService();
      expect(service, isNotNull);
      expect(CrashlyticsService.isInitialized, isFalse);
    });

    test('CrashlyticsService safe methods run without error when uninitialized', () async {
      // All these methods have internal try/catch guards so they don't throw even when Firebase is uninitialized
      await expectLater(CrashlyticsService.log('test breadcrumb'), completes);
      await expectLater(CrashlyticsService.setUserIdentifier('user-123'), completes);
      await expectLater(CrashlyticsService.clearUserIdentifier(), completes);
      await expectLater(CrashlyticsService.setCustomKey('test_key', 'test_val'), completes);
      await expectLater(
        CrashlyticsService.recordError(Exception('Test error'), null, reason: 'Unit test'),
        completes,
      );
    });
  });
}
