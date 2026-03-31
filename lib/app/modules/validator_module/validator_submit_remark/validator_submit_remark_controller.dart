import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../data/models/validator/final_submit_validator_response.dart';
import '../../../data/network/exceptions.dart';
import '../../../data/network/networkcall.dart';
import '../../../data/urls.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';
import '../../../utils/responsive_utils.dart';
import '../../../widgets/app_snackbar_styles.dart';
import '../../../widgets/app_style.dart';

class ValidatorSubmitRemarkController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final remarkController = TextEditingController();
  final selectedReport = 'Ok'.obs;
  final reports = ['Ok', 'Not Ok'];
  final RxBool isSubmitting = false.obs;
  final String surveyAppSideId;
  final String surveyId;

  ValidatorSubmitRemarkController({
    required this.surveyAppSideId,
    required this.surveyId,
  });

  @override
  void onClose() {
    remarkController.dispose();
    super.onClose();
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/thanks.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'THANKS',
                  style: AppStyle.buttonTextSmallPoppinsWhite.responsive,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Feedback Submitted',
                style: AppStyle.heading1PoppinsBlack.responsive,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your feedback has been submitted\nsuccessfully.',
                style: AppStyle.bodySmallPoppinsGrey.responsive,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.validatorHome);
                      },
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Dashboard',
                          style:
                              AppStyle.buttonTextSmallPoppinsBlack.responsive,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.until((route) =>
                            route.settings.name ==
                            AppRoutes.validatorStartSurveyList);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.defaultBlack,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Next Validate',
                          style:
                              AppStyle.buttonTextSmallPoppinsWhite.responsive,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitFeedback() async {
    if (formKey.currentState!.validate()) {
      try {
        isSubmitting.value = true;

        // Get current location
        final position = await _getCurrentLocation();
        if (position == null) {
          isSubmitting.value = false;
          return;
        }

        // Get address from coordinates
        final address = await _getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );

        // Call API
        final success = await _submitValidatorFeedback(
          latitude: position.latitude.toString(),
          longitude: position.longitude.toString(),
          address: address,
        );

        if (success) {
          _showSuccessDialog();
        }
      } catch (e) {
        AppLogger.e('Error submitting feedback', error: e);
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'Failed to submit feedback',
        );
      } finally {
        isSubmitting.value = false;
      }
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool? openSettings = await Get.dialog<bool>(
          AlertDialog(
            title: Text('Location Services Disabled',
                style: AppStyle.heading1PoppinsBlack.responsive),
            content: Text('Please enable location services to submit feedback.',
                style: AppStyle.bodyRegularPoppinsBlack.responsive),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel',
                    style: AppStyle.buttonTextSmallPoppinsGrey.responsive),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text('Open Settings',
                    style: AppStyle.buttonTextSmallPoppinsPrimary.responsive),
              ),
            ],
          ),
        );

        if (openSettings == true) {
          await Geolocator.openLocationSettings();
          // Re-check after user potentially enabled location
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            AppSnackbarStyles.showError(
              title: 'Location Error',
              message: 'Location services are still disabled',
            );
            return null;
          }
        } else {
          return null;
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        AppSnackbarStyles.showError(
          title: 'Permission Denied',
          message: 'Location permission is required to submit feedback',
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      AppLogger.e('Error getting location', error: e);
      AppSnackbarStyles.showError(
        title: 'Location Error',
        message: 'Failed to get current location',
      );
      return null;
    }
  }

  Future<String> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}'
            .replaceAll(RegExp(r'^,\s*|,\s*$'), '')
            .replaceAll(RegExp(r',\s*,'), ',');
      }
      return 'Unknown Location';
    } catch (e) {
      AppLogger.e('Error getting address', error: e);
      return 'Unknown Location';
    }
  }

  Future<bool> _submitValidatorFeedback({
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    try {
      final jsonBody = {
        "survey_id": surveyId,
        "validator_id": AppUtility.userID,
        "response_id": surveyAppSideId,
        "validator_remark": remarkController.text.trim(),
        "validator_status": selectedReport.value == 'Ok' ? '1' : '0',
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "user_id": AppUtility.userID,
      };

      List<FinalSubmitValidatorResponse>? response =
          (await Networkcall().postMethod(
        Networkutility.finalSubmitSurveyByValidatorApi,
        Networkutility.finalSubmitSurveyByValidator,
        jsonEncode(jsonBody),
        Get.context!,
      )) as List<FinalSubmitValidatorResponse>?;

      if (response != null && response.isNotEmpty) {
        if (response[0].status == "true") {
          AppLogger.i(
            'Validator feedback submitted successfully',
            tag: 'ValidatorSubmitRemarkController',
          );
          return true;
        } else {
          AppSnackbarStyles.showError(
            title: 'Error',
            message: response[0].message ?? 'Failed to submit feedback',
          );
          return false;
        }
      } else {
        AppSnackbarStyles.showError(
          title: 'Error',
          message: 'No response from server',
        );
        return false;
      }
    } on NoInternetException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
      return false;
    } on TimeoutException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
      return false;
    } on HttpException catch (e) {
      AppSnackbarStyles.showError(
        title: 'Error',
        message: '${e.message} (Code: ${e.statusCode})',
      );
      return false;
    } on ParseException catch (e) {
      AppSnackbarStyles.showError(title: 'Error', message: e.message);
      return false;
    } catch (e) {
      AppLogger.e('Unexpected error', error: e);
      AppSnackbarStyles.showError(
        title: 'Error',
        message: 'Unexpected error: $e',
      );
      return false;
    }
  }
}
