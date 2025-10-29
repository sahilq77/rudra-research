// To parse this JSON data, do
//
//     final getSetInterviewerInfoResponse = getSetInterviewerInfoResponseFromJson(jsonString);

import 'dart:convert';

List<GetSetInterviewerInfoResponse> getSetInterviewerInfoResponseFromJson(
  String str,
) => List<GetSetInterviewerInfoResponse>.from(
  json.decode(str).map((x) => GetSetInterviewerInfoResponse.fromJson(x)),
);

String getSetInterviewerInfoResponseToJson(
  List<GetSetInterviewerInfoResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSetInterviewerInfoResponse {
  String status;
  String message;
  Data data;

  GetSetInterviewerInfoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSetInterviewerInfoResponse.fromJson(Map<String, dynamic> json) =>
      GetSetInterviewerInfoResponse(
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
  String id;
  String surveyAppSideId;
  String name;
  String age;
  String gender;
  String mobNumber;
  String castId;

  Data({
    required this.id,
    required this.surveyAppSideId,
    required this.name,
    required this.age,
    required this.gender,
    required this.mobNumber,
    required this.castId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? "",
    surveyAppSideId: json["survey_app_side_id"] ?? "",
    name: json["name"] ?? "",
    age: json["age"] ?? "",
    gender: json["gender"] ?? "",
    mobNumber: json["mob_number"] ?? "",
    castId: json["cast_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "survey_app_side_id": surveyAppSideId,
    "name": name,
    "age": age,
    "gender": gender,
    "mob_number": mobNumber,
    "cast_id": castId,
  };
}
