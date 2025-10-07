// lib/app/modules/add_executive/add_executive_binding.dart
import 'package:get/get.dart';

import 'add_executive_controller.dart';

class AddExecutiveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddExecutiveController>(
      () => AddExecutiveController(),
    );
  }
}
