// lib/app/modules/survey_details/survey_details_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rudra/app/data/models/survey_detail/get_area_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_set_survey_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_survey_detail_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import '../../../routes/app_routes.dart';

class SurveyDetailsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxList<AreaData> areaList = <AreaData>[].obs;
  RxList<SurveyDetailData> surveyDetailList = <SurveyDetailData>[].obs;
  var isLoadingArea = false.obs;
  var errorMessageArea = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  RxString? selectedAreaVal = RxString("");

  final AudioRecorderController audioRecorder = Get.put(
    AudioRecorderController(),
  );
  // ---------- LANGUAGE ----------
  final RxString selectedLanguage = 'Marathi'.obs;
  final RxInt selectedLanguageId = 0.obs;

  final Map<String, int> _languageIdMap = {
    'Marathi': 0,
    'Hindi': 1,
    'English': 2,
  };

  final List<String> languages = ['Marathi', 'Hindi', 'English'];

  // ---------- AREA ----------
  final RxString selectedAreaId = ''.obs;
  String surveyId = "";

  // -----------------------------------------------------------------
  // AUDIO RECORDING
  // -----------------------------------------------------------------
  final AudioRecorder _audioRecorder = AudioRecorder();
  RxBool isRecording = false.obs;
  RxString recordingPath = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Sync language ID when name changes
    ever(selectedLanguage, (String name) {
      selectedLanguageId.value = _languageIdMap[name] ?? 0;
    });

    // Get survey_id from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";

    // Load data

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchArea(context: Get.context!, surveyId: surveyId);
      await fetchSurveyDetail(context: Get.context!, surveyId: surveyId);
      await audioRecorder.startRecording();
    });
  }

  // -----------------------------------------------------------------
  // AUTO START RECORDING
  // -----------------------------------------------------------------

  // -----------------------------------------------------------------
  // AREA & SURVEY FETCH
  // -----------------------------------------------------------------
  Future<void> fetchSurveyDetail({
    required BuildContext context,
    bool reset = false,
    required String surveyId,
  }) async {
    try {
      if (reset) surveyDetailList.clear();
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {"survey_id": surveyId};

      List<GetSurveyDetailResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getSurveyDetailApi,
                Networkutility.getSurveyDetail,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetSurveyDetailResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        final detail = response[0].data;
        surveyDetailList.add(
          SurveyDetailData(
            region: detail.region,
            regionId: detail.regionId,
            stateName: detail.stateName,
            stateId: detail.stateId,
            districtName: detail.districtName,
            districtId: detail.districtId,
            loksabhaName: detail.loksabhaName,
            loksabhaId: detail.loksabhaId,
            assemblyName: detail.assemblyName,
            assemblyId: detail.assemblyId,
            wardName: detail.wardName,
            zpWardId: detail.zpWardId,
            teamName: detail.teamName,
            teamId: detail.teamId,
          ),
        );
      } else {
        errorMessage.value = 'No myTeam found';
        AppSnackbarStyles.showError(title: 'Error', message: 'No myTeam found');
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(title: 'Error', message: errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchArea({
    required BuildContext context,
    bool forceFetch = false,
    required String? surveyId,
  }) async {
    if (!forceFetch && areaList.isNotEmpty) return;

    try {
      isLoadingArea.value = true;
      errorMessageArea.value = '';
      areaList.clear();
      selectedAreaVal?.value = "";
      selectedAreaId.value = "";

      final jsonBody = {"survey_id": surveyId};
      List<GetAreaResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getAreaApi,
                Networkutility.getArea,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetAreaResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        areaList.value = response[0].data;
      } else {
        errorMessageArea.value = response?[0].message ?? 'No areas found';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: errorMessageArea.value,
        );
      }
    } on NoInternetException catch (e) {
      errorMessageArea.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessageArea.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessageArea.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageArea.value,
      );
    } on ParseException catch (e) {
      errorMessageArea.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, s) {
      errorMessageArea.value = 'Unexpected error: $e';
      log('Fetch Area Exception: $e', stackTrace: s);
      AppSnackbarStyles.showError(
        title: 'Error',
        message: errorMessageArea.value,
      );
    } finally {
      isLoadingArea.value = false;
    }
  }

  List<String> getAreaNames() {
    return areaList.map((s) => s.areaName).toSet().toList();
  }

  String? getAreaId(String areaName) {
    return areaList
            .firstWhereOrNull((area) => area.areaName == areaName)
            ?.villageAreaId ??
        '';
  }

  String? getAreaNameById(String areaId) {
    return areaList
        .firstWhereOrNull((area) => area.villageAreaId == areaId)
        ?.areaName;
  }

  void setSelectedArea(String? areaName) {
    selectedAreaVal?.value = areaName ?? '';
    selectedAreaId.value = getAreaId(areaName ?? '') ?? '';
  }

  // -----------------------------------------------------------------
  // SET SURVEY API
  // -----------------------------------------------------------------
  Future<String?> setSurvey({required BuildContext context}) async {
    try {
      isLoadings.value = true;
      errorMessages.value = '';

      final jsonBody = {
        "survey_id": surveyId,
        "survey_language_id": selectedLanguageId.value.toString(),
        "village_area_id": selectedAreaId.value,
        "survey_done_by": AppUtility.userID,
      };

      final response =
          await Networkcall().postMethod(
                Networkutility.setSurveyApi,
                Networkutility.setSurvey,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetSetServeyResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        final newSurveyAppSideId = response[0].data?.surveyAppSideId ?? '';
        AppSnackbarStyles.showSuccess(
          title: 'Success',
          message: "Survey started",
        );
        return newSurveyAppSideId;
      } else {
        final msg = response?[0].message ?? "No questions found";
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

  void nextPage() async {
    if (!formKey.currentState!.validate()) return;

    final newSurveyAppSideId = await setSurvey(context: Get.context!);
    if (newSurveyAppSideId == null) return;

    Get.toNamed(
      AppRoutes.surveyQuestion,
      arguments: {
        'survey_id': surveyId,
        'survey_app_side_id': newSurveyAppSideId,
      },
    );
  }

  Future<void> refreshPage() async {
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  // -----------------------------------------------------------------
  // CLEANUP
  // -----------------------------------------------------------------
  @override
  void onClose() {
    // Stop recording if still active

    _audioRecorder.dispose();
    super.onClose();
  }
}
