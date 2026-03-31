import 'package:get/get.dart';
import 'package:rudra/app/utils/app_utility.dart';

import '../app/routes/app_routes.dart';

class BottomNavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;

  // Single declaration of routes, initialized based on userType
  late final List<String> routes;

  @override
  void onInit() {
    super.onInit();
    routes = _getRoutesForUserType(AppUtility.userRole);
    syncIndexWithRoute(Get.currentRoute);
  }

  // Determine routes based on userType
  List<String> _getRoutesForUserType(int? userType) {
    switch (userType) {
      case 0:
        return [
          AppRoutes.home,
          AppRoutes.myreport,
          AppRoutes.myteam,
          AppRoutes.mySurvey,
          AppRoutes.profile,
        ];
      case 1:
        return [
          AppRoutes.executiveHome,
          AppRoutes.executiveMySurvey,
          AppRoutes.executivProfile,
        ];
      case 2:
        return [
          AppRoutes.validatorHome,
          AppRoutes.validatorMySurvey,
          AppRoutes.validatorProfile,
        ];
      case 3:
        return [
          AppRoutes.superAdminHome,
          AppRoutes.superAdminAllSurveys,
          AppRoutes.superAdminReport,
          AppRoutes.superAdminProfile,
        ];
      default:
        // Fallback routes in case userType is invalid
        print('Invalid userType: $userType, defaulting to userType 0 routes');
        return [
          AppRoutes.home,
          AppRoutes.myreport,
          AppRoutes.myteam,
          AppRoutes.mySurvey,
          AppRoutes.profile,
        ];
    }
  }

  void syncIndexWithRoute(String? route) {
    if (route == null) {
      print('Route is null, keeping current index: ${selectedIndex.value}');
      return;
    }
    final index = routes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
    } else {
      print(
        'Route $route not found in routes, keeping current index: ${selectedIndex.value}',
      );
    }
  }

  void changeTab(int index) {
    if (index < 0 || index >= routes.length || selectedIndex.value == index) {
      return;
    }
    selectedIndex.value = index;
    Get.offAllNamed(routes[index]);
  }

  void goToHome() {
    selectedIndex.value = 0;
    if (AppUtility.userRole == 0) {
      Get.offAllNamed(AppRoutes.home);
    } else if (AppUtility.userRole == 1) {
      Get.offAllNamed(AppRoutes.executiveHome);
    } else if (AppUtility.userRole == 2) {
      Get.offAllNamed(AppRoutes.validatorHome);
    } else if (AppUtility.userRole == 3) {
      Get.offAllNamed(AppRoutes.superAdminHome);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<bool> onWillPop() async {
    if (Get.nestedKey(1)?.currentState?.canPop() ?? false) {
      Get.back(id: 1); // Pop within the current tab's stack
      return false; // Prevent app exit
    }
    if (selectedIndex.value != 0) {
      goToHome(); // Go to Home tab if not already there
      return false; // Prevent app exit
    }
    return true; // Allow app exit if on Home tab with no stack
  }
}
