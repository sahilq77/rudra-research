import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/models/profile_details/performance_data_model.dart';
import '../../data/models/profile_details/profile_details_model.dart';
import '../../utils/app_logger.dart';
import '../../utils/app_utility.dart';

class ProfileDetailsController extends GetxController {
  final RxBool isLoading = false.obs;
  final Rx<ProfileDetailsModel?> profileDetails =
      Rx<ProfileDetailsModel?>(null);
  final RxList<PerformanceDataModel> performanceData =
      <PerformanceDataModel>[].obs;
  final RxString selectedPeriod = 'Weekly'.obs;
  final RxString currentMonth = 'March 2023'.obs;

  final List<String> periodOptions = ['Daily', 'Weekly', 'Monthly'];

  String get userName => AppUtility.fullName ?? 'User';

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadProfileDetails();
    _loadPerformanceData();
  }

  Future<void> onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadProfileDetails();
    _loadPerformanceData();
    AppLogger.d('Profile details page refreshed',
        tag: 'ProfileDetailsController');
  }

  void _loadProfileDetails() {
    try {
      isLoading.value = true;

      // Mock data - Replace with actual API call
      profileDetails.value = ProfileDetailsModel(
        name: 'Pradeep Nayar',
        phoneNumber: '9874563210',
        emailId: 'pradeep123@gmail.com',
        address: 'MG Road, Shivaji Nagar, Pune.',
        designation: 'Manager',
        joiningDate: 'Sep 16, 2025',
        dob: 'Mar 16, 2000',
      );

      AppLogger.d('Profile details loaded successfully',
          tag: 'ProfileDetailsController');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load profile details',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProfileDetailsController',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadPerformanceData() {
    try {
      // Mock data - Replace with actual API call
      performanceData.value = [
        PerformanceDataModel(day: 'Mon', target: 85, targetCompleted: 78),
        PerformanceDataModel(day: 'Tue', target: 90, targetCompleted: 85),
        PerformanceDataModel(day: 'Wed', target: 88, targetCompleted: 84),
        PerformanceDataModel(day: 'Thu', target: 92, targetCompleted: 88),
        PerformanceDataModel(day: 'Fri', target: 87, targetCompleted: 90),
        PerformanceDataModel(day: 'Sat', target: 85, targetCompleted: 85),
        PerformanceDataModel(day: 'Sun', target: 90, targetCompleted: 86),
      ];

      final now = DateTime.now();
      currentMonth.value = DateFormat('MMMM yyyy').format(now);

      AppLogger.d('Performance data loaded successfully',
          tag: 'ProfileDetailsController');
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to load performance data',
        error: e,
        stackTrace: stackTrace,
        tag: 'ProfileDetailsController',
      );
    }
  }

  void onPeriodChanged(String? value) {
    if (value != null) {
      selectedPeriod.value = value;
      AppLogger.d('Period changed to: $value', tag: 'ProfileDetailsController');
      // Reload performance data based on new period
      _loadPerformanceData();
    }
  }

  void onPreviousMonth() {
    AppLogger.d('Previous month tapped', tag: 'ProfileDetailsController');
    // Implement month navigation logic
  }

  void onNextMonth() {
    AppLogger.d('Next month tapped', tag: 'ProfileDetailsController');
    // Implement month navigation logic
  }

  void onEditProfile() {
    AppLogger.d('Edit profile tapped', tag: 'ProfileDetailsController');
    Get.snackbar(
      'Coming Soon',
      'Edit profile feature will be available soon',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }
}
