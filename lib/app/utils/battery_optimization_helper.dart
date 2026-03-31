import 'package:permission_handler/permission_handler.dart';
import 'package:rudra/app/utils/app_logger.dart';

class BatteryOptimizationHelper {
  static Future<void> requestBatteryOptimizationExemption() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;

      if (!status.isGranted) {
        AppLogger.i(
          'Requesting battery optimization exemption for background sync',
          tag: 'BatteryOptimization',
        );

        final result = await Permission.ignoreBatteryOptimizations.request();

        if (result.isGranted) {
          AppLogger.i(
            '✅ Battery optimization exemption granted',
            tag: 'BatteryOptimization',
          );
        } else {
          AppLogger.w(
            '⚠️ Battery optimization exemption denied - background sync may be limited',
            tag: 'BatteryOptimization',
          );
        }
      } else {
        AppLogger.i(
          '✅ Battery optimization already exempted',
          tag: 'BatteryOptimization',
        );
      }
    } catch (e) {
      AppLogger.e(
        'Failed to request battery optimization exemption',
        error: e,
        tag: 'BatteryOptimization',
      );
    }
  }
}
