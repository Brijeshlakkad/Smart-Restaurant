import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:smart_kitchen/models/user_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "staff.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE User(id INTEGER PRIMARY KEY, email TEXT, password TEXT, name Text, type Text, mobile Text)");
    print("Created tables");
  }

  Future<int> saveUser(User user) async {
    await this.deleteUsers();
    var dbClient = await db;
    int res = await dbClient.insert("User", user.toMap());
    return res;
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    return res;
  }

  Future deleteDatabaseFile() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "user.db");
    await deleteDatabase(path);
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("User");
    return res.length == 1 ? true : false;
  }

  Future<String> getUser() async {
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT * FROM User");
    if (res.length > 0) {
      return res.first['email'].toString();
    } else {
      return null;
    }
  }

  Future<User> getUserDetails() async {
    var dbClient = await db;
    var res = await dbClient.rawQuery("SELECT * FROM User");
    if (res.length == 1) {
      return User.map(res.first);
    } else {
      this.deleteUsers();
      return null;
    }
  }
}
