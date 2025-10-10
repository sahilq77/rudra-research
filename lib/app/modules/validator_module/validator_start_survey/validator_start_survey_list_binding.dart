import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_controller.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey/validator_start_survey_list_controller.dart';


class ValidatorStartSurveyListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorStartSurveyListController>(
      () => ValidatorStartSurveyListController(),
    );
  }
}