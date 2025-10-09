import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/my_report/my_report_model.dart';
import '../../../data/models/my_team/my_team_model.dart';
import '../../../utils/app_logger.dart';

import 'package:get/get.dart';


class MyTeamController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var reportList = <MyTeamModel>[].obs;
  var filteredReportList = <MyTeamModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  // Fetch reports (simulating API call)
  Future<void> fetchReports() async {
    try {
      isLoading(true);
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Sample data (replace with actual API call)
      final List<MyTeamModel> tempList = [
        MyTeamModel(id: '1', title: 'Team Report Q1', date: '2025-03-31'),
        MyTeamModel(id: '2', title: 'Team Report Q2', date: '2025-06-30'),
        MyTeamModel(id: '3', title: 'Team Report Q3', date: '2025-09-30'),
      ];

      reportList.assignAll(tempList);
      filteredReportList.assignAll(tempList);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load reports: $e');
    } finally {
      isLoading(false);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchReports();
  }

  // Filter reports (optional, can be expanded based on requirements)
  void filterReports(String query) {
    if (query.isEmpty) {
      filteredReportList.assignAll(reportList);
    } else {
      filteredReportList.assignAll(
        reportList
            .where((report) =>
                report.title.toLowerCase().contains(query.toLowerCase()))
            .toList(),
      );
    }
  }
}
