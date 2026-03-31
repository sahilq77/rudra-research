import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/service/sync_notification_service.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/battery_optimization_helper.dart';
import 'package:workmanager/workmanager.dart';

import 'sync_lock_manager.dart';

const String syncTaskName = "rudra_background_sync";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Check if sync is already in progress
      if (await SyncLockManager.isLocked()) {
        AppLogger.i('⚠️ Background sync already in progress, skipping',
            tag: 'BackgroundSync');
        return Future.value(true);
      }

      // Acquire sync lock
      if (!await SyncLockManager.acquireLock()) {
        AppLogger.i(
            '🔒 Failed to acquire sync lock, another process is syncing',
            tag: 'BackgroundSync');
        return Future.value(true);
      }
      AppLogger.i('🔔 Background sync started: $task', tag: 'BackgroundSync');

      // Initialize notification service for background
      await SyncNotificationService.initialize();

      final localRepo = SurveyLocalRepository();
      final pendingCount = await localRepo.getPendingSubmissionsCount();

      if (pendingCount > 0) {
        AppLogger.i('📊 Found $pendingCount pending submissions',
            tag: 'BackgroundSync');
        await SyncNotificationService.showPendingSurveysNotification(
            pendingCount);
        await _performBackgroundSync(localRepo, pendingCount);
      } else {
        AppLogger.i('✅ No pending submissions', tag: 'BackgroundSync');
        await SyncNotificationService.cancelNotification();
      }

      return Future.value(true);
    } catch (e) {
      AppLogger.e('Background sync error', error: e, tag: 'BackgroundSync');
      return Future.value(true);
    } finally {
      await SyncLockManager.releaseLock();
    }
  });
}

