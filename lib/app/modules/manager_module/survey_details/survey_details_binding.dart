// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';

import 'survey_details_controller.dart';

class SurveyDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurveyDetailsController>(() => SurveyDetailsController());
  }
}