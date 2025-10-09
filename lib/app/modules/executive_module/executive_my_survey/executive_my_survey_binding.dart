// lib/app/modules/home/home_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_controller.dart';

class ExecutiveMySurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveMySurveyController>(
      () => ExecutiveMySurveyController(),
    );
  }
}
