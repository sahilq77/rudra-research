// lib/app/modules/survey_details/survey_details_binding.dart
import 'package:get/get.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_controller.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_controller.dart';

class AudioRecorderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AudioRecorderController>(() => AudioRecorderController());
  }
}
