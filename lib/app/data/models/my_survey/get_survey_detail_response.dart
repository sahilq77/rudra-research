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
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: SurveyDetailData.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class SurveyDetailData {
  SurveyInfoDetail surveyInfo;
  List<QuestionAnswer> questionsAndAnswers;
  PeopleDetails peopleDetails;
  AudioDetails audioDetails;

  SurveyDetailData({
    required this.surveyInfo,
    required this.questionsAndAnswers,
    required this.peopleDetails,
    required this.audioDetails,
  });

  factory SurveyDetailData.fromJson(Map<String, dynamic> json) =>
      SurveyDetailData(
        surveyInfo: SurveyInfoDetail.fromJson(json["survey_info"] ?? {}),
        questionsAndAnswers: List<QuestionAnswer>.from(
          (json["questions_and_answers"] ?? [])
              .map((x) => QuestionAnswer.fromJson(x)),
        ),
        peopleDetails: PeopleDetails.fromJson(json["people_details"] ?? {}),
        audioDetails: AudioDetails.fromJson(json["audio_details"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "survey_info": surveyInfo.toJson(),
        "questions_and_answers":
            List<dynamic>.from(questionsAndAnswers.map((x) => x.toJson())),
        "people_details": peopleDetails.toJson(),
        "audio_details": audioDetails.toJson(),
      };
}

class SurveyInfoDetail {
  String surveyId;
  String surveyTitle;
  String surveyDate;
  String surveyLanguage;
  String region;
  String regionId;
  String state;
  String stateId;
  String district;
  String districtId;
  String loksabha;
  String loksabhaId;
  String assembly;
  String assemblyId;
  String ward;
  String wardId;
  String villageArea;
  String villageAreaId;
  String team;
  String teamId;

  SurveyInfoDetail({
    required this.surveyId,
    required this.surveyTitle,
    required this.surveyDate,
    required this.surveyLanguage,
    required this.region,
    required this.regionId,
    required this.state,
    required this.stateId,
    required this.district,
    required this.districtId,
    required this.loksabha,
    required this.loksabhaId,
    required this.assembly,
    required this.assemblyId,
    required this.ward,
    required this.wardId,
    required this.villageArea,
    required this.villageAreaId,
    required this.team,
    required this.teamId,
  });

  factory SurveyInfoDetail.fromJson(Map<String, dynamic> json) =>
      SurveyInfoDetail(
        surveyId: json["survey_id"] ?? "",
        surveyTitle: json["survey_title"] ?? "",
        surveyDate: json["survey_date"] ?? "",
        surveyLanguage: json["survey_language"] ?? "",
        region: json["region"] ?? "",
        regionId: json["region_id"] ?? "",
        state: json["state"] ?? "",
        stateId: json["state_id"] ?? "",
        district: json["district"] ?? "",
        districtId: json["district_id"] ?? "",
        loksabha: json["loksabha"] ?? "",
        loksabhaId: json["loksabha_id"] ?? "",
        assembly: json["assembly"] ?? "",
        assemblyId: json["assembly_id"] ?? "",
        ward: json["ward"] ?? "",
        wardId: json["ward_id"] ?? "",
        villageArea: json["village_area"] ?? "",
        villageAreaId: json["village_area_id"] ?? "",
        team: json["team"] ?? "",
        teamId: json["team_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "survey_id": surveyId,
        "survey_title": surveyTitle,
        "survey_date": surveyDate,
        "survey_language": surveyLanguage,
        "region": region,
        "region_id": regionId,
        "state": state,
        "state_id": stateId,
        "district": district,
        "district_id": districtId,
        "loksabha": loksabha,
        "loksabha_id": loksabhaId,
        "assembly": assembly,
        "assembly_id": assemblyId,
        "ward": ward,
        "ward_id": wardId,
        "village_area": villageArea,
        "village_area_id": villageAreaId,
        "team": team,
        "team_id": teamId,
      };
}

class QuestionAnswer {
  String id;
  String surveyAppSideId;
  String questionId;
  String answerId;
  String? validatorId;
  String? validatorComment;
  String status;
  String isDeleted;
  String createdOn;
  String updatedOn;
  String question;
  String chosenOptionName;
  List<AnswerOption> allOptions;
  String? audioPath;

  QuestionAnswer({
    required this.id,
    required this.surveyAppSideId,
    required this.questionId,
    required this.answerId,
    this.validatorId,
    this.validatorComment,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.question,
    required this.chosenOptionName,
    required this.allOptions,
    this.audioPath,
  });

  factory QuestionAnswer.fromJson(Map<String, dynamic> json) => QuestionAnswer(
        id: json["id"] ?? "",
        surveyAppSideId: json["survey_app_side_id"] ?? "",
        questionId: json["question_id"] ?? "",
        answerId: json["answer_id"] ?? "",
        validatorId: json["validator_id"],
        validatorComment: json["validator_comment"],
        status: json["status"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        createdOn: json["created_on"] ?? "",
        updatedOn: json["updated_on"] ?? "",
        question: json["question"] ?? "",
        chosenOptionName: json["chosen_option_name"] ?? "",
        allOptions: List<AnswerOption>.from(
          (json["all_options"] ?? []).map((x) => AnswerOption.fromJson(x)),
        ),
        audioPath: json["audio_path"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "survey_app_side_id": surveyAppSideId,
        "question_id": questionId,
        "answer_id": answerId,
        "validator_id": validatorId,
        "validator_comment": validatorComment,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn,
        "question": question,
        "chosen_option_name": chosenOptionName,
        "all_options": List<dynamic>.from(allOptions.map((x) => x.toJson())),
        "audio_path": audioPath,
      };
}

class AnswerOption {
  String optionId;
  String choiceText;
  String? textFieldType;
  String? answerType;

  AnswerOption({
    required this.optionId,
    required this.choiceText,
    this.textFieldType,
    this.answerType,
  });

  factory AnswerOption.fromJson(Map<String, dynamic> json) => AnswerOption(
        optionId: json["option_id"] ?? "",
        choiceText: json["choice_text"] ?? "",
        textFieldType: json["text_field_type"],
        answerType: json["answer_type"],
      );

  Map<String, dynamic> toJson() => {
        "option_id": optionId,
        "choice_text": choiceText,
        "text_field_type": textFieldType,
        "answer_type": answerType,
      };
}

class PeopleDetails {
  String surveyAppSideId;
  String name;
  String mobileNo;
  String age;
  String gender;
  String castId;
  String? castName;
  String submittedAt;

  PeopleDetails({
    required this.surveyAppSideId,
    required this.name,
    required this.mobileNo,
    required this.age,
    required this.gender,
    required this.castId,
    this.castName,
    required this.submittedAt,
  });

  factory PeopleDetails.fromJson(Map<String, dynamic> json) => PeopleDetails(
        surveyAppSideId: json["survey_app_side_id"] ?? "",
        name: json["name"] ?? "",
        mobileNo: json["mobile_no"] ?? "",
        age: json["age"] ?? "",
        gender: json["gender"] ?? "",
        castId: json["cast_id"] ?? "",
        castName: json["cast_name"],
        submittedAt: json["submitted_at"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "survey_app_side_id": surveyAppSideId,
        "name": name,
        "mobile_no": mobileNo,
        "age": age,
        "gender": gender,
        "cast_id": castId,
        "cast_name": castName,
        "submitted_at": submittedAt,
      };
}

class AudioDetails {
  String surveyAppSideId;
  String? audio;
  String? audioUrl;

  AudioDetails({
    required this.surveyAppSideId,
    this.audio,
    this.audioUrl,
  });

  factory AudioDetails.fromJson(Map<String, dynamic> json) => AudioDetails(
        surveyAppSideId: json["survey_app_side_id"] ?? "",
        audio: json["audio"],
        audioUrl: json["audio_url"],
      );

  Map<String, dynamic> toJson() => {
        "survey_app_side_id": surveyAppSideId,
        "audio": audio,
        "audio_url": audioUrl,
      };
}
