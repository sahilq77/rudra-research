import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/super_admin/get_super_admin_dashboard_counter_response.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';

import '../../../utils/app_images.dart';
import '../../../utils/app_utility.dart';

class SuperAdminHomeController extends GetxController {
  final RxString completeSurvey = '0'.obs;
  final RxString incompleteSurvey = '0'.obs;
  final RxString teamCount = '0'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    fetchDashboardCounters(context: Get.context!);
  }

  List<Map<String, dynamic>> get dashboardStats {
    return [
      {
        'title': 'Start Survey',
        'value': completeSurvey.value,
        'color': const Color(0xFFE9F9EF),
        'borderColor': const Color(0xFFA3EFC0),
        'imagePath': AppImages.targetCompleted,
        'textColor': const Color(0xFF4A4A4A),
      },
      {
        'title': 'Stop Survey',
        'value': incompleteSurvey.value,
        'color': const Color(0xFFFFF4E6),
        'borderColor': const Color(0xFFFFD699),
        'imagePath': AppImages.pendingSurvey,
        'textColor': const Color(0xFF4A4A4A),
      },
      {
        'title': 'Team Count',
        'value': teamCount.value,
        'color': const Color(0xFFE6F4FF),
        'borderColor': const Color(0xFF99D6FF),
        'imagePath': AppImages.surveyInProgress,
        'textColor': const Color(0xFF4A4A4A),
      },
    ];
  }

  Future<void> fetchDashboardCounters({required BuildContext context}) async {
    try {
      final jsonBody = {
        "user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.getSuperAdminDashboardCounterApi,
        Networkutility.getSuperAdminDashboardCounter,
        jsonEncode(jsonBody),
        context,
      ) as List<GetSuperAdminDashboardCounterResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        final data = response[0].data;
        completeSurvey.value = data.inProgress ?? '0';
        incompleteSurvey.value = data.stopedSurvey ?? '0';
        teamCount.value = data.teamCount ?? '0';
        log('Dashboard counters updated: complete=${completeSurvey.value}, incomplete=${incompleteSurvey.value}, team=${teamCount.value}');
      } else {
        log('Dashboard API response invalid or empty');
      }
    } catch (e, stackTrace) {
      log('Error fetching dashboard counters: $e');
      log('Stack trace: $stackTrace');
    }
  }

  Future<void> refreshData() async {
    await AppUtility.fetchAndUpdateTeamIds(Get.context!);
    await fetchDashboardCounters(context: Get.context!);
  }

  String get userName => AppUtility.fullName ?? 'User';
}
