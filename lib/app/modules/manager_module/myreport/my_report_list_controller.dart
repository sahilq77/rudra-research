import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_report/my_report_model.dart';
import '../../../utils/app_logger.dart';

class MyReportListController extends GetxController {
  final RxList<MyReportModel> reportList = <MyReportModel>[].obs;
  final RxList<MyReportModel> filteredReportList = <MyReportModel>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
    searchController.addListener(() {
      searchReports(searchController.text);
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadReports() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API call
      reportList.value = [
        MyReportModel(
          id: '1',
          title: 'OBC Question 13-09 Nanded',
          subtitle: 'OBC Question 13-09 Nanded',
          surveyId: '100',
          responseCount: '00',
        ),
        MyReportModel(
          id: '2',
          title: 'OBC Question 14-09 Pune',
          subtitle: 'OBC Question 14-09 Pune',
          surveyId: '101',
          responseCount: '05',
        ),
        MyReportModel(
          id: '3',
          title: 'OBC Question 15-09 Mumbai',
          subtitle: 'OBC Question 15-09 Mumbai',
          surveyId: '102',
          responseCount: '03',
        ),
      ];

      filteredReportList.value = reportList;
      isLoading.value = false;
      AppLogger.i('Reports loaded successfully', tag: 'MyReportController');
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error loading reports', error: e, tag: 'MyReportController');
      Get.snackbar(
        'Error',
        'Failed to load reports',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void searchReports(String query) {
    if (query.isEmpty) {
      filteredReportList.value = reportList;
    } else {
      filteredReportList.value = reportList
          .where(
            (report) =>
                report.title.toLowerCase().contains(query.toLowerCase()) ||
                report.subtitle.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    AppLogger.d(
      'Search query: $query, Results: ${filteredReportList.length}',
      tag: 'MyReportController',
    );
  }

  Future<void> refreshData() async {
    await loadReports();
  }
}
