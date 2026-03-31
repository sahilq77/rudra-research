import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_controller.dart';

class ValidatorStartSurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ValidatorStartSurveyController>(
      ValidatorStartSurveyController(),
    );
  }
}
