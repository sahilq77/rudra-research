// lib/app/modules/survey_details/survey_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/models/survey_detail/get_area_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_survey_detail_response.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_controller.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';

import '../../../routes/app_routes.dart';

class ExecutiveSurveyDetailController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxList<AreaData> areaList = <AreaData>[].obs;
  RxList<AreaData> allAreasList = <AreaData>[].obs;
  RxList<ZpWardData> zpWardsList = <ZpWardData>[].obs;
  RxList<SurveyDetailData> surveyDetailList = <SurveyDetailData>[].obs;
  var isLoadingArea = false.obs;
  var errorMessageArea = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isLoadings = false.obs;
  var errorMessages = ''.obs;
  RxString? selectedAreaVal = RxString("");
  RxString selectedWardName = RxString("");
  RxString selectedWardId = RxString("");

  final AudioRecorderController audioRecorder = Get.put(
    AudioRecorderController(),
  );
  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  // ---------- LANGUAGE ----------
  final RxString selectedLanguage = 'Marathi'.obs;
  final RxInt selectedLanguageId = 0.obs;

  final Map<String, int> _languageIdMap = {
    'Marathi': 0,
    'Hindi': 1,
    'English': 2,
  };

  final List<String> allLanguages = ['Marathi', 'Hindi', 'English'];
  final RxList<String> availableLanguages = <String>[].obs;

  // ---------- AREA ----------
  final RxString selectedAreaId = ''.obs;
  String surveyId = "";
  String? zpWardId;

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
      await _loadLanguagesFromCache();
      await _loadZpWardsFromCache();
      await _loadAreasFromCache();
      await _loadSurveyDetailFromCache();
      await audioRecorder.autoStartRecording();
    });

    // Listen to ward selection changes and filter villages
    ever(selectedWardId, (wardId) {
      _filterVillagesByWard(wardId);
    });
  }

  Future<void> _loadSurveyDetailFromCache() async {
    try {
      isLoading.value = true;
      final detail = await _localRepo.getSurveyDetails(surveyId);

      if (detail != null) {
        surveyDetailList.add(
          SurveyDetailData(
            region: detail['region'] ?? '',
            regionId: detail['region_id'] ?? '',
            stateName: detail['state_name'] ?? '',
            stateId: detail['state_id'] ?? '',
            districtName: detail['district_name'] ?? '',
            districtId: detail['district_id'] ?? '',
            loksabhaName: detail['loksabha_name'] ?? '',
            loksabhaId: detail['loksabha_id'] ?? '',
            assemblyName: detail['assembly_name'] ?? '',
            assemblyId: detail['assembly_id'] ?? '',
            wardName: detail['ward_name'] ?? '',
            zpWardId: detail['zp_ward_id'] ?? '',
            teamName: detail['team_name'] ?? '',
            teamId: detail['team_id'] ?? '',
          ),
        );
        AppLogger.i('✅ Loaded survey details from cache',
            tag: 'ExecutiveSurveyDetail');
      } else {
        AppLogger.w('⚠️ No cached survey details found',
            tag: 'ExecutiveSurveyDetail');
      }
    } catch (e) {
      AppLogger.e('Error loading survey detail from cache: $e',
          tag: 'ExecutiveSurveyDetail');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadZpWardsFromCache() async {
    try {
      zpWardsList.clear();
      final wards = await _localRepo.getZpWards(surveyId);
      if (wards.isNotEmpty) {
        zpWardsList.value = wards
            .map((w) => ZpWardData(
                  zpWardId: w['zp_ward_id'],
                  wardName: w['ward_name'],
                ))
            .toList();
        AppLogger.i('✅ Loaded ${wards.length} zp_wards from cache',
            tag: 'ExecutiveSurveyDetail');
      } else {
        AppLogger.w('⚠️ No cached zp_wards found',
            tag: 'ExecutiveSurveyDetail');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading zp_wards from cache',
        error: e,
        stackTrace: stackTrace,
        tag: 'ExecutiveSurveyDetail',
      );
    }
  }

  Future<void> _loadAreasFromCache() async {
    try {
      isLoadingArea.value = true;
      allAreasList.clear();
      areaList.clear();
      selectedAreaVal?.value = "";
      selectedAreaId.value = "";

      final areas = await _localRepo.getAreas(surveyId);
      if (areas.isNotEmpty) {
        allAreasList.value = areas
            .map((a) => AreaData(
                  villageAreaId: a['village_area_id'],
                  areaName: a['area_name'],
                  zpWardId: a['zp_ward_id'],
                  wardName: a['ward_name'],
                ))
            .toList();
        // Don't show villages by default - wait for ward selection
        areaList.value = [];
        AppLogger.i('✅ Loaded ${areas.length} areas from cache',
            tag: 'ExecutiveSurveyDetail');
      } else {
        AppLogger.w('⚠️ No cached areas found', tag: 'ExecutiveSurveyDetail');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading areas from cache',
        error: e,
        stackTrace: stackTrace,
        tag: 'ExecutiveSurveyDetail',
      );
    } finally {
      isLoadingArea.value = false;
    }
  }

  void _filterVillagesByWard(String wardId) {
    AppLogger.d(
      '🔍 Filtering villages for ward_id: "$wardId"',
      tag: 'ExecutiveSurveyDetail',
    );

    if (wardId.isEmpty) {
      areaList.value = [];
      AppLogger.d('📋 No ward selected, showing empty villages',
          tag: 'ExecutiveSurveyDetail');
    } else {
      areaList.value =
          allAreasList.where((area) => area.zpWardId == wardId).toList();

      AppLogger.i(
        '✅ Filtered ${areaList.length} villages for ward_id: "$wardId"',
        tag: 'ExecutiveSurveyDetail',
      );
    }

    // Reset village selection when ward changes
    selectedAreaVal?.value = "";
    selectedAreaId.value = "";
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

  void setSelectedArea(String? areaName) {
    selectedAreaVal?.value = areaName ?? '';
    selectedAreaId.value = getAreaId(areaName ?? '') ?? '';
  }

  List<String> getWardNames() {
    return zpWardsList.map((w) => w.wardName).toSet().toList();
  }

  String? getWardId(String wardName) {
    return zpWardsList
            .firstWhereOrNull((ward) => ward.wardName == wardName)
            ?.zpWardId ??
        '';
  }

  void setSelectedWard(String? wardName) {
    selectedWardName.value = wardName ?? '';
    selectedWardId.value = getWardId(wardName ?? '') ?? '';

    AppLogger.d(
      '🏛️ Ward selected: "$wardName" → ID: "${selectedWardId.value}"',
      tag: 'ExecutiveSurveyDetail',
    );
  }

  Future<String?> _generateLocalSurveyId() async {
    try {
      isLoadings.value = true;

      // Generate TRULY unique offline survey ID with UUID
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final random = (timestamp % 100000).toString(); // Last 5 digits as random
      final localId =
          'offline_${surveyId}_${selectedLanguageId.value}_${selectedAreaId.value}_${timestamp}_$random';

      AppLogger.i(
        '✅ Generated local survey_app_side_id: $localId',
        tag: 'ExecutiveSurveyDetail',
      );

      final audioPath = await audioRecorder.startRecording();
      AppLogger.d(
        '🎤 Audio recording started: $audioPath',
        tag: 'ExecutiveSurveyDetail',
      );

      return localId;
    } catch (e, s) {
      AppLogger.e(
        'Error generating local survey ID',
        error: e,
        stackTrace: s,
        tag: 'ExecutiveSurveyDetail',
      );
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to start survey',
      );
      return null;
    } finally {
      isLoadings.value = false;
    }
  }

  void nextPage(formKey) async {
    if (!formKey.currentState!.validate()) return;

    final localSurveyId = await _generateLocalSurveyId();
    if (localSurveyId == null) return;

    AppLogger.d(
      '🚀 Navigating with ward_id: "${selectedWardId.value}", village_area_id: "${selectedAreaId.value}"',
      tag: 'ExecutiveSurveyDetail',
    );

    // Delete old interviewer controller if exists
    if (Get.isRegistered<ExecutiveSurveyInterviewerController>()) {
      Get.delete<ExecutiveSurveyInterviewerController>();
      AppLogger.d('Deleted old ExecutiveSurveyInterviewerController',
          tag: 'ExecutiveSurveyDetail');
    }

    Get.toNamed(
      AppRoutes.executiveSurveyQuestion,
      arguments: {
        'survey_id': surveyId,
        'survey_app_side_id': localSurveyId,
        'language_id': selectedLanguageId.value.toString(),
        'zp_ward_id': selectedWardId.value,
        'village_area_id': selectedAreaId.value,
      },
    );

    _resetForm();
  }

  Future<void> refreshPage() async {
    await _loadLanguagesFromCache();
    await _loadZpWardsFromCache();
    await _loadAreasFromCache();
    await _loadSurveyDetailFromCache();
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }

  Future<void> _loadLanguagesFromCache() async {
    try {
      final languages = await _localRepo.getLanguages(surveyId);

      if (languages.isNotEmpty) {
        final cachedLanguages = <String>[];

        for (var lang in languages) {
          final langName = lang['language_name'] as String?;
          if (langName != null && allLanguages.contains(langName)) {
            cachedLanguages.add(langName);
          }
        }

        if (cachedLanguages.isNotEmpty) {
          availableLanguages.assignAll(cachedLanguages);
          if (!cachedLanguages.contains(selectedLanguage.value)) {
            selectedLanguage.value = cachedLanguages.first;
          }
          AppLogger.i('✅ Loaded ${cachedLanguages.length} languages from cache',
              tag: 'ExecutiveSurveyDetail');
        } else {
          availableLanguages.assignAll(allLanguages);
          AppLogger.w('⚠️ No matching languages in cache, showing all',
              tag: 'ExecutiveSurveyDetail');
        }
      } else {
        availableLanguages.assignAll(allLanguages);
        AppLogger.w('⚠️ No cached languages found, showing all',
            tag: 'ExecutiveSurveyDetail');
      }
    } catch (e) {
      availableLanguages.assignAll(allLanguages);
      AppLogger.e('Error loading languages from cache: $e',
          tag: 'ExecutiveSurveyDetail');
    }
  }

  void _resetForm() {
    selectedWardName.value = "";
    selectedWardId.value = "";
    selectedAreaVal?.value = "";
    selectedAreaId.value = "";
  }

  @override
  void onClose() {
    _audioRecorder.dispose();
    super.onClose();
  }
}
