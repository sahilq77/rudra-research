// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_controller.dart';
import 'package:rudra/app/modules/executive_profile_details/executive_profile_detail_controller.dart';


class ExecutiveProfileDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExecutiveProfileDetailController>(() => ExecutiveProfileDetailController());
  }
}