import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../data/models/my_team/get_my_team_member_detail.dart';
import '../../../data/models/profile/upload_user_image_response.dart';
import '../../../data/models/profile_details/profile_details_model.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

class SuperAdminProfileDetailsController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<ProfileDetailsModel?> profileDetails =
      Rx<ProfileDetailsModel?>(null);
  var errorMessage = ''.obs;

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
    fetchProfileDetails();
  }

  Future<void> fetchProfileDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final jsonBody = {"user_id": AppUtility.userID};
      List<GetMyTeamMemberDetailResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.getUserApi,
        Networkutility.getUser,
        jsonEncode(jsonBody),
        Get.context!,
      )) as List<GetMyTeamMemberDetailResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          final data = response[0].data;
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
        } else {
          errorMessage.value = 'No profile data found';
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'No profile data found',
          );
        }
      } else {
        errorMessage.value = 'No response from server';
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
      }
    } on NoInternetException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on TimeoutException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } on HttpException catch (e) {
      errorMessage.value = '${e.message} (Code: ${e.statusCode})';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
    } on ParseException catch (e) {
      errorMessage.value = e.message;
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
    } catch (e) {
      errorMessage.value = 'Unexpected error: $e';
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onEditProfile() {
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
        tag: 'SuperAdminProfileDetailsController',
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
          tag: 'SuperAdminProfileDetailsController');

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
              tag: 'SuperAdminProfileDetailsController');
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
        tag: 'SuperAdminProfileDetailsController',
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
    await fetchProfileDetails();
  }
}
