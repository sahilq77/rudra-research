import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_survey/my_surevy_model.dart';
import '../../../utils/app_logger.dart';

class ValidatorStartSurveyListController extends GetxController {
  final RxList<MySurveyModel> surveyList = <MySurveyModel>[].obs;
  final RxList<MySurveyModel> filteredSurveyList = <MySurveyModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSurveys();
    searchController.addListener(() {
      searchSurveys(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadSurveys() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API call
      surveyList.value = [
        MySurveyModel(
          id: '1',
          title: 'Mallikarjun Pote',
          subtitle: 'Umesh',
          surveyId: 'Umesh',
          responseCount: 'Sep 16, 2025 – 11:25 AM',
        ),
        MySurveyModel(
          id: '2',
          title: 'Mallikarjun Pote',
          subtitle: 'Ganesh',
          surveyId: 'Ganesh',
          responseCount: 'Sep 16, 2025 – 11:25 AM',
        ),
        MySurveyModel(
          id: '3',
          title: 'Mallikarjun Pote',
          subtitle: 'Manoj Patil',
          surveyId: 'Manoj Patil',
          responseCount: 'Sep 16, 2025 – 11:25 AM',
        ),
      ];

      filteredSurveyList.value = surveyList;
      isLoading.value = false;
      AppLogger.i(
        'Surveys loaded successfully',
        tag: 'ValidatorStartSurveyListController',
      );
    } catch (e) {
      isLoading.value = false;
      AppLogger.e(
        'Error loading surveys',
        error: e,
        tag: 'ValidatorStartSurveyListController',
      );
      Get.snackbar(
        'Error',
        'Failed to load surveys',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void searchSurveys(String query) {
    if (query.isEmpty) {
      filteredSurveyList.value = surveyList;
    } else {
      filteredSurveyList.value = surveyList
          .where(
            (survey) =>
                survey.title.toLowerCase().contains(query.toLowerCase()) ||
                survey.subtitle.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    AppLogger.d(
      'Search query: $query, Results: ${filteredSurveyList.length}',
      tag: 'ValidatorStartSurveyListController',
    );
  }

  Future<void> refreshData() async {
    await loadSurveys();
  }
}
