// lib/app/modules/otp/otp_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_utility.dart';

class OtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  late String phone;
  late int role;
  late String maskedPhone;
  final List<String> userTypes = ['Manager', 'Executor', 'Validator'];

  // Timer properties
  final RxInt countdown = 60.obs;
  final RxBool canResend = false.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    phone = args['phone'] ?? '';
    role = args['role'] ?? 0;
    if (phone.length >= 6) {
      maskedPhone = '${phone.substring(0, 3)}-${phone.substring(3, 6)}-XXXX';
    } else {
      maskedPhone = phone;
    }
    startTimer();
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

  void verify() {
    String otp = otpController.text;
    if (otp.length != 6) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit OTP',
        backgroundColor: AppColors.redColor,
        colorText: AppColors.white,
      );
      return;
    }
    // Store dummy data
    final String dummyName = 'Dummy ${userTypes[role]}';
    AppUtility.setUserInfo(
      dummyName,
      phone,
      '',
      'dummy_user_$role',
      'dummy_plant_1',
      role,
    );
    if (role == 0) {
      // Manager
      Get.offAllNamed(AppRoutes.home, arguments: {'userRole': role});
      // Additional setup for manager if needed
    } else if (role == 1) {
      // Executive
      Get.offAllNamed(AppRoutes.executiveHome, arguments: {'userRole': role});
      // Additional setup for executive if needed
    } else {
      Get.offAllNamed(AppRoutes.validatorHome, arguments: {'userRole': role});
    }
  }

  void resend() {
    if (!canResend.value) return;
    Get.snackbar(
      'Resend',
      'OTP has been resent',
      backgroundColor: AppColors.greenColor,
      colorText: AppColors.white,
    );
    otpController.clear();
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
