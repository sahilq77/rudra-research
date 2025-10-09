import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_controller.dart';

class MyReportListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyReportListController>(
      () => MyReportListController(),
    );
  }
}