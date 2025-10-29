// To parse this JSON data, do
//
//     final getSurveyDetailResponse = getSurveyDetailResponseFromJson(jsonString);

import 'dart:convert';

List<GetSurveyDetailResponse> getSurveyDetailResponseFromJson(String str) =>
    List<GetSurveyDetailResponse>.from(
      json.decode(str).map((x) => GetSurveyDetailResponse.fromJson(x)),
    );

String getSurveyDetailResponseToJson(List<GetSurveyDetailResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSurveyDetailResponse {
  String status;
  String message;
  SurveyDetailData data;

  GetSurveyDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSurveyDetailResponse.fromJson(Map<String, dynamic> json) =>
      GetSurveyDetailResponse(
        status: json["status"],
        message: json["message"],
        data: SurveyDetailData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class SurveyDetailData {
  String region;
  String regionId;
  String stateName;
  String stateId;
  String districtName;
  String districtId;
  String loksabhaName;
  String loksabhaId;
  String assemblyName;
  String assemblyId;
  String wardName;
  String zpWardId;
  String teamName;
  String teamId;

  SurveyDetailData({
    required this.region,
    required this.regionId,
    required this.stateName,
    required this.stateId,
    required this.districtName,
    required this.districtId,
    required this.loksabhaName,
    required this.loksabhaId,
    required this.assemblyName,
    required this.assemblyId,
    required this.wardName,
    required this.zpWardId,
    required this.teamName,
    required this.teamId,
  });

  factory SurveyDetailData.fromJson(Map<String, dynamic> json) =>
      SurveyDetailData(
        region: json["region"] ?? "",
        regionId: json["region_id"] ?? "",
        stateName: json["state_name"] ?? "",
        stateId: json["state_id"] ?? "",
        districtName: json["district_name"] ?? "",
        districtId: json["district_id"] ?? "",
        loksabhaName: json["loksabha_name"] ?? "",
        loksabhaId: json["loksabha_id"] ?? "",
        assemblyName: json["assembly_name"] ?? "",
        assemblyId: json["assembly_id"] ?? "",
        wardName: json["ward_name"] ?? "",
        zpWardId: json["zp_ward_id"] ?? "",
        teamName: json["team_name"] ?? "",
        teamId: json["team_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
    "region": region,
    "region_id": regionId,
    "state_name": stateName,
    "state_id": stateId,
    "district_name": districtName,
    "district_id": districtId,
    "loksabha_name": loksabhaName,
    "loksabha_id": loksabhaId,
    "assembly_name": assemblyName,
    "assembly_id": assemblyId,
    "ward_name": wardName,
    "zp_ward_id": zpWardId,
    "team_name": teamName,
    "team_id": teamId,
  };
}
