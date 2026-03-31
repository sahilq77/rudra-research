import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/network/exceptions.dart'
    show NoInternetException, HttpException, ParseException;
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/my_team/get_my_team_member_response.dart';
import '../../../../utils/app_utility.dart';

class MyTeamDetailListController extends GetxController {
  var isLoading = true.obs;
  var isSearching = false.obs;
  var teamMemberList = <TeamMembersDetails>[].obs;
  var filteredTeamMemberList = <TeamMembersDetails>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasPaginated = false.obs;

  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    final team = Get.arguments?['team'];
    final String teamId = team?.teamId?.toString() ?? '0';
    fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  void searchMembers(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final team = Get.arguments?['team'];
      final String teamId = team?.teamId?.toString() ?? '0';
      fetchMyTeamMember(
          context: Get.context!, teamId: teamId, reset: true, isSearch: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    final team = Get.arguments?['team'];
    final String teamId = team?.teamId?.toString() ?? '0';
    fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
  }

  // Fetch team members
  Future<void> fetchMyTeamMember({
    required BuildContext context,
    required String teamId,
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        teamMemberList.clear();
        hasMoreData.value = true;
        hasPaginated.value = false;
      }
      if (!hasMoreData.value && !reset) {
        log('No more data to fetch');
        return;
      }

      if (isPagination) {
        isLoadingMore.value = true;
        hasPaginated.value = true;
      } else if (isSearch) {
        isSearching.value = true;
      } else {
        isLoading.value = true;
      }
      errorMessage.value = '';

      final jsonBody = {
        "team_id": teamId,
        "search_member": searchQuery.value,
        "offset": offset.value,
        "limit": limit,
        "user_id": AppUtility.userID,
      };

      List<GetMyTeamMemberResponse>? response = (await Networkcall().postMethod(
        Networkutility.getTeamMemberListApi,
        Networkutility.getTeamMemberList,
        jsonEncode(jsonBody),
        context,
      )) as List<GetMyTeamMemberResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final myTeam = response[0].data.teamMembersDetails;

          if (myTeam.isEmpty || myTeam.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${myTeam.length}');
          }
          for (var team in myTeam) {
            teamMemberList.add(
              TeamMembersDetails(
                memberId: team.memberId,
                memberFirstName: team.memberFirstName,
                memberLastName: team.memberLastName,
                memberMobileNo: team.memberMobileNo,
                role: team.role,
                file: team.file,
              ),
            );
          }
          offset.value += limit;
          filteredTeamMemberList.assignAll(teamMemberList);
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No team members found';
          teamMemberList.clear();
          filteredTeamMemberList.clear();
          log('API returned status false: No team members found');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        teamMemberList.clear();
        filteredTeamMemberList.clear();
        log('No response from server');
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      teamMemberList.clear();
      filteredTeamMemberList.clear();
      log('NoInternetException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message.toString();
      teamMemberList.clear();
      filteredTeamMemberList.clear();
      log('TimeoutException: ${e.message}');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: e.message.toString(),
      );
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      teamMemberList.clear();
      filteredTeamMemberList.clear();
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      teamMemberList.clear();
      filteredTeamMemberList.clear();
      log('ParseException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      teamMemberList.clear();
      filteredTeamMemberList.clear();
      log('Unexpected error: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isSearching.value = false;
    }
  }

  // Refresh data for pull-to-refresh
  Future<void> refreshData() async {
    final team = Get.arguments?['team'];
    final String teamId = team?.teamId?.toString() ?? '0';
    await fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final phone = phoneNumber.trim();
      if (phone.isEmpty) {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Phone number not available',
        );
        return;
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
      log('Making call to: $phone');
    } catch (e) {
      log('Error making call: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to make call',
      );
    }
  }
}
