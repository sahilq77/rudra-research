import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/interviewer_info/get_cast_response.dart';
import '../../../../data/models/my_report/get_assembly_response.dart';
import '../../../../data/models/my_report/get_executive_response.dart';
import '../../../../data/models/my_report/get_survey_report_response.dart';
import '../../../../data/models/my_report/get_ward_response.dart';
import '../../../../data/models/survey_detail/get_area_response.dart';
import '../../../../data/network/exceptions.dart';
import '../../../../data/network/networkcall.dart';
import '../../../../data/urls.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_logger.dart';
import '../../../../utils/app_utility.dart';
import '../../../../widgets/app_snackbar_styles.dart';

class MyReportFormViewController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String surveyId = '';
  final RxBool isLoading = false.obs;

  // Multi-select lists
  final RxList<String> selectedCastIds = <String>[].obs;
  final RxList<String> selectedExecutiveIds = <String>[].obs;
  final RxList<String> selectedAssemblyIds = <String>[].obs;
  final RxList<String> selectedWardIds = <String>[].obs;
  final RxList<String> selectedAreaIds = <String>[].obs;

  // Dropdown options
  final RxList<CastData> castList = <CastData>[].obs;
  final RxList<ExecutiveData> executiveList = <ExecutiveData>[].obs;
  final RxList<AssemblyData> assemblyList = <AssemblyData>[].obs;
  final RxList<WardData> wardList = <WardData>[].obs;
  final RxList<AreaData> areaList = <AreaData>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    surveyId = args['survey_id']?.toString() ?? '';
    if (surveyId.isNotEmpty) {
      fetchAllDropdownOptions();
    }
  }

  Future<void> fetchAllDropdownOptions() async {
    isLoading.value = true;
    await Future.wait([
      fetchCastOptions(),
      fetchExecutiveOptions(),
      fetchAssemblyOptions(),
      fetchWardOptions(),
      fetchAreaOptions(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchCastOptions() async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID,
      };
      final response = await Networkcall().postMethod(
        Networkutility.getCastApi,
        Networkutility.getCast,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GeCastResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          castList.value = response[0].data;
          AppLogger.i('Cast options loaded: ${castList.length}');
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error fetching cast options: $e');
    }
  }

  Future<void> fetchExecutiveOptions() async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID,
      };
      final response = await Networkcall().postMethod(
        Networkutility.getExecutiveAccToSurveyIdApi,
        Networkutility.getExecutiveAccToSurveyId,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetExecutiveResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          executiveList.value = response[0].data;
          AppLogger.i('Executive options loaded: ${executiveList.length}');
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error fetching executive options: $e');
    }
  }

  Future<void> fetchAssemblyOptions() async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID,
      };
      final response = await Networkcall().postMethod(
        Networkutility.getAssemblyAccToSurveyIdApi,
        Networkutility.getAssemblyAccToSurveyId,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetAssemblyResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          assemblyList.value = [response[0].data];
          AppLogger.i('Assembly options loaded: ${assemblyList.length}');
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error fetching assembly options: $e');
    }
  }

  Future<void> fetchWardOptions() async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID,
      };
      final response = await Networkcall().postMethod(
        Networkutility.getWardAccToSurveyIdApi,
        Networkutility.getWardAccToSurveyId,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetWardResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          wardList.value = [response[0].data];
          AppLogger.i('Ward options loaded: ${wardList.length}');
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error fetching ward options: $e');
    }
  }

  Future<void> fetchAreaOptions() async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "user_id": AppUtility.userID,
      };
      final response = await Networkcall().postMethod(
        Networkutility.getAreaApi,
        Networkutility.getArea,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetAreaResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          areaList.value = response[0].data;
          AppLogger.i('Area options loaded: ${areaList.length}');
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error fetching area options: $e');
    }
  }

  String? validateAtLeastOne() {
    if (selectedCastIds.isEmpty &&
        selectedExecutiveIds.isEmpty &&
        selectedAssemblyIds.isEmpty &&
        selectedWardIds.isEmpty &&
        selectedAreaIds.isEmpty) {
      return 'Please select at least one filter option';
    }
    return null;
  }

  void resetForm() {
    selectedCastIds.clear();
    selectedExecutiveIds.clear();
    selectedAssemblyIds.clear();
    selectedWardIds.clear();
    selectedAreaIds.clear();
  }

  Future<void> refreshData() async {
    resetForm();
    await fetchAllDropdownOptions();
  }

  Future<void> submitReport() async {
    // if (formKey.currentState?.validate() != true) return;

    isLoading.value = true;
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "executive_id": selectedExecutiveIds,
        "cast_id": selectedCastIds,
        "assembly_id": selectedAssemblyIds,
        "zp_ward_id": selectedWardIds,
        "village_area_id": selectedAreaIds,
        "user_id": AppUtility.userID,
      };

      final response = await Networkcall().postMethod(
        Networkutility.getSurveyReportApi,
        Networkutility.getSurveyReport,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetSurveyReportResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          AppLogger.i('Report fetched successfully');
          Get.toNamed(AppRoutes.myreportChart,
              arguments: {'data': response[0].data});
        } else {
          AppSnackbarStyles.showError(
            title: 'Error',
            message: response[0].message,
          );
        }
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } catch (e) {
      AppLogger.e('Error submitting report: $e');
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to fetch report',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
