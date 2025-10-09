// lib/app/modules/survey_question/survey_question_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_question/executive_survey_question_view.dart';



class ExecutiveSurveyQuestionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveSurveyQuestionView>(() => ExecutiveSurveyQuestionView());
  }
}