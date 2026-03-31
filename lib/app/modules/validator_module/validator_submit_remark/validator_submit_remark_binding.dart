import 'package:get/get.dart';

import 'validator_submit_remark_controller.dart';

class ValidatorSubmitRemarkBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final surveyAppSideId = args['survey_app_side_id'] as String? ?? '';
    final surveyId = args['survey_id'] as String? ?? '';
    Get.lazyPut<ValidatorSubmitRemarkController>(
      () => ValidatorSubmitRemarkController(
        surveyAppSideId: surveyAppSideId,
        surveyId: surveyId,
      ),
    );
  }
}
