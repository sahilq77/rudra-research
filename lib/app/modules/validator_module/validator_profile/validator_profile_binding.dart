import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_profile/validator_profile_controller.dart';

class ValidatorProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorProfileController>(() => ValidatorProfileController());
  }
}
