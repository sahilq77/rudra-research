import 'dart:convert';
import 'dart:developer';

import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class SurveyLocalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== SURVEYS ====================
  Future<void> clearSurveys() async {
    final db = await _dbHelper.database;
    await db.delete('surveys');
    log('Cleared surveys table');
  }

  Future<void> saveSurveys(List<Map<String, dynamic>> surveys) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var survey in surveys) {
      batch.insert(
        'surveys',
        {
          'survey_id': survey['survey_id'],
          'survey_title': survey['survey_title'],
          'district_name': survey['district_name'],
          'is_live': survey['is_live'],
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${surveys.length} surveys to local DB');
  }

  Future<List<Map<String, dynamic>>> getSurveys() async {
    final db = await _dbHelper.database;
    return await db.query('surveys', orderBy: 'created_at ASC');
  }

  // ==================== SURVEY DETAILS ====================
  Future<void> saveSurveyDetails(
      String surveyId, Map<String, dynamic> details) async {
    final db = await _dbHelper.database;
    await db.insert(
      'survey_details',
      {
        'survey_id': surveyId,
        'region': details['region'],
        'region_id': details['region_id'],
        'state_name': details['state_name'],
        'state_id': details['state_id'],
        'district_name': details['district_name'],
        'district_id': details['district_id'],
        'loksabha_name': details['loksabha_name'],
        'loksabha_id': details['loksabha_id'],
        'assembly_name': details['assembly_name'],
        'assembly_id': details['assembly_id'],
        'ward_name': details['ward_name'],
        'zp_ward_id': details['zp_ward_id'],
        'team_name': details['team_name'],
        'team_id': details['team_id'],
        'validation_name': details['validation_name'] ?? '1',
        'validation_age': details['validation_age'] ?? '1',
        'validation_gender': details['validation_gender'] ?? '1',
        'validation_phone': details['validation_phone'] ?? '1',
        'validation_caste': details['validation_caste'] ?? '1',
        'synced': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('Saved survey details for survey_id: $surveyId');
  }

  Future<Map<String, dynamic>?> getSurveyDetails(String surveyId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'survey_details',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ==================== SURVEY QUESTIONS ====================
  Future<void> saveSurveyQuestions(
    String surveyId,
    String languageId,
    List<Map<String, dynamic>> questions,
  ) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var question in questions) {
      batch.insert(
        'survey_questions',
        {
          'survey_id': surveyId,
          'language_id': languageId,
          'question_id': question['question_id'],
          'question': question['question'],
          'question_type': question['question_type'],
          'sequence_number': question['sequence_number'],
          'parent_question_id': question['parent_question_id'],
          'parent_option_id': question['parent_option_id'],
          'options': jsonEncode(question['options'] ?? []),
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${questions.length} questions for survey_id: $surveyId, language_id: $languageId');
  }

  Future<List<Map<String, dynamic>>> getSurveyQuestions(
    String surveyId,
    String languageId,
  ) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'survey_questions',
      where: 'survey_id = ? AND language_id = ?',
      whereArgs: [surveyId, languageId],
      orderBy: 'sequence_number ASC',
    );

    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['options'] = jsonDecode(row['options'] as String);
      return map;
    }).toList();
  }

  // ==================== AREAS ====================
  Future<void> saveAreas(
      String surveyId, List<Map<String, dynamic>> areas) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var area in areas) {
      batch.insert(
        'areas',
        {
          'survey_id': surveyId,
          'village_area_id': area['village_area_id'],
          'area_name': area['area_name'],
          'zp_ward_id': area['zp_ward_id'],
          'ward_name': area['ward_name'],
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${areas.length} areas for survey_id: $surveyId');
  }

  Future<List<Map<String, dynamic>>> getAreas(String surveyId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'areas',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
  }

  // ==================== ZP WARDS ====================
  Future<void> saveZpWards(
      String surveyId, List<Map<String, dynamic>> wards) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var ward in wards) {
      batch.insert(
        'zp_wards',
        {
          'survey_id': surveyId,
          'zp_ward_id': ward['zp_ward_id'],
          'ward_name': ward['ward_name'],
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${wards.length} zp_wards for survey_id: $surveyId');
  }

  Future<List<Map<String, dynamic>>> getZpWards(String surveyId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'zp_wards',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
  }

  // ==================== CASTS ====================
  Future<void> saveCasts(
      String surveyId, List<Map<String, dynamic>> casts) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var cast in casts) {
      batch.insert(
        'casts',
        {
          'survey_id': surveyId,
          'cast_id': cast['cast_id'],
          'cast_name': cast['cast_name'],
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${casts.length} casts for survey_id: $surveyId');
  }

  Future<List<Map<String, dynamic>>> getCasts(String surveyId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'casts',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
  }

  // ==================== PENDING SUBMISSIONS ====================
  Future<int> savePendingSubmission(Map<String, dynamic> submission) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    try {
      final id = await db.insert(
        'pending_submissions',
        {
          'survey_app_side_id': submission['survey_app_side_id'],
          'offline_survey_id': submission['offline_survey_id'],
          'survey_id': submission['survey_id'],
          'survey_language_id': submission['survey_language_id'],
          'village_area_id': submission['village_area_id'],
          'zp_ward_id': submission['zp_ward_id'],
          'user_id': submission['user_id'],
          'interviewer_name': submission['interviewer_name'],
          'interviewer_age': submission['interviewer_age'],
          'interviewer_gender': submission['interviewer_gender'],
          'interviewer_phone': submission['interviewer_phone'],
          'interviewer_cast': submission['interviewer_cast'],
          'answers': submission['answers'],
          'audio_path': submission['audio_path'],
          'completion_stage':
              submission['completion_stage'] ?? 'questions_only',
          'actual_completion_time': submission['actual_completion_time'] ?? now,
          'synced': 0,
          'created_at': now,
          'updated_at': now,
          'retry_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );

      if (id == 0) {
        log('⚠️ Duplicate submission ignored - already exists in database');
        return 0;
      }

      log('✅ Saved pending submission with id: $id, stage: ${submission['completion_stage'] ?? 'questions_only'}');
      return id;
    } catch (e) {
      log('❌ Error saving submission: $e');
      if (e.toString().contains('UNIQUE constraint failed')) {
        log('⚠️ Duplicate submission detected and prevented');
        return 0;
      }
      rethrow;
    }
  }

  Future<void> deletePendingSubmission(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'pending_submissions',
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ Deleted pending submission with id: $id');
  }

  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    final db = await _dbHelper.database;

    // Only return submissions that are ready to upload (have interviewer info)
    final results = await db.query(
      'pending_submissions',
      where:
          'synced = ? AND interviewer_name IS NOT NULL AND interviewer_name != ? AND TRIM(interviewer_name) != ?',
      whereArgs: [0, '', ''],
      orderBy: 'created_at ASC',
    );

    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['answers'] = jsonDecode(row['answers'] as String);
      return map;
    }).toList();
  }

  Future<void> markSubmissionAsSynced(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'pending_submissions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    log('\n${'✅ ' * 20}');
    log('✅ SUBMISSION $id SYNCED SUCCESSFULLY');
    log('${'✅ ' * 20}\n');
  }

  Future<void> incrementRetryCount(int id) async {
    final db = await _dbHelper.database;
    await db.rawUpdate(
      'UPDATE pending_submissions SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<int> getPendingSubmissionsCount() async {
    final db = await _dbHelper.database;

    // Count only submissions that are ready to upload (have interviewer info)
    // This matches the sync logic that skips incomplete submissions
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count FROM pending_submissions 
      WHERE synced = 0 
      AND interviewer_name IS NOT NULL 
      AND interviewer_name != ''
      AND TRIM(interviewer_name) != ''
      ''',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAllPendingSubmissions() async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'pending_submissions',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    return results.map((row) {
      final map = Map<String, dynamic>.from(row);
      map['answers'] = jsonDecode(row['answers'] as String);
      return map;
    }).toList();
  }

  Future<void> cleanupIncompleteSubmissions() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    final sixHoursAgo =
        now.subtract(const Duration(hours: 6)).toIso8601String();
    final twentyFourHoursAgo =
        now.subtract(const Duration(hours: 24)).toIso8601String();

    final questionsOnlyDeleted = await db.delete(
      'pending_submissions',
      where: 'synced = 0 AND completion_stage = ? AND created_at < ?',
      whereArgs: ['questions_only', sixHoursAgo],
    );

    final interviewerInfoDeleted = await db.delete(
      'pending_submissions',
      where: 'synced = 0 AND completion_stage = ? AND created_at < ?',
      whereArgs: ['interviewer_info', twentyFourHoursAgo],
    );

    final legacyDeleted = await db.delete(
      'pending_submissions',
      where:
          'synced = 0 AND completion_stage IS NULL AND (interviewer_name IS NULL OR interviewer_name = "") AND created_at < ?',
      whereArgs: [sixHoursAgo],
    );

    final totalDeleted =
        questionsOnlyDeleted + interviewerInfoDeleted + legacyDeleted;
    if (totalDeleted > 0) {
      log('🧹 Cleaned up $totalDeleted incomplete submissions (questions-only: $questionsOnlyDeleted, interviewer-info: $interviewerInfoDeleted, legacy: $legacyDeleted)');
    }
  }

  Future<void> updateSubmissionStage(int id, String stage,
      {String? completionTime}) async {
    final db = await _dbHelper.database;
    final updateData = {
      'completion_stage': stage,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (completionTime != null) {
      updateData['actual_completion_time'] = completionTime;
    }

    await db.update(
      'pending_submissions',
      updateData,
      where: 'id = ?',
      whereArgs: [id],
    );
    log('✅ Updated submission $id to stage: $stage${completionTime != null ? ' with completion time: $completionTime' : ''}');
  }

  // ==================== LANGUAGES ====================
  Future<void> saveLanguages(
      String surveyId, List<Map<String, dynamic>> languages) async {
    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var language in languages) {
      batch.insert(
        'languages',
        {
          'survey_id': surveyId,
          'survey_language_id': language['survey_language_id'],
          'language_name': language['language_name'],
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    log('Saved ${languages.length} languages for survey_id: $surveyId');
  }

  Future<List<Map<String, dynamic>>> getLanguages(String surveyId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'languages',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
  }

  // ==================== COMPLETE SURVEY DATA ====================
  Future<void> saveCompleteSurveyData(
    String surveyId,
    Map<String, dynamic> surveyDetails,
    List<Map<String, dynamic>> languages,
    List<Map<String, dynamic>> zpWards,
    List<Map<String, dynamic>> areas,
    List<Map<String, dynamic>> casts,
    Map<String, List<Map<String, dynamic>>> questionsByLanguage,
  ) async {
    final db = await _dbHelper.database;

    await db.transaction((txn) async {
      // Delete existing data for this survey
      await txn.delete('survey_details',
          where: 'survey_id = ?', whereArgs: [surveyId]);
      await txn
          .delete('languages', where: 'survey_id = ?', whereArgs: [surveyId]);
      await txn
          .delete('zp_wards', where: 'survey_id = ?', whereArgs: [surveyId]);
      await txn.delete('areas', where: 'survey_id = ?', whereArgs: [surveyId]);
      await txn.delete('casts', where: 'survey_id = ?', whereArgs: [surveyId]);
      await txn.delete('survey_questions',
          where: 'survey_id = ?', whereArgs: [surveyId]);

      // Save survey details
      await txn.insert(
        'survey_details',
        {
          'survey_id': surveyId,
          'region': surveyDetails['region'],
          'region_id': surveyDetails['region_id'],
          'state_name': surveyDetails['state_name'],
          'state_id': surveyDetails['state_id'],
          'district_name': surveyDetails['district_name'],
          'district_id': surveyDetails['district_id'],
          'loksabha_name': surveyDetails['loksabha_name'],
          'loksabha_id': surveyDetails['loksabha_id'],
          'assembly_name': surveyDetails['assembly_name'],
          'assembly_id': surveyDetails['assembly_id'],
          'ward_name': surveyDetails['ward_name'],
          'zp_ward_id': surveyDetails['zp_ward_id'],
          'team_name': surveyDetails['team_name'],
          'team_id': surveyDetails['team_id'],
          'validation_name': surveyDetails['validation_name'] ?? '1',
          'validation_age': surveyDetails['validation_age'] ?? '1',
          'validation_gender': surveyDetails['validation_gender'] ?? '1',
          'validation_phone': surveyDetails['validation_phone'] ?? '1',
          'validation_caste': surveyDetails['validation_caste'] ?? '1',
          'synced': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Save languages
      for (var language in languages) {
        await txn.insert(
          'languages',
          {
            'survey_id': surveyId,
            'survey_language_id': language['survey_language_id'],
            'language_name': language['language_name'],
            'synced': 1,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Save zp_wards
      for (var ward in zpWards) {
        await txn.insert(
          'zp_wards',
          {
            'survey_id': surveyId,
            'zp_ward_id': ward['zp_ward_id'],
            'ward_name': ward['ward_name'],
            'synced': 1,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Save areas
      for (var area in areas) {
        await txn.insert(
          'areas',
          {
            'survey_id': surveyId,
            'village_area_id': area['village_area_id'],
            'area_name': area['area_name'],
            'zp_ward_id': area['zp_ward_id'],
            'ward_name': area['ward_name'],
            'synced': 1,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Save casts
      for (var cast in casts) {
        await txn.insert(
          'casts',
          {
            'survey_id': surveyId,
            'cast_id': cast['id'],
            'cast_name': cast['cast_name'],
            'synced': 1,
            'created_at': DateTime.now().toIso8601String(),
          },
        );
      }

      // Save questions grouped by language
      for (var entry in questionsByLanguage.entries) {
        final languageId = entry.key;
        final questions = entry.value;

        for (var question in questions) {
          await txn.insert(
            'survey_questions',
            {
              'survey_id': surveyId,
              'language_id': languageId,
              'question_id': question['question_id'],
              'question': question['question'],
              'question_type': question['question_type'],
              'sequence_number': question['sequence_number'],
              'parent_question_id': question['parent_question_id'],
              'parent_option_id': question['parent_option_id'],
              'options': jsonEncode(question['options'] ?? []),
              'synced': 1,
              'created_at': DateTime.now().toIso8601String(),
            },
          );
        }
      }

      // Mark survey as data loaded
      await txn.update(
        'surveys',
        {'is_data_loaded': 1},
        where: 'survey_id = ?',
        whereArgs: [surveyId],
      );
    });

    log('✅ Saved complete survey data for survey_id: $surveyId');
  }

  Future<bool> isSurveyDataLoaded(String surveyId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'surveys',
      columns: ['is_data_loaded'],
      where: 'survey_id = ?',
      whereArgs: [surveyId],
      limit: 1,
    );

    if (result.isEmpty) return false;
    return (result.first['is_data_loaded'] as int?) == 1;
  }
}
