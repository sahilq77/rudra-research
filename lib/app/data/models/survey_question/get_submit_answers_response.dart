// To parse this JSON data, do
//
//     final getSubmitAnswersResponse = getSubmitAnswersResponseFromJson(jsonString);

import 'dart:convert';

List<GetSubmitAnswersResponse> getSubmitAnswersResponseFromJson(String str) => List<GetSubmitAnswersResponse>.from(json.decode(str).map((x) => GetSubmitAnswersResponse.fromJson(x)));

String getSubmitAnswersResponseToJson(List<GetSubmitAnswersResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSubmitAnswersResponse {
    String status;
    String message;
    Data data;

    GetSubmitAnswersResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetSubmitAnswersResponse.fromJson(Map<String, dynamic> json) => GetSubmitAnswersResponse(
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
    int totalAnswersSaved;

    Data({
        required this.totalAnswersSaved,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalAnswersSaved: json["total_answers_saved"]??0,
    );

    Map<String, dynamic> toJson() => {
        "total_answers_saved": totalAnswersSaved,
    };
}
