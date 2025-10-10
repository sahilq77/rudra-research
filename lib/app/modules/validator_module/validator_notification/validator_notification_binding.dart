// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_notification/validator_notification_controller.dart';

class ValidatorNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorNotificationController>(
      () => ValidatorNotificationController(),
    );
  }
}
