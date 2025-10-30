// To parse this JSON data, do
//
//     final setExecutiveResponse = setExecutiveResponseFromJson(jsonString);

import 'dart:convert';

List<SetExecutiveResponse> setExecutiveResponseFromJson(String str) =>
    List<SetExecutiveResponse>.from(
      json.decode(str).map((x) => SetExecutiveResponse.fromJson(x)),
    );

String setExecutiveResponseToJson(List<SetExecutiveResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SetExecutiveResponse {
  String status;
  String message;
  Data data;

  SetExecutiveResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SetExecutiveResponse.fromJson(Map<String, dynamic> json) =>
      SetExecutiveResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String teamId;
  String totalTeamMembers;

  Data({required this.teamId, required this.totalTeamMembers});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    teamId: json["team_id"] ?? "",
    totalTeamMembers: json["total_team_members"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "team_id": teamId,
    "total_team_members": totalTeamMembers,
  };
}
