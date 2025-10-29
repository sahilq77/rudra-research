// lib/app/modules/survey_details/survey_details_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/survey_detail/get_area_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_survey_detail_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
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
  RxString? selectedAreaVal = RxString("");

  // ---------- LANGUAGE ----------
  final RxString selectedLanguage = 'Marathi'.obs;

  // NEW: language ID (0 = Marathi, 1 = Hindi, 2 = English)
  final RxInt selectedLanguageId = 0.obs;

  // Map name → id (kept inside controller – no view changes needed)
  final Map<String, int> _languageIdMap = {
    'Marathi': 0,
    'Hindi': 1,
    'English': 2,
  };

  // List of display names (order must match IDs)
  final List<String> languages = ['Marathi', 'Hindi', 'English'];



  // ---------- NEW: AREA ID ----------
  final RxString selectedAreaId = ''.obs; // <-- ADDED

  @override
  void onInit() {
    super.onInit();

    // Keep language ID in sync whenever the name changes
    ever(selectedLanguage, (String name) {
      selectedLanguageId.value = _languageIdMap[name] ?? 0;
    });

    final args = Get.arguments as Map<String, dynamic>?;
    final String surveyId = args?['survey_id']?.toString() ?? "";
    fetchArea(context: Get.context!, surveyId: surveyId);
    fetchSurveyDetail(context: Get.context!, surveyId: surveyId);
  }

  // -----------------------------------------------------------------
  // NEW: Helper to keep name + id in sync
  // -----------------------------------------------------------------
  void setSelectedArea(String? areaName) {
    selectedAreaVal?.value = areaName ?? '';
    selectedAreaId.value = getAreaId(areaName ?? '') ?? '';
  }

  Future<void> fetchSurveyDetail({
    required BuildContext context,
    bool reset = false,
    required String surveyId,
  }) async {
    try {
      if (reset) {
        surveyDetailList.clear();
      }

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

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
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
          log('API returned status false: No myTeam found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No myTeam found',
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        log('No response from server');
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      log('NoInternetException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      log('TimeoutException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      log('ParseException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      log('Unexpected error: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // -----------------------------------------------------------------
  // AREA FETCH (unchanged)
  // -----------------------------------------------------------------
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
      selectedAreaId.value = ""; // <-- clear ID when list reloads

      final jsonBody = {"survey_id": surveyId};

      List<GetAreaResponse>? response =
          await Networkcall().postMethod(
                Networkutility.getAreaApi,
                Networkutility.getArea,
                jsonEncode(jsonBody),
                context,
              )
              as List<GetAreaResponse>?;

      log(
        'Fetch Areas Response: ${response?.isNotEmpty == true ? response![0].toJson() : 'null'}',
      );

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          areaList.value = response[0].data;
          log(
            'Area List Loaded: ${areaList.map((s) => "${s.villageAreaId}: ${s.areaName}").toList()}',
          );
        } else {
          errorMessageArea.value = response[0].message;
          AppSnackbarStyles.showError(
            title: 'Error',
            message: response[0].message,
          );
        }
      } else {
        errorMessageArea.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
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
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessageArea.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e, stackTrace) {
      errorMessageArea.value = 'Unexpected error: $e';
      log('Fetch Area Exception: $e, stack: $stackTrace');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
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

  // -----------------------------------------------------------------
  // NAVIGATION – now passes languageId **and** areaId
  // -----------------------------------------------------------------
  void nextPage() {
    if (formKey.currentState!.validate()) {
      Get.toNamed(
        AppRoutes.surveyQuestion,
        arguments: {
          'language': selectedLanguage.value, // name (String)
          'languageId': selectedLanguageId.value, // id (int)
          'area': selectedAreaVal!.value, // name
          'areaId': selectedAreaId.value, // <-- NEW
        },
      );
    }
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }
}
