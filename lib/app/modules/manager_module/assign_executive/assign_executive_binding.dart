// lib/app/modules/assign_executive/assign_executive_binding.dart
import 'package:get/get.dart';
import 'assign_executive_controller.dart';

class AssignExecutiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssignExecutiveController>(
      () => AssignExecutiveController(),
    );
  }
}