import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_list.dart';
import '../models/todo_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'daily_todo.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todo_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE todo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (list_id) REFERENCES todo_lists (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<TodoList> getOrCreateTodoList(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todo_lists',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      return TodoList.fromMap(maps.first);
    } else {
      final todoList = TodoList(
        date: date,
        createdAt: DateTime.now(),
      );
      final id = await db.insert('todo_lists', todoList.toMap());
      return todoList.copyWith(id: id);
    }
  }

  Future<List<TodoItem>> getTodoItems(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todo_items',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => TodoItem.fromMap(maps[i]));
  }

  Future<int> insertTodoItem(TodoItem item) async {
    final db = await database;
    return await db.insert('todo_items', item.toMap());
  }

  Future<int> updateTodoItem(TodoItem item) async {
    final db = await database;
    return await db.update(
      'todo_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteTodoItem(int id) async {
    final db = await database;
    return await db.delete(
      'todo_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> getAllTodoListDates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todo_lists',
      columns: ['date'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => maps[i]['date'] as String);
  }
}
