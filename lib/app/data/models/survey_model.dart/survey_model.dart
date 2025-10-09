
class SurveyModel {
  String? language;
  String? state;
  String? region;
  String? district;
  String? loksabha;
  String? assembly;
  String? wardZp;
  String? area;
  String? interviewerName;
  int? interviewerAge;
  String? interviewerGender;
  String? interviewerPhone;
  String? interviewerCast;
  List<String>? questionAnswers;

  SurveyModel({
    this.language,
    this.state,
    this.region,
    this.district,
    this.loksabha,
    this.assembly,
    this.wardZp,
    this.area,
    this.interviewerName,
    this.interviewerAge,
    this.interviewerGender,
    this.interviewerPhone,
    this.interviewerCast,
    this.questionAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'state': state,
      'region': region,
      'district': district,
      'loksabha': loksabha,
      'assembly': assembly,
      'wardZp': wardZp,
      'area': area,
      'interviewerName': interviewerName,
      'interviewerAge': interviewerAge,
      'interviewerGender': interviewerGender,
      'interviewerPhone': interviewerPhone,
      'interviewerCast': interviewerCast,
      'questionAnswers': questionAnswers,
    };
  }
}
