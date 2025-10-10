// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/survey_detail_multiple/survey_detail_multiple_controller.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_controller.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_controller.dart';

class ValidatorSubmitSurveyFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorSubmitSurveyFormController>(
      () => ValidatorSubmitSurveyFormController(),
    );
  }
}
