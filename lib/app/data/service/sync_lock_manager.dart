import 'package:shared_preferences/shared_preferences.dart';

class SyncLockManager {
  static const String _lockKey = 'sync_in_progress';
  static const String _lockTimestampKey = 'sync_lock_timestamp';
  static const int _lockTimeoutMinutes = 10; // Timeout after 10 minutes

  /// Acquire sync lock. Returns true if lock acquired, false if already locked
  static Future<bool> acquireLock() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if lock exists and is still valid
    final isLocked = prefs.getBool(_lockKey) ?? false;
    if (isLocked) {
      final lockTimestamp = prefs.getInt(_lockTimestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final lockAge = now - lockTimestamp;

      // If lock is older than timeout, force release it
      if (lockAge > (_lockTimeoutMinutes * 60 * 1000)) {
        await releaseLock();
      } else {
        return false; // Lock is still active
      }
    }

    // Acquire lock
    await prefs.setBool(_lockKey, true);
    await prefs.setInt(
        _lockTimestampKey, DateTime.now().millisecondsSinceEpoch);
    return true;
  }

  /// Release sync lock
  static Future<void> releaseLock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockKey);
    await prefs.remove(_lockTimestampKey);
  }

  /// Check if sync is currently locked
  static Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    final isLocked = prefs.getBool(_lockKey) ?? false;

    if (isLocked) {
      final lockTimestamp = prefs.getInt(_lockTimestampKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final lockAge = now - lockTimestamp;

      // If lock is older than timeout, consider it released
      if (lockAge > (_lockTimeoutMinutes * 60 * 1000)) {
        await releaseLock();
        return false;
      }
    }

    return isLocked;
  }
}
