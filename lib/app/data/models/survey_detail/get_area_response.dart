// To parse this JSON data, do
//
//     final getAreaResponse = getAreaResponseFromJson(jsonString);

import 'dart:convert';

List<GetAreaResponse> getAreaResponseFromJson(String str) => List<GetAreaResponse>.from(json.decode(str).map((x) => GetAreaResponse.fromJson(x)));

String getAreaResponseToJson(List<GetAreaResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetAreaResponse {
    String status;
    String message;
    List<AreaData> data;

    GetAreaResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetAreaResponse.fromJson(Map<String, dynamic> json) => GetAreaResponse(
        status: json["status"],
        message: json["message"],
        data: List<AreaData>.from(json["data"].map((x) => AreaData.fromJson(x))),
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

    AreaData({
        required this.villageAreaId,
        required this.areaName,
    });

    factory AreaData.fromJson(Map<String, dynamic> json) => AreaData(
        villageAreaId: json["village_area_id"]??"",
        areaName: json["area_name"]??"",
    );

    Map<String, dynamic> toJson() => {
        "village_area_id": villageAreaId,
        "area_name": areaName,
    };
}
