// lib/app/modules/survey_details/survey_details_controller.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/models/survey_detail/get_area_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_survey_detail_response.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/modules/manager_module/survey_interviewer/survey_interviewer_controller.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../routes/app_routes.dart';

class SurveyDetailsController extends GetxController {
  RxList<AreaData> areaList = <AreaData>[].obs;
  RxList<AreaData> allAreasList = <AreaData>[].obs;
  RxList<ZpWardData> zpWardsList = <ZpWardData>[].obs;
  RxList<ZpWardData> allZpWardsList = <ZpWardData>[].obs;
  RxList<AssemblyData> assembliesList = <AssemblyData>[].obs;
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
  RxString selectedAssemblyName = RxString("");
  RxString selectedAssemblyId = RxString("");

  final AudioRecorderController audioRecorder = Get.put(
    AudioRecorderController(),
  );
  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  // Store the real survey_app_side_id from first online survey
  String? _storedSurveyAppSideId;
  static const String _surveyIdKey = 'stored_survey_app_side_id';

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

  // ---------- WARD DATA MODEL ----------

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

    // Load stored survey_app_side_id from SharedPreferences
    _loadStoredSurveyId();

    // Set loading true before data loads
    isLoading.value = true;

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLanguagesFromCache();
      await _loadAssembliesFromCache();
      await _loadZpWardsFromCache();
      await _loadAreasFromCache();
      await _loadSurveyDetailFromCache();
      await audioRecorder.autoStartRecording();
      isLoading.value = false;
    });

    // Listen to assembly selection changes and filter wards
    ever(selectedAssemblyId, (assemblyId) {
      _filterWardsByAssembly(assemblyId);
    });

    // Listen to ward selection changes and filter villages
    ever(selectedWardId, (wardId) {
      _filterVillagesByWard(wardId);
    });
  }

  Future<void> _loadStoredSurveyId() async {
    final prefs = await SharedPreferences.getInstance();
    _storedSurveyAppSideId = prefs.getString(_surveyIdKey);
    if (_storedSurveyAppSideId != null) {
      log('📦 Loaded stored survey_app_side_id: $_storedSurveyAppSideId');
    }
  }

  Future<void> _saveStoredSurveyId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_surveyIdKey, id);
    _storedSurveyAppSideId = id;
    log('💾 Saved survey_app_side_id to SharedPreferences: $id');
  }

  // -----------------------------------------------------------------
  // AUTO START RECORDING
  // -----------------------------------------------------------------

  // -----------------------------------------------------------------
  // AREA & SURVEY FETCH
  // -----------------------------------------------------------------
  Future<void> _loadSurveyDetailFromCache() async {
    try {
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
        AppLogger.i('✅ Loaded survey details from cache', tag: 'SurveyDetails');
      } else {
        AppLogger.w('⚠️ No cached survey details found', tag: 'SurveyDetails');
      }
    } catch (e) {
      AppLogger.e('Error loading survey detail from cache: $e',
          tag: 'SurveyDetails');
    }
  }

  Future<void> _loadZpWardsFromCache() async {
    try {
      allZpWardsList.clear();
      zpWardsList.clear();
      final wards = await _localRepo.getZpWards(surveyId);
      if (wards.isNotEmpty) {
        allZpWardsList.value = wards
            .map((w) => ZpWardData(
                  zpWardId: w['zp_ward_id'],
                  wardName: w['ward_name'],
                  assemblyId: w['assembly_id'],
                ))
            .toList();
        // Show all wards initially if no assembly selected
        zpWardsList.value = List.from(allZpWardsList);
        AppLogger.i('✅ Loaded ${wards.length} zp_wards from cache',
            tag: 'SurveyDetails');
      } else {
        AppLogger.w('⚠️ No cached zp_wards found', tag: 'SurveyDetails');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading zp_wards from cache',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyDetails',
      );
    }
  }

  Future<void> _loadAssembliesFromCache() async {
    try {
      assembliesList.clear();
      final assemblies = await _localRepo.getAssemblies(surveyId);
      if (assemblies.isNotEmpty) {
        assembliesList.value = assemblies
            .map((a) => AssemblyData(
                  assemblyId: a['assembly_id'],
                  assemblyName: a['assembly_name'],
                ))
            .toList();
        AppLogger.i('✅ Loaded ${assemblies.length} assemblies from cache',
            tag: 'SurveyDetails');
      } else {
        AppLogger.w('⚠️ No cached assemblies found', tag: 'SurveyDetails');
      }
    } catch (e) {
      AppLogger.e('Error loading assemblies from cache: $e',
          tag: 'SurveyDetails');
    }
  }

  void _filterWardsByAssembly(String assemblyId) {
    if (assemblyId.isEmpty) {
      zpWardsList.value = List.from(allZpWardsList);
    } else {
      zpWardsList.value = allZpWardsList
          .where((w) => w.assemblyId == assemblyId)
          .toList();
    }
    // Reset ward and area when assembly changes
    selectedWardName.value = '';
    selectedWardId.value = '';
    selectedAreaVal?.value = '';
    selectedAreaId.value = '';
    areaList.value = [];
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
            tag: 'SurveyDetails');
        
        // Debug: Log first few areas with ward mapping
        for (var i = 0; i < areas.length && i < 3; i++) {
          AppLogger.d(
            '📍 Area[$i]: ${areas[i]['area_name']} → ward_id: ${areas[i]['zp_ward_id']}',
            tag: 'SurveyDetails',
          );
        }
      } else {
        AppLogger.w('⚠️ No cached areas found', tag: 'SurveyDetails');
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Error loading areas from cache',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyDetails',
      );
    } finally {
      isLoadingArea.value = false;
    }
  }

  void _filterVillagesByWard(String wardId) {
    AppLogger.d(
      '🔍 Filtering villages for ward_id: "$wardId" (length: ${wardId.length})',
      tag: 'SurveyDetails',
    );
    
    if (wardId.isEmpty) {
      areaList.value = allAreasList;
      AppLogger.d('📋 No ward selected, showing all ${allAreasList.length} villages',
          tag: 'SurveyDetails');
    } else {
      // Debug: Log all areas with their ward IDs
      AppLogger.d('📊 Total areas to filter: ${allAreasList.length}',
          tag: 'SurveyDetails');
      for (var area in allAreasList) {
        AppLogger.d(
          '  - ${area.areaName}: zpWardId="${area.zpWardId}" (match: ${area.zpWardId == wardId})',
          tag: 'SurveyDetails',
        );
      }
      
      areaList.value = allAreasList
          .where((area) => area.zpWardId == wardId)
          .toList();
      
      AppLogger.i(
        '✅ Filtered ${areaList.length} villages for ward_id: "$wardId"',
        tag: 'SurveyDetails',
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
  // GENERATE LOCAL SURVEY ID (NO API CALL)
  // -----------------------------------------------------------------
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
        tag: 'SurveyDetails',
      );

      // DON'T reset form here - need selectedAreaId for navigation

      // Start audio recording
      final audioPath = await audioRecorder.startRecording();
      AppLogger.d(
        '🎤 Audio recording started: $audioPath',
        tag: 'SurveyDetails',
      );

      return localId;
    } catch (e, s) {
      AppLogger.e(
        'Error generating local survey ID',
        error: e,
        stackTrace: s,
        tag: 'SurveyDetails',
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

  List<String> getAssemblyNames() {
    return assembliesList.map((a) => a.assemblyName).toSet().toList();
  }

  String? getAssemblyId(String assemblyName) {
    return assembliesList
            .firstWhereOrNull((a) => a.assemblyName == assemblyName)
            ?.assemblyId ??
        '';
  }

  void setSelectedAssembly(String? assemblyName) {
    selectedAssemblyName.value = assemblyName ?? '';
    selectedAssemblyId.value = getAssemblyId(assemblyName ?? '') ?? '';
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
      tag: 'SurveyDetails',
    );
  }

  void nextPage(formKey) async {
    if (!formKey.currentState!.validate()) return;

    final localSurveyId = await _generateLocalSurveyId();
    if (localSurveyId == null) return;

    AppLogger.d(
      '🚀 Navigating with ward_id: "${selectedWardId.value}", village_area_id: "${selectedAreaId.value}"',
      tag: 'SurveyDetails',
    );

    // Delete old interviewer controller if exists
    if (Get.isRegistered<SurveyInterviewerController>()) {
      Get.delete<SurveyInterviewerController>();
      AppLogger.d('Deleted old SurveyInterviewerController',
          tag: 'SurveyDetails');
    }

    Get.toNamed(
      AppRoutes.surveyQuestion,
      arguments: {
        'survey_id': surveyId,
        'survey_app_side_id': localSurveyId,
        'language_id': selectedLanguageId.value.toString(),
        'zp_ward_id': selectedWardId.value,
        'village_area_id': selectedAreaId.value,
      },
    );

    // Reset form AFTER navigation
    _resetForm();
  }

  Future<void> refreshPage() async {
    await _loadLanguagesFromCache();
    await _loadAssembliesFromCache();
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
              tag: 'SurveyDetails');
        } else {
          availableLanguages.assignAll(allLanguages);
          AppLogger.w('⚠️ No matching languages in cache, showing all',
              tag: 'SurveyDetails');
        }
      } else {
        availableLanguages.assignAll(allLanguages);
        AppLogger.w('⚠️ No cached languages found, showing all',
            tag: 'SurveyDetails');
      }
    } catch (e) {
      availableLanguages.assignAll(allLanguages);
      AppLogger.e('Error loading languages from cache: $e',
          tag: 'SurveyDetails');
    }
  }

  Future<bool> _hasQuestionsForLanguage(String surveyId, int languageId) async {
    try {
      final questions =
          await _localRepo.getSurveyQuestions(surveyId, languageId.toString());

      AppLogger.d(
        '\n${'─' * 80}\n📋 DATABASE QUERY RESULT\n${'─' * 80}',
        tag: 'SurveyDetails-DB',
      );
      AppLogger.d('Survey ID: $surveyId', tag: 'SurveyDetails-DB');
      AppLogger.d('Language ID: $languageId', tag: 'SurveyDetails-DB');
      AppLogger.d('Questions Found: ${questions.length}',
          tag: 'SurveyDetails-DB');

      if (questions.isNotEmpty) {
        AppLogger.d(
          '\n📊 QUESTIONS TABLE (First 3 rows):\n${'─' * 80}',
          tag: 'SurveyDetails-DB',
        );
        AppLogger.d(
          '| ${'ID'.padRight(5)} | ${'Survey ID'.padRight(12)} | ${'Lang ID'.padRight(8)} | ${'Question ID'.padRight(12)} | ${'Sequence'.padRight(8)} | ${'Question'.padRight(30)} |',
          tag: 'SurveyDetails-DB',
        );
        AppLogger.d('|${'─' * 88}|', tag: 'SurveyDetails-DB');

        for (var i = 0; i < questions.length && i < 3; i++) {
          final q = questions[i];
          final id = (q['id']?.toString() ?? 'N/A').padRight(5);
          final sId = (q['survey_id']?.toString() ?? 'N/A').padRight(12);
          final lId = (q['language_id']?.toString() ?? 'N/A').padRight(8);
          final qId = (q['question_id']?.toString() ?? 'N/A').padRight(12);
          final seq = (q['sequence_number']?.toString() ?? 'N/A').padRight(8);
          final question = (q['question']?.toString() ?? 'N/A');
          final truncated = question.length > 30
              ? '${question.substring(0, 27)}...'
              : question.padRight(30);

          AppLogger.d(
            '| $id | $sId | $lId | $qId | $seq | $truncated |',
            tag: 'SurveyDetails-DB',
          );
        }

        if (questions.length > 3) {
          AppLogger.d(
            '| ... (${questions.length - 3} more rows) ${' ' * 60} |',
            tag: 'SurveyDetails-DB',
          );
        }
        AppLogger.d('${'─' * 80}\n', tag: 'SurveyDetails-DB');
      } else {
        AppLogger.w(
          '❌ NO QUESTIONS IN DATABASE for Survey: $surveyId, Language: $languageId',
          tag: 'SurveyDetails-DB',
        );
      }

      return questions.isNotEmpty;
    } catch (e, stackTrace) {
      AppLogger.e(
        '❌ DATABASE ERROR',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyDetails-DB',
      );
      return false;
    }
  }

  void _resetForm() {
    selectedAssemblyName.value = '';
    selectedAssemblyId.value = '';
    selectedWardName.value = "";
    selectedWardId.value = "";
    selectedAreaVal?.value = "";
    selectedAreaId.value = "";
    areaList.value = [];
    zpWardsList.value = List.from(allZpWardsList);
    // DON'T reset language - preserve user's selection
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
