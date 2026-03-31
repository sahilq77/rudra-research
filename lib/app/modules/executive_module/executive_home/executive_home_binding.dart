// lib/app/modules/home/home_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/data/service/survey_data_service.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_controller.dart';

class ExecutiveHomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register SurveyDataService if not already registered
    if (!Get.isRegistered<SurveyDataService>()) {
      Get.lazyPut<SurveyDataService>(() => SurveyDataService());
    }
    Get.lazyPut<ExecutiveHomeController>(() => ExecutiveHomeController());
  }
}
