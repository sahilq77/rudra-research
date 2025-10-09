// lib/app/modules/survey_question/survey_question_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../widgets/app_snackbar_styles.dart';

class SurveyQuestionController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late String language;
  final RxString selectedAnswer = ''.obs;

  // Questions based on language
  final Map<String, Map<String, dynamic>> questions = {
    'Marathi': {
      'posterName': 'Mallikarjun Pote',
      'date': '16 Sep 2025',
      'question':
          'आगामी नागपूर महानगरपालिके निवडणुकीत कोणाला आपल्या वार्डीची तसेच राहिले आणि अपालयाम वाटते?',
      'options': [
        'भाजपा (वर्तमान) + शिवसेना (शिंदे गट) + राष्ट्रवादी काँग्रेस (अजित पवार)',
        'महाविकास आघाडी (काँग्रेस + राष्ट्रवादी काँग्रेस (शरद पवार) + शिवसेना (उद्धव गट))',
        'यापैकी नाही',
        'उत्तर देऊ नाही',
      ],
    },
    'Hindi': {
      'posterName': 'Mallikarjun Pote',
      'date': '16 Sep 2025',
      'question':
          'आगामी नागपुर महानगरपालिका चुनाव में, आपको लगता है कि आपके वार्ड और निगम में कौन जीतेगा?',
      'options': [
        'भाजपा (वर्तमान) + शिवसेना (शिंदे गुट) + राष्ट्रवादी कांग्रेस (अजित पवार)',
        'महा विकास अघाड़ी (कांग्रेस + राष्ट्रवादी कांग्रेस (शरद पवार) + शिवसेना (उद्धव गुट))',
        'इनमें से कोई नहीं',
        'कोई जवाब नहीं',
      ],
    },
    'English': {
      'posterName': 'Mallikarjun Pote',
      'date': '16 Sep 2025',
      'question':
          'In the upcoming Nagpur Municipal Corporation election, who do you think will win in your ward and the corporation?',
      'options': [
        'BJP (Current) + Shiv Sena (Shinde Group) + NCP (Ajit Pawar)',
        'Maha Vikas Aghadi (Congress + NCP (Sharad Pawar) + Shiv Sena (Uddhav Group))',
        'None of these',
        'No answer',
      ],
    },
  };

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    language = args?['language'] ?? 'Marathi';
  }

  void nextPage() {
    if (formKey.currentState!.validate() && selectedAnswer.value.isNotEmpty) {
      Get.toNamed(AppRoutes.surveyInterviewer, arguments: {
        'language': language,
        'answer': selectedAnswer.value,
      });
    } else {
      AppSnackbarStyles.showError(
          title: 'Error', message: 'Please select an answer');
    }
  }

  Future<void> refreshPage() async {
    await Future.delayed(const Duration(seconds: 1));
    AppSnackbarStyles.showInfo(title: 'Refresh', message: 'Page refreshed');
  }
}
