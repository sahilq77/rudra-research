import 'package:get/get.dart';
import 'package:rudra/app/modules/validator_module/validator_profile/validator_profile_controller.dart';
import 'package:rudra/app/modules/validator_module/validator_profile_details/validator_profile_detail_controller.dart';

class ValidatorProfileDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidatorProfileDetailController>(() => ValidatorProfileDetailController());
  }
}
