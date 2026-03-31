import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_survey/my_surevy_model.dart';
import '../../../data/models/validator/get_validator_response_list_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';

class ValidatorStartSurveyListController extends GetxController {
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
  final RxString errorMessage = ''.obs;
  final int limit = 10;
  String? surveyId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['survey_id'] != null) {
      surveyId = args['survey_id'] as String;
    }
    _fetchResponseList(context: Get.context!);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _fetchResponseList({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        surveyList.clear();
        filteredSurveyList.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
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
        "survey_id": surveyId ?? '',
        "validator_id": AppUtility.userID ?? "",
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
        "user_id": AppUtility.userID,
      };

      List<GetValidatorResponseListResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getValidatorResponseListApi,
        Networkutility.getValidatorResponseList,
        jsonEncode(jsonBody),
        context,
      )) as List<GetValidatorResponseListResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final responseData = response[0].data;
          final responseLists = responseData.responseLists;

          for (var group in responseLists) {
            for (var person in group.responseList) {
              surveyList.add(
                MySurveyModel(
                  id: group.responseId,
                  title: person.name,
                  subtitle: '',
                  surveyId: group.respondentName,
                  responseCount: person.submittedAt,
                ),
              );
            }
          }

          if (responseLists.length < limit) {
            hasMoreData.value = false;
          }
          offset.value += limit;
          AppLogger.d('Offset updated to: ${offset.value}',
              tag: 'ValidatorStartSurveyListController');

          filteredSurveyList.value = surveyList;
        } else {
          surveyList.clear();
          filteredSurveyList.clear();
          hasMoreData.value = false;
          errorMessage.value = response[0].message;
        }
      } else {
        surveyList.clear();
        filteredSurveyList.clear();
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
      }
    } on NoInternetException catch (e) {
      surveyList.clear();
      filteredSurveyList.clear();
      errorMessage.value = e.message;
      AppLogger.e('NoInternetException: ${e.message}',
          tag: 'ValidatorStartSurveyListController', error: e);
    } on TimeoutException catch (e) {
      surveyList.clear();
      filteredSurveyList.clear();
      errorMessage.value = e.message;
      AppLogger.e('TimeoutException: ${e.message}',
          tag: 'ValidatorStartSurveyListController', error: e);
    } on HttpException catch (e) {
      surveyList.clear();
      filteredSurveyList.clear();
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppLogger.e('HttpException: ${e.message}',
          tag: 'ValidatorStartSurveyListController', error: e);
    } on ParseException catch (e) {
      surveyList.clear();
      filteredSurveyList.clear();
      errorMessage.value = e.message;
      AppLogger.e('ParseException: ${e.message}',
          tag: 'ValidatorStartSurveyListController', error: e);
    } catch (e, stackTrace) {
      surveyList.clear();
      filteredSurveyList.clear();
      errorMessage.value = 'Unexpected error: $e';
      AppLogger.e('Unexpected error: $e',
          tag: 'ValidatorStartSurveyListController',
          error: e,
          stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreResponses({required BuildContext context}) async {
    if (!isLoadingMore.value && hasMoreData.value && !isLoading.value) {
      await _fetchResponseList(context: context, isPagination: true);
    }
  }

  void searchSurveys(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      isSearching.value = true;
      _fetchResponseList(context: Get.context!, reset: true, isSearch: true)
          .then((_) {
        isSearching.value = false;
      });
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    _fetchResponseList(context: Get.context!, reset: true);
  }

  Future<void> refreshData() async {
    await _fetchResponseList(context: Get.context!, reset: true);
    if (errorMessage.value.isEmpty) {
      AppSnackbarStyles.showSuccess(
        title: 'Success',
        message: 'Data refreshed successfully',
      );
    }
  }
}
