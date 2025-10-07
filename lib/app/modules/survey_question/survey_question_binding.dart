// lib/app/modules/survey_question/survey_question_binding.dart
import 'package:get/get.dart';

import 'survey_question_controller.dart';

class SurveyQuestionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SurveyQuestionController>(() => SurveyQuestionController());
  }
}