Future<void> _performBackgroundSync(
    SurveyLocalRepository localRepo, int totalCount) async {
  try {
    await localRepo.cleanupIncompleteSubmissions();

    // Get ready-to-upload submissions (already filtered)
    final pending = await localRepo.getPendingSubmissions();

    if (pending.isEmpty) {
      AppLogger.i('✅ No pending submissions after cleanup',
          tag: 'BackgroundSync');
      await SyncNotificationService.cancelNotification();
      return;
    }

    AppLogger.i('🚀 Starting upload: ${pending.length} submissions',
        tag: 'BackgroundSync');

    int successCount = 0;
    int failedCount = 0;

    // Process one by one to avoid race conditions
    for (var i = 0; i < pending.length; i++) {
      final submission = pending[i];

      try {
        // Re-check if submission still exists (might have been processed by another sync)
        final currentPending = await localRepo.getPendingSubmissions();
        final stillExists =
            currentPending.any((s) => s['id'] == submission['id']);

        if (!stillExists) {
          AppLogger.i(
              '⚠️ Submission ${submission['id']} already processed, skipping',
              tag: 'BackgroundSync');
          continue;
        }

        final result = await _syncSingleSubmission(submission, localRepo);
        if (result == 'success') {
          successCount++;
          await SyncNotificationService.showUploadProgress(
              successCount, pending.length);
        } else {
          failedCount++;
        }
      } catch (e) {
        AppLogger.e('Failed to sync submission ${submission['id']}',
            error: e, tag: 'BackgroundSync');
        failedCount++;
        await localRepo.incrementRetryCount(submission['id']);
      }

      // Small delay between submissions
      if (i < pending.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Final notification
    if (successCount > 0) {
      await SyncNotificationService.showUploadComplete(successCount);
    }
    if (failedCount > 0) {
      await SyncNotificationService.showUploadFailed(
          failedCount, pending.length);
    }

    // Final cleanup - cancel notification if no pending submissions remain
    final finalCount = await localRepo.getPendingSubmissionsCount();
    if (finalCount == 0) {
      await SyncNotificationService.cancelNotification();
    }
  } catch (e) {
    AppLogger.e('Background sync error', error: e, tag: 'BackgroundSync');
  }
}

Future<String> _syncSingleSubmission(
  Map<String, dynamic> submission,
  SurveyLocalRepository localRepo,
) async {
  final submissionId = submission['id'];

  AppLogger.i(
    '\n${'=' * 80}\n'
    '📤 UPLOADING SUBMISSION #$submissionId (Form-Data)\n'
    '${'=' * 80}',
    tag: 'BackgroundSync',
  );

  final request = http.MultipartRequest(
    'POST',
    Uri.parse(Networkutility.setCompleteSurvey),
  );

  // Map database columns to API parameter names
  request.fields['survey_id'] = submission['survey_id']?.toString() ?? '';
  request.fields['survey_language_id'] =
      submission['survey_language_id']?.toString() ?? '';
  request.fields['village_area_id'] =
      submission['village_area_id']?.toString() ?? '';
  request.fields['zp_ward_id'] = submission['zp_ward_id']?.toString() ?? '';
  request.fields['survey_done_by'] = submission['user_id']?.toString() ?? '';

  // Handle answers - could be String or List from SQLite
  final answers = submission['answers'];
  if (answers is String) {
    request.fields['questions'] = answers;
  } else if (answers is List) {
    request.fields['questions'] = jsonEncode(answers);
  } else {
    request.fields['questions'] = '[]';
  }
  request.fields['name'] = submission['interviewer_name']?.toString() ?? '';
  request.fields['age'] = submission['interviewer_age']?.toString() ?? '0';
  request.fields['gender'] = submission['interviewer_gender']?.toString() ?? '';
  request.fields['mob_number'] =
      submission['interviewer_phone']?.toString() ?? '';
  request.fields['cast_id'] = submission['interviewer_cast']?.toString() ?? '';
  request.fields['created_on'] =
      submission['actual_completion_time']?.toString() ??
          submission['created_at']?.toString() ??
          '';
  request.fields['updated_on'] =
      submission['actual_completion_time']?.toString() ??
          submission['updated_at']?.toString() ??
          '';

  // Log request details
  AppLogger.i(
    '\n${'🔥' * 40}\n'
    '📤 FORM-DATA REQUEST\n'
    '${'🔥' * 40}\n'
    'URL: ${Networkutility.setCompleteSurvey}\n'
    '\nFORM FIELDS:\n'
    '  survey_id: ${request.fields['survey_id']}\n'
    '  survey_language_id: ${request.fields['survey_language_id']}\n'
    '  village_area_id: ${request.fields['village_area_id']}\n'
    '  zp_ward_id: ${request.fields['zp_ward_id']}\n'
    '  survey_done_by: ${request.fields['survey_done_by']}\n'
    '  questions: ${request.fields['questions']}\n'
    '  name: ${request.fields['name']}\n'
    '  age: ${request.fields['age']}\n'
    '  gender: ${request.fields['gender']}\n'
    '  mob_number: ${request.fields['mob_number']}\n'
    '  cast_id: ${request.fields['cast_id']}\n'
    '  created_on: ${request.fields['created_on']}\n'
    '  updated_on: ${request.fields['updated_on']}\n'
    '${'🔥' * 40}',
    tag: 'BackgroundSync',
  );

  // Add audio file if exists
  final audioPath = submission['audio_path']?.toString();
  if (audioPath != null && audioPath.isNotEmpty) {
    final file = File(audioPath);
    if (await file.exists()) {
      final sizeKB = ((await file.length()) / 1024).toStringAsFixed(2);
      AppLogger.i('📎 Attaching audio file: $audioPath ($sizeKB KB)',
          tag: 'BackgroundSync');

      request.files.add(
        await http.MultipartFile.fromPath(
          'recorded_audio',
          audioPath,
          filename: audioPath.split('/').last,
        ),
      );
    } else {
      AppLogger.w('⚠️ Audio file not found: $audioPath', tag: 'BackgroundSync');
    }
  }

  // Send request with extended timeout for large audio files
  AppLogger.i('📡 Sending request...', tag: 'BackgroundSync');
  final streamedResponse = await request.send().timeout(
    const Duration(minutes: 10), // 10 minutes for large audio on slow networks
    onTimeout: () {
      throw Exception('Upload timeout after 10 minutes');
    },
  );
  final response = await http.Response.fromStream(streamedResponse);

  AppLogger.i(
    '\n${'✅' * 40}\n'
    '📥 API RESPONSE\n'
    '${'✅' * 40}\n'
    'Status Code: ${response.statusCode}\n'
    'Response Body:\n${response.body}\n'
    '${'✅' * 40}',
    tag: 'BackgroundSync',
  );

  if (response.statusCode == 200) {
    try {
      final json = jsonDecode(response.body);
      if (json['status'] == 'true' || json['status'] == true) {
        // Double-check submission still exists before deletion
        final existingSubmissions = await localRepo.getPendingSubmissions();
        final stillExists =
            existingSubmissions.any((s) => s['id'] == submission['id']);

        if (stillExists) {
          await localRepo.deletePendingSubmission(submission['id']);
          AppLogger.i('✅ Submission ${submission['id']} deleted from local DB',
              tag: 'BackgroundSync');

          // Delete audio file
          if (audioPath != null && audioPath.isNotEmpty) {
            try {
              final file = File(audioPath);
              if (await file.exists()) {
                await file.delete();
                AppLogger.i('🗑️ Audio file deleted', tag: 'BackgroundSync');
              }
            } catch (e) {
              AppLogger.w('Failed to delete audio file: $e',
                  tag: 'BackgroundSync');
            }
          }
        } else {
          AppLogger.w(
              '⚠️ Submission ${submission['id']} already deleted by another process',
              tag: 'BackgroundSync');
        }

        return 'success';
      } else {
        AppLogger.e(
            '❌ Server returned false status: ${json['message'] ?? 'Unknown error'}',
            tag: 'BackgroundSync');
        throw Exception(
            'Server returned false status: ${json['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      AppLogger.e('❌ Error parsing response: $e', tag: 'BackgroundSync');
      throw Exception('Error parsing response: $e');
    }
  }

  throw Exception('Upload failed: HTTP ${response.statusCode}');
}

class BackgroundSyncService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Request battery optimization exemption for doze mode
    await BatteryOptimizationHelper.requestBatteryOptimizationExemption();

    AppLogger.i('BackgroundSyncService initialized with doze-mode support',
        tag: 'BackgroundSync');
  }

  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      "1",
      syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false, // Allow sync even on low battery
        requiresCharging: false, // Allow sync without charging
        requiresDeviceIdle: false, // Allow sync even when device is active
        requiresStorageNotLow: true, // Only require sufficient storage
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
    AppLogger.i(
        'Periodic sync registered (every 15 minutes) with doze-mode support',
        tag: 'BackgroundSync');
  }

  static Future<void> scheduleImmediateSync() async {
    await Workmanager().registerOneOffTask(
      "immediate_sync_${DateTime.now().millisecondsSinceEpoch}",
      syncTaskName,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    AppLogger.i('Immediate sync scheduled', tag: 'BackgroundSync');
  }

  static Future<void> cancelAllSync() async {
    await Workmanager().cancelAll();
    AppLogger.i('All sync tasks cancelled', tag: 'BackgroundSync');
  }
}
