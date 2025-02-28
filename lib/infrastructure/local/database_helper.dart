import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management/domain/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId INTEGER NOT NULL,  -- ✅ Added userId column
      title TEXT NOT NULL,
      description TEXT,
      dueDate TEXT,
      priority TEXT,
      status TEXT,
      assignedUserId INTEGER,
      completed INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }


  Future<int> insertTask(Task task) async {
    final db = await database;
    int result = await db.insert(
      'tasks',
      {
        'id': task.id, // Ensure `id` is unique or use NULL to auto-increment
        'userId': task.userId,
        'title': task.title,
        'description': task.description,
        'dueDate': task.dueDate?.toIso8601String(), // Convert DateTime to String
        'priority': task.priority,
        'status': task.status,
        'assignedUserId': task.assignedUserId,
        'completed': task.completed ? 1 : 0, // Convert bool to int (SQLite doesn't support bool)
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Avoid duplicate primary key errors
    );

    // ✅ Debugging: Fetch and print all tasks
    final allTasks = await fetchTasks();
    print("📂 All Tasks in DB: $allTasks");

    return result;
  }



  Future<List<Task>> fetchTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');

    // ✅ Debugging: Print fetched tasks
    print("📂 Tasks Fetched from DB: $maps");

    return List.generate(maps.length, (i) => Task.fromJson(maps[i]));
  }


  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db.update('tasks', task.toJson(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
