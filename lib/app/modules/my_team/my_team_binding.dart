import 'package:get/get.dart';
import 'package:rudra/app/modules/my_team/my_team_controller.dart';
import 'package:rudra/app/modules/myreport/my_report_list_controller.dart';

class MyTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyTeamController>(
      () => MyTeamController(),
    );
  }
}