// lib/app/modules/assign_executive/assign_executive_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../data/models/executive/executive_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_logger.dart';

class AssignExecutiveController extends GetxController {
  final RxList<ExecutiveModel> executives = <ExecutiveModel>[].obs;
  final RxList<ExecutiveModel> filteredExecutives = <ExecutiveModel>[].obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadExecutives();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadExecutives() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - Replace with actual API call
      executives.value = [
        ExecutiveModel(
          id: '1',
          name: 'Pratik Wadh',
          mobile: '9874563210',
          designation: 'Manager',
          image: '',
        ),
        ExecutiveModel(
          id: '2',
          name: 'Pratik Wadh',
          mobile: '9874563210',
          designation: 'Manager',
          image: '',
        ),
        ExecutiveModel(
          id: '3',
          name: 'Pratik Wadh',
          mobile: '9874563210',
          designation: 'Manager',
          image: '',
        ),
        ExecutiveModel(
          id: '4',
          name: 'Pratik Wadh',
          mobile: '9874563210',
          designation: 'Manager',
          image: '',
        ),
        ExecutiveModel(
          id: '5',
          name: 'Pratik Wadh',
          mobile: '9874563210',
          designation: 'Manager',
          image: '',
        ),
      ];

      filteredExecutives.value = executives;
      isLoading.value = false;
      AppLogger.i('Executives loaded successfully',
          tag: 'AssignExecutiveController');
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error loading executives',
          error: e, tag: 'AssignExecutiveController');
    }
  }

  void searchExecutives(String query) {
    if (query.isEmpty) {
      filteredExecutives.value = executives;
    } else {
      final lowerQuery = query.toLowerCase();
      filteredExecutives.value = executives
          .where((executive) =>
              executive.name.toLowerCase().contains(lowerQuery) ||
              executive.mobile.contains(query) ||
              executive.designation.toLowerCase().contains(lowerQuery))
          .toList();
    }
    AppLogger.d('Search query: $query, Results: ${filteredExecutives.length}',
        tag: 'AssignExecutiveController');
  }

  void toggleSelect(String id) {
    final index = filteredExecutives.indexWhere((e) => e.id == id);
    if (index != -1) {
      filteredExecutives[index] = filteredExecutives[index].copyWith(
        isSelected: !filteredExecutives[index].isSelected,
      );
      filteredExecutives.refresh();
      AppLogger.d('Toggled selection for executive: $id',
          tag: 'AssignExecutiveController');
    }
  }

  Future<void> assignExecutives() async {
    try {
      isLoading.value = true;

      // Filter selected executives
      final selectedExecutives = filteredExecutives
          .where((executive) => executive.isSelected)
          .toList();

      if (selectedExecutives.isEmpty) {
        Get.snackbar(
          'No Selection',
          'Please select at least one executive',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.primary,
          colorText: AppColors.white,
        );
        isLoading.value = false;
        return;
      }

      // TODO: Make API call to assign executives
      await Future.delayed(const Duration(seconds: 1));

      AppLogger.i('Executives assigned successfully',
          tag: 'AssignExecutiveController');

      Get.snackbar(
        'Success',
        'Executives assigned successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.greenColor,
        colorText: AppColors.white,
      );

      // Refresh the list
      await refreshData();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      AppLogger.e('Error assigning executives',
          error: e, tag: 'AssignExecutiveController');
      Get.snackbar(
        'Error',
        'Failed to assign executives',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
      );
    }
  }

  Future<void> refreshData() async {
    await loadExecutives();
  }
}
