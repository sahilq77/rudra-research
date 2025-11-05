import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_response_list/my_survey_response_controller.dart';

class MySurveyResponseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySurveyResponseController>(
      () => MySurveyResponseController(),
    );
  }
}
