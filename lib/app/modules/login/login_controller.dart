// lib/app/modules/login/login_controller.dart
import 'dart:convert';
import 'dart:io';

import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/login/get_login_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/app_logger.dart';

import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxInt selectedRole = 0.obs;
  final List<String> userTypes = [
    'Super Admin',
    'Manager',
    'Executive',
    'Validator'
  ];
  final List<int> roleIds = [
    1,
    3,
    4,
    5
  ]; // SuperAdmin=1, Manager=3, Executive=4, Validator=5
  final formKey = GlobalKey<FormState>();
  late FocusNode phoneFocusNode;
  final GlobalKey phoneFieldKey = GlobalKey();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode = FocusNode();
    phoneFocusNode.addListener(_onPhoneFocusChange);
    _initializeDeviceInfo();
  }

  Future<void> _initializeDeviceInfo() async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      AppLogger.i('FCM Token: $fcmToken');

      final deviceInfo = DeviceInfoPlugin();
      String deviceId = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
      }

      AppLogger.i('Device ID: $deviceId');
    } catch (e) {
      AppLogger.e('Error initializing device info', error: e);
    }
  }

  void _onPhoneFocusChange() {
    if (phoneFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = phoneFieldKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> login({
    BuildContext? context,
    required String? mobile,
    required String? password,
    required String? deviceToken,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      String fcmToken = '';
      try {
        fcmToken = await FirebaseMessaging.instance.getToken() ?? '';
      } catch (e) {
        AppLogger.e('Error getting FCM token', error: e);
      }

      String deviceId = '';
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        }
      } catch (e) {
        AppLogger.e('Error getting device ID', error: e);
      }

      // Use controller values directly since they are validated by the form
      final jsonBody = {
        "mobile_no": phoneController.text.trim(),
        "device_token": fcmToken,
        "device_id": deviceId,
        "role_id": roleIds[selectedRole.value].toString(),
      };

      AppLogger.i('Login request body: $jsonBody');

      isLoading.value = true;
      List<Object?>? list = await Networkcall().postMethod(
        Networkutility.loginApi,
        Networkutility.login,
        jsonEncode(jsonBody),
        Get.context!,
      );

      if (list != null && list.isNotEmpty) {
        List<GetLoginResponse> response = List.from(list);

        if (response[0].status == "true") {
          AppLogger.d(response[0].data.role);
          final user = response[0].data;

          Clarity.setCustomUserId(user.userId);
          Clarity.setCustomTag('role', userTypes[selectedRole.value]);
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
            messageText: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.darkGreen,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Success : Sign in successfully!',
                      style: TextStyle(
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

          Get.toNamed(
            AppRoutes.otp,
            arguments: {
              'phone': user.mobileNo,
              'deviceId': deviceId,
              'user_id': user.userId,
            },
          );
        } else if (response[0].status == "false") {
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
                    'Error : No response from server',
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
      }
    } on NoInternetException catch (e) {
      Get.back();
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
      Get.back();
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
      Get.back();
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
    } on ParseException catch (e) {
      Get.back();
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
    } catch (e) {
      Get.back();
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
}
