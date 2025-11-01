import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_detail.dart';
import 'package:rudra/app/data/models/profile_details/performance_data_model.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart' show Networkcall;
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/app_utility.dart';
import '../../../data/models/profile_details/profile_details_model.dart';
import '../../../widgets/app_snackbar_styles.dart';

class ExecutiveProfileDetailController extends GetxController {
  // Observable variables for profile details
  final RxBool isLoading = true.obs;
  final Rx<ProfileDetailsModel?> profileDetails = Rx<ProfileDetailsModel?>(
    null,
  );
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;

  // Observable variables for performance data
  final RxList<PerformanceDataModel> performanceData =
      <PerformanceDataModel>[].obs;
  final RxString selectedPeriod = 'Weekly'.obs;
  final RxString currentMonth = ''.obs;
  final List<String> periodOptions = ['Daily', 'Weekly', 'Monthly'];

  String get userName => profileDetails.value?.name ?? 'User';

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

  @override
  void onInit() {
    super.onInit();
    // Set initial month
    currentMonth.value = DateFormat('MMMM yyyy').format(DateTime.now());
    // Fetch initial data
    fetchProfileDetails(context: Get.context!, reset: true);
    _loadPerformanceData();
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

  Future<void> fetchProfileDetails({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        profileDetails.value = null;
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

      // Replace with your actual API endpoint and request body
      final jsonBody = {
        "user_id": AppUtility.userID, // Replace with actual user ID logic
      };
      List<GetMyTeamMemberDetailResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getUserApi, // Define this in your URLs file
                Networkutility.getUser,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetMyTeamMemberDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        // Assuming response is a List<ProfileDetailsResponse> similar to TeamMemberDetail
        if (response[0].status == "true") {
          final data =
              response[0].data; // Adjust based on your API response structure
          profileDetails.value = ProfileDetailsModel(
            image: data.file ?? "",
            name: '${data.firstName ?? ""} ${data.lastName ?? ""}',
            phoneNumber: data.mobileNo ?? 'N/A',
            emailId: data.email ?? 'N/A',
            address: data.address ?? 'N/A',
            designation: data.role ?? 'N/A',
            joiningDate: data.joiningDate?.toString() ?? 'N/A',
            dob: data.dob?.toString() ?? 'N/A',
          );

          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No profile data found';
          log('API returned status false: No profile data found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No profile data found',
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

  void _loadPerformanceData() {
    try {
      // Mock data - Replace with actual API call
      performanceData.value = [
        PerformanceDataModel(day: 'Mon', target: 85, targetCompleted: 78),
        PerformanceDataModel(day: 'Tue', target: 90, targetCompleted: 85),
        PerformanceDataModel(day: 'Wed', target: 88, targetCompleted: 84),
        PerformanceDataModel(day: 'Thu', target: 92, targetCompleted: 88),
        PerformanceDataModel(day: 'Fri', target: 87, targetCompleted: 90),
        PerformanceDataModel(day: 'Sat', target: 85, targetCompleted: 85),
        PerformanceDataModel(day: 'Sun', target: 90, targetCompleted: 86),
      ];

      AppLogger.d(
        'Performance data loaded successfully',
        tag: 'ProfileDetailsController',
      );
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load performance data',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProfileDetailsController',
      );
    }
  }

  void onPeriodChanged(String? value) {
    if (value != null) {
      selectedPeriod.value = value;
      AppLogger.d('Period changed to: $value', tag: 'ProfileDetailsController');
      _loadPerformanceData();
    }
  }

  void onPreviousMonth() {
    final current = DateFormat('MMMM yyyy').parse(currentMonth.value);
    final previous = DateTime(current.year, current.month - 1);
    currentMonth.value = DateFormat('MMMM yyyy').format(previous);
    AppLogger.d(
      'Previous month: ${currentMonth.value}',
      tag: 'ProfileDetailsController',
    );
    _loadPerformanceData();
  }

  void onNextMonth() {
    final current = DateFormat('MMMM yyyy').parse(currentMonth.value);
    final next = DateTime(current.year, current.month + 1);
    currentMonth.value = DateFormat('MMMM yyyy').format(next);
    AppLogger.d(
      'Next month: ${currentMonth.value}',
      tag: 'ProfileDetailsController',
    );
    _loadPerformanceData();
  }

  void onEditProfile() {
    AppLogger.d('Edit profile tapped', tag: 'ProfileDetailsController');
    Get.snackbar(
      'Coming Soon',
      'Edit profile feature will be available soon',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> onRefresh() async {
    await fetchProfileDetails(context: Get.context!, reset: true);
    _loadPerformanceData();
    AppLogger.d(
      'Profile details page refreshed',
      tag: 'ProfileDetailsController',
    );
  }
}
