import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/local/survey_local_repository.dart';
import 'package:rudra/app/data/models/survey_detail/get_complete_survey_details_response.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/connctivityservice.dart';

class SurveyDataService extends GetxService {
  final SurveyLocalRepository _localRepo = SurveyLocalRepository();
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();

  final RxMap<String, RxBool> surveyLoadingStatus = <String, RxBool>{}.obs;

  Future<bool> fetchAndCacheCompleteSurveyData({
    required String surveyId,
    required BuildContext context,
  }) async {
    try {
      AppLogger.i(
        '📥 Starting to fetch complete survey data for survey_id: $surveyId',
        tag: 'SurveyDataService',
      );

      surveyLoadingStatus[surveyId] = true.obs;

      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        AppLogger.w(
          'No internet connection, checking local cache',
          tag: 'SurveyDataService',
        );
        final isLoaded = await _localRepo.isSurveyDataLoaded(surveyId);
        surveyLoadingStatus[surveyId]?.value = false;
        return isLoaded;
      }

      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID ?? "",
        "team_id": AppUtility.teamId ?? "",
      };

      AppLogger.d(
        'Request body: ${jsonEncode(jsonBody)}',
        tag: 'SurveyDataService',
      );

      final response = await Networkcall().postMethod(
        Networkutility.getCompleteSurveyDetailsApi,
        Networkutility.getCompleteSurveyDetails,
        jsonEncode(jsonBody),
        context,
      ) as List<GetCompleteSurveyDetailsResponse>?;

      if (response == null || response.isEmpty) {
        AppLogger.e(
          'No response from server for survey_id: $surveyId',
          tag: 'SurveyDataService',
        );
        surveyLoadingStatus[surveyId]?.value = false;
        return false;
      }

      final first = response.first;
      if (first.status != "true") {
        AppLogger.e(
          'API returned error: ${first.message}',
          tag: 'SurveyDataService',
        );
        surveyLoadingStatus[surveyId]?.value = false;
        return false;
      }

      final surveyDetails = first.data.surveyDetails;

      AppLogger.d(
        '✅ Received complete survey data:\n'
        '   - Languages: ${surveyDetails.language.length}\n'
        '   - Areas: ${surveyDetails.villageArea.length}\n'
        '   - Questions: ${surveyDetails.questions.length}\n'
        '   - Casts: ${surveyDetails.cast.length}',
        tag: 'SurveyDataService',
      );

      final detailsMap = {
        'region': surveyDetails.region,
        'region_id': surveyDetails.regionId,
        'state_name': surveyDetails.stateName,
        'state_id': surveyDetails.stateId,
        'district_name': surveyDetails.districtName,
        'district_id': surveyDetails.districtId,
        'loksabha_name': surveyDetails.loksabhaName,
        'loksabha_id': surveyDetails.loksabhaId,
        'assembly_name': surveyDetails.assemblyName,
        'assembly_id': surveyDetails.assemblyId,
        'ward_name': surveyDetails.wardName,
        'zp_ward_id': surveyDetails.zpWardId,
        'team_name': surveyDetails.teamName,
        'team_id': surveyDetails.teamId,
        'validation_name': surveyDetails.defaultSettings?.name ?? '1',
        'validation_age': surveyDetails.defaultSettings?.age ?? '1',
        'validation_gender': surveyDetails.defaultSettings?.gender ?? '1',
        'validation_phone': surveyDetails.defaultSettings?.phone ?? '1',
        'validation_caste': surveyDetails.defaultSettings?.caste ?? '1',
      };

      final languages = surveyDetails.language
          .map((l) => {
                'survey_language_id': l.surveyLanguageId,
                'language_name': l.languageName,
              })
          .toList();

      final zpWards = surveyDetails.zpWards
          .map((w) => {
                'zp_ward_id': w.zpWardId,
                'ward_name': w.wardName,
              })
          .toList();

      final areas = surveyDetails.villageArea
          .map((a) => {
                'village_area_id': a.villageAreaId,
                'area_name': a.areaName,
                'zp_ward_id': a.zpWardId,
                'ward_name': a.wardName,
              })
          .toList();

      final casts = surveyDetails.cast
          .map((c) => {
                'id': c.id,
                'cast_name': c.castName,
              })
          .toList();

      final Map<String, List<Map<String, dynamic>>> questionsByLanguage = {};
      for (var question in surveyDetails.questions) {
        final langId = question.questionLanguageId;
        if (!questionsByLanguage.containsKey(langId)) {
          questionsByLanguage[langId] = [];
        }

        questionsByLanguage[langId]!.add({
          'question_id': question.questionId,
          'question': question.question,
          'question_type': question.questionType,
          'sequence_number': question.sequenceNumber,
          'parent_question_id': question.parentQuestionId,
          'parent_option_id': question.parentOptionId,
          'options': question.options
              .map((o) => {
                    'option_id': o.optionId,
                    'choice_text': o.choiceText,
                    'text_field_type': o.textFieldType,
                    'answer_type': o.answerType,
                  })
              .toList(),
        });
      }

      AppLogger.d(
        '💾 Saving to local database...',
        tag: 'SurveyDataService',
      );

      await _localRepo.saveCompleteSurveyData(
        surveyId,
        detailsMap,
        languages,
        zpWards,
        areas,
        casts,
        questionsByLanguage,
      );

      AppLogger.i(
        '✅ Successfully cached complete survey data for survey_id: $surveyId',
        tag: 'SurveyDataService',
      );

      surveyLoadingStatus[surveyId]?.value = false;
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch complete survey data for survey_id: $surveyId',
        error: e,
        stackTrace: stackTrace,
        tag: 'SurveyDataService',
      );
      surveyLoadingStatus[surveyId]?.value = false;
      return false;
    }
  }

  Future<void> fetchMultipleSurveysInParallel({
    required List<String> surveyIds,
    required BuildContext context,
  }) async {
    AppLogger.i(
      '🚀 Starting parallel fetch for ${surveyIds.length} surveys',
      tag: 'SurveyDataService',
    );

    final futures = surveyIds.map((surveyId) {
      return fetchAndCacheCompleteSurveyData(
        surveyId: surveyId,
        context: context,
      );
    }).toList();

    await Future.wait(futures);

    AppLogger.i(
      '✅ Completed parallel fetch for all surveys',
      tag: 'SurveyDataService',
    );
  }

  bool isSurveyLoading(String surveyId) {
    return surveyLoadingStatus[surveyId]?.value ?? false;
  }

  Future<bool> isSurveyDataAvailable(String surveyId) async {
    return await _localRepo.isSurveyDataLoaded(surveyId);
  }
}
