import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rudra_survey.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 13,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Survey List Table
    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL UNIQUE,
        survey_title TEXT NOT NULL,
        district_name TEXT,
        is_live TEXT,
        is_data_loaded INTEGER DEFAULT 0,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Survey Details Table
    await db.execute('''
      CREATE TABLE survey_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        region TEXT,
        region_id TEXT,
        state_name TEXT,
        state_id TEXT,
        district_name TEXT,
        district_id TEXT,
        loksabha_name TEXT,
        loksabha_id TEXT,
        assembly_name TEXT,
        assembly_id TEXT,
        ward_name TEXT,
        zp_ward_id TEXT,
        team_name TEXT,
        team_id TEXT,
        validation_name TEXT DEFAULT "1",
        validation_age TEXT DEFAULT "1",
        validation_gender TEXT DEFAULT "1",
        validation_phone TEXT DEFAULT "1",
        validation_caste TEXT DEFAULT "1",
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Survey Questions Table
    await db.execute('''
      CREATE TABLE survey_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        language_id TEXT NOT NULL,
        question_id TEXT NOT NULL,
        question TEXT NOT NULL,
        question_type TEXT,
        sequence_number TEXT,
        parent_question_id TEXT,
        parent_option_id TEXT,
        options TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Pending Survey Submissions Table
    await db.execute('''
      CREATE TABLE pending_submissions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_app_side_id TEXT,
        offline_survey_id TEXT UNIQUE,
        survey_id TEXT NOT NULL,
        survey_language_id TEXT,
        village_area_id TEXT,
        zp_ward_id TEXT,
        user_id TEXT NOT NULL,
        interviewer_name TEXT,
        interviewer_age TEXT,
        interviewer_gender TEXT,
        interviewer_phone TEXT,
        interviewer_cast TEXT,
        answers TEXT NOT NULL,
        audio_path TEXT,
        completion_stage TEXT DEFAULT 'questions_only',
        actual_completion_time TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        retry_count INTEGER DEFAULT 0,
        UNIQUE(survey_id, user_id, village_area_id, interviewer_name, interviewer_phone)
      )
    ''');

    // Area/Village Table
    await db.execute('''
      CREATE TABLE areas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        village_area_id TEXT NOT NULL,
        area_name TEXT NOT NULL,
        zp_ward_id TEXT,
        ward_name TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // ZP Wards Table
    await db.execute('''
      CREATE TABLE zp_wards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        zp_ward_id TEXT NOT NULL,
        ward_name TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Languages Table
    await db.execute('''
      CREATE TABLE languages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        survey_language_id TEXT NOT NULL,
        language_name TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Cast Table
    await db.execute('''
      CREATE TABLE casts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        cast_id TEXT NOT NULL,
        cast_name TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    log('Database tables created successfully');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('Upgrading database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      try {
        await db.execute(
          'ALTER TABLE survey_questions ADD COLUMN language_id INTEGER NOT NULL DEFAULT 0',
        );
        log('✅ Database upgraded to version 2: Added language_id column');
      } catch (e) {
        log('⚠️ Error adding language_id column (may already exist): $e');
      }
    }

    if (oldVersion < 3) {
      try {
        await db.execute(
          'ALTER TABLE survey_questions ADD COLUMN parent_question_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_questions ADD COLUMN parent_option_id TEXT',
        );
        log('✅ Database upgraded to version 3: Added parent_question_id and parent_option_id columns');
      } catch (e) {
        log('⚠️ Error adding parent columns (may already exist): $e');
      }
    }

    if (oldVersion < 4) {
      try {
        await db.execute(
          'ALTER TABLE surveys ADD COLUMN is_data_loaded INTEGER DEFAULT 0',
        );
        await db.execute('''
          CREATE TABLE IF NOT EXISTS languages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            survey_id TEXT NOT NULL,
            survey_language_id TEXT NOT NULL,
            language_name TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN region_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN state_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN district_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN loksabha_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN assembly_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN zp_ward_id TEXT',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN team_id TEXT',
        );
        log('✅ Database upgraded to version 4: Added unified API support');
      } catch (e) {
        log('⚠️ Error upgrading to version 4: $e');
      }
    }

    if (oldVersion < 5) {
      try {
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN survey_language_id TEXT',
        );
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN village_area_id TEXT',
        );
        log('✅ Database upgraded to version 5: Added survey_language_id and village_area_id to pending_submissions');
      } catch (e) {
        log('⚠️ Error upgrading to version 5: $e');
      }
    }

    if (oldVersion < 6) {
      try {
        await db.execute('DROP TABLE IF EXISTS pending_submissions_old');
        await db.execute(
            'ALTER TABLE pending_submissions RENAME TO pending_submissions_old');
        await db.execute('''
          CREATE TABLE pending_submissions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            survey_app_side_id TEXT,
            offline_survey_id TEXT,
            survey_id TEXT NOT NULL,
            survey_language_id TEXT,
            village_area_id TEXT,
            user_id TEXT NOT NULL,
            interviewer_name TEXT,
            interviewer_age TEXT,
            interviewer_gender TEXT,
            interviewer_phone TEXT,
            interviewer_cast TEXT,
            answers TEXT NOT NULL,
            audio_path TEXT,
            synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL,
            retry_count INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          INSERT INTO pending_submissions SELECT * FROM pending_submissions_old
        ''');
        await db.execute('DROP TABLE pending_submissions_old');
        log('✅ Database upgraded to version 6: Removed UNIQUE constraint');
      } catch (e) {
        log('⚠️ Error upgrading to version 6: $e');
      }
    }

    if (oldVersion < 7) {
      try {
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN updated_at TEXT',
        );
        log('✅ Database upgraded to version 7: Added updated_at column');
      } catch (e) {
        log('⚠️ Error upgrading to version 7: $e');
      }
    }

    if (oldVersion < 8) {
      try {
        // Add zp_ward_id and ward_name to areas table
        await db.execute(
          'ALTER TABLE areas ADD COLUMN zp_ward_id TEXT',
        );
        await db.execute(
          'ALTER TABLE areas ADD COLUMN ward_name TEXT',
        );

        // Create zp_wards table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS zp_wards (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            survey_id TEXT NOT NULL,
            zp_ward_id TEXT NOT NULL,
            ward_name TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        // Add zp_ward_id to pending_submissions
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN zp_ward_id TEXT',
        );

        log('✅ Database upgraded to version 8: Added ward-village mapping support');
      } catch (e) {
        log('⚠️ Error upgrading to version 8: $e');
      }
    }

    if (oldVersion < 9) {
      try {
        // Recreate surveys table with UNIQUE constraint on survey_id
        await db.execute('DROP TABLE IF EXISTS surveys_old');
        await db.execute('ALTER TABLE surveys RENAME TO surveys_old');
        await db.execute('''
          CREATE TABLE surveys (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            survey_id TEXT NOT NULL UNIQUE,
            survey_title TEXT NOT NULL,
            district_name TEXT,
            is_live TEXT,
            is_data_loaded INTEGER DEFAULT 0,
            synced INTEGER DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');
        // Copy unique surveys only
        await db.execute('''
          INSERT OR IGNORE INTO surveys 
          SELECT * FROM surveys_old 
          GROUP BY survey_id
        ''');
        await db.execute('DROP TABLE surveys_old');
        log('✅ Database upgraded to version 9: Added UNIQUE constraint on survey_id');
      } catch (e) {
        log('⚠️ Error upgrading to version 9: $e');
      }
    }

    if (oldVersion < 10) {
      try {
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN completion_stage TEXT DEFAULT "questions_only"',
        );
        log('✅ Database upgraded to version 10: Added completion_stage column');
      } catch (e) {
        log('⚠️ Error upgrading to version 10: $e');
      }
    }

    if (oldVersion < 11) {
      try {
        await db.execute(
          'ALTER TABLE pending_submissions ADD COLUMN actual_completion_time TEXT',
        );
        log('✅ Database upgraded to version 11: Added actual_completion_time column');
      } catch (e) {
        log('⚠️ Error upgrading to version 11: $e');
      }
    }

    if (oldVersion < 13) {
      try {
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN validation_name TEXT DEFAULT "1"',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN validation_age TEXT DEFAULT "1"',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN validation_gender TEXT DEFAULT "1"',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN validation_phone TEXT DEFAULT "1"',
        );
        await db.execute(
          'ALTER TABLE survey_details ADD COLUMN validation_caste TEXT DEFAULT "1"',
        );
        log('✅ Database upgraded to version 13: Added validation fields');
      } catch (e) {
        log('⚠️ Error upgrading to version 13: $e');
      }
    }

    // Ensure all tables exist (for users upgrading from very old versions)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS survey_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        region TEXT,
        region_id TEXT,
        state_name TEXT,
        state_id TEXT,
        district_name TEXT,
        district_id TEXT,
        loksabha_name TEXT,
        loksabha_id TEXT,
        assembly_name TEXT,
        assembly_id TEXT,
        ward_name TEXT,
        zp_ward_id TEXT,
        team_name TEXT,
        team_id TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS casts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id TEXT NOT NULL,
        cast_id TEXT NOT NULL,
        cast_name TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    log('✅ Ensured all required tables exist');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearAllTables() async {
    final db = await instance.database;
    await db.delete('surveys');
    await db.delete('survey_details');
    await db.delete('survey_questions');
    await db.delete('pending_submissions');
    await db.delete('areas');
    await db.delete('zp_wards');
    await db.delete('casts');
    await db.delete('languages');
    log('All tables cleared');
  }
}
