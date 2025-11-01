// lib/app/modules/survey_interviewer/survey_interviewer_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

// -----------------------------------------------------------------
//  ORIGINAL IMPORTS (unchanged)
// -----------------------------------------------------------------
import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_set_interviewer_info.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/utils/app_images.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/utils/responsive_utils.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

// -----------------------------------------------------------------
//  WAV HEADER PARSER – top-level class (fixed indexOf)
// -----------------------------------------------------------------
class _WavHeader {
  final int sampleRate;
  final int channels;
  final int dataOffset;

  _WavHeader(this.sampleRate, this.channels, this.dataOffset);

  factory _WavHeader.fromBytes(Uint8List bytes) {
    final view = ByteData.sublistView(bytes);

    // ---- RIFF check ----
    if (String.fromCharCodes(bytes, 0, 4) != 'RIFF') {
      throw Exception('Not a WAV file');
    }

    // ---- Find "fmt " chunk ----
    final fmtPos = _findChunk(bytes, [0x66, 0x6D, 0x74, 0x20]); // "fmt "
    if (fmtPos == -1) throw Exception('fmt chunk missing');

    // ---- Read fmt fields ----
    final audioFormat = view.getUint16(fmtPos + 8, Endian.little);
    if (audioFormat != 1) throw Exception('Only PCM supported');
    final channels = view.getUint16(fmtPos + 10, Endian.little);
    final sampleRate = view.getUint32(fmtPos + 12, Endian.little);

    // ---- Find "data" chunk ----
    final dataPos = _findChunk(bytes, [0x64, 0x61, 0x74, 0x61]); // "data"
    if (dataPos == -1) throw Exception('data chunk missing');

    final dataOffset = dataPos + 8;
    return _WavHeader(sampleRate, channels, dataOffset);
  }
}

