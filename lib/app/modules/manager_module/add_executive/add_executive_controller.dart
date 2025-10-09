// lib/app/modules/add_executive/add_executive_controller.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../data/models/add_executive/add_executive_model.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_logger.dart';

class AddExecutiveController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController joiningDateController = TextEditingController();
  final RxInt selectedRole = 0.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  final List<String> roles = ['Executive'];

  DateTime selectedDob = DateTime(2025, 9, 16);
  DateTime selectedJoiningDate = DateTime(2025, 9, 16);

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _initializeDates();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    dobController.dispose();
    joiningDateController.dispose();
    super.onClose();
  }

  void _initializeDates() {
    dobController.text = DateFormat('MMM dd, yyyy').format(selectedDob);
    joiningDateController.text =
        DateFormat('MMM dd, yyyy').format(selectedJoiningDate);
  }

  Future<void> pickDate(bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: isDob ? selectedDob : selectedJoiningDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      if (isDob) {
        selectedDob = picked;
        dobController.text = DateFormat('MMM dd, yyyy').format(picked);
      } else {
        selectedJoiningDate = picked;
        joiningDateController.text = DateFormat('MMM dd, yyyy').format(picked);
      }
    }
  }

  Future<void> showImageSourceBottomSheet() async {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Gallery'),
                      onTap: () {
                        Get.back();
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Camera'),
                      onTap: () {
                        Get.back();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        selectedImage.value = File(image.path);
        AppLogger.i('Image picked successfully from $source',
            tag: 'AddExecutiveController');
      }
    } catch (e) {
      AppLogger.e('Error picking image',
          error: e, tag: 'AddExecutiveController');
    }
  }

  Future<void> addExecutive() async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fix the errors in the form',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Make API call to add executive
      await Future.delayed(const Duration(seconds: 2));

      final newExecutive = AddExecutiveModel(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        mobile: mobileController.text.trim(),
        dateOfBirth: selectedDob,
        address: addressController.text.trim(),
        profileImage: selectedImage.value,
        joiningDate: selectedJoiningDate,
        role: roles[selectedRole.value],
      );

      AppLogger.i('Executive added successfully: ${newExecutive.firstName}',
          tag: 'AddExecutiveController');

      Get.snackbar(
        'Success',
        'Executive added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.greenColor,
        colorText: AppColors.white,
      );

      Get.offNamed(AppRoutes.assignExecutive);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error adding executive',
          error: e, tag: 'AddExecutiveController');
      Get.snackbar(
        'Error',
        'Failed to add executive',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
