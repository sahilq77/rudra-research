import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_detail.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_response.dart' show TeamMembersDetails;
import 'package:rudra/app/data/models/profile_details/get_my_survey_response.dart';
import 'package:rudra/app/data/models/profile_details/get_user_performance_response.dart';
import 'package:rudra/app/data/models/profile_details/performance_data_model.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

class TeamMemberDetailController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var teamDetail = <TeamMemberDetail>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;

  // Variable to store the passed team member argument
  var selectedMember = Rxn<TeamMembersDetails>();

  // Performance data variables
  final RxList<PerformanceDataModel> performanceData = <PerformanceDataModel>[].obs;
  final RxString selectedPeriod = 'weekly'.obs;
  final RxString currentMonth = ''.obs;
  final List<String> periodOptions = ['daily', 'weekly', 'monthly'];
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString assignedTarget = '0'.obs;
  final RxString completedTarget = '0'.obs;
  final RxList<SurveyData> surveyList = <SurveyData>[].obs;
  final Rx<SurveyData?> selectedSurvey = Rx<SurveyData?>(null);

  @override
  void onInit() {
    super.onInit();
    selectedMember.value = Get.arguments as TeamMembersDetails?;
    currentMonth.value = DateFormat('MMMM yyyy').format(DateTime.now());
    _setInitialDates();
    fetchTeamMemberDetail(context: Get.context!, reset: true);
    fetchSurveyList();
    fetchPerformanceData();
  }

  void _setInitialDates() {
    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = now.subtract(const Duration(days: 7));
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
String formatDateTime(String dateTimeString) {
    try {
      // Parse the input string to DateTime
      DateTime dateTime = DateTime.parse(dateTimeString);

      // Define the desired format (e.g., "Sep 16, 2025 – 11:25 AM")
      final DateFormat formatter = DateFormat('MMM d, yyyy');

      // Format the DateTime object
      return formatter.format(dateTime);
    } catch (e) {
      return 'Invalid date format';
    }
  }

  Future<void> fetchTeamMemberDetail({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        teamDetail.clear();
        hasMoreData.value = true;
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      // Use the member ID from the passed argument if available
      final jsonBody = {
        "user_id": selectedMember.value!.memberId ?? "",
      };

      List<GetMyTeamMemberDetailResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getTeamMemberDetailApi,
        Networkutility.getTeamMemberDetail,
        jsonEncode(jsonBody),
        context,
      )) as List<GetMyTeamMemberDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final myTeam = response[0].data;
          teamDetail.add(
            TeamMemberDetail(
              memberId: myTeam.memberId,
              firstName: myTeam.firstName,
              lastName: myTeam.lastName,
              email: myTeam.email,
              mobileNo: myTeam.mobileNo,
              otp: myTeam.otp,
              file: myTeam.file, // image URL
              dob: myTeam.dob,
              address: myTeam.address,
              roleId: myTeam.roleId,
              joiningDate: myTeam.joiningDate,
              assignedBy: myTeam.assignedBy,
              updatedBy: myTeam.updatedBy,
              status: myTeam.status,
              flag: myTeam.flag,
              updatedFlagReason: myTeam.updatedFlagReason,
              role: myTeam.role,
            ),
          );

          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No team member found';
          log('API returned status false: No team member found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No team member found',
          );
        }
      } else {
        hasMoreData.value = false;
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
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchSurveyList() async {
    try {
      final jsonBody = {"team_id": AppUtility.teamId ?? ""};
      final response = await Networkcall().postMethod(
        Networkutility.getMySurveyApi,
        Networkutility.getMySurvey,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetMySurveyResponse>?;

      if (response != null && response.isNotEmpty && response[0].status == "true") {
        surveyList.value = response[0].data;
      }
    } catch (e) {
      AppLogger.e('Error fetching survey list: $e');
    }
  }

  Future<void> fetchPerformanceData() async {
    if (fromDate.value == null || toDate.value == null) return;

    try {
      isLoading.value = true;
      final jsonBody = {
        "user_id": selectedMember.value?.memberId ?? "",
        "from_date": DateFormat('yyyy-MM-dd').format(fromDate.value!),
        "to_date": DateFormat('yyyy-MM-dd').format(toDate.value!),
        "period": selectedPeriod.value,
      };
      if (selectedSurvey.value != null) {
        jsonBody["survey_id"] = selectedSurvey.value!.surveyId;
      }

      final response = await Networkcall().postMethod(
        Networkutility.getUserPerformanceApi,
        Networkutility.getUserPerformance,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetUserPerformanceResponse>?;

      if (response != null && response.isNotEmpty && response[0].status == "true") {
        final data = response[0].data;
        assignedTarget.value = data.assignedSurveyTarget;
        completedTarget.value = data.completedSurveyTarget;
        _generateChartData(data.periodData);
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: '${e.message} (Code: ${e.statusCode})');
    } catch (e) {
      AppLogger.e('Error fetching performance data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _generateChartData(List<PeriodData> periodData) {
    if (periodData.isEmpty) {
      performanceData.value = [];
      return;
    }

    performanceData.value = periodData.map((item) {
      return PerformanceDataModel(
        day: item.label,
        target: double.tryParse(item.assigned) ?? 0,
        targetCompleted: double.tryParse(item.completed) ?? 0,
      );
    }).toList();
  }

  void onPeriodChanged(String? value) {
    if (value != null) {
      selectedPeriod.value = value;
      fetchPerformanceData();
    }
  }

  Future<void> selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      fromDate.value = picked;
      fetchPerformanceData();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate.value ?? DateTime.now(),
      firstDate: fromDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      toDate.value = picked;
      fetchPerformanceData();
    }
  }

  void onPreviousMonth() {
    final current = DateFormat('MMMM yyyy').parse(currentMonth.value);
    final now = DateTime.now();
    final previous = DateTime(current.year, current.month - 1);
    if (previous.isAfter(DateTime(now.year, now.month))) return;
    currentMonth.value = DateFormat('MMMM yyyy').format(previous);
    final firstDay = DateTime(previous.year, previous.month, 1);
    final lastDay = DateTime(previous.year, previous.month + 1, 0);
    fromDate.value = firstDay;
    toDate.value = lastDay.isAfter(now) ? now : lastDay;
    fetchPerformanceData();
  }

  void onNextMonth() {
    final current = DateFormat('MMMM yyyy').parse(currentMonth.value);
    final now = DateTime.now();
    final next = DateTime(current.year, current.month + 1);
    if (next.isAfter(DateTime(now.year, now.month))) return;
    currentMonth.value = DateFormat('MMMM yyyy').format(next);
    final firstDay = DateTime(next.year, next.month, 1);
    final lastDay = DateTime(next.year, next.month + 1, 0);
    fromDate.value = firstDay;
    toDate.value = lastDay.isAfter(now) ? now : lastDay;
    fetchPerformanceData();
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchTeamMemberDetail(context: Get.context!, reset: true);
    await fetchPerformanceData();
  }
}