// To parse this JSON data, do
//
//     final getAreaResponse = getAreaResponseFromJson(jsonString);

import 'dart:convert';

List<GetAreaResponse> getAreaResponseFromJson(String str) =>
    List<GetAreaResponse>.from(
        json.decode(str).map((x) => GetAreaResponse.fromJson(x)));

String getAreaResponseToJson(List<GetAreaResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAreaResponse {
  String status;
  String message;
  List<AreaData> data;

  GetAreaResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetAreaResponse.fromJson(Map<String, dynamic> json) =>
      GetAreaResponse(
        status: json["status"],
        message: json["message"],
        data:
            List<AreaData>.from(json["data"].map((x) => AreaData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class AreaData {
  String villageAreaId;
  String areaName;
  String? zpWardId;
  String? wardName;

  AreaData({
    required this.villageAreaId,
    required this.areaName,
    this.zpWardId,
    this.wardName,
  });

  factory AreaData.fromJson(Map<String, dynamic> json) => AreaData(
        villageAreaId: json["village_area_id"] ?? "",
        areaName: json["area_name"] ?? "",
        zpWardId: json["zp_ward_id"],
        wardName: json["ward_name"],
      );

  Map<String, dynamic> toJson() => {
        "village_area_id": villageAreaId,
        "area_name": areaName,
        "zp_ward_id": zpWardId,
        "ward_name": wardName,
      };
}

class ZpWardData {
  String zpWardId;
  String wardName;
  String? assemblyId;

  ZpWardData({
    required this.zpWardId,
    required this.wardName,
    this.assemblyId,
  });

  factory ZpWardData.fromJson(Map<String, dynamic> json) => ZpWardData(
        zpWardId: json["zp_ward_id"] ?? "",
        wardName: json["ward_name"] ?? "",
        assemblyId: json["assembly_id"],
      );

  Map<String, dynamic> toJson() => {
        "zp_ward_id": zpWardId,
        "ward_name": wardName,
        "assembly_id": assemblyId,
      };
}

class AssemblyData {
  String assemblyId;
  String assemblyName;

  AssemblyData({
    required this.assemblyId,
    required this.assemblyName,
  });

  factory AssemblyData.fromJson(Map<String, dynamic> json) => AssemblyData(
        assemblyId: json["assembly_id"] ?? "",
        assemblyName: json["assembly_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "assembly_id": assemblyId,
        "assembly_name": assemblyName,
      };
}
