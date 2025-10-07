// Updated lib/utils/app_utility.dart (assuming this path based on imports)
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUtility {
  static String? userID;
  static String? fullName;
  static String? mobileNumber;
  static String? email;
  static String? plantId;
  static RxString plantName = ''.obs;
  static int? userRole;
  static bool isLoggedIn = false;
  static bool hasSeenOnboarding = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    if (isLoggedIn) {
      fullName = prefs.getString('full_name');
      mobileNumber = prefs.getString('mobile_number');
      email = prefs.getString('email');
      plantId = prefs.getString('plant_id');
      plantName.value = prefs.getString('plant_name') ?? '';
      userID = prefs.getString('login_user_id');
      userRole = prefs.getInt('user_role');
    }
  }

  static Future<void> setUserInfo(
    String name,
    String mobile,
    String emailid,
    String userid,
    String plantid,
    int role,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('full_name', name);
    await prefs.setString('mobile_number', mobile);
    await prefs.setString('email', emailid);
    await prefs.setString('login_user_id', userid);
    await prefs.setString('plant_id', plantid);
    await prefs.setString('plant_name', '');
    await prefs.setInt('user_role', role);
    fullName = name;
    mobileNumber = mobile;
    userID = userid;
    email = emailid;
    plantId = plantid;
    userRole = role;
    plantName.value = '';
    isLoggedIn = true;
  }

  static Future<void> updatePlant(String plantid, String plantname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plant_id', plantid);
    await prefs.setString('plant_name', plantname);
    plantId = plantid;
    plantName.value = plantname;
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('full_name');
    await prefs.remove('mobile_number');
    await prefs.remove('email');
    await prefs.remove('login_user_id');
    await prefs.remove('plant_id');
    await prefs.remove('plant_name');
    await prefs.remove('user_role');
    userID = null;
    fullName = null;
    mobileNumber = null;
    email = null;
    plantId = null;
    userRole = null;
    plantName.value = '';
    isLoggedIn = false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    hasSeenOnboarding = true;
  }

  // OPTIONAL: Add this static getter for cleaner access (not required, but aligns with previous suggestion)
  static bool get isUserLoggedIn => isLoggedIn;
  static bool get isOnboardingCompleted => hasSeenOnboarding;
}
