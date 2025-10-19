import 'package:get/get.dart';
import 'package:rudra/app/modules/Manager_module/survey_detail_multiple/survey_detail_multiple_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_view.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_view.dart';
import 'package:rudra/app/modules/executive_module/executive_profile/executive_profile_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_profile/executive_profile_view.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_view.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_question/executive_survey_question_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_view.dart';
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
import 'package:rudra/app/modules/validator_module/validator_home/validator_home_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_home/validator_home_view.dart';
import 'package:rudra/app/modules/validator_module/validator_my_survey/validator_my_survey_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_my_survey/validator_my_survey_view.dart';
import 'package:rudra/app/modules/validator_module/validator_notification/validator_notification_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_notification/validator_notification_view.dart';
import 'package:rudra/app/modules/validator_module/validator_profile/validator_profile_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_profile/validator_profile_view.dart';
import 'package:rudra/app/modules/validator_module/validator_profile_details/validator_profile_detail_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_profile_details/validator_profile_detail_view.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey/validator_start_survey_list_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey/validator_start_survey_list_view.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_start_survey_detail_view.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_controller.dart';
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_view.dart';
import 'package:rudra/app/widgets/no_internet_screen.dart';

import '../modules/executive_module/executive_home/executive_home_view.dart';
import '../modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_view.dart';
import '../modules/executive_module/executive_survey_detail/executive_survey_question/executive_survey_question_view.dart';
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

  //<============================== Executive ==============================>

  static const String executiveHome = '/executive-home';
  static const String executiveMySurvey = '/executive-my-survey';
  static const String executiveSurveyDetail = '/executive-survey-detail';
  static const String executiveSurveyQuestion = '/executive-survey-question';
  static const String executiveSurveyInterviewer =
      '/executive-survey-interviewer';
  static const String executivProfile = '/executive-profile';
  static const String executivProfileDetail = '/executive-profile-detail';
  static const String executiveNotification = '/executive-notification';

  //<============================== Validator ==============================>

  static const String validatorHome = '/validator-home';
  static const String validatorStartSurveyList = '/validator-start-survey-list';
  static const String validatorStartSurveyDetail =
      '/validator-start-survey-detail';
  static const String validatorSubmitSurvey = '/validator-submit';
  static const String validatorMySurvey = '/validator-my-survey';

  static const String validatorProfile = '/validator-my-profile';
  static const String validatorProfileDetail = '/validator-my-profile-detail';
static const String validatorNotification = '/validator-notification';


  static const String noInternet = '/nointernet';

  

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
      binding: SurveyDetailMultipleBinding(),
    ),

    //<============================== Executive ==============================>
    GetPage(
      name: executiveHome,
      page: () => ExecutiveHomeView(),
      binding: ExecutiveHomeBinding(),
    ),
    GetPage(
      name: executiveMySurvey,
      page: () => ExecutiveMySurveyView(),
      binding: ExecutiveMySurveyBinding(),
    ),
    GetPage(
      name: executiveSurveyDetail,
      page: () => ExecutiveSurveyDetailView(),
      binding: ExecutiveSurveyDetailBinding(),
    ),
    GetPage(
      name: executiveSurveyQuestion,
      page: () => ExecutiveSurveyQuestionView(),
      binding: ExecutiveSurveyQuestionBinding(),
    ),
    GetPage(
      name: executiveSurveyInterviewer,
      page: () => ExecutiveSurveyInterviewerView(),
      binding: ExecutiveSurveyInterviewerBinding(),
    ),
    GetPage(
      name: executivProfile,
      page: () => ExecutiveProfileView(),
      binding: ExecutiveProfileBinding(),
    ),
   GetPage(
      name: executivProfileDetail,
      page: () => ExecutiveProfileDetailView(),
      binding: ExecutiveProfileDetailBinding(),
    ),

    
    GetPage(
      name: executiveNotification,
      page: () => ExecutiveNotificationView(),
      binding: ExecutiveNotificationBinding(),
    ),

    //<============================== Validaor ==============================>
    GetPage(
      name: validatorHome,
      page: () => ValidatorHomeView(),
      binding: ValidatorHomeBinding(),
    ),
    GetPage(
      name: validatorStartSurveyList,
      page: () => ValidatorStartSurveyListView(),
      binding: ValidatorStartSurveyListBinding(),
    ),
    GetPage(
      name: validatorStartSurveyDetail,
      page: () => ValidatorStartSurveyDetailView(),
      binding: ValidatorStartSurveyBinding(),
    ),
    GetPage(
      name: validatorSubmitSurvey,
      page: () => ValidatorSubmitSurveyFormView(),
      binding: ValidatorSubmitSurveyFormBinding(),
    ),
    GetPage(
      name: validatorMySurvey,
      page: () => ValidatorMySurveyView(),
      binding: ValidatorMySurveyBinding(),
    ),
    GetPage(
      name: validatorProfile,
      page: () => ValidatorProfileView(),
      binding: ValidatorProfileBinding(),
    ),
    GetPage(
      name: validatorProfileDetail,
      page: () => ValidatorProfileDetailView(),
      binding: ValidatorProfileDetailBinding(),
    ),
     GetPage(
      name: validatorNotification,
      page: () => ValidatorNotificationView(),
      binding: ValidatorNotificationBinding(),
    ),
//no internet
GetPage(
      name: noInternet,
      page: () => NoInternetScreen(),
      transition: Transition.fadeIn,
    ),
    
  ];
}
