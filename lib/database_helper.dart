import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            isCompleted INTEGER,
            dueDate TEXT,
            dueTime TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN dueTime TEXT');
        }
      },
    );
  }


  Future<int> insertTask(
      String title, bool isCompleted, String dueDate, String dueTime) async {
    final db = await database;
    return await db.insert(
      'tasks',
      {
        'title': title,
        'isCompleted': isCompleted ? 1 : 0,
        'dueDate': dueDate,
        'dueTime': dueTime,
      },
    );
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks');
  }

  Future<void> updateTask(
      int id, String newTitle, String newDueDate, String newDueTime, bool isCompleted) async {
    final db = await database;

    await db.update(
      'tasks',
      {
        'title': newTitle,
        'dueDate': newDueDate,
        'dueTime': newDueTime,
        'isCompleted': isCompleted ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTaskStatus(int id, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
