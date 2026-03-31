import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/otp/get_otp_response.dart';
import 'package:rudra/app/data/models/otp/validate_otp_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';
import '../../../utils/app_utility.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late String phone;
  late String deviceId;
  late String userId;
  late String maskedPhone;
  final RxBool isLoading = false.obs;

  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    phone = args['phone'] ?? '';
    deviceId = args['deviceId'] ?? '';
    userId = args['user_id'] ?? '';
    if (phone.length >= 6) {
      maskedPhone = '${phone.substring(0, 3)}-${phone.substring(3, 6)}-XXXX';
    } else {
      maskedPhone = phone;
    }
    getOtp();
  }

  void startTimer() {
    countdown.value = 60;
    canResend.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  Future<void> getOtp() async {
    try {
      final jsonBody = {
        "mobile_no": phone,
        "device_id": deviceId,
        "user_id": userId,
      };

      AppLogger.i('Get OTP request body: $jsonBody');

      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.getOtpApi,
        Networkutility.getOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetOtpResponse> response = List.from(list);

        if (response[0].status == "true") {
          AppLogger.d('OTP sent: ${response[0].data.otp}');
          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.lightGreen,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            padding: EdgeInsets.zero,
            borderRadius: 8,
            isDismissible: true,
            titleText: const SizedBox.shrink(),
            messageText: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.darkGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Success : ${response[0].message}',
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          startTimer();
        } else {
          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.lightRed,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            padding: EdgeInsets.zero,
            borderRadius: 8,
            isDismissible: true,
            titleText: const SizedBox.shrink(),
            messageText: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed : ${response[0].message}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.e('Error getting OTP', error: e);
    }
  }

  Future<void> verify() async {
    String otp = otpController.text;
    if (otp.length != 6) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightRed,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        isDismissible: true,
        titleText: const SizedBox.shrink(),
        messageText: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error : Please enter a valid 6-digit OTP',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    try {
      final jsonBody = {
        "otp": otp,
        "mobile_no": phone,
        "user_id": userId,
      };

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.validateOtpApi,
        Networkutility.validateOtp,
        jsonEncode(jsonBody),
        Get.context!,
      );
      AppLogger.i(
          'URL : ${Networkutility.validateOtpApi} \nRequest Body: $jsonBody \nResponse: $list');
      if (list != null && list.isNotEmpty) {
        List<ValidateOtpResponse> response = List.from(list);

        if (response[0].status == "true") {
          final user = response[0].data;

          await AppUtility.setUserInfo(
            "${user.firstName} ${user.lastName}",
            user.mobileNo,
            user.email,
            user.userId,
            user.roleId,
            user.teamId.isEmpty ? "" : user.teamId,
            int.parse(user.roleValue),
            user.image,
            deviceId,
          );

          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.lightGreen,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            padding: EdgeInsets.zero,
            borderRadius: 8,
            isDismissible: true,
            titleText: const SizedBox.shrink(),
            messageText: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.darkGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Success : ${response[0].message}',
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

          final userRole = int.parse(user.roleValue);
          if (userRole == 0) {
            Get.offAllNamed(AppRoutes.home, arguments: {'userRole': userRole});
          } else if (userRole == 1) {
            Get.offAllNamed(AppRoutes.executiveHome,
                arguments: {'userRole': userRole});
          } else if (userRole == 2) {
            Get.offAllNamed(AppRoutes.validatorHome,
                arguments: {'userRole': userRole});
          } else if (userRole == 3) {
            Get.offAllNamed(AppRoutes.superAdminHome,
                arguments: {'userRole': userRole});
          }
        } else {
          Get.snackbar(
            '',
            '',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.lightRed,
            margin:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
            padding: EdgeInsets.zero,
            borderRadius: 8,
            isDismissible: true,
            titleText: const SizedBox.shrink(),
            messageText: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Failed : ${response[0].message}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } on NoInternetException catch (e) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightRed,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        isDismissible: true,
        titleText: const SizedBox.shrink(),
        messageText: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error : ${e.message}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } on TimeoutException catch (e) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightRed,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        isDismissible: true,
        titleText: const SizedBox.shrink(),
        messageText: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error : ${e.message}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } on HttpException catch (e) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightRed,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        isDismissible: true,
        titleText: const SizedBox.shrink(),
        messageText: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error : ${e.message} (Code: ${e.statusCode})',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      Get.snackbar(
        '',
        '',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.lightRed,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        padding: EdgeInsets.zero,
        borderRadius: 8,
        isDismissible: true,
        titleText: const SizedBox.shrink(),
        messageText: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error : Unexpected error: $e',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resend() {
    if (!canResend.value) return;
    otpController.clear();
    getOtp();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
