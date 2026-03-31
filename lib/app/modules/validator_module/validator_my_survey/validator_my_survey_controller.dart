import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_survey/my_surevy_model.dart';
import '../../../data/models/validator/get_validator_my_survey_detail_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class ValidatorMySurveyController extends GetxController {
  final RxList<MySurveyModel> surveyList = <MySurveyModel>[].obs;
  final RxList<MySurveyModel> filteredSurveyList = <MySurveyModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool hasPaginated = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxInt offset = 0.obs;
  final int limit = 10;
  final RxString errorMessage = ''.obs;
  String surveyId = "";

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    surveyId = args?['survey_id']?.toString() ?? "";
    loadSurveys();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadSurveys({
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        surveyList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        AppLogger.d('No more data to fetch',
            tag: 'ValidatorMySurveyController');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
        hasPaginated.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "survey_id": surveyId,
        "validator_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
        "user_id": AppUtility.userID,
      };

      List<GetValidatorMySurveyDetailResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getValidatorMySurveyDetailApi,
        Networkutility.getValidatorMySurveyDetail,
        jsonEncode(jsonBody),
        Get.context!,
      )) as List<GetValidatorMySurveyDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final surveys = response[0].data;

          if (surveys.isEmpty || surveys.length < limit) {
            hasMoreData.value = false;
            AppLogger.d(
              'No more data or fewer items received: ${surveys.length}',
              tag: 'ValidatorMySurveyController',
            );
          }

          for (var survey in surveys) {
            surveyList.add(
              MySurveyModel(
                id: survey.surveyInfo.surveyId,
                title: survey.surveyInfo.surveyTitle,
                subtitle:
                    '${survey.teamInfo.teamName} - ${survey.surveyInfo.surveyDate}',
                surveyId: survey.surveyInfo.surveyId,
                responseCount: survey.surveyInfo.surveyCount.toString(),
              ),
            );
          }

          offset.value += limit;
          filteredSurveyList.value = surveyList;
          AppLogger.i(
            'Surveys loaded successfully. Offset: ${offset.value}',
            tag: 'ValidatorMySurveyController',
          );
        } else {
          hasMoreData.value = false;
          errorMessage.value = response[0].message;
          if (!isPagination) {
            surveyList.clear();
            filteredSurveyList.clear();
          }
          AppLogger.d(
            'API returned status false: ${errorMessage.value}',
            tag: 'ValidatorMySurveyController',
          );
          if (!isPagination) {
            AppSnackbarStyles.showError(
              title: 'Error',
              message: errorMessage.value,
            );
          }
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        if (!isPagination) {
          surveyList.clear();
          filteredSurveyList.clear();
        }
        AppLogger.d('No response from server',
            tag: 'ValidatorMySurveyController');
        if (!isPagination) {
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No response from server',
          );
        }
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      if (!isPagination) {
        surveyList.clear();
        filteredSurveyList.clear();
      }
      AppLogger.e('NoInternetException: ${e.message}',
          tag: 'ValidatorMySurveyController', error: e);
      if (!isPagination) {
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      }
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      if (!isPagination) {
        surveyList.clear();
        filteredSurveyList.clear();
      }
      AppLogger.e('TimeoutException: ${e.message}',
          tag: 'ValidatorMySurveyController', error: e);
      if (!isPagination) {
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      }
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      if (!isPagination) {
        surveyList.clear();
        filteredSurveyList.clear();
      }
      AppLogger.e('HttpException: ${e.message} (Code: ${e.statusCode})',
          tag: 'ValidatorMySurveyController', error: e);
      if (!isPagination) {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: '${e.message} (Code: ${e.statusCode})',
        );
      }
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      if (!isPagination) {
        surveyList.clear();
        filteredSurveyList.clear();
      }
      AppLogger.e('ParseException: ${e.message}',
          tag: 'ValidatorMySurveyController', error: e);
      if (!isPagination) {
        AppSnackbarStyles.showError(title: 'Error', message: e.message);
      }
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      if (!isPagination) {
        surveyList.clear();
        filteredSurveyList.clear();
      }
      AppLogger.e('Unexpected error: $e',
          tag: 'ValidatorMySurveyController', error: e);
      if (!isPagination) {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Unexpected error: $e',
        );
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void searchSurveys(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      isSearching.value = true;
      loadSurveys(reset: true, isSearch: true).then((_) {
        isSearching.value = false;
      });
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    loadSurveys(reset: true);
  }

  Future<void> refreshData() async {
    await loadSurveys(reset: true);
  }
}
