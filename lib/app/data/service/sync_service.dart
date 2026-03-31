import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/service/sync_notification_service.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';

import 'sync_lock_manager.dart';

class SyncService extends GetxService {
  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initSync();
  }

  Future<void> _initSync() async {
    try {
      await updatePendingCount();

      // Cancel existing subscription if any
      await _connectivitySubscription?.cancel();

      // Listen to connectivity changes
      _connectivitySubscription =
          _connectivityService.connectionStatus.listen((isConnected) async {
        log('🌐 Connectivity changed: $isConnected');
        if (isConnected) {
          await updatePendingCount();
          if (pendingCount.value > 0) {
            log('📡 Internet connected, starting auto-sync...');
            await Future.delayed(const Duration(seconds: 2));
            syncPendingSubmissions();
          }
        }
      });

      // Check immediately if online and has pending
      final isConnected = await _connectivityService.checkConnectivity();
      if (isConnected && pendingCount.value > 0) {
        log('📡 Already online with pending surveys, starting sync...');
        await Future.delayed(const Duration(seconds: 2));
        syncPendingSubmissions();
      }
    } catch (e) {
      log('⚠️ SyncService init error (database may be initializing): $e');
    }
  }

  Future<void> updatePendingCount() async {
    try {
      // Clean up incomplete submissions first
      await _localRepo.cleanupIncompleteSubmissions();

      final count = await _localRepo.getPendingSubmissionsCount();
      pendingCount.value = count;
      log('📊 Pending submissions: $count');

      // Update notification only if there are pending submissions
      if (count > 0) {
        await SyncNotificationService.showPendingSurveysNotification(count);
      } else {
        await SyncNotificationService.cancelNotification();
      }
    } catch (e) {
      log('⚠️ Error updating pending count: $e');
      pendingCount.value = 0;
    }
  }

  Future<void> syncPendingSubmissions() async {
    // Check if sync is already in progress
    if (await SyncLockManager.isLocked()) {
      log('⏳ Sync already in progress, skipping...');
      return;
    }

    // Acquire sync lock
    if (!await SyncLockManager.acquireLock()) {
      log('🔒 Failed to acquire sync lock, another process is syncing');
      return;
    }

    final isConnected = await _connectivityService.checkConnectivity();
    if (!isConnected) {
      log('No internet connection, skipping sync');
      await SyncLockManager.releaseLock();
      return;
    }

    isSyncing.value = true;

    try {
      final pending = await _localRepo.getPendingSubmissions();

      if (pending.isEmpty) {
        log('✅ No pending submissions to sync');
        await updatePendingCount();
        return;
      }

      log('\n${'=' * 80}');
      log('📤 STARTING SYNC: ${pending.length} PENDING SUBMISSION(S)');
      log('=' * 80);

      int successCount = 0;
      int failedCount = 0;

      // Upload in batches of 2
      const batchSize = 2;
      for (var i = 0; i < pending.length; i += batchSize) {
        final remainingCount = pending.length - i;
        final currentBatchSize =
            remainingCount >= batchSize ? batchSize : remainingCount;
        final chunk = pending.skip(i).take(currentBatchSize).toList();

        log('\n📦 Processing batch ${(i ~/ batchSize) + 1} ($currentBatchSize survey${currentBatchSize > 1 ? 's' : ''})');

        for (var submission in chunk) {
          try {
            await _syncSingleSubmission(submission);
            successCount++;
            await SyncNotificationService.showUploadProgress(
                successCount, pending.length);
          } catch (e) {
            log('❌ Failed to sync submission ${submission['id']}: $e');
            failedCount++;
            await _localRepo.incrementRetryCount(submission['id']);
          }
        }

        // Small delay between batches
        if (i + batchSize < pending.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Show completion notification
      if (successCount > 0) {
        await SyncNotificationService.showUploadComplete(successCount);
      }
      if (failedCount > 0) {
        await SyncNotificationService.showUploadFailed(
            failedCount, pending.length);
      }

      await updatePendingCount();
      log('\n${'=' * 80}');
      log('✅ SYNC COMPLETED - Remaining pending: ${pendingCount.value}');
      log('=' * 80);
    } catch (e) {
      log('❌ Sync error: $e');
    } finally {
      isSyncing.value = false;
      await SyncLockManager.releaseLock();
    }
  }

  Future<void> _syncSingleSubmission(Map<String, dynamic> submission) async {
    final submissionId = submission['id'];

    log('\n${'─' * 80}');
    log('🔄 SYNCING SUBMISSION #$submissionId');
    log('─' * 80);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Networkutility.setCompleteSurvey),
    );

    // Map database columns to API parameter names
    request.fields['survey_id'] = submission['survey_id']?.toString() ?? '';
    request.fields['survey_language_id'] =
        submission['survey_language_id']?.toString() ?? '';
    request.fields['zp_ward_id'] = submission['zp_ward_id']?.toString() ?? '';
    request.fields['village_area_id'] =
        submission['village_area_id']?.toString() ?? '';
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
    request.fields['gender'] =
        submission['interviewer_gender']?.toString() ?? '';
    request.fields['mob_number'] =
        submission['interviewer_phone']?.toString() ?? '';
    request.fields['cast_id'] =
        submission['interviewer_cast']?.toString() ?? '';
    request.fields['created_on'] =
        submission['actual_completion_time']?.toString() ??
            submission['created_at']?.toString() ??
            '';
    request.fields['updated_on'] =
        submission['actual_completion_time']?.toString() ??
            submission['updated_at']?.toString() ??
            '';

    // Log request details
    log('\n${'🔥' * 40}');
    log('📤 API REQUEST (Form-Data)');
    log('🔥' * 40);
    log('URL: ${Networkutility.setCompleteSurvey}');
    log('\nFORM FIELDS:');
    log('  survey_id: ${request.fields['survey_id']}');
    log('  survey_language_id: ${request.fields['survey_language_id']}');
    log('  zp_ward_id: ${request.fields['zp_ward_id']}');
    log('  village_area_id: ${request.fields['village_area_id']}');
    log('  survey_done_by: ${request.fields['survey_done_by']}');
    log('  questions (DB): ${submission['answers']}');
    log('  questions (TYPE): ${submission['answers'].runtimeType}');
    log('  questions (SENT): ${request.fields['questions']}');
    log('  name: ${request.fields['name']}');
    log('  age: ${request.fields['age']}');
    log('  gender: ${request.fields['gender']}');
    log('  mob_number: ${request.fields['mob_number']}');
    log('  cast_id: ${request.fields['cast_id']}');
    log('  created_on: ${request.fields['created_on']}');
    log('  updated_on: ${request.fields['updated_on']}');

    // Add audio file if exists
    final audioPath = submission['audio_path']?.toString();
    if (audioPath != null && audioPath.isNotEmpty) {
      final file = File(audioPath);
      if (await file.exists()) {
        final sizeKB = ((await file.length()) / 1024).toStringAsFixed(2);
        log('  recorded_audio: $audioPath ($sizeKB KB)');
        request.files.add(
          await http.MultipartFile.fromPath(
            'recorded_audio',
            audioPath,
            filename: audioPath.split('/').last,
          ),
        );
      }
    }
    log('🔥' * 40);

    log('\n📡 Sending request...');
    final streamedResponse = await request.send().timeout(
      const Duration(
          minutes: 10), // 10 minutes for large audio on slow networks
      onTimeout: () {
        throw Exception('Upload timeout after 10 minutes');
      },
    );
    final response = await http.Response.fromStream(streamedResponse);

    // Log response
    log('\n${'✅' * 40}');
    log('📥 API RESPONSE');
    log('✅' * 40);
    log('Status Code: ${response.statusCode}');
    log('Response Body:');
    log(response.body);
    log('✅' * 40);

    if (response.statusCode == 200) {
      try {
        final json = jsonDecode(response.body);
        if (json['status'] == 'true' || json['status'] == true) {
          // Double-check submission still exists before deletion
          final existingSubmissions =
              await _localRepo.getAllPendingSubmissions();
          final stillExists =
              existingSubmissions.any((s) => s['id'] == submissionId);

          if (stillExists) {
            await _localRepo.deletePendingSubmission(submissionId);
            log('\n✅ Submission #$submissionId deleted from local DB');

            // Delete audio file
            if (audioPath != null && audioPath.isNotEmpty) {
              try {
                final file = File(audioPath);
                if (await file.exists()) {
                  await file.delete();
                  log('🗑️ Audio file deleted');
                }
              } catch (e) {
                log('⚠️ Failed to delete audio file: $e');
              }
            }
          } else {
            log('⚠️ Submission #$submissionId already deleted by another process');
          }
          return;
        } else {
          log('❌ Server returned false status: ${json['message'] ?? 'Unknown error'}');
          throw Exception(
              'Server returned false status: ${json['message'] ?? 'Unknown error'}');
        }
      } catch (e) {
        log('❌ Error parsing response: $e');
        throw Exception('Error parsing response: $e');
      }
    }

    throw Exception('Upload failed: HTTP ${response.statusCode}');
  }

  Future<bool> forceSyncNow() async {
    log('🔄 Force sync triggered');

    // Check if sync is already in progress
    if (await SyncLockManager.isLocked()) {
      log('⏳ Sync already in progress, skipping force sync');
      return false;
    }

    await syncPendingSubmissions();
    return true;
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
