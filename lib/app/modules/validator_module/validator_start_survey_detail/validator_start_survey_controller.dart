import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rudra/app/widgets/app_snackbar_styles.dart';

import '../../../data/models/survey_model.dart/survey_model.dart';
import '../../../utils/responsive_utils.dart';

class ValidatorStartSurveyController extends GetxController {
  final PageController pageController = PageController();
  final Rx<SurveyModel> surveyModel = SurveyModel().obs;
  final RxInt currentPage = 0.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Reactive variables for form fields
  final RxString selectedLanguage = 'Marathi'.obs;
  final RxString selectedArea = 'Mallewadi'.obs;
  final RxString selectedAssembly = 'Kasba'.obs;
  final RxString selectedWardZp = '38'.obs;

  // Sample data for dropdowns
  final List<String> languages = ['Marathi', 'English', 'Hindi'];
  final List<String> areas = ['Mallewadi', 'Kolhapur', 'Pune'];
  final List<String> assemblies = [
    'Kasba',
    'Shivaji Nagar',
    'Kothrud',
    'Wadgaon Sheri',
  ];
  final List<String> wardsZp = ['38', '39', '40', '41', '42'];

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> refreshPage() async {
    await Future.delayed(Duration(seconds: 1));
  }

  void nextPage() {
    if (currentPage.value < 4) {
      // Validate the form for step 0 (section screen)
      if (currentPage.value == 0) {
        if (formKey.currentState?.validate() ?? false) {
          surveyModel.update((val) {
            val?.language = selectedLanguage.value;
            val?.area = selectedArea.value;
            val?.state = 'Maharashtra';
            val?.region = 'Western';
            val?.district = 'Kolhapur';
            val?.loksabha = 'Kolhapur';
            val?.assembly = selectedAssembly.value;
            val?.wardZp = selectedWardZp.value;
          });
          currentPage.value++;
        }
      } else if (currentPage.value >= 1 && currentPage.value <= 3) {
        // Validate that an answer is selected for the current question
        if (surveyModel.value.questionAnswers != null &&
            surveyModel.value.questionAnswers!.length > currentPage.value - 1 &&
            surveyModel
                .value
                .questionAnswers![currentPage.value - 1]
                .isNotEmpty) {
          currentPage.value++;
        } else {
          // Show error snackbar if no answer is selected
          AppSnackbarStyles.showError(
            title: 'Error',
            message: 'Please select an answer for the current question.',
          );
        }
      } else if (currentPage.value == 4) {
        // For interviewer screen (step 4), add validation if needed
        if (formKey.currentState?.validate() ?? false) {
          currentPage.value++;
        }
      }
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
    }
  }

  void updateQuestionAnswer(int index, String answer) {
    surveyModel.update((val) {
      if (val?.questionAnswers == null)
        val?.questionAnswers = List.filled(3, '');
      val?.questionAnswers?[index] = answer;
    });
  }

  void updateInterviewerDetails({
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? cast,
  }) {
    surveyModel.update((val) {
      val?.interviewerName = name;
      val?.interviewerAge = age;
      val?.interviewerGender = gender;
      val?.interviewerPhone = phone;
      val?.interviewerCast = cast;
    });
  }

  void submitSurvey() {
    if (formKey.currentState?.validate() ?? false) {
      Get.snackbar('Success', 'Survey submitted successfully!');
    }
  }
}
