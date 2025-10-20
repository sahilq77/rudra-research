import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_detail.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_response.dart' show TeamMembersDetails;
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
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

  @override
  void onInit() {
    super.onInit();
    // Retrieve the passed argument
    selectedMember.value = Get.arguments as TeamMembersDetails?;
    // Fetch initial data
    fetchTeamMemberDetail(context: Get.context!, reset: true);
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

  // Refresh data for pull-to-refresh
  Future<void> refreshData() async {
    await fetchTeamMemberDetail(context: Get.context!, reset: true);
  }
}