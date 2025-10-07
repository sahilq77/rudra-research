// lib/app/modules/assigned_survey_target/assigned_survey_target_binding.dart
import 'package:get/get.dart';
import 'assigned_survey_target_controller.dart';

class AssignedSurveyTargetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignedSurveyTargetController>(
      () => AssignedSurveyTargetController(),
    );
  }
}