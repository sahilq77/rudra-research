import 'package:get/get.dart';

import 'super_admin_all_surveys_controller.dart';

class SuperAdminAllSurveysBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminAllSurveysController>(
      () => SuperAdminAllSurveysController(),
    );
  }
}
