import 'package:get/get.dart';
import 'package:rudra/app/modules/myreport/my_report_list_controller.dart';
import 'package:rudra/app/modules/myreport/my_report_view/report_form_controller.dart';

class ReportFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyReportFormViewController>(
      () => MyReportFormViewController(),
    );
  }
}