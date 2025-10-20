// lib/app/modules/login/login_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/data/models/login/get_login_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/data/network/networkcall.dart';
import 'package:rudra/app/data/urls.dart';
import 'package:rudra/app/utils/app_colors.dart';
import 'package:rudra/app/utils/app_utility.dart' show AppUtility;

import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxInt selectedRole = 0.obs;
  final List<String> userTypes = ['Manager', 'Executor', 'Validator'];
  final formKey = GlobalKey<FormState>();
  late FocusNode phoneFocusNode;
  final GlobalKey phoneFieldKey = GlobalKey();
  RxBool isLoading = false.obs; // Changed initial value to false

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode = FocusNode();
    phoneFocusNode.addListener(_onPhoneFocusChange);
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
    try {
      // Use controller values directly since they are validated by the form
      final jsonBody = {
        "mobile_no": phoneController.text.trim(),

        "device_token": deviceToken.toString(),
      };

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
          log(response[0].data!.role);
          final user = response[0].data;

          // Save credentials if "Remember Me" is checked

          AppUtility.setUserInfo(
            user.firstName + user.lastName,
            user.mobileNo,
            user.email,
            user.userId,
            user.roleId,
            int.parse(user.roleValue),
          );
          if (user.roleValue == "0") {
            // Manager
            Get.offAllNamed(
              AppRoutes.home,
              arguments: {'userRole': int.parse(user.roleValue)},
            );
            // Additional setup for manager if needed
          } else if (user.roleValue == "1") {
            // Executive
            Get.offAllNamed(
              AppRoutes.executiveHome,
              arguments: {'userRole': int.parse(user.roleValue)},
            );
            // Additional setup for executive if needed
          } else {
            Get.offAllNamed(
              AppRoutes.validatorHome,
              arguments: {'userRole': int.parse(user.roleValue)},
            );
          }

          Get.snackbar(
            'Success',
            'Sign in successfully!',
            backgroundColor: AppColors.greenColor,
            colorText: Colors.white,
          );
          Get.offNamed(AppRoutes.home);
        } else if (response[0].status == "false") {
          Get.snackbar(
            'Failed',
            "Your username or password is incorrect.\nPlease try again.",
            backgroundColor: AppColors.redColor,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'No response from server',
          backgroundColor: AppColors.redColor,
          colorText: Colors.white,
        );
      }
    } on NoInternetException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on TimeoutException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on HttpException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        '${e.message} (Code: ${e.statusCode})',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } on ParseException catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        e.message,
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Unexpected error: $e',
        backgroundColor: AppColors.redColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
