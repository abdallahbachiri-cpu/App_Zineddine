import 'package:cuisinous/data/db/db_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/errors/failures.dart';
import '../models/settings_model.dart';

import 'dart:developer' as devtools;

class AppSettings {
  final DatabaseHelper _databaseHelper;

  AppSettings({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  Future<Database> get database async => await _databaseHelper.database;

  Future<Settings?> getSettings() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'settings',
        limit: 1,
      );

      return maps.isNotEmpty ? Settings.fromMap(maps.first) : null;
    } on DatabaseException catch (e, s) {
      devtools.log('Error getting settings: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    } catch (e, s) {
      devtools.log('Unexpected error: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    }
  }

  Future<bool> insertSettings(Settings settings) async {
    try {
      final db = await database;
      return await db.insert(
            'settings',
            settings.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          ) >
          0;
    } on DatabaseException catch (e, s) {
      devtools.log('Error inserting settings: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    } catch (e, s) {
      devtools.log('Unexpected error: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    }
  }

  Future<bool> updateSettings(Settings settings) async {
    try {
      final db = await database;
      return await db.update(
            'settings',
            settings.toMap(),
            where: 'id = ?',
            whereArgs: [settings.id],
          ) >
          0;
    } on DatabaseException catch (e, s) {
      devtools.log('Error updating settings: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    } catch (e, s) {
      devtools.log('Unexpected error: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    }
  }

  Future<bool> deleteSettings(String id) async {
    try {
      final db = await database;
      return await db.delete('settings', where: 'id = ?', whereArgs: [id]) > 0;
    } on DatabaseException catch (e, s) {
      devtools.log('Error deleting settings: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    } catch (e, s) {
      devtools.log('Unexpected error: $e', error: e, stackTrace: s);
      throw DatabaseFailure(e.toString());
    }
  }
}
