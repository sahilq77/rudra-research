import 'package:get/get.dart';

import '../modules/add_executive/add_executive_binding.dart';
import '../modules/add_executive/add_executive_view.dart';
import '../modules/assign_executive/assign_executive_binding.dart';
import '../modules/assign_executive/assign_executive_view.dart';
import '../modules/assigned_survey_target/assigned_survey_target_binding.dart';
import '../modules/assigned_survey_target/assigned_survey_target_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/notification/notification_binding.dart';
import '../modules/notification/notification_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/otp/otp_binding.dart';
import '../modules/otp/otp_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/profile_details/profile_details_binding.dart';
import '../modules/profile_details/profile_details_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/survey_details/survey_details_binding.dart';
import '../modules/survey_details/survey_details_view.dart';
import '../modules/survey_interviewer/survey_interviewer_binding.dart';
import '../modules/survey_interviewer/survey_interviewer_view.dart';
import '../modules/survey_question/survey_question_binding.dart';
import '../modules/survey_question/survey_question_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String profileDetails = '/profile-details';
  static const String notifications = '/notifications';
  static const String assignedSurveyTarget = '/assigned-survey-target';
  static const String assignExecutive = '/assign-executive';
  static const String addExecutive = '/add-executive';

  static const String surveyDetails = '/survey-details';
  static const String surveyQuestion = '/survey-question';
  static const String surveyInterviewer = '/survey-interviewer';
  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    // Add when login module is ready:
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: profileDetails,
      page: () => const ProfileDetailsView(),
      binding: ProfileDetailsBinding(),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: assignedSurveyTarget,
      page: () => const AssignedSurveyTargetView(),
      binding: AssignedSurveyTargetBinding(),
    ),
    GetPage(
      name: assignExecutive,
      page: () => const AssignExecutiveView(),
      binding: AssignExecutiveBinding(),
    ),
    GetPage(
      name: addExecutive,
      page: () => const AddExecutiveView(),
      binding: AddExecutiveBinding(),
    ),

    GetPage(
      name: surveyDetails,
      page: () => const SurveyDetailsView(),
      binding: SurveyDetailsBinding(),
    ),
    GetPage(
      name: surveyQuestion,
      page: () => const SurveyQuestionView(),
      binding: SurveyQuestionBinding(),
    ),
    GetPage(
      name: surveyInterviewer,
      page: () => const SurveyInterviewerView(),
      binding: SurveyInterviewerBinding(),
    ),
  ];
}
