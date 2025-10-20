class Networkutility {
  //https://seekhelp.in/tfd/
  //https://staginglink.org/tfd//lve
  static String baseUrl = "https://seekhelp.in/rudra/";

  static String login = "${baseUrl + "get_app_login_api"}";
  static int loginApi = 1;
  static String getTeamList =
      "${baseUrl + "get_team_data_api"}";
  static int getTeamListApi = 2;
  static String getTeamMemberList = "${baseUrl + "get_team_details_according_to_team_id_api"}";
  static int getTeamMemberListApi = 3;
  static String getTeamMemberDetail = "${baseUrl + "get_team_member_profile_api"}";
  static int getTeamMemberDetailApi = 4;
  static String getCompanyList = "${baseUrl + "get_completed_company_list"}";
  static int getCompanyListApi = 5;
  static String getPlantList = "${baseUrl + "get_completed_plant_list"}";
  static int getPlantListApi = 6;
  static String getSystemList = "${baseUrl + "get_completed_system_list"}";
  static int getSystemListApi = 7;
  static String logout = "${baseUrl + "post_app_logout"}";
  static int logoutApi = 8;
  static String forgotPassword = "${baseUrl + "forgot_password_api"}";
  static int forgotPasswordApi = 9;
  static String notifications =
      "${baseUrl + "get_completed_notification_list"}";
  static int notificationsApi = 10;

  // static String register = "${baseUrl + "registration"}";
  // static int registerApi = 1;
  // static String getStates = "${baseUrl + "get_states"}";
  // static int getStatesApi = 2;
  // static String getCity = "${baseUrl + "get_cities"}";
  // static int getCityApi = 3;
  // static String login = "${baseUrl + "get_app_login"}";
  // static int loginApi = 4;
}
