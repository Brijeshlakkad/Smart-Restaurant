import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/utils/network_util.dart';
import 'package:smart_restaurant/utils/custom_exception.dart';
import 'package:smart_restaurant/models/user_data.dart';

class TableB {
  String _id, _name;
  bool _isAvail;
  TableB(this._id, this._name, this._isAvail);
  TableB.map(Map obj) {
    this._id = obj['id'];
    this._name = obj['name'];
    this._isAvail = obj['isAvail'];
  }
  String get id => _id;
  String get name => _name;
  bool get isAvail => _isAvail;
  Map toMap() {
    Map<String, dynamic> obj = new Map<String, dynamic>();
    obj['name'] = this._name;
    obj['id'] = this._id;
    obj['isAvail'] = this._isAvail;
    return obj;
  }

  @override
  String toString() {
    return name;
  }
}

class TableBooking {
  int _id;
  String _tableID, _tableName, _slotID, _slotName, _date, _day;
  TableBooking(this._id, this._tableID, this._tableName, this._slotID,
      this._slotName, this._date, this._day);
  TableBooking.map(Map obj) {
    this._id = int.parse(obj['id'].toString());
    this._tableID = obj['tableID'];
    this._tableName = obj['tableName'];
    this._slotID = obj['slotID'];
    this._slotName = obj['slotName'];
    this._date = obj['date'];
    this._day = obj['day'];
  }
  int get id => _id;
  String get tableID => _tableID;
  String get tableName => _tableName;
  String get slotID => _slotID;
  String get slotName => _slotName;
  String get date => _date;
  String get day => _day;
  Map toMap() {
    Map obj = new Map();
    obj['id'] = this._id;
    obj['tableID'] = this._tableID;
    obj['tableName'] = this._tableName;
    obj['slotID'] = this._slotID;
    obj['slotName'] = this._slotName;
    obj['date'] = this._date;
    obj['day'] = this._day;
    return obj;
  }

  @override
  String toString() {
    return tableName;
  }
}

class RequestTableBook {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/customer';
  static final finalURL = baseURL + "/booking_table_actions.php";
  static final db = new DatabaseHelper();
  Future<List<TableB>> getTableList(User user, String personNum) async {
    return _netUtil.post(finalURL, body: {
      "userID": user.id.toString(),
      "action": "1",
      "personNum": personNum
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int totalRows = int.parse(res['user']['totalRows'].toString());
      List<TableB> tableList = new List<TableB>();
      for (int i = 0; i < totalRows; i++) {
        tableList.add(TableB.map(res['user']['table'][i]));
      }
      return tableList;
    });
  }

  Future<List<TableB>> getSlotList(User user, TableB tableB) async {
    return _netUtil.post(finalURL, body: {
      "userID": user.id.toString(),
      "action": "2",
      "tableID": tableB.id.toString()
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int totalRows = int.parse(res['user']['totalRows'].toString());
      List<TableB> slotList = new List<TableB>();
      for (int i = 0; i < totalRows; i++) {
        slotList.add(TableB.map(res['user']['slot'][i]));
      }
      return slotList;
    });
  }

  Future bookTable(User user, TableB table, TableB slot) {
    return _netUtil.post(finalURL, body: {
      "userID": user.id.toString(),
      "action": "3",
      "tableID": table.id.toString(),
      "slotID": slot.id.toString(),
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      Map result = new Map();
      result['responseMessage'] = res['responseMessage'];
      try {
        result['success'] = true;
        result['tableBooking'] = TableBooking.map(res['user']['tableBooking']);
      } on Exception catch (error) {
        result['success'] = false;
      }
      return result;
    });
  }

  Future<TableBooking> getBookedTable(User user) {
    return _netUtil.post(finalURL, body: {
      "userID": user.id.toString(),
      "action": "4",
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      if (res['user']['isTableBooked']) {
        return TableBooking.map(res['user']['tableBooking']);
      } else {
        return null;
      }
    });
  }

  Future<String> removeBookedTable(User user, TableBooking tableBooking) {
    print(tableBooking.id.toString());
    return _netUtil.post(finalURL, body: {
      "userID": user.id.toString(),
      "action": "5",
      "tableBookingID": tableBooking.id.toString(),
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return res['responseMessage'].toString();
    });
  }
}

abstract class TableBookContract {
  void onBookTableSuccess(Map result);
  void onBookTableError(String errorString);
  void onGetBookedTableSuccess(TableBooking tableBooking);
}

class TableBookPresenter {
  TableBookContract _view;
  RequestTableBook api = new RequestTableBook();
  TableBookPresenter(this._view);

  doBookTable(User user, TableB table, TableB slot) async {
    try {
      var result = await api.bookTable(user, table, slot);
      if (result['success']) {
        _view.onBookTableSuccess(result);
      } else {
        _view.onBookTableError("Please try again");
      }
    } on Exception catch (error) {
      _view.onBookTableError(error.toString());
    }
  }

  doGetBookedTable(User user) async {
    try {
      var result = await api.getBookedTable(user);
      _view.onGetBookedTableSuccess(result);
    } on Exception catch (error) {
      _view.onBookTableError(error.toString());
    }
  }
}

abstract class TableActionContract {
  void onError(String errorString);
  void onSuccess(String message);
}

class TableActionPresenter {
  TableActionContract _view;
  RequestTableBook api = new RequestTableBook();

  TableActionPresenter(this._view);

  doRemoveBookedTable(User user, TableBooking tableBooking) async {
    try {
      String response = await api.removeBookedTable(user, tableBooking);
      _view.onSuccess(response);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}
