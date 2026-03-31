import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:rudra/app/data/models/add_executive/get_add_executive_response.dart';
import 'package:rudra/app/data/models/dashboard/get_dashboard_counter_response.dart';
import 'package:rudra/app/data/models/executive/get_executive_list.dart';
import 'package:rudra/app/data/models/executive/set_executive_response.dart';
import 'package:rudra/app/data/models/home/get_live_survey_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_cast_response.dart';
import 'package:rudra/app/data/models/interviewer_info/get_set_interviewer_info.dart';
import 'package:rudra/app/data/models/login/get_login_response.dart';
import 'package:rudra/app/data/models/my_survey/get_my_survey_list_response.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_detail.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_member_response.dart';
import 'package:rudra/app/data/models/my_team/get_my_team_response.dart';
import 'package:rudra/app/data/models/notification/get_notification_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_area_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_complete_survey_details_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_set_survey_response.dart';
import 'package:rudra/app/data/models/survey_detail/get_survey_detail_response.dart';
import 'package:rudra/app/data/models/survey_question/get_submit_answers_response.dart';
import 'package:rudra/app/data/models/survey_question/get_survey_questions_response.dart';
import 'package:rudra/app/data/models/survey_target/get_assign_survey_target_list_response.dart';
import 'package:rudra/app/data/models/survey_target/set_assign_survey_target_response.dart';
import 'package:rudra/app/data/network/exceptions.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart'; // Import AppSnackbarStyles
import 'package:rudra/app/widgets/app_style.dart';
import 'package:rudra/app/widgets/connctivityservice.dart'
    show ConnectivityService;

import '../../routes/app_routes.dart';
import '../../utils/app_logger.dart';
import '../../utils/app_utility.dart';
import '../models/device_info/device_info_response.dart';
import '../models/logout/logout_response.dart';
import '../models/my_report/get_assembly_response.dart';
import '../models/my_report/get_executive_response.dart';
import '../models/my_report/get_survey_report_response.dart';
import '../models/my_report/get_ward_response.dart';
import '../models/my_survey/get_my_survey_submitted_response.dart';
import '../models/my_survey/get_survey_detail_response.dart' as MySurveyDetail;
import '../models/otp/get_otp_response.dart';
import '../models/otp/validate_otp_response.dart';
import '../models/profile/upload_user_image_response.dart';
import '../models/profile_details/get_my_survey_response.dart';
import '../models/profile_details/get_user_performance_response.dart';
import '../models/super_admin/get_all_survey_response.dart';
import '../models/super_admin/get_super_admin_dashboard_counter_response.dart';
import '../models/super_admin/get_super_admin_live_survey_response.dart';
import '../models/super_admin/get_team_members_acc_to_survey_response.dart';
import '../models/team/get_team_id_response.dart';
import '../models/validator/final_submit_validator_response.dart';
import '../models/validator/get_validator_my_survey_detail_response.dart';
import '../models/validator/get_validator_response_list_response.dart';
import '../models/validator/get_validator_survey_response.dart';
import '../models/validator/save_validator_comment_response.dart';
import '../models/validator/validator_survey_list_response.dart';
import '../service/sync_service.dart';

class Networkcall {
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  static GetSnackBar? _slowInternetSnackBar;
  static const int _minResponseTimeMs =
      3000; // Threshold for slow internet (3s)
  static bool _isNavigatingToNoInternet = false; // Prevent multiple navigations

