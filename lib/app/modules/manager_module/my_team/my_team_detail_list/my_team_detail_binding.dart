import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_controller.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_detail_list/my_team_detail_list_controller.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_controller.dart';

class MyTeamDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyTeamDetailListController>(
      () => MyTeamDetailListController(),
    );
  }
}