/// Search for a 4-byte chunk identifier in the WAV file.
int _findChunk(Uint8List bytes, List<int> signature) {
  for (int i = 0; i <= bytes.length - 4; i++) {
    bool match = true;
    for (int j = 0; j < 4; j++) {
      if (bytes[i + j] != signature[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return -1;
}

// -----------------------------------------------------------------
//  CONTROLLER
// -----------------------------------------------------------------
class SurveyInterviewerController extends GetxController {
  RxList<CastData> castList = <CastData>[].obs;
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  var isLoadingCast = false.obs;
  var errorMessageCast = ''.obs;
  var isLoading = false.obs;

  final RxString selectedCast = ''.obs;
  final RxString selectedCastId = ''.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final List<String> ageRanges = ['18-25', '26-39', '40-55', '56+'];
  final RxString selectedAgeLabel = ''.obs;
  final RxInt selectedAgeId = 0.obs;

  final List<String> genders = ['Male', 'Female', 'Other'];
  final RxString selectedGenderLabel = ''.obs;
  final RxInt selectedGenderId = 0.obs;

  late String surveyId = "";
  late String surveyAppId = "";

  // -----------------------------------------------------------------
  //  AUDIO RECORDING – DELEGATED TO SEPARATE CONTROLLER
  // -----------------------------------------------------------------
  late final AudioRecorderController audioRecorder;

  @override
  void onInit() {
    super.onInit();

    audioRecorder = Get.put(AudioRecorderController());

    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    surveyAppId = args?['survey_app_side_id']?.toString() ?? "";

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.context != null) {
        await fetchCast(context: Get.context!, surveyId: surveyId);
      }
    });
  }

  // -----------------------------------------------------------------
  //  CAST HELPERS
  // -----------------------------------------------------------------
  List<String> getCastNames() {
    return castList.map((s) => s.castName).toSet().toList();
  }

  String? getCastId(String? castName) {
    if (castName == null) return '';
    return castList
            .firstWhereOrNull((cast) => cast.castName == castName)
            ?.castId ??
        '';
  }

  void setSelectedCast(String? castName) {
    selectedCast.value = castName ?? '';
    selectedCastId.value = getCastId(castName) ?? '';
  }

  void setSelectedAge(String? label) {
    selectedAgeLabel.value = label ?? '';
    selectedAgeId.value = ageRanges.indexOf(label ?? '');
  }

  void setSelectedGender(String? label) {
    selectedGenderLabel.value = label ?? '';
    selectedGenderId.value = genders.indexOf(label ?? '');
  }

  // -----------------------------------------------------------------
  //  SUBMIT SURVEY – STOPS RECORDING + UPLOADS AUDIO
  // -----------------------------------------------------------------
  Future<String?> setSurvey({
    required BuildContext context,
    required formKey,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    if (audioRecorder.isRecording.value) {
      final stoppedPath = await audioRecorder.stopRecording();
      if (stoppedPath != null) {
        AppSnackbarStyles.showInfo(
          title: 'Recording',
          message: 'Recording stopped automatically',
        );
      } else {
        AppSnackbarStyles.showError(
          title: 'Warning',
          message: 'Failed to stop recording – will try to upload anyway',
        );
      }
    }

    try {
      isLoadings.value = true;
      errorMessages.value = '';

      final jsonBody = {
        "survey_app_side_id": surveyAppId,
        "name": nameController.text.trim(),
        "age": selectedAgeId.value.toString(),
        "gender": selectedGenderId.value.toString(),
        "mob_number": phoneController.text.trim(),
        "cast_id": selectedCastId.value,
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.setInterviewerInfoApi,
                Networkutility.setInterviewerInfo,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetSetInterviewerInfoResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        // AppSnackbarStyles.showSuccess(
        //   title: 'Success',
        //   message: "Info submitted",
        // );
        log("Info Submitted success");
        if (audioRecorder.recordingPath.value.isNotEmpty) {
          await uploadRecording();
        } else {
          AppSnackbarStyles.showInfo(
            title: 'No Audio',
            message: 'No recording to upload',
          );
        }

        return response[0].data?.surveyAppSideId ?? '';
      } else {
        final msg = response?[0].message ?? "Submission failed";
        errorMessages.value = msg;
        AppSnackbarStyles.showError(title: 'Failed', message: msg);
        return null;
      }
    } on NoInternetException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessages.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessages.value);
    } on ParseException catch (e) {
      errorMessages.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, s) {
      errorMessages.value = 'Unexpected error: $e';
      log('setSurvey error: $e', stackTrace: s);
      AppSnackbarStyles.showError(title: 'Error', message: errorMessages.value);
    } finally {
      isLoadings.value = false;
    }
    return null;
  }

  void submitSurvey(formKey) {
    if (formKey.currentState!.validate()) {
      AppLogger.d('Survey submitted', tag: 'SurveyInterviewerController');
      showSuccessDialog(Get.context!);
    }
  }

  void discardSurvey() {
    _showDiscardDialog(Get.context!);
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false, // This disables back navigation
          onPopInvoked: (didPop) {
            if (didPop) return;
            // Optional: Show a confirmation dialog if needed later
            debugPrint('Back navigation blocked');
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppImages.thanks, width: 80, height: 80),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'THANKS',
                      style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Response Submitted',
                    style: AppStyle.heading1PoppinsBlack.responsive,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your response has been submitted\nsuccessfully.',
                    style: AppStyle.bodySmallPoppinsGrey.responsive,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            resetForm();
                            Get.back(); // Close dialog
                            Get.offAllNamed(AppRoutes.home);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.defaultBlack,
                            side: const BorderSide(
                              color: AppColors.defaultBlack,
                              width: 1.5,
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Dashboard',
                              style: AppStyle
                                  .buttonTextSmallPoppinsBlack
                                  .responsive,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            resetForm();
                            Get.back(); // Close dialog
                            Get.toNamed(
                              AppRoutes.surveyDetails,
                              arguments: {'survey_id': surveyId},
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.defaultBlack,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Next Survey',
                              style: AppStyle
                                  .buttonTextSmallPoppinsWhite
                                  .responsive,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Discard Survey',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to discard this survey?',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(100, 40),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: Text(
                        'No',
                        style: AppStyle.buttonTextSmallPoppinsBlack.responsive
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        resetForm();
                        Get.back();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        minimumSize: const Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void resetForm() {
    nameController.clear();
    phoneController.clear();
    selectedAgeLabel.value = '';
    selectedAgeId.value = 0;
    selectedGenderLabel.value = '';
    selectedGenderId.value = 0;
    selectedCast.value = '';
    selectedCastId.value = '';
    audioRecorder.reset();
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  // -----------------------------------------------------------------
  //  FETCH CAST
  // -----------------------------------------------------------------
  Future<void> fetchCast({
    required BuildContext context,
    bool forceFetch = false,
    required String? surveyId,
  }) async {
    if (!forceFetch && castList.isNotEmpty) return;

    try {
      isLoadingCast.value = true;
      errorMessageCast.value = '';
      castList.clear();
      selectedCast.value = "";
      selectedCastId.value = "";

      final jsonBody = {"survey_id": surveyId};

      List<GeCastResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getCastApi,
                Networkutility.getCast,
                jsonEncode(jsonBody),
                context,
              )
              as List<GeCastResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        castList.value = response[0].data;
      } else {
        errorMessageCast.value = response?[0].message ?? 'No casts found';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessageCast.value,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessageCast.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageCast.value,
      );
    } on ParseException catch (e) {
      errorMessageCast.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, stackTrace) {
      errorMessageCast.value = 'Unexpected error: $e';
      log('Fetch Cast Exception: $e', stackTrace: stackTrace);
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageCast.value,
      );
    } finally {
      isLoadingCast.value = false;
    }
  }

  // -----------------------------------------------------------------
  //  MAXIMUM COMPRESSION: 16 kHz mono 16-bit + gzip
  // -----------------------------------------------------------------
  Future<String> _compressWavMax(String wavPath) async {
    // 1. Read original file
    final wavFile = File(wavPath);
    final wavBytes = await wavFile.readAsBytes();

    // 2. Parse header
    final header = _WavHeader.fromBytes(wavBytes);
    final pcmData = wavBytes.sublist(header.dataOffset);

    // 3. Convert to Int16List (16-bit PCM)
    final int16Samples = Int16List(pcmData.length ~/ 2);
    for (int i = 0; i < pcmData.length; i += 2) {
      int16Samples[i ~/ 2] = pcmData[i] | (pcmData[i + 1] << 8);
    }

    // 4. Resample to 16 kHz
    final targetRate = 16000;
    final resampled = _resampleInt16(
      samples: int16Samples,
      srcRate: header.sampleRate,
      dstRate: targetRate,
      channels: header.channels,
    );

    // 5. Force mono (average channels)
    final mono = _forceMono(resampled);

    // 6. Build new WAV header
    final newHeader = _buildWavHeader(
      sampleRate: targetRate,
      channels: 1,
      sampleCount: mono.length,
    );

    // 7. Write down-sampled PCM to temporary file
    final tempDir = await getTemporaryDirectory();
    final pcmPath = p.join(
      tempDir.path,
      '${p.basenameWithoutExtension(wavPath)}_cmp.wav',
    );
    final outFile = File(pcmPath);
    await outFile.writeAsBytes(newHeader);
    final sink = outFile.openWrite(mode: FileMode.writeOnlyAppend);
    sink.add(mono.buffer.asUint8List());
    sink.close(); // <-- NO await (returns void)

    // 8. Gzip the PCM file
    final gzPath = '$pcmPath.gz';
    final gzipSink = gzip.encoder.startChunkedConversion(
      File(gzPath).openWrite(),
    );
    await for (final chunk in outFile.openRead()) {
      gzipSink.add(chunk);
    }
    gzipSink.close(); // <-- NO await (returns void)

    // Clean intermediate PCM file
    await outFile.delete();

    return gzPath;
  }

  // Linear resampler (good enough for speech)
  List<Int16List> _resampleInt16({
    required Int16List samples,
    required int srcRate,
    required int dstRate,
    required int channels,
  }) {
    if (srcRate == dstRate) {
      final perChannel = samples.length ~/ channels;
      final out = <Int16List>[];
      for (int ch = 0; ch < channels; ch++) {
        final channel = Int16List(perChannel);
        for (int i = 0; i < perChannel; i++) {
          channel[i] = samples[i * channels + ch];
        }
        out.add(channel);
      }
      return out;
    }

    final ratio = dstRate / srcRate;
    final srcFrames = samples.length ~/ channels;
    final dstFrames = (srcFrames * ratio).floor();

    final out = <Int16List>[];
    for (int ch = 0; ch < channels; ch++) {
      final channelOut = Int16List(dstFrames);
      for (int i = 0; i < dstFrames; i++) {
        final srcIdx = (i / ratio).floor();
        channelOut[i] = samples[srcIdx * channels + ch];
      }
      out.add(channelOut);
    }
    return out;
  }

  // Force mono by averaging channels
  Int16List _forceMono(List<Int16List> channels) {
    final frames = channels[0].length;
    final mono = Int16List(frames);
    for (int i = 0; i < frames; i++) {
      int sum = 0;
      for (final ch in channels) sum += ch[i];
      mono[i] = (sum ~/ channels.length);
    }
    return mono;
  }

  // Build minimal WAV header (16-bit PCM)
  Uint8List _buildWavHeader({
    required int sampleRate,
    required int channels,
    required int sampleCount,
  }) {
    final byteRate = sampleRate * channels * 2;
    final blockAlign = channels * 2;
    final dataSize = sampleCount * blockAlign;
    final fileSize = 36 + dataSize;

    final buffer = BytesBuilder();
    buffer.add([0x52, 0x49, 0x46, 0x46]); // RIFF
    buffer.add(_int32ToBytes(fileSize - 8));
    buffer.add([0x57, 0x41, 0x56, 0x45]); // WAVE
    buffer.add([0x66, 0x6D, 0x74, 0x20]); // fmt
    buffer.add(_int32ToBytes(16));
    buffer.add(_int16ToBytes(1)); // PCM
    buffer.add(_int16ToBytes(channels));
    buffer.add(_int32ToBytes(sampleRate));
    buffer.add(_int32ToBytes(byteRate));
    buffer.add(_int16ToBytes(blockAlign));
    buffer.add(_int16ToBytes(16)); // 16-bit
    buffer.add([0x64, 0x61, 0x74, 0x61]); // data
    buffer.add(_int32ToBytes(dataSize));
    return buffer.toBytes();
  }

  Uint8List _int32ToBytes(int value) {
    final b = Uint8List(4);
    final view = ByteData.sublistView(b);
    view.setUint32(0, value, Endian.little);
    return b;
  }

  Uint8List _int16ToBytes(int value) {
    final b = Uint8List(2);
    final view = ByteData.sublistView(b);
    view.setUint16(0, value, Endian.little);
    return b;
  }

  // -----------------------------------------------------------------
  //  UPLOAD AUDIO – uses the new compressor + gzip
  // -----------------------------------------------------------------
  Future<void> uploadRecording() async {
    final recordingPath = audioRecorder.recordingPath.value;
    if (recordingPath.isEmpty) {
      AppSnackbarStyles.showError(
        title: 'No Recording',
        message: 'Please record audio first.',
      );
      return;
    }

    final file = File(recordingPath);
    if (!await file.exists()) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Audio file not found on disk.',
      );
      return;
    }

    await _logFileSize(recordingPath);

    String uploadPath;
    bool useGzip = false;

    try {
      uploadPath = await _compressWavMax(recordingPath);
      useGzip = true;
      await _logFileSize(uploadPath);
    } catch (e, s) {
      log('Compression failed: $e', stackTrace: s);
      uploadPath = recordingPath;
    }

    final uploadFile = File(uploadPath);
    final bytes = await uploadFile.readAsBytes();
    final filename = p.basename(uploadPath);

    try {
      isLoading.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Networkutility.uploadAudio),
      );

      request.fields['survey_app_side_id'] = surveyAppId;
      request.fields['completed_by'] = AppUtility.userID.toString();

      if (useGzip) {
        request.headers['Content-Encoding'] = 'gzip';
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'recorded_audio',
          bytes,
          filename: filename,
          contentType: MediaType.parse('audio/wav'),
        ),
      );

      log(
        'Uploading to ${request.url} | File: $filename | Size: ${bytes.length} bytes${useGzip ? " (gzipped)" : ""}',
      );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      String body = resp.body.trim();
      if (body.endsWith('null')) {
        body = body.substring(0, body.lastIndexOf('null')).trim();
      }

      if (resp.statusCode == 200) {
        try {
          final json = jsonDecode(body);
          if (json['status'] == 'true' || json['status'] == true) {
            log(resp.body);
            AppSnackbarStyles.showSuccess(
              title: 'Success',
              message: "Interviewer info submitted successfully",
            );
            // AppSnackbarStyles.showSuccess(
            //   title: 'Uploaded',
            //   message: 'Audio uploaded successfully',
            // );
            _showSuccessDialog(Get.context!);
            await audioRecorder.deleteRecording();
          } else {
            AppSnackbarStyles.showError(
              title: 'Upload failed',
              message: json['message'] ?? 'Unknown error',
            );
          }
        } catch (_) {
          if (resp.body.contains('"status":"true"')) {
            AppSnackbarStyles.showSuccess(
              title: 'Uploaded',
              message: 'Audio uploaded',
            );
            await audioRecorder.deleteRecording();
          } else {
            AppSnackbarStyles.showError(
              title: 'Invalid response',
              message: 'Server returned unexpected data.',
            );
          }
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Server error',
          message: 'HTTP ${resp.statusCode}',
        );
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'No Internet', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Timeout', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'HTTP error',
        message: '${e.message} (${e.statusCode})',
      );
    } catch (e, s) {
      log('uploadRecording EXCEPTION: $e', stackTrace: s);
      AppSnackbarStyles.showError(title: 'Error', message: 'Upload failed');
    } finally {
      isLoading.value = false;

      if (uploadPath.endsWith('.gz') || uploadPath.contains('_cmp')) {
        try {
          await File(uploadPath).delete();
        } catch (_) {}
      }
    }
  }

  Future<void> _logFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final bytes = await file.length();
      final kb = (bytes / 1024).toStringAsFixed(2);
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      log('File size: $bytes B | $kb KB | $mb MB');
    } else {
      log('File NOT found: $path');
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppImages.thanks, width: 80, height: 80),
                const SizedBox(height: 16),
                // Thanks Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'THANKS',
                    style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  'Response Submitted',
                  style: AppStyle.heading1PoppinsBlack.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Message
                Text(
                  'Your response has been submitted\nsuccessfully.',
                  style: AppStyle.bodySmallPoppinsGrey.responsive,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          resetForm();
                          Get.back();
                          Get.offAllNamed(AppRoutes.home);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.defaultBlack,
                          side: const BorderSide(
                            color: AppColors.defaultBlack,
                            width: 1.5,
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Dashboard',
                            style:
                                AppStyle.buttonTextSmallPoppinsBlack.responsive,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          resetForm();
                          Get.back(); // Close dialog
                          Get.toNamed(
                            AppRoutes.surveyDetails,
                            arguments: {'survey_id': surveyId},
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.defaultBlack,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Next Survey',
                            style:
                                AppStyle.buttonTextSmallPoppinsWhite.responsive,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------------
  //  CLEAN-UP
  // -----------------------------------------------------------------
  @override
  void onClose() {
    audioRecorder.stopRecording();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
