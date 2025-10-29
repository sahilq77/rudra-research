// To parse this JSON data, do
//
//     final getSetServeyResponse = getSetServeyResponseFromJson(jsonString);

import 'dart:convert';

List<GetSetServeyResponse> getSetServeyResponseFromJson(String str) => List<GetSetServeyResponse>.from(json.decode(str).map((x) => GetSetServeyResponse.fromJson(x)));

String getSetServeyResponseToJson(List<GetSetServeyResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSetServeyResponse {
    String status;
    String message;
    Data data;

    GetSetServeyResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetSetServeyResponse.fromJson(Map<String, dynamic> json) => GetSetServeyResponse(
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
    String surveyAppSideId;

    Data({
        required this.surveyAppSideId,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        surveyAppSideId: json["survey_app_side_id"]??"",
    );

    Map<String, dynamic> toJson() => {
        "survey_app_side_id": surveyAppSideId,
    };
}
