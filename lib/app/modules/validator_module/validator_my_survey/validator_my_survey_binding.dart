import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_my_survey/validator_my_survey_controller.dart';

class ValidatorMySurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorMySurveyController>(
      () => ValidatorMySurveyController(),
    );
  }
}
