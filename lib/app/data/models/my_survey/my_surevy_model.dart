class MySurveyModel {
  final String id;
  final String title;
  final String subtitle;
  final String surveyId;
  final String responseCount;
  bool isDataLoaded;
  bool isDataLoading;

  MySurveyModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.surveyId,
    required this.responseCount,
    this.isDataLoaded = false,
    this.isDataLoading = false,
  });

  MySurveyModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? surveyId,
    String? responseCount,
    bool? isDataLoaded,
    bool? isDataLoading,
  }) {
    return MySurveyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      surveyId: surveyId ?? this.surveyId,
      responseCount: responseCount ?? this.responseCount,
      isDataLoaded: isDataLoaded ?? this.isDataLoaded,
      isDataLoading: isDataLoading ?? this.isDataLoading,
    );
  }
}