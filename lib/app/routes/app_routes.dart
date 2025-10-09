import 'package:get/get.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_view.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_binding.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_detail_list_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_detail_list/my_team_detail_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_view.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_binding.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_list_view.dart';
import 'package:rudra/app/modules/manager_module/myreport/my_report_survey_view.dart/my_report_survey_view.dart'
    show MyReportSurveyView;

import 'package:rudra/app/modules/manager_module/myreport/my_report_view/my_report_form_view.dart';

import '../modules/manager_module/add_executive/add_executive_binding.dart';
import '../modules/manager_module/add_executive/add_executive_view.dart';
import '../modules/manager_module/assign_executive/assign_executive_binding.dart';
import '../modules/manager_module/assign_executive/assign_executive_view.dart';
import '../modules/manager_module/assigned_survey_target/assigned_survey_target_binding.dart';
import '../modules/manager_module/assigned_survey_target/assigned_survey_target_view.dart';
import '../modules/manager_module/home/home_binding.dart';
import '../modules/manager_module/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/manager_module/my_survey/my_survey_detail_list/my_survey_deatil_list_view.dart';
import '../modules/manager_module/my_team/my_team_detail_list/my_team_detail_list_view.dart';
import '../modules/manager_module/myreport/my_report_survey_view.dart/my_report_survey_chart_binding.dart';

import '../modules/manager_module/myreport/my_report_view/report_form_binding.dart';
import '../modules/manager_module/notification/notification_binding.dart';
import '../modules/manager_module/notification/notification_view.dart';
import '../modules/manager_module/onboarding/onboarding_binding.dart';
import '../modules/manager_module/onboarding/onboarding_view.dart';
import '../modules/manager_module/otp/otp_binding.dart';
import '../modules/manager_module/otp/otp_view.dart';
import '../modules/manager_module/profile/profile_binding.dart';
import '../modules/manager_module/profile/profile_view.dart';
import '../modules/manager_module/profile_details/profile_details_binding.dart';
import '../modules/manager_module/profile_details/profile_details_view.dart';
import '../modules/manager_module/splash/splash_view.dart';
import '../modules/manager_module/survey_detail_multiple/survey_details_multiple_view.dart';
import '../modules/manager_module/survey_details/survey_details_binding.dart';
import '../modules/manager_module/survey_details/survey_details_view.dart';
import '../modules/manager_module/survey_interviewer/survey_interviewer_binding.dart';
import '../modules/manager_module/survey_interviewer/survey_interviewer_view.dart';
import '../modules/manager_module/survey_question/survey_question_binding.dart';
import '../modules/manager_module/survey_question/survey_question_view.dart';

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
  static const String mySurvey = '/mysurvey';
  static const String mySurveyDetailList = '/mysurvey-detail-list';

  static const String surveyDetailsPreview = '/survey-details-preview';

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
    //My Report
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

    //My Team
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

    //My Survey
    GetPage(
      name: mySurvey,
      page: () => const MySurveyView(),
      binding: MySurveyBinding(),
    ),
    GetPage(
      name: mySurveyDetailList,
      page: () => const MySurveyDeatilListView(),
      binding: MySurveyDetailListBinding(),
    ),
    //survey detail multiple
    GetPage(
      name: surveyDetailsPreview,
      page: () => SurveyDetailsMultipleView(),
      binding: SurveyDetailsBinding(),
    ),
  ];
}
