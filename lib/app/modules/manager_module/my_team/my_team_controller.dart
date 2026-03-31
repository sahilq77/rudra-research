import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart' show Networkcall;
import 'package:rudra/app/data/urls.dart' show Networkutility;
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

class MyTeamController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var isSearching = false.obs;
  var teamList = <TeamData>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounce;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;
  RxBool hasPaginated = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyTeam(context: Get.context!, reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchMyTeam({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool isSearch = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        teamList.clear();
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
        "user_id": AppUtility.userID,
        "role_id": AppUtility.roleId,
        "limit": limit.toString(),
        "offset": offset.value.toString(),
        "search": searchQuery.value,
      };

      List<GetMyTeamResponse>? response = (await Networkcall().postMethod(
        Networkutility.getTeamListApi,
        Networkutility.getTeamList,
        jsonEncode(jsonBody),
        context,
      )) as List<GetMyTeamResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final myTeam = response[0].data;

          if (myTeam.isEmpty || myTeam.length < limit) {
            hasMoreData.value = false;
            log('No more data or fewer items received: ${myTeam.length}');
          }
          for (var team in myTeam) {
            teamList.add(
              TeamData(
                teamId: team.teamId,
                teamName: team.teamName,
                teamManagerId: team.teamManagerId,
                teamMembersId: team.teamMembersId,
                managerDetails: team.managerDetails,
                teamMembersCount: team.teamMembersCount,
              ),
            );
          }
          offset.value += limit;
          log('Offset updated to: ${offset.value}');
        } else {
          hasMoreData.value = false;
          errorMessage.value = 'No myTeam found';
          teamList.clear();
          log('API returned status false: No myTeam found');
        }
      } else {
        hasMoreData.value = false;
        errorMessage.value = 'No response from server';
        teamList.clear();
        log('No response from server');
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      teamList.clear();
      log('NoInternetException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      teamList.clear();
      log('TimeoutException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      teamList.clear();
      log('HttpException: ${e.message} (Code: ${e.statusCode})');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      teamList.clear();
      log('ParseException: ${e.message}');
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      teamList.clear();
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
    await fetchMyTeam(context: Get.context!, reset: true);
  }

  void searchTeams(String query) {
    searchQuery.value = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchMyTeam(context: Get.context!, reset: true, isSearch: true);
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
    fetchMyTeam(context: Get.context!, reset: true);
  }
}
