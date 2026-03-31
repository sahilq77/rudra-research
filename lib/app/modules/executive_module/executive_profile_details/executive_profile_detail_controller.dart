import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_detail.dart';
import 'package:rudra/app/data/models/profile_details/get_my_survey_response.dart';
import 'package:rudra/app/data/models/profile_details/get_user_performance_response.dart';
import 'package:rudra/app/data/models/profile_details/performance_data_model.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart' show Networkcall;
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_logger.dart';
import 'package:rudra/app/utils/app_utility.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../data/models/profile/upload_user_image_response.dart';
import '../../../data/models/profile_details/profile_details_model.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

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
  final RxBool isPerformanceLoading = false.obs;
  final RxList<PerformanceDataModel> performanceData =
      <PerformanceDataModel>[].obs;
  final RxString selectedPeriod = 'weekly'.obs;
  final RxString currentMonth = ''.obs;
  final List<String> periodOptions = ['daily', 'weekly', 'monthly'];
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxString assignedTarget = '0'.obs;
  final RxString completedTarget = '0'.obs;
  final RxList<SurveyData> surveyList = <SurveyData>[].obs;
  final Rx<SurveyData?> selectedSurvey = Rx<SurveyData?>(null);

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
    currentMonth.value = DateFormat('MMMM yyyy').format(DateTime.now());
    _setInitialDates();
    fetchProfileDetails(context: Get.context!, reset: true);
    fetchSurveyList();
    fetchPerformanceData();
  }

  void _setInitialDates() {
    final now = DateTime.now();
    toDate.value = now;
    fromDate.value = now.subtract(const Duration(days: 7));
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
      )) as List<GetMyTeamMemberDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        // Assuming response is a List<ProfileDetailsResponse> similar to TeamMemberDetail
        if (response[0].status == "true") {
          final data =
              response[0].data; // Adjust based on your API response structure
          profileDetails.value = ProfileDetailsModel(
            image: data.file ?? "",
            name: '${data.firstName ?? ""} ${data.lastName ?? ""}'.trim(),
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

  Future<void> fetchSurveyList() async {
    try {
      final jsonBody = {
        "team_id": AppUtility.teamId ?? "",
        "user_id": AppUtility.userID ?? "",
      };
      final response = await Networkcall().postMethod(
        Networkutility.getMySurveyApi,
        Networkutility.getMySurvey,
        jsonEncode(jsonBody),
        Get.context!,
      ) as List<GetMySurveyResponse>?;

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
        surveyList.value = response[0].data;
      }
    } catch (e) {
      AppLogger.e('Error fetching survey list: $e');
    }
  }

  Future<void> fetchPerformanceData() async {
    if (fromDate.value == null || toDate.value == null) return;

    try {
      isPerformanceLoading.value = true;
      final jsonBody = {
        "user_id": AppUtility.userID,
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

      if (response != null &&
          response.isNotEmpty &&
          response[0].status == "true") {
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
      AppSnackbarStyles.showError(
          title: 'Error', message: '${e.message} (Code: ${e.statusCode})');
    } catch (e) {
      AppLogger.e('Error fetching performance data: $e');
    } finally {
      isPerformanceLoading.value = false;
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

  void onEditProfile() {
    AppLogger.d('onEditProfile called',
        tag: 'ExecutiveProfileDetailController');
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );

      if (pickedFile != null) {
        _showUploadConfirmation(File(pickedFile.path));
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to pick image',
        error: e,
        stackTrace: stackTrace,
        tag: 'ExecutiveProfileDetailController',
      );
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to pick image. Please try again.',
      );
    }
  }

  void _showUploadConfirmation(File imageFile) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload Image',
                    style: AppStyle.heading1PoppinsBlack.responsive,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Do you want to upload this image as your profile picture?',
                    style: AppStyle.bodySmallPoppinsGrey.responsive,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.defaultBlack,
                            side: const BorderSide(
                              color: AppColors.defaultBlack,
                              width: 1.5,
                            ),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style:
                                AppStyle.buttonTextSmallPoppinsBlack.responsive,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back();
                            _uploadImage(imageFile);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Upload',
                            style:
                                AppStyle.buttonTextSmallPoppinsWhite.responsive,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      isLoading.value = true;
      AppLogger.d('Uploading image...',
          tag: 'ExecutiveProfileDetailController');

      final formData = {
        'user_id': AppUtility.userID ?? '',
      };

      final fileMap = {
        'user_image': imageFile,
      };

      final response = await Networkcall().postFormDataMethod(
        Networkutility.uploadUserImageApi,
        Networkutility.uploadUserImage,
        formData,
        fileMap,
        Get.context!,
      );

      if (response != null && response.isNotEmpty) {
        final uploadResponse = response[0] as UploadUserImageResponse;

        if (uploadResponse.status == 'true' && uploadResponse.data != null) {
          final imageUrl = uploadResponse.data!.file ?? '';
          await AppUtility.updateUserImage(imageUrl);
          if (profileDetails.value != null) {
            profileDetails.value =
                profileDetails.value!.copyWith(image: imageUrl);
          }

          AppSnackbarStyles.showSuccess(
            title: 'Success',
            message: uploadResponse.message ?? 'Image uploaded successfully',
          );

          AppLogger.i('Image uploaded successfully',
              tag: 'ExecutiveProfileDetailController');
        } else {
          AppSnackbarStyles.showError(
            title: 'Failed',
            message: uploadResponse.message ?? 'Failed to upload image',
          );
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Failed to upload image. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'Image upload failed',
        error: e,
        stackTrace: stackTrace,
        tag: 'ExecutiveProfileDetailController',
      );
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Failed to upload image. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await fetchProfileDetails(context: Get.context!, reset: true);
    await fetchPerformanceData();
  }
}
