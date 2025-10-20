import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_controller.dart';
import 'package:rudra/app/modules/manager_module/my_team/team_member_detail/team_member_detail_controller.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_controller.dart';

class TeamMemberDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeamMemberDetailController>(
      () => TeamMemberDetailController(),
    );
  }
}