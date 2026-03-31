import 'package:get/get.dart';
import 'package:rudra/app/modules/Manager_module/survey_detail_multiple/survey_detail_multiple_binding.dart';
import 'package:rudra/app/modules/audio_recorder/audio_recorder_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_home/executive_home_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_my_survey/executive_my_survey_view.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_notification/executive_notification_view.dart';
import 'package:rudra/app/modules/executive_module/executive_profile/executive_profile_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_profile/executive_profile_view.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_profile_details/executive_profile_detail_view.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_detail_view.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_binding.dart';
import 'package:rudra/app/modules/executive_module/executive_survey_detail/executive_survey_question/executive_survey_question_binding.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_binding.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_detail_list/my_survey_detail_list_binding.dart';
import 'package:rudra/app/modules/manager_module/my_survey/my_survey_view.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_detail_list/my_team_detail_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/my_team_view.dart';
import 'package:rudra/app/modules/manager_module/my_team/team_member_detail/team_member_detail_binding.dart';
import 'package:rudra/app/modules/manager_module/my_team/team_member_detail/team_member_detail_view.dart';
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
import 'package:rudra/app/modules/validator_module/validator_start_survey_detail/validator_submit_survey/validator_submit_survey_form_view.dart';
import 'package:rudra/app/modules/validator_module/validator_submit_remark/validator_submit_remark_binding.dart';
import 'package:rudra/app/modules/validator_module/validator_submit_remark/validator_submit_remark_view.dart';
import 'package:rudra/app/widgets/no_internet_screen.dart';
import 'package:rudra/bottom_navigation/bottom_navigation_binding.dart';

