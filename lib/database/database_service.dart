import 'package:path/path.dart';
import 'package:slite/database/todo_db.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  Database? _database;

  //function to check if the databse already exists
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initialize();
    return _database!;
  }

  //fullpath function
  Future<String> get fullpath async {
    const name = 'todo.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  //initialize function
  Future<Database> _initialize() async {
    final path = await fullpath;
    var database = await openDatabase(path,
        version: 1, onCreate: create, singleInstance: true);
    return database;
  }

  Future<void> create(Database database, int version) async =>
      await TodoDB().createTable(database);
}
