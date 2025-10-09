// lib/app/modules/home/home_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_controller.dart';



class ExecutiveHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveHomeController>(() => ExecutiveHomeController());
  }
}