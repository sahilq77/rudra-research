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

import '../../../data/models/my_team/my_team_model.dart';
import '../../../utils/app_logger.dart';

class MyTeamController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var teamList = <TeamData>[].obs;
  var errorMessage = ''.obs;
  RxInt offset = 0.obs;
  final int limit = 10;
  RxBool hasMoreData = true.obs;
  RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch initial data
    fetchMyTeam(context: Get.context!, reset: true);
  }

  Future<void> fetchMyTeam({
    required BuildContext context,
    bool reset = false,
    bool isPagination = false,
    bool forceFetch = false,
  }) async {
    try {
      if (reset) {
        offset.value = 0;
        teamList.clear();
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
        "user_id": AppUtility.userID,
        "role_id": AppUtility.roleId,
      };

      List<GetMyTeamResponse>? response =
          (await Networkcall().postMethod(
                Networkutility.getTeamListApi,
                Networkutility.getTeamList,
                jsonEncode(jsonBody),
                context,
              ))
              as List<GetMyTeamResponse>?;

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
          log('API returned status false: No myTeam found');
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No myTeam found',
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
    await fetchMyTeam(context: Get.context!, reset: true);
  }
}
