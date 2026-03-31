import 'package:get/get.dart';

import 'super_admin_profile_details_controller.dart';

class SuperAdminProfileDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminProfileDetailsController>(
      () => SuperAdminProfileDetailsController(),
    );
  }
}