  Future<List<Object?>?> postMethod(
    int requestCode,
    String url,
    String body,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        // await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make POST request with timeout
      var response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body.isEmpty ? null : body,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;

      // Handle 401 - User inactive/deleted
      if (response.statusCode == 401) {
        AppLogger.d('URL : $url \nRequest body: $body \nResponse: $data');
        await _handle401Unauthorized();
        return null;
      }

      if (response.statusCode == 200) {
        log(
          "url : $url \n Request Code : $requestCode \n body : $body \n Response : $data",
        );

        // Wrap response in [] for consistency
        String str = "[${response.body}]";

        switch (requestCode) {
          case 1:
            final login = getLoginResponseFromJson(str);
            return login;
          case 2:
            final getTeam = getMyTeamResponseFromJson(str);
            return getTeam;
          case 3:
            final getMemberList = getMyTeamMemberResponseFromJson(str);
            return getMemberList;
          case 4:
            final getMemberDetail = getMyTeamMemberDetailResponseFromJson(str);
            return getMemberDetail;
          case 5:
            final getMemberDetail = getMyTeamMemberDetailResponseFromJson(str);
            return getMemberDetail;
          case 6:
            final addExecutive = getAddExcecutiveResponseFromJson(str);
            return addExecutive;

          case 7:
            final getNotification = getNotificationResponseFromJson(str);
            return getNotification;
          case 8:
            final getLiveSurvey = getLiveSurveyListResponseFromJson(str);
            return getLiveSurvey;
          case 9:
            final getSurveyDetail = getSurveyDetailResponseFromJson(str);
            return getSurveyDetail;
          case 10:
            final getArea = getAreaResponseFromJson(str);
            return getArea;
          case 11:
            final setSurvey = getSetServeyResponseFromJson(str);
            return setSurvey;

          case 12:
            final getSurveyQuestion = getSurveyQuestionsResponseFromJson(str);
            return getSurveyQuestion;
          case 13:
            final submitAnswers = getSubmitAnswersResponseFromJson(str);
            return submitAnswers;

          case 14:
            final getCast = geCastResponseFromJson(str);
            return getCast;

          case 15:
            final setInterviewerInfo = getSetInterviewerInfoResponseFromJson(
              str,
            );
            return setInterviewerInfo;
          case 16:
            final getAssignSurveyTargetList =
                getAssignSurveyTargetListResponseFromJson(str);
            return getAssignSurveyTargetList;
          case 17:
            final setAssignSurveyTarget = seAssignSurveyTargetResponseFromJson(
              str,
            );
            return setAssignSurveyTarget;

          case 18:
            final getExeutiveList = getExecutiveListResponseFromJson(str);
            return getExeutiveList;
          case 19:
            final setExeutive = setExecutiveResponseFromJson(str);
            return setExeutive;
          case 21:
            final getMySurveyList = getMySurveyListResponseFromJson(str);
            return getMySurveyList;
          case 22:
            final getDashboardCounter =
                getDashboardCounterResponseFromJson(str);
            return getDashboardCounter;
          case 23:
            final getCompleteSurveyDetails =
                getCompleteSurveyDetailsResponseFromJson(str);
            return getCompleteSurveyDetails;
          case 25:
            final getMySurveySubittedResponse =
                getMySurveySubmittedResponseFromJson(str);
            return getMySurveySubittedResponse;
          case 26:
            final getSurveyDetailResponse =
                MySurveyDetail.getSurveyDetailResponseFromJson(str);
            return getSurveyDetailResponse;
          case 27:
            final getValidatorSurveyList =
                validatorSurveyListResponseFromJson(str);
            return getValidatorSurveyList;
          case 28:
            final getValidatorResponseList =
                getValidatorResponseListResponseFromJson(str);
            return getValidatorResponseList;
          case 29:
            final saveComment = saveValidatorCommentResponseFromJson(str);
            return saveComment;
          case 30:
            final finalSubmit = finalSubmitValidatorResponseFromJson(str);
            return finalSubmit;
          case 31:
            final getValidatorSurveyDetail =
                getValidatorSurveyResponseFromJson(str);
            return getValidatorSurveyDetail;
          case 32:
            final getValidatorMySurveyDetail =
                getValidatorMySurveyDetailResponseFromJson(str);
            return getValidatorMySurveyDetail;
          case 33:
            final getExecutiveList = getExecutiveResponseFromJson(str);
            return getExecutiveList;
          case 34:
            final getAssembly = getAssemblyResponseFromJson(str);
            return getAssembly;
          case 35:
            final getWard = getWardResponseFromJson(str);
            return getWard;
          case 36:
            final getSurveyReport = getSurveyReportResponseFromJson(str);
            return getSurveyReport;
          case 37:
            final getUserPerformance = getUserPerformanceResponseFromJson(str);
            return getUserPerformance;
          case 38:
            final getMySurvey = getMySurveyResponseFromJson(str);
            return getMySurvey;
          case 40:
            final logout = logoutResponseFromJson(str);
            return logout;
          case 41:
            final getOtp = getOtpResponseFromJson(str);
            return getOtp;
          case 42:
            final validateOtp = validateOtpResponseFromJson(str);
            return validateOtp;
          case 43:
            final getSuperAdminDashboardCounter =
                getSuperAdminDashboardCounterResponseFromJson(str);
            return getSuperAdminDashboardCounter;
          case 44:
            final getSuperAdminLiveSurvey =
                getSuperAdminLiveSurveyListResponseFromJson(str);
            return getSuperAdminLiveSurvey;
          case 45:
            final getTeamMembers =
                getTeamMembersAccToSurveyResponseFromJson(str);
            return getTeamMembers;
          case 46:
            final getAllSurvey = getAllSurveyResponseFromJson(str);
            return getAllSurvey;
          case 47:
            final deviceInfo = deviceInfoResponseFromJson(str);
            return deviceInfo;
          case 48:
            final getTeamIds = getTeamIdResponseFromJson(str);
            return getTeamIds;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Request body : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      // await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      // Use AppSnackbarStyles for timeout error
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Request body : $body \n Response : $e");
      return null;
    }
  }

  Future<List<Object?>?> getMethod(
    int requestCode,
    String url,
    BuildContext context,
  ) async {
    try {
      // Check connectivity with retries
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        // await _navigateToNoInternet();
        return null;
      }

      // Start measuring response time
      final stopwatch = Stopwatch()..start();

      // Make GET request with timeout
      var response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      // Stop measuring response time
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;

      // Handle slow internet
      _handleSlowInternet(responseTimeMs);

      var data = response.body;
      log(url);

      // Handle 401 - User inactive/deleted
      if (response.statusCode == 401) {
        await _handle401Unauthorized();
        return null;
      }

      if (response.statusCode == 200) {
        log("url : $url \n Response : $data");
        String str = "[${response.body}]";
        switch (requestCode) {
          // case 2:
          //   final getStates = getStateResponseFromJson(str);
          //   return getStates;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url : $url \n Response : $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url : $url \n Response : $e");
      // await _navigateToNoInternet();
      return null;
    } on TimeoutException catch (e) {
      log("url : $url \n Response : $e");
      // Use AppSnackbarStyles for timeout error
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      log("url : $url \n Response : $e");
      return null;
    } on SocketException catch (e) {
      log("url : $url \n Response : $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url : $url \n Response : $e");
      return null;
    }
  }

  Future<List<Object?>?> postFormDataMethod(
    int requestCode,
    String url,
    Map<String, String> formData,
    Map<String, File> fileMap,
    BuildContext context,
  ) async {
    try {
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        return null;
      }

      final stopwatch = Stopwatch()..start();
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Content-Type'] = 'multipart/form-data';

      final fieldLogs = <String>[];
      formData.forEach((key, value) {
        request.fields[key] = value;
        fieldLogs.add('$key: $value');
      });

      final fileLogs = <String>[];
      for (var entry in fileMap.entries) {
        final key = entry.key;
        final file = entry.value;
        if (file.existsSync()) {
          final filename = p.basename(file.path);
          final bytes = await file.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              key,
              bytes,
              filename: filename,
            ),
          );
          fileLogs.add('$key: ${file.path}');
        } else {
          log('File does not exist: ${file.path}');
        }
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timed out. Please try again.');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      final responseTimeMs = stopwatch.elapsedMilliseconds;
      _handleSlowInternet(responseTimeMs);

      var data = response.body;

      // Handle 401 - User inactive/deleted
      if (response.statusCode == 401) {
        AppLogger.d(
            '$url \nForm Fields: [${fieldLogs.join(', ')}] \nFile Fields: [${fileLogs.join(', ')}] \nResponse: $data');
        await _handle401Unauthorized();
        return null;
      }

      if (response.statusCode == 200) {
        log("url: $url \nForm Fields: [${fieldLogs.join(', ')}] \nFile Fields: [${fileLogs.join(', ')}] \nResponse: $data");
        String str = "[${response.body}]";

        switch (requestCode) {
          case 39:
            final uploadImage = uploadUserImageResponseFromJson(str);
            return uploadImage;
          case 49:
            final addExecutive = getAddExcecutiveResponseFromJson(str);
            return addExecutive;
          default:
            log("Invalid request code: $requestCode");
            throw ParseException('Unhandled request code: $requestCode');
        }
      } else {
        log("url: $url \nForm Fields: [${fieldLogs.join(', ')}] \nFile Fields: [${fileLogs.join(', ')}] \nResponse: $data");
        throw HttpException(
          'Server error: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on NoInternetException catch (e) {
      log("url: $url \nForm Fields: [] \nFile Fields: [] \nResponse: $e");
      return null;
    } on TimeoutException catch (e) {
      log("url: $url \nForm Fields: [] \nFile Fields: [] \nResponse: $e");
      AppSnackbarStyles.showError(
        title: 'Request Timed Out',
        message: 'The server took too long to respond. Please try again.',
      );
      return null;
    } on HttpException catch (e) {
      log("url: $url \nForm Fields: [] \nFile Fields: [] \nResponse: $e");
      return null;
    } on SocketException catch (e) {
      log("url: $url \nForm Fields: [] \nFile Fields: [] \nResponse: $e");
      await _navigateToNoInternet();
      return null;
    } catch (e) {
      log("url: $url \nForm Fields: [] \nFile Fields: [] \nResponse: $e");
      return null;
    }
  }

  Future<void> _navigateToNoInternet() async {
    if (!_isNavigatingToNoInternet &&
        Get.currentRoute != AppRoutes.noInternet) {
      _isNavigatingToNoInternet = true;
      // Double-check connectivity before navigating
      final isConnected = await _connectivityService.checkConnectivity();
      if (!isConnected) {
        await Get.offNamed(AppRoutes.noInternet);
      }
      // Reset flag after a delay
      await Future.delayed(const Duration(milliseconds: 500));
      _isNavigatingToNoInternet = false;
    }
  }

  void _handleSlowInternet(int responseTimeMs) {
    if (responseTimeMs > _minResponseTimeMs) {
      // Show slow internet snackbar if not already shown
      if (_slowInternetSnackBar == null || !Get.isSnackbarOpen) {
        _slowInternetSnackBar = GetSnackBar(
          titleText: Text(
            'Slow Internet',
            style:
                AppStyle.heading1PoppinsWhite, // Use AppStyle for consistency
          ),
          messageText: Text(
            'Slow internet connection detected. Please check your network.',
            style: AppStyle.subheading1PoppinsWhite,
          ),
          duration: const Duration(days: 1), // Persistent until closed
          backgroundColor: Colors.orange.shade600, // Match warning style
          snackPosition: SnackPosition.TOP,
          isDismissible: true,
          margin: const EdgeInsets.all(10),
          borderRadius: 8,
          icon: const Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 28,
          ),
          shouldIconPulse: true,
        );
        Get.showSnackbar(_slowInternetSnackBar!);
      }
    } else {
      // Close slow internet snackbar if connection improves
      if (_slowInternetSnackBar != null && Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
        _slowInternetSnackBar = null;
      }
    }
  }

  static bool _is401Handling = false;
  static bool _hasNavigatedToLogin = false;

  Future<void> _handle401Unauthorized() async {
    // Prevent multiple simultaneous 401 handling

    if (_is401Handling || _hasNavigatedToLogin) {
      log('⏳ 401 handling already done or in progress');
      return;
    }

    _is401Handling = true;
    _hasNavigatedToLogin = true;

    try {
      log('\n${'🚨' * 40}');
      log('🚨 401 UNAUTHORIZED - User inactive/deleted');
      log('🚨' * 40);

      // Step 1: Start uploading pending surveys in background (non-blocking)
      log('\n📤 Step 1: Starting background upload of pending surveys...');
      if (Get.isRegistered<SyncService>()) {
        final syncService = Get.find<SyncService>();
        await syncService.updatePendingCount();

        if (syncService.pendingCount.value > 0) {
          log('📊 Found ${syncService.pendingCount.value} pending surveys');
          // Fire and forget - don't wait for completion
          syncService.syncPendingSubmissions().then((_) {
            log('✅ Background upload completed');
          }).catchError((e) {
            log('⚠️ Background upload error: $e');
          });
          log('✅ Background upload started');
        } else {
          log('✅ No pending surveys to upload');
        }
      } else {
        log('⚠️ SyncService not registered, skipping survey upload');
      }

      // Step 2: Clear user data
      log('\n🗑️ Step 2: Clearing user data...');
      await AppUtility.clearUserInfo();
      log('✅ User data cleared');

      // Step 3: Navigate to login
      log('\n🔄 Step 3: Navigating to login screen...');
      Get.offAllNamed(AppRoutes.login);

      // Show message to user
      await Future.delayed(const Duration(milliseconds: 500));
      AppSnackbarStyles.showError(
        title: 'Session Expired',
        message: 'Your account is inactive. Please login again.',
      );

      log('✅ 401 handling completed');
      log('🚨' * 40);
    } catch (e) {
      log('❌ Error in 401 handling: $e');
      _hasNavigatedToLogin = false; // Reset on error
    } finally {
      _is401Handling = false;
    }
  }
}