import '../modules/executive_module/executive_home/executive_home_view.dart';
import '../modules/executive_module/executive_survey_detail/executive_survey_interviewer_view/executive_survey_interviewer_view.dart';
import '../modules/executive_module/executive_survey_detail/executive_survey_question/executive_survey_question_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/manager_module/add_executive/add_executive_binding.dart';
import '../modules/manager_module/add_executive/add_executive_view.dart';
import '../modules/manager_module/assign_executive/assign_executive_binding.dart';
import '../modules/manager_module/assign_executive/assign_executive_view.dart';
import '../modules/manager_module/assigned_survey_target/assigned_survey_target_binding.dart';
import '../modules/manager_module/assigned_survey_target/assigned_survey_target_view.dart';
import '../modules/manager_module/home/home_binding.dart';
import '../modules/manager_module/home/home_view.dart';
import '../modules/manager_module/my_survey/my_survey_detail_list/my_survey_deatil_list_view.dart';
import '../modules/manager_module/my_survey/my_survey_detail_list/my_survey_response_list/my_survey_response_binding.dart';
import '../modules/manager_module/my_survey/my_survey_detail_list/my_survey_response_list/my_survey_response_list.dart';
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
import '../modules/super_admin_module/home/super_admin_home_binding.dart';
import '../modules/super_admin_module/home/super_admin_home_view.dart';
import '../modules/super_admin_module/super_admin_all_surveys/super_admin_all_surveys_binding.dart';
import '../modules/super_admin_module/super_admin_all_surveys/super_admin_all_surveys_view.dart';
import '../modules/super_admin_module/super_admin_profile/super_admin_profile_binding.dart';
import '../modules/super_admin_module/super_admin_profile/super_admin_profile_view.dart';
import '../modules/super_admin_module/super_admin_profile_details/super_admin_profile_details_binding.dart';
import '../modules/super_admin_module/super_admin_profile_details/super_admin_profile_details_view.dart';
import '../modules/super_admin_module/super_admin_report/super_admin_report_binding.dart';
import '../modules/super_admin_module/super_admin_report/super_admin_report_view.dart';
import '../modules/super_admin_module/super_admin_survey_team_members/super_admin_survey_team_members_binding.dart';
import '../modules/super_admin_module/super_admin_survey_team_members/super_admin_survey_team_members_view.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String superAdminHome = '/super-admin-home';
  static const String superAdminAllSurveys = '/super-admin-all-surveys';
  static const String superAdminProfile = '/super-admin-profile';
  static const String superAdminProfileDetails = '/super-admin-profile-details';
  static const String superAdminSurveyTeamMembers =
      '/super-admin-survey-team-members';
  static const String superAdminReport = '/super-admin-report';
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
  static const String mySurveyResponse = '/mysurvey-response-list';
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
  static const String validatorSubmitRemark = '/validator-submit-remark';
  static const String validatorMySurvey = '/validator-my-survey';

  static const String validatorProfile = '/validator-my-profile';
  static const String validatorProfileDetail = '/validator-my-profile-detail';
  static const String validatorNotification = '/validator-notification';

  static const String noInternet = '/nointernet';
  static const String teamMemberDetail = '/team-member-detail';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
      transition: Transition.rightToLeft,
    ),
    // Add when login module is ready:
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminHome,
      page: () => const SuperAdminHomeView(),
      bindings: [
        SuperAdminHomeBinding(),
        BottomNavigationBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminProfile,
      page: () => const SuperAdminProfileView(),
      bindings: [
        SuperAdminProfileBinding(),
        BottomNavigationBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminProfileDetails,
      page: () => const SuperAdminProfileDetailsView(),
      binding: SuperAdminProfileDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminSurveyTeamMembers,
      page: () => const SuperAdminSurveyTeamMembersView(),
      binding: SuperAdminSurveyTeamMembersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminAllSurveys,
      page: () => const SuperAdminAllSurveysView(),
      bindings: [
        SuperAdminAllSurveysBinding(),
        BottomNavigationBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: superAdminReport,
      page: () => const SuperAdminReportView(),
      bindings: [
        SuperAdminReportBinding(),
        BottomNavigationBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: profileDetails,
      page: () => const ProfileDetailsView(),
      binding: ProfileDetailsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assignedSurveyTarget,
      page: () => const AssignedSurveyTargetView(),
      binding: AssignedSurveyTargetBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: assignExecutive,
      page: () => const AssignExecutiveView(),
      binding: AssignExecutiveBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addExecutive,
      page: () => const AddExecutiveView(),
      binding: AddExecutiveBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: surveyDetails,
      page: () => const SurveyDetailsView(),
      bindings: [
        SurveyDetailsBinding(),
        AudioRecorderBinding(),
        BottomNavigationBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: surveyQuestion,
      page: () => const SurveyQuestionView(),
      binding: SurveyQuestionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: surveyInterviewer,
      page: () => const SurveyInterviewerView(),
      bindings: [
        SurveyInterviewerBinding(),
        AudioRecorderBinding(),
      ],
      transition: Transition.rightToLeft,
    ),
    //My Report
    GetPage(
      name: myreport,
      page: () => const MyReportListView(),
      binding: MyReportListBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: myreportform,
      page: () => const MyReportFormView(),
      binding: ReportFormBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: myreportChart,
      page: () => const MyReportSurveyView(),
      binding: MyReportSurveyChartBinding(),
      transition: Transition.rightToLeft,
    ),

    //My Team
    GetPage(
      name: myteam,
      page: () => const MyTeamView(),
      binding: MyTeamBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: myteamdetail,
      page: () => const MyTeamDetailListView(),
      binding: MyTeamDetailBinding(),
      transition: Transition.rightToLeft,
    ),

    //My Survey
    GetPage(
      name: mySurvey,
      page: () => const MySurveyView(),
      binding: MySurveyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: mySurveyDetailList,
      page: () => const MySurveyDetailListView(),
      binding: MySurveyDetailListBinding(),
      transition: Transition.rightToLeft,
    ),
    //survey detail multiple
    GetPage(
      name: surveyDetailsPreview,
      page: () => const SurveyDetailsMultipleView(),
      binding: SurveyDetailMultipleBinding(),
      transition: Transition.rightToLeft,
    ),

    //<============================== Executive ==============================>
    GetPage(
      name: executiveHome,
      page: () => const ExecutiveHomeView(),
      binding: ExecutiveHomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executiveMySurvey,
      page: () => const ExecutiveMySurveyView(),
      binding: ExecutiveMySurveyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executiveSurveyDetail,
      page: () => const ExecutiveSurveyDetailView(),
      binding: ExecutiveSurveyDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executiveSurveyQuestion,
      page: () => const ExecutiveSurveyQuestionView(),
      binding: ExecutiveSurveyQuestionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executiveSurveyInterviewer,
      page: () => const ExecutiveSurveyInterviewerView(),
      binding: ExecutiveSurveyInterviewerBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executivProfile,
      page: () => const ExecutiveProfileView(),
      binding: ExecutiveProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: executivProfileDetail,
      page: () => const ExecutiveProfileDetailView(),
      binding: ExecutiveProfileDetailBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: executiveNotification,
      page: () => const ExecutiveNotificationView(),
      binding: ExecutiveNotificationBinding(),
      transition: Transition.rightToLeft,
    ),

    //<============================== Validaor ==============================>
    GetPage(
      name: validatorHome,
      page: () => const ValidatorHomeView(),
      binding: ValidatorHomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorStartSurveyList,
      page: () => const ValidatorStartSurveyListView(),
      binding: ValidatorStartSurveyListBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorStartSurveyDetail,
      page: () => const ValidatorStartSurveyDetailView(),
      binding: ValidatorStartSurveyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorSubmitSurvey,
      page: () => ValidatorSubmitSurveyFormView(),
      binding: ValidatorSubmitSurveyFormBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorSubmitRemark,
      page: () => const ValidatorSubmitRemarkView(),
      binding: ValidatorSubmitRemarkBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorMySurvey,
      page: () => const ValidatorMySurveyView(),
      binding: ValidatorMySurveyBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorProfile,
      page: () => const ValidatorProfileView(),
      binding: ValidatorProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorProfileDetail,
      page: () => const ValidatorProfileDetailView(),
      binding: ValidatorProfileDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: validatorNotification,
      page: () => const ValidatorNotificationView(),
      binding: ValidatorNotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    //no internet
    GetPage(
      name: noInternet,
      page: () => const NoInternetScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: teamMemberDetail,
      page: () => const TeamMemberDetailView(),
      binding: TeamMemberDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: mySurveyResponse,
      page: () => const MySurveyResponseList(),
      binding: MySurveyResponseBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
