import 'dart:convert';

List<GetCompleteSurveyDetailsResponse> getCompleteSurveyDetailsResponseFromJson(
  String str,
) =>
    List<GetCompleteSurveyDetailsResponse>.from(
      json.decode(str).map((x) => GetCompleteSurveyDetailsResponse.fromJson(x)),
    );

String getCompleteSurveyDetailsResponseToJson(
  List<GetCompleteSurveyDetailsResponse> data,
) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCompleteSurveyDetailsResponse {
  String status;
  String message;
  CompleteSurveyData data;

  GetCompleteSurveyDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetCompleteSurveyDetailsResponse.fromJson(
          Map<String, dynamic> json) =>
      GetCompleteSurveyDetailsResponse(
        status: json["status"],
        message: json["message"],
        data: CompleteSurveyData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
      };
}

class CompleteSurveyData {
  SurveyDetails surveyDetails;

  CompleteSurveyData({
    required this.surveyDetails,
  });

  factory CompleteSurveyData.fromJson(Map<String, dynamic> json) =>
      CompleteSurveyData(
        surveyDetails: SurveyDetails.fromJson(json["survey_details"]),
      );

  Map<String, dynamic> toJson() => {
        "survey_details": surveyDetails.toJson(),
      };
}

class SurveyDetails {
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
  List<LanguageOption> language;
  List<ZpWard> zpWards;
  List<VillageArea> villageArea;
  List<SurveyQuestion> questions;
  List<CastOption> cast;
  DefaultSettings? defaultSettings;

  SurveyDetails({
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
    required this.language,
    required this.zpWards,
    required this.villageArea,
    required this.questions,
    required this.cast,
    this.defaultSettings,
  });

  factory SurveyDetails.fromJson(Map<String, dynamic> json) => SurveyDetails(
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
        language: List<LanguageOption>.from(
          json["language"].map((x) => LanguageOption.fromJson(x)),
        ),
        zpWards: json["zp_wards"] != null
            ? List<ZpWard>.from(
                json["zp_wards"].map((x) => ZpWard.fromJson(x)),
              )
            : [],
        villageArea: List<VillageArea>.from(
          json["village_area"].map((x) => VillageArea.fromJson(x)),
        ),
        questions: List<SurveyQuestion>.from(
          json["questions"].map((x) => SurveyQuestion.fromJson(x)),
        ),
        cast: List<CastOption>.from(
          json["cast"].map((x) => CastOption.fromJson(x)),
        ),
        defaultSettings: json["default_settings"] != null
            ? DefaultSettings.fromJson(json["default_settings"])
            : null,
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
        "language": List<dynamic>.from(language.map((x) => x.toJson())),
        "zp_wards": List<dynamic>.from(zpWards.map((x) => x.toJson())),
        "village_area": List<dynamic>.from(villageArea.map((x) => x.toJson())),
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
        "cast": List<dynamic>.from(cast.map((x) => x.toJson())),
        "default_settings": defaultSettings?.toJson(),
      };
}

class LanguageOption {
  String surveyLanguageId;
  String languageName;

  LanguageOption({
    required this.surveyLanguageId,
    required this.languageName,
  });

  factory LanguageOption.fromJson(Map<String, dynamic> json) => LanguageOption(
        surveyLanguageId: json["survey_language_id"] ?? "",
        languageName: json["language_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "survey_language_id": surveyLanguageId,
        "language_name": languageName,
      };
}

class ZpWard {
  String zpWardId;
  String wardName;

  ZpWard({
    required this.zpWardId,
    required this.wardName,
  });

  factory ZpWard.fromJson(Map<String, dynamic> json) => ZpWard(
        zpWardId: json["zp_ward_id"] ?? "",
        wardName: json["ward_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "zp_ward_id": zpWardId,
        "ward_name": wardName,
      };
}

class VillageArea {
  String villageAreaId;
  String areaName;
  String? zpWardId;
  String? wardName;

  VillageArea({
    required this.villageAreaId,
    required this.areaName,
    this.zpWardId,
    this.wardName,
  });

  factory VillageArea.fromJson(Map<String, dynamic> json) => VillageArea(
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

class SurveyQuestion {
  String surveyQuestionId;
  String questionId;
  String sequenceNumber;
  String questionLanguageId;
  String question;
  String questionType;
  String? parentQuestionId;
  String? parentOptionId;
  String? isConteginious;
  List<QuestionOption> options;

  SurveyQuestion({
    required this.surveyQuestionId,
    required this.questionId,
    required this.sequenceNumber,
    required this.questionLanguageId,
    required this.question,
    required this.questionType,
    this.parentQuestionId,
    this.parentOptionId,
    this.isConteginious,
    required this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) => SurveyQuestion(
        surveyQuestionId: json["survey_question_id"] ?? "",
        questionId: json["question_id"] ?? "",
        sequenceNumber: json["sequence_number"] ?? "",
        questionLanguageId: json["question_language_id"] ?? "",
        question: json["question"] ?? "",
        questionType: json["question_type"] ?? "",
        parentQuestionId: json["parent_question_id"],
        parentOptionId: json["parent_option_id"],
        isConteginious: json["is_conteginious"],
        options: List<QuestionOption>.from(
          json["options"].map((x) => QuestionOption.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "survey_question_id": surveyQuestionId,
        "question_id": questionId,
        "sequence_number": sequenceNumber,
        "question_language_id": questionLanguageId,
        "question": question,
        "question_type": questionType,
        "parent_question_id": parentQuestionId,
        "parent_option_id": parentOptionId,
        "is_conteginious": isConteginious,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}

class QuestionOption {
  String optionId;
  String? choiceText;
  String? textFieldType;
  String? answerType;

  QuestionOption({
    required this.optionId,
    this.choiceText,
    this.textFieldType,
    this.answerType,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) => QuestionOption(
        optionId: json["option_id"] ?? "",
        choiceText: json["choice_text"],
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

class CastOption {
  String id;
  String castName;

  CastOption({
    required this.id,
    required this.castName,
  });

  factory CastOption.fromJson(Map<String, dynamic> json) => CastOption(
        id: json["id"] ?? "",
        castName: json["cast_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cast_name": castName,
      };
}

class DefaultSettings {
  String name;
  String age;
  String gender;
  String phone;
  String caste;

  DefaultSettings({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.caste,
  });

  factory DefaultSettings.fromJson(Map<String, dynamic> json) =>
      DefaultSettings(
        name: json["name"] ?? "0",
        age: json["age"] ?? "0",
        gender: json["gender"] ?? "0",
        phone: json["phone"] ?? "0",
        caste: json["caste"] ?? "0",
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "age": age,
        "gender": gender,
        "phone": phone,
        "caste": caste,
      };

  bool get isNameRequired => name == "1";
  bool get isAgeRequired => age == "1";
  bool get isGenderRequired => gender == "1";
  bool get isPhoneRequired => phone == "1";
  bool get isCasteRequired => caste == "1";
}
