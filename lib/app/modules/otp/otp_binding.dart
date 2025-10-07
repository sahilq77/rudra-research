// lib/app/modules/otp/otp_binding.dart
import 'package:get/get.dart';

import 'otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpController>(() => OtpController());
  }
}