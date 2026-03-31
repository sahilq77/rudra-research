import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/team/get_team_id_response.dart';
import '../data/network/networkcall.dart';
import '../data/urls.dart';
import 'app_logger.dart';

class AppUtility {
  static String? userID;
  static String? fullName;
  static String? mobileNumber;
  static String? email;
  static String? roleId;
  static String? teamId;
  static String? deviceId;
  static RxString userImage = ''.obs;
  static RxString plantName = ''.obs;
  static int? userRole;
  static bool isLoggedIn = false;
  static bool hasSeenOnboarding = false;
  static bool isOtpVerified = false;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    isOtpVerified = prefs.getBool('isOtpVerified') ?? false;
    if (isLoggedIn) {
      fullName = prefs.getString('full_name');
      mobileNumber = prefs.getString('mobile_number');
      email = prefs.getString('email');
      roleId = prefs.getString('role_id');
      teamId = prefs.getString('team_id');
      userImage.value = prefs.getString('user_image') ?? '';
      plantName.value = prefs.getString('plant_name') ?? '';
      userID = prefs.getString('login_user_id');
      userRole = prefs.getInt('user_role');
      deviceId = prefs.getString('device_id');
    }
  }

  static Future<void> setUserInfo(
    String name,
    String mobile,
    String emailid,
    String userid,
    String roleid,
    String teamid,
    int role,
    String image,
    String device,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('full_name', name);
    await prefs.setString('mobile_number', mobile);
    await prefs.setString('email', emailid);
    await prefs.setString('login_user_id', userid);
    await prefs.setString('role_id', roleid);
    await prefs.setString('team_id', teamid);
    await prefs.setString('user_image', image);
    await prefs.setString('device_id', device);
    await prefs.setString('plant_name', '');
    await prefs.setInt('user_role', role);
    fullName = name;
    mobileNumber = mobile;
    userID = userid;
    email = emailid;
    roleId = roleid;
    userRole = role;
    teamId = teamid;
    userImage.value = image;
    deviceId = device;
    plantName.value = '';
    isLoggedIn = true;
    isOtpVerified = false;
  }

  static Future<void> updatePlant(String plantid, String plantname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plant_id', plantid);
    await prefs.setString('plant_name', plantname);
    roleId = plantid;
    plantName.value = plantname;
  }

  static Future<void> updateUserImage(String imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_image', imageUrl);
    userImage.value = imageUrl;
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
    await prefs.remove('user_image');
    await prefs.remove('device_id');
    userID = null;
    fullName = null;
    mobileNumber = null;
    email = null;
    roleId = null;
    userRole = null;
    deviceId = null;
    userImage.value = '';
    plantName.value = '';
    isLoggedIn = false;
    isOtpVerified = false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    hasSeenOnboarding = true;
  }

  static Future<void> setOtpVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOtpVerified', true);
    isOtpVerified = true;
  }

  static Future<bool> fetchAndUpdateTeamIds(BuildContext context) async {
    try {
      AppLogger.i('Fetching team IDs for user', tag: 'AppUtility');

      final jsonBody = {"user_id": userID ?? ""};

      final response = await Networkcall().postMethod(
        Networkutility.getTeamIdAccUserIdApi,
        Networkutility.getTeamIdAccUserId,
        jsonEncode(jsonBody),
        context,
      ) as List<GetTeamIdResponse>?;

      if (response == null || response.isEmpty) {
        AppLogger.e('No response from server', tag: 'AppUtility');
        return false;
      }

      final apiResponse = response.first;
      if (apiResponse.status != "true") {
        AppLogger.e('API error: ${apiResponse.message}', tag: 'AppUtility');
        return false;
      }

      final teamIds = apiResponse.data.map((team) => team.teamId).toList();
      final teamIdsString = teamIds.join(',');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('team_id', teamIdsString);
      teamId = teamIdsString;

      AppLogger.i(
        'Team IDs updated: $teamIdsString (${teamIds.length} teams)',
        tag: 'AppUtility',
      );
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Failed to fetch team IDs',
        error: e,
        stackTrace: stackTrace,
        tag: 'AppUtility',
      );
      return false;
    }
  }

  static bool get isUserLoggedIn => isLoggedIn;
  static bool get isOnboardingCompleted => hasSeenOnboarding;
}
