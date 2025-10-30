class Networkutility {
  //https://seekhelp.in/tfd/
  //https://staginglink.org/tfd//lve
  static String baseUrl = "https://seekhelp.in/rudra/";

  static String login = "${baseUrl + "get_app_login_api"}";
  static int loginApi = 1;
  static String getTeamList = "${baseUrl + "get_team_data_api"}";
  static int getTeamListApi = 2;
  static String getTeamMemberList =
      "${baseUrl + "get_team_details_according_to_team_id_api"}";
  static int getTeamMemberListApi = 3;
  static String getTeamMemberDetail =
      "${baseUrl + "get_team_member_profile_api"}";
  static int getTeamMemberDetailApi = 4;
  static String getUser = "${baseUrl + "get_manager_profile_api"}";
  static int getUserApi = 5;
  static String addExecutive = "${baseUrl + "set_member_by_manager_api"}";
  static int addExecutiveApi = 6;
  static String notifications = "${baseUrl + "get_user_notifications_api"}";
  static int notificationsApi = 7;

  static String getLiveSurveyList = "${baseUrl + "get_survey_title_name_api"}";
  static int getLiveSurveyListApi = 8;
  static String getSurveyDetail =
      "${baseUrl + "get_data_according_to_survey_id_api"}";
  static int getSurveyDetailApi = 9;
  static String getArea =
      "${baseUrl + "get_village_area_according_to_survey_id_api"}";
  static int getAreaApi = 10;

  static String setSurvey = "${baseUrl + "set_survey_api"}";
  static int setSurveyApi = 11;
  static String getQustions = "${baseUrl + "get_questions_and_options_api"}";
  static int getQustionsApi = 12;
  static String submitQuestionAnswer =
      "${baseUrl + "save_survey_questions_answers"}";
  static int submitQuestionAnswerApi = 13;
  static String getCast =
      "${baseUrl + "get_cast_according_to_survey_id_api"}";
  static int getCastApi = 14;
  static String setInterviewerInfo =
      "${baseUrl + "get_local_people_details"}";
  static int setInterviewerInfoApi = 15;
  static String getAssignSurveyTargetList =
      "${baseUrl + "assign_survey_to_executives"}";
  static int getAssignSurveyTargetListApi = 16;
  


  

  // static String logout = "${baseUrl + "post_app_logout"}";
  // static int logoutApi = 8;
  // static String forgotPassword = "${baseUrl + "forgot_password_api"}";
  // static int forgotPasswordApi = 9;

  // static String register = "${baseUrl + "registration"}";
  // static int registerApi = 1;
  // static String getStates = "${baseUrl + "get_states"}";
  // static int getStatesApi = 2;
  // static String getCity = "${baseUrl + "get_cities"}";
  // static int getCityApi = 3;
  // static String login = "${baseUrl + "get_app_login"}";
  // static int loginApi = 4;
}
