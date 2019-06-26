import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_restaurant/models/menu_item_data.dart';
import 'package:smart_restaurant/models/category_data.dart';
import 'package:smart_restaurant/models/order_data.dart';
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
    String path = join(documentsDirectory.path, "user.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE User(id INTEGER PRIMARY KEY, email TEXT, password TEXT, name Text, city Text, mobile Text, address Text)");
    await db.execute(
        "CREATE TABLE category(id INTEGER PRIMARY KEY, name TEXT, image TEXT)");
    await db.execute(
        "CREATE TABLE menuItem(id INTEGER PRIMARY KEY, name TEXT, cid TEXT, price TEXT, description TEXT, image TEXT)");
    await db.execute(
        "CREATE TABLE orderItem(id INTEGER PRIMARY KEY, menuItemID TEXT, quantity TEXT)");
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

  Future updateUser(User user) async {
    var dbClient = await db;
    int res = await dbClient.rawUpdate(
        "UPDATE User SET name=?,address=?,city=?,mobile=? WHERE email=?",
        [user.name, user.address, user.city, user.mobile, user.email]);
    return res;
  }

  Future<bool> checkCategoryExists(int categoryID) async {
    var dbClient = await db;
    var res = await dbClient
        .rawQuery("SELECT * FROM category WHERE id=?", [categoryID]);
    if (res.length > 0) {
      return true;
    }
    return false;
  }

  Future<bool> checkMenuItemExists(int menuItemID) async {
    var dbClient = await db;
    var res = await dbClient
        .rawQuery("SELECT * FROM menuItem WHERE id=?", [menuItemID]);
    if (res.length > 0) {
      return true;
    }
    return false;
  }

  Future<bool> checkOrderExists(int menuItemID) async {
    var dbClient = await db;
    var res = await dbClient
        .rawQuery("SELECT * FROM orderItem WHERE menuItemID=?", [menuItemID]);
    if (res.length > 0) {
      return true;
    }
    return false;
  }

  Future<int> saveOrder(Order order) async {
    var dbClient = await db;
    int res;
    bool categoryExists = await checkCategoryExists(order.category.id);
    if (!categoryExists) {
      res = await dbClient.insert("category", order.category.toMap());
    }
    bool menuItemExists = await checkMenuItemExists(order.menuItemC.id);
    if (!menuItemExists) {
      res = await dbClient.insert("menuItem", order.menuItemC.toMap());
    }
    bool orderExists = await checkOrderExists(order.menuItemC.id);
    if (!orderExists) {
      res = await dbClient.rawInsert(
          "INSERT INTO orderItem(menuItemID,quantity) VALUES(?,?)",
          [order.menuItemC.id, order.quantity]);
    } else {
      res = await dbClient.rawUpdate(
          "UPDATE orderItem SET quantity=? WHERE menuItemID=?",
          [order.quantity, order.menuItemC.id]);
    }
    return res;
  }

  Future<List<Order>> getOrderDetails() async {
    var dbClient = await db;
    List<Order> orderList = new List<Order>();
    var res = await dbClient.rawQuery("SELECT * FROM orderItem");
    for (int i = 0; i < res.length; i++) {
      String menuItemID = res[i]['menuItemID'].toString();
      int quantity = int.parse(res[i]['quantity'].toString());
      var menuItem = await dbClient
          .rawQuery("SELECT * FROM menuItem WHERE id=?", [menuItemID]);
      String categoryID = menuItem.first['cid'].toString();
      var category = await dbClient
          .rawQuery("SELECT * FROM category WHERE id=?", [categoryID]);
      orderList.add(Order(Category.map(category.first),
          MenuItemC.map(menuItem.first), quantity));
    }
    return orderList;
  }

  Future updateOrder(Order order, int quantity) async {
    var dbClient = await db;
    int res;
    if (quantity == 0) {
      res = await dbClient.rawDelete(
          "DELETE FROM orderItem WHERE menuItemID=?", [order.menuItemC.id]);
      return res;
    }
    res = await dbClient.rawUpdate(
        "UPDATE orderItem SET quantity=? WHERE menuItemID=?",
        [quantity, order.menuItemC.id]);
    return res;
  }

  Future deleteAllOrders() async {
    var dbClient = await db;
    int res = 0;
    res += await dbClient.rawDelete("DELETE FROM orderItem");
    res += await dbClient.rawDelete("DELETE FROM category");
    res += await dbClient.rawDelete("DELETE FROM menuItem");
    return res;
  }
}
