// lib/app/modules/survey_details/survey_details_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_snackbar_styles.dart';

class SurveyDetailsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Rx variables
  final RxString selectedLanguage = 'Marathi'.obs;
  final RxString selectedArea = 'Mallewadi'.obs;

  // Lists
  final List<String> languages = ['Marathi', 'Hindi', 'English'];
  final List<String> areas = ['Mallewadi']; // Sample, can be dynamic

  // Auto-fetched
  final String state = 'Maharashtra';
  final String region = 'North Maharashtra';
  final String district = 'Kolhapur';
  final String loksabha = 'Kolhapur';
  final String assembly = 'Radhanagari';
  final String wardZp = 'Sarwade';

  void nextPage() {
    if (formKey.currentState!.validate()) {
      Get.toNamed(AppRoutes.surveyQuestion, arguments: {
        'language': selectedLanguage.value,
        'area': selectedArea.value,
        // Pass other auto-fetched if needed
      });
    }
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }
}
