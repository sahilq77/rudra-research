import 'package:get/get.dart';

import 'super_admin_survey_team_members_controller.dart';

class SuperAdminSurveyTeamMembersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminSurveyTeamMembersController>(
      () => SuperAdminSurveyTeamMembersController(),
    );
  }
}
