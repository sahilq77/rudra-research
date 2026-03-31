import 'dart:convert';

List<GetTeamIdResponse> getTeamIdResponseFromJson(String str) =>
    List<GetTeamIdResponse>.from(
      json.decode(str).map((x) => GetTeamIdResponse.fromJson(x)),
    );

class GetTeamIdResponse {
  final String status;
  final String message;
  final List<TeamData> data;

  GetTeamIdResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetTeamIdResponse.fromJson(Map<String, dynamic> json) {
    return GetTeamIdResponse(
      status: json['status']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TeamData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TeamData {
  final String teamId;
  final String teamName;
  final String userRole;

  TeamData({
    required this.teamId,
    required this.teamName,
    required this.userRole,
  });

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      teamId: json['team_id']?.toString() ?? '',
      teamName: json['team_name']?.toString() ?? '',
      userRole: json['user_role']?.toString() ?? '',
    );
  }
}
