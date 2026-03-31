import 'package:get/get.dart';

import 'super_admin_profile_controller.dart';

class SuperAdminProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuperAdminProfileController>(
      () => SuperAdminProfileController(),
    );
  }
}
