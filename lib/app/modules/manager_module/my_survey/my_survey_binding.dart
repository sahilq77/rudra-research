import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_controller.dart';


class MySurveyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySurveyController>(
      () => MySurveyController(),
    );
  }
}