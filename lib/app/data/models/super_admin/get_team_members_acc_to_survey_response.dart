import 'dart:convert';

List<GetTeamMembersAccToSurveyResponse> getTeamMembersAccToSurveyResponseFromJson(
    String str) {
  final jsonData = json.decode(str);
  return List<GetTeamMembersAccToSurveyResponse>.from(
    jsonData.map((x) => GetTeamMembersAccToSurveyResponse.fromJson(x)),
  );
}

class GetTeamMembersAccToSurveyResponse {
  String status;
  String message;
  int totalCount;
  int limit;
  int offset;
  List<TeamMemberData> data;

  GetTeamMembersAccToSurveyResponse({
    required this.status,
    required this.message,
    required this.totalCount,
    required this.limit,
    required this.offset,
    required this.data,
  });

  factory GetTeamMembersAccToSurveyResponse.fromJson(Map<String, dynamic> json) {
    return GetTeamMembersAccToSurveyResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      totalCount: int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
      limit: int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
      offset: int.tryParse(json['offset']?.toString() ?? '0') ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TeamMemberData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TeamMemberData {
  String userId;
  String firstName;
  String lastName;
  String roleId;
  String role;
  String teamName;
  String teamId;
  String totalAssigned;
  String totalResponses;

  TeamMemberData({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.roleId,
    required this.role,
    required this.teamName,
    required this.teamId,
    required this.totalAssigned,
    required this.totalResponses,
  });

  factory TeamMemberData.fromJson(Map<String, dynamic> json) {
    return TeamMemberData(
      userId: json['user_id']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      roleId: json['role_id']?.toString() ?? '',
      role: json['role'] ?? '',
      teamName: json['team_name'] ?? '',
      teamId: json['team_id']?.toString() ?? '',
      totalAssigned: json['total_assigned']?.toString() ?? '0',
      totalResponses: json['total_responses']?.toString() ?? '0',
    );
  }

  String get fullName => '$firstName $lastName'.trim();
}
