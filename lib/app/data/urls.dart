class Networkutility {
  static String baseUrl =
      "https://seekhelp.in/rudra/"; //live = https://surveys.rudraresearch.in/ staging = https://seekhelp.in/rudra/

  static String login = "${baseUrl}get_app_login_api";
  static int loginApi = 1;
  static String getTeamList = "${baseUrl}get_team_data_api";
  static int getTeamListApi = 2;
  static String getTeamMemberList =
      "${baseUrl}get_team_details_according_to_team_id_api";
  static int getTeamMemberListApi = 3;
  static String getTeamMemberDetail = "${baseUrl}get_team_member_profile_api";
  static int getTeamMemberDetailApi = 4;
  static String getUser = "${baseUrl}get_manager_profile_api";
  static int getUserApi = 5;
  static String addExecutive = "${baseUrl}set_member_by_manager_api";
  static int addExecutiveApi = 6;
  static String notifications = "${baseUrl}get_user_notifications_api";
  static int notificationsApi = 7;

  static String getLiveSurveyList = "${baseUrl}get_survey_title_name_api";
  static int getLiveSurveyListApi = 8;
  static String getSurveyDetail =
      "${baseUrl}get_data_according_to_survey_id_api";
  static int getSurveyDetailApi = 9;
  static String getArea =
      "${baseUrl}get_village_area_according_to_survey_id_api";
  static int getAreaApi = 10;

  static String setSurvey = "${baseUrl}set_survey_api";
  static int setSurveyApi = 11;
  static String getQustions = "${baseUrl}get_questions_and_options_api";
  static int getQustionsApi = 12;
  static String submitQuestionAnswer =
      "${baseUrl}save_survey_questions_answers";
  static int submitQuestionAnswerApi = 13;
  static String getCast = "${baseUrl}get_cast_according_to_survey_id_api";
  static int getCastApi = 14;
  static String setInterviewerInfo = "${baseUrl}get_local_people_details";
  static int setInterviewerInfoApi = 15;
  static String getAssignSurveyTargetList =
      "${baseUrl}assign_survey_to_executives";
  static int getAssignSurveyTargetListApi = 16;
  static String setAssignSurveyTarget = "${baseUrl}set_survey_target";
  static int setAssignSurveyTargetApi = 17;
  static String getAllExecutive = "${baseUrl}get_all_execative";
  static int getAllExecutiveApi = 18;
  static String setExecutive = "${baseUrl}set_execative_to_team";
  static int setExecutiveApi = 19;
  static String uploadAudio = "${baseUrl}upload_audio_api";
  static int uploadAudioApi = 20;

  static String getMySurveyList = "${baseUrl}get_my_survey_api";
  static int getMySurveyListApi = 21;

  static String getDashboardCounter = "${baseUrl}dashboard_counter_api";
  static int getDashboardCounterApi = 22;

  static String getCompleteSurveyDetails =
      "${baseUrl}get_complete_survey_details";
  static int getCompleteSurveyDetailsApi = 23;

  static String setCompleteSurvey = "${baseUrl}set_complete_survey_api";
  static int setCompleteSurveyApi = 24;
  static String getMySurveySubmittedResponseList =
      "${baseUrl}get_response_data_acc_to_survey_id_and_user_id";
  static int getMySurveySubmittedResponseListApi = 25;
  static String getSurveyDetailAccToPeopleId =
      "${baseUrl}get_survey_detail_acc_to_people_id_and_survey_id";
  static int getSurveyDetailAccToPeopleIdApi = 26;
  static String getValidatorSurveyList =
      "${baseUrl}get_survey_list_detail_validator";
  static int getValidatorSurveyListApi = 27;
  static String getValidatorResponseList =
      "${baseUrl}get_response_data_acc_to_survey_id_and_validator_id";
  static int getValidatorResponseListApi = 28;
  static String saveQuestionCommentOfValidator =
      "${baseUrl}save_question_comment_of_validator";
  static int saveQuestionCommentOfValidatorApi = 29;
  static String finalSubmitSurveyByValidator =
      "${baseUrl}final_submit_survey_by_validator";
  static int finalSubmitSurveyByValidatorApi = 30;
  static String viewQuestionsDetailsForValidator =
      "${baseUrl}view_questions_details_for_validator";
  static int viewQuestionsDetailsForValidatorApi = 31;
  static String getValidatorMySurveyDetail =
      "${baseUrl}get_my_survey_detail_validator";
  static int getValidatorMySurveyDetailApi = 32;
  static String getExecutiveAccToSurveyId =
      "${baseUrl}get_execative_according_to_survey_id";
  static int getExecutiveAccToSurveyIdApi = 33;
  static String getAssemblyAccToSurveyId =
      "${baseUrl}get_assembly_acc_to_survey_id";
  static int getAssemblyAccToSurveyIdApi = 34;
  static String getWardAccToSurveyId = "${baseUrl}get_ward_acc_to_survey_id";
  static int getWardAccToSurveyIdApi = 35;
  static String getSurveyReport = "${baseUrl}get_survey_report_api";
  static int getSurveyReportApi = 36;
  static String getUserPerformance = "${baseUrl}get_user_performance_api";
  static int getUserPerformanceApi = 37;
  static String getMySurvey = "${baseUrl}get_my_survey_api";
  static int getMySurveyApi = 38;
  static String uploadUserImage = "${baseUrl}upload_user_image_api";
  static int uploadUserImageApi = 39;
  static String logout = "${baseUrl}logout_api";
  static int logoutApi = 40;
  static String getOtp = "${baseUrl}get_otp_api";
  static int getOtpApi = 41;
  static String validateOtp = "${baseUrl}verify_otp_api";
  static int validateOtpApi = 42;
  static String getSuperAdminDashboardCounter =
      "${baseUrl}super_admin_dashboard_counter_api";
  static int getSuperAdminDashboardCounterApi = 43;
  static String getSuperAdminLiveSurveyList =
      "${baseUrl}get_super_admin_survey_title_name_api";
  static int getSuperAdminLiveSurveyListApi = 44;
  static String getTeamMembersAccToSurvey =
      "${baseUrl}get_team_members_acc_to_survey_id";
  static int getTeamMembersAccToSurveyApi = 45;
  static String getAllSurvey = "${baseUrl}get_all_survey_api";
  static int getAllSurveyApi = 46;
  static String deviceCompleteInfo = "${baseUrl}get_device_complete_info_api";
  static int deviceCompleteInfoApi = 47;
  static String getTeamIdAccUserId = "${baseUrl}get_team_id_acc_user_id";
  static int getTeamIdAccUserIdApi = 48;
  static String addExecutiveFormData = "${baseUrl}set_member_by_manager_api";
  static int addExecutiveFormDataApi = 49;
}
