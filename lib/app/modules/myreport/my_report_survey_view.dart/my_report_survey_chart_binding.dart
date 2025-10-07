import 'package:get/get.dart';

import '../my_report_view/report_form_controller.dart';

class MyReportSurveyChartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyReportFormViewController>(() => MyReportFormViewController());
  }
}
