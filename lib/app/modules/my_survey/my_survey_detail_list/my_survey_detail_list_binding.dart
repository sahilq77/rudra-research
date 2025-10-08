import 'package:get/get.dart';
import 'package:rudra/app/modules/my_survey/my_survey_detail_list/my_survey_detail_list_controller.dart';

class MySurveyDetailListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MySurveyDetailListController>(
      () => MySurveyDetailListController(),
    );
  }
}
