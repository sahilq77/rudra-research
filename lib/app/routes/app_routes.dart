import 'package:get/get.dart';
import 'package:rudra/app/modules/my_team/my_team_binding.dart';
import 'package:rudra/app/modules/my_team/my_team_detail_list/my_team_detail_binding.dart';
import 'package:rudra/app/modules/my_team/my_team_view.dart';
import 'package:rudra/app/modules/myreport/my_report_list_binding.dart';
import 'package:rudra/app/modules/myreport/my_report_list_view.dart';
import 'package:rudra/app/modules/myreport/my_report_survey_view.dart/my_report_survey_view.dart'
    show MyReportSurveyView;

import 'package:rudra/app/modules/myreport/my_report_view/my_report_form_view.dart';

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
import '../modules/my_team/my_team_detail_list/my_team_detail_list_view.dart';
import '../modules/myreport/my_report_survey_view.dart/my_report_survey_chart_binding.dart';

import '../modules/myreport/my_report_view/report_form_binding.dart';
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
  static const String myreport = '/myreport-list';
  static const String myreportform = '/myreport-form';
  static const String myreportChart = '/myreport-chart';
  static const String myteam = '/myteam';
 static const String myteamdetail = '/myteam-detail';
  

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(name: otp, page: () => const OtpView(), binding: OtpBinding()),
    // Add when login module is ready:
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(name: home, page: () => const HomeView(), binding: HomeBinding()),
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
    GetPage(
      name: myreport,
      page: () => const MyReportListView(),
      binding: MyReportListBinding(),
    ),
    GetPage(
      name: myreportform,
      page: () => const MyReportFormView(),
      binding: ReportFormBinding(),
    ),
    GetPage(
      name: myreportChart,
      page: () => const MyReportSurveyView(),
      binding: MyReportSurveyChartBinding(),
    ),
    GetPage(
      name: myteam,
      page: () => const MyTeamView(),
      binding: MyTeamBinding(),
    ),
 GetPage(
      name: myteamdetail,
      page: () => const MyTeamDetailListView(),
      binding: MyTeamDetailBinding(),
    ),
    
  ];
}
