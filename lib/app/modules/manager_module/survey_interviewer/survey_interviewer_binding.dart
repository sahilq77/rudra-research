// lib/app/modules/survey_interviewer/survey_interviewer_binding.dart
import 'package:get/get.dart';

import 'survey_interviewer_controller.dart';

class SurveyInterviewerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurveyInterviewerController>(() => SurveyInterviewerController());
  }
}