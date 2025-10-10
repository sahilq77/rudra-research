import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_profile/executive_profile_controller.dart';

class ExecutiveProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveProfileController>(() => ExecutiveProfileController());
  }
}
