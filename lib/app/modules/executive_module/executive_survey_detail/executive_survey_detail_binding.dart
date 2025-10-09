// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_controller.dart';


class ExecutiveSurveyDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveSurveyDetailController>(() => ExecutiveSurveyDetailController());
  }
}