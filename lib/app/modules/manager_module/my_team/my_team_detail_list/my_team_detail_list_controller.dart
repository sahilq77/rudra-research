import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/network/exceptions.dart'
    show NoInternetException, HttpException, ParseException;
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_utility.dart' show AppUtility;
import 'package:rudra/app/widgets/app_snackbar_styles.dart';
import 'dart:async';
import '../../../../data/models/my_team/get_my_team_member_response.dart';

class MyTeamDetailListController extends GetxController {
  var isLoading = true.obs;
  var teamMemberList = <TeamMembersDetail>[].obs;
  var filteredTeamMemberList = <TeamMembersDetail>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;

  var searchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Retrieve team_id from navigation arguments
    final team = Get.arguments?['team'];
    final String teamId = team?.teamId?.toString() ?? '0'; // Fallback to '0' if not found
    // Initial data fetch with dynamic team_id
    fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
    // Setup pagination listener
    scrollController.addListener(_scrollListener);
    // Setup search listener
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // Handle scroll for pagination
  void _scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore.value &&
        hasMoreData.value) {
      final team = Get.arguments?['team'];
      final String teamId = team?.teamId?.toString() ?? '0';
      fetchMyTeamMember(context: Get.context!, teamId: teamId, isPagination: true);
    }
  }

  // Debounced search
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = searchController.text.trim();
      filterTeamMembers();
      // Optionally fetch new data with search query
      final team = Get.arguments?['team'];
      final String teamId = team?.teamId?.toString() ?? '0';
      fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
    });
  }

  // Filter team members based on search query
  void filterTeamMembers() {
    if (searchQuery.value.isEmpty) {
      filteredTeamMemberList.assignAll(teamMemberList);
    } else {
      filteredTeamMemberList.assignAll(teamMemberList.where((member) {
        final fullName =
            '${member.memberFirstName} ${member.memberLastName}'.toLowerCase();
        return fullName.contains(searchQuery.value.toLowerCase()) ||
            member.memberMobileNo
                .toLowerCase()
                .contains(searchQuery.value.toLowerCase()) ||
            member.role.toLowerCase().contains(searchQuery.value.toLowerCase());
      }).toList());
    }
  }

  // Fetch team members
  Future<void> fetchMyTeamMember({
    required BuildContext context,
    required String teamId,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        teamMemberList.clear();
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

      final jsonBody = {
        "team_id": teamId,
        "search_member": searchQuery.value,
        "offset": offset.value,
        "limit": limit,
      };

      List<GetMyTeamMemberResponse>? response =
          (await Networkcall().postMethod(
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
              TeamMembersDetail(
                memberId: team.memberId,
                memberFirstName: team.memberFirstName,
                memberLastName: team.memberLastName,
                memberMobileNo: team.memberMobileNo,
                role: team.role,
              ),
            );
          }
          offset.value += limit;
          filterTeamMembers(); // Update filtered list after fetching
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No team members found';
          log('API returned status false: No team members found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No team members found',
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
      errorMessage.value = e.message.toString();
      log('TimeoutException: ${e.message}');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: e.message.toString(),
      );
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
    final team = Get.arguments?['team'];
    final String teamId = team?.teamId?.toString() ?? '0';
    await fetchMyTeamMember(context: Get.context!, teamId: teamId, reset: true);
  }
}