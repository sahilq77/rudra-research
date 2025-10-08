class MySurveyModel {
  final String id;
  final String title;
  final String subtitle;
  final String surveyId;
  final String responseCount;

  MySurveyModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.surveyId,
    required this.responseCount,
  });

  MySurveyModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? surveyId,
    String? responseCount,
  }) {
    return MySurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      surveyId: surveyId ?? this.surveyId,
      responseCount: responseCount ?? this.responseCount,
    );
  }
}