// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/survey_detail_multiple/survey_detail_multiple_controller.dart';



class SurveyDetailMultipleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurveyDetailMultipleController>(() => SurveyDetailMultipleController());
  }
}