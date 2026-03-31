// lib/app/modules/audio_recorder/audio_recorder_controller.dart
import 'dart:developer';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../widgets/app_snackbar_styles.dart';

class AudioRecorderController extends GetxController {
final AudioRecorder _audioRecorder = AudioRecorder();

  // Observable states
  final RxBool isRecording = false.obs;
  final RxString recordingPath = ''.obs;
  final RxBool isPermissionGranted = false.obs;

  @override
  void onClose() {
    stopRecording(); // Ensure stop if still running
    _audioRecorder.dispose();
    super.onClose();
  }

  // -----------------------------------------------------------------
  //  REQUEST MICROPHONE PERMISSION
  // -----------------------------------------------------------------
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    isPermissionGranted.value = status.isGranted;

    if (!status.isGranted) {
      AppSnackbarStyles.showError(
        title: 'Permission Denied',
        message: 'Microphone access is required to record audio.',
      );
    }
    return status.isGranted;
  }

  // -----------------------------------------------------------------
  //  START RECORDING (Returns file path or null)
  // -----------------------------------------------------------------
  Future<String?> startRecording() async {
    if (isRecording.value) {
      log('Recording already in progress.');
      return recordingPath.value;
    }

    if (!isPermissionGranted.value) {
      final granted = await requestMicPermission();
      if (!granted) return null;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Check Opus support and fallback to AAC if needed
      AudioEncoder encoder = AudioEncoder.opus;
      String extension = 'opus';

      final isOpusSupported =
          await _audioRecorder.isEncoderSupported(AudioEncoder.opus);
      if (!isOpusSupported) {
        log('Opus not supported, falling back to AAC');
        encoder = AudioEncoder.aacLc;
        extension = 'm4a';
      }

      final path = '${dir.path}/recording_$timestamp.$extension';

      // Optimized for speech: low bitrate, mono, 16kHz
      await _audioRecorder.start(
        RecordConfig(
          encoder: encoder,
          sampleRate: 16000,
          bitRate: 12000,
          numChannels: 1,
        ),
        path: path,
      );

      recordingPath.value = path;
      isRecording.value = true;

      log('Recording STARTED → $path (encoder: $encoder, 16kHz, 12kbps, mono)');
      // Silent recording - no snackbar

      return path;
    } catch (e, s) {
      log('START RECORDING ERROR: $e', stackTrace: s);
      AppSnackbarStyles.showError(
        title: 'Recording Failed',
        message: 'Could not start recording.',
      );
      return null;
    }
  }

  // -----------------------------------------------------------------
  //  STOP RECORDING (Returns final file path)
  // -----------------------------------------------------------------
  Future<String?> stopRecording() async {
    if (!isRecording.value) {
      log('No active recording to stop.');
      return recordingPath.value;
    }

    try {
      final path = await _audioRecorder.stop();
      isRecording.value = false;

      if (path != null) {
        recordingPath.value = path;
        log('Recording STOPPED → $path');
        // Silent recording - no snackbar
      } else {
        log('Stop returned null path');
      }

      return path;
    } catch (e, s) {
      log('STOP RECORDING ERROR: $e', stackTrace: s);
      AppSnackbarStyles.showError(
        title: 'Stop Failed',
        message: 'Could not stop recording.',
      );
      return null;
    }
  }

  // -----------------------------------------------------------------
  //  AUTO-START RECORDING (with permission check)
  // -----------------------------------------------------------------
  Future<void> autoStartRecording() async {
    final granted = await requestMicPermission();
    if (!granted) {
      isRecording.value = false;
      return;
    }
    await startRecording();
  }

  // -----------------------------------------------------------------
  //  RESET / CLEAR
  // -----------------------------------------------------------------
  void reset() {
    recordingPath.value = '';
    isRecording.value = false;
  }

  // -----------------------------------------------------------------
  //  GET FILE (for upload)
  // -----------------------------------------------------------------
  Future<File?> getRecordingFile() async {
    if (recordingPath.value.isEmpty) return null;
    final file = File(recordingPath.value);
    return await file.exists() ? file : null;
  }

  // -----------------------------------------------------------------
  //  DELETE RECORDING FILE
  // -----------------------------------------------------------------
  Future<bool> deleteRecording() async {
    final file = await getRecordingFile();
    if (file != null) {
      try {
        await file.delete();
        reset();
        log('Recording file deleted: ${file.path}');
        return true;
      } catch (e) {
        log('Delete failed: $e');
      }
    }
    return false;
  }

  // -----------------------------------------------------------------
  //  LOG FILE SIZE (Utility)
  // -----------------------------------------------------------------
  Future<void> logFileSize() async {
    final file = await getRecordingFile();
    if (file != null) {
      final bytes = await file.length();
      final kb = (bytes / 1024).toStringAsFixed(2);
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      log('Recording size: $bytes B | $kb KB | $mb MB');
    }
  }
}
