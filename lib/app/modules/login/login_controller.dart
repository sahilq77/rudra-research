// lib/app/modules/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxInt selectedRole = 0.obs;
  final List<String> userTypes = ['Manager', 'Executor', 'Validator'];
  final formKey = GlobalKey<FormState>();
  late FocusNode phoneFocusNode;
  final GlobalKey phoneFieldKey = GlobalKey();

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

  void login() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    // Navigate to OTP with arguments
    Get.offNamed(
      AppRoutes.otp,
      arguments: {
        'phone': phoneController.text,
        'role': selectedRole.value,
      },
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.onClose();
  }
}
