import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/utils/responsive_utils.dart';

import '../../../../widgets/app_snackbar_styles.dart';


class MyReportFormViewController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController sonarController = TextEditingController();
  final TextEditingController executiveController = TextEditingController();
  final TextEditingController assemblyController = TextEditingController();
  final TextEditingController wardController = TextEditingController();
  final TextEditingController areaController = TextEditingController();

  // Rx for dropdowns
  final RxString selectedSonar = ''.obs;
  final RxString selectedExecutive = ''.obs;
  final RxString selectedAssembly = ''.obs;
  final RxString selectedWard = ''.obs;
  final RxString selectedArea = ''.obs;

  // Lists
  final List<String> sonars = ['Sonar']; // Sample
  final List<String> executives = ['Mallikarjun Pote']; // Sample
  final List<String> assemblies = ['Kasaba Peth']; // Sample
  final List<String> wards = ['Ward No. 17']; // Sample
  final List<String> areas = ['Budhwar Peth']; // Sample

  

 

 
  void resetForm() {
    sonarController.clear();
    executiveController.clear();
    assemblyController.clear();
    wardController.clear();
    areaController.clear();
    selectedSonar.value = '';
    selectedExecutive.value = '';
    selectedAssembly.value = '';
    selectedWard.value = '';
    selectedArea.value = '';
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Data refreshed');
  }

  @override
  void onClose() {
    sonarController.dispose();
    executiveController.dispose();
    assemblyController.dispose();
    wardController.dispose();
    areaController.dispose();
    super.onClose();
  }
}