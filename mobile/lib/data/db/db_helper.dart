import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const int _currentVersion = 2;

  DatabaseHelper();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'app_database.db');

    return await openDatabase(
      path,
      version: _currentVersion,
      onCreate: (db, version) async {
        await _runMigrations(db, version, 1);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _runMigrations(db, newVersion, oldVersion + 1);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        throw Exception('Database downgrade not supported');
      },
    );
  }

  Future<void> _runMigrations(
    Database db,
    int newVersion,
    int startVersion,
  ) async {
    for (int version = startVersion; version <= newVersion; version++) {
      if (_migrations.containsKey(version)) {
        await _migrations[version]!(db);
      }
    }
  }

  static final Map<int, Future<void> Function(Database)> _migrations = {
    1: _createInitialSchema,
    2: _migrateV2,
  };

  static Future<void> _createInitialSchema(Database db) async {
    await db.execute('''
      CREATE TABLE settings (
        id TEXT PRIMARY KEY NOT NULL,
        theme INTEGER NOT NULL,
        language_code TEXT NOT NULL,
        currency TEXT NOT NULL,
        is_welcomed INTEGER NOT NULL
      );
    ''');
  }

  static Future<void> _migrateV2(Database db) async {
    await db.execute('''
      ALTER TABLE settings ADD COLUMN isGoogleAuthUser INTEGER NOT NULL DEFAULT 0;
    ''');
    await db.execute('''
      ALTER TABLE settings ADD COLUMN hasCompletedRegister INTEGER NOT NULL DEFAULT 1;
    ''');
  }

  Future<void> deleteDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'app_database.db');
    _database = null;
    await databaseFactory.deleteDatabase(path);
  }
}
