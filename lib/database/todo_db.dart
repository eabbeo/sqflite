import 'package:slite/database/database_service.dart';
import 'package:slite/model/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoDB {
  final tableName = 'todos';

  Future<void> createTable(Database database) async {
    await database.execute('''CREATE TABLE IF NOT EXISTS $tableName (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "title" TEXT NOT NULL,
    "created_at" INTEGER NOT NULL DEFAULT (cast(strftime('%s','now') as integer)),
    "updated_at" INTEGER
  );''');
  }

  //INSERTING DATA IN A TABLE
  Future<int> create({required String title}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert(
        '''INSERT INTO $tableName (title,created_at) VALUES (?,?)''',
        [title, DateTime.now().millisecondsSinceEpoch]);
  }

  //fetch all todos data
  Future<List<Todo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos = await database.rawQuery(
        '''SELECT * FROM $tableName ORDER BY COALESCE (updated_at,created_at)''');
    return todos.map((todos) => Todo.fromSqfliteDatabase(todos)).toList();
  }

  //get a particular record
  Future<Todo> fetchById(int id) async {
    final database = await DatabaseService().database;
    final todo = await database
        .rawQuery('''SELECT * FROM $tableName WHERE id = ?''', [id]);
    return Todo.fromSqfliteDatabase(todo.first);
  }

  //update todos
  Future<int> update({required int id, String? title}) async {
    final database = await DatabaseService().database;
    return await database.update(
        tableName,
        {
          if (title != null) 'title': title,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        conflictAlgorithm: ConflictAlgorithm.rollback,
        whereArgs: [id]);
  }

  //delete rows
  Future<void> delete(int id) async {
    final database = await DatabaseService().database;
    await database.rawDelete('''DELETE FROM $tableName WHERE id = ?''', [id]);
  }
}
