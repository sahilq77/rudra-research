// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_controller.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_controller.dart';


class ExecutiveNotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveNotificationController>(() => ExecutiveNotificationController());
  }
}