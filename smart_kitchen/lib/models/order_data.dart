import 'package:smart_kitchen/utils/network_util.dart';
import 'package:smart_kitchen/utils/custom_exception.dart';
import 'package:smart_kitchen/models/user_data.dart';
import 'package:smart_kitchen/models/booking_table_data.dart';
import 'package:smart_kitchen/models/menu_item_data.dart';
import 'package:smart_kitchen/models/category_data.dart';

class Order {
  Category _category;
  MenuItemC _menuItemC;
  int _quantity;
  Order(this._category, this._menuItemC, this._quantity);
  Category get category => _category;
  MenuItemC get menuItemC => _menuItemC;
  int get quantity => _quantity;
  Order.map(Map obj) {
    this._category = Category.map(obj['category']);
    this._menuItemC = MenuItemC.map(obj['menuItem']);
    this._quantity = int.parse(obj['quantity']);
  }
  Map toMap() {
    Map obj = new Map();
    obj['menuItem'] = this._menuItemC.toMap();
    obj['quantity'] = this._quantity;
    return obj;
  }
}

class MadeOrder {
  TableBooking _tableBooking;
  List<Order> _orderList;
  int _id;
  String _userID, _token, _date, _status;
  MadeOrder(this._id, this._tableBooking, this._orderList, this._userID,
      this._token, this._status, this._date);
  MadeOrder.map(Map obj) {
    this._id = int.parse(obj['id'].toString());
    this._tableBooking = TableBooking.map(obj['tableBooking']);
    List<Order> orderList = new List<Order>();
    if (obj['orderList'] != null && obj['orderList'].length != 0) {
      for (int i = 0; i < obj['orderList'].length; i++) {
        orderList.add(Order.map(obj['orderList'][i]));
      }
    }
    this._orderList = orderList;
    this._userID = obj['userID'];
    this._token = obj['token'];
    this._date = obj['date'];
    this._status = obj['status'];
  }
  int get id => _id;
  TableBooking get tableBooking => _tableBooking;
  List<Order> get orderList => _orderList;
  String get userID => _userID;
  String get token => _token;
  String get date => _date;
  String get status => _status;
  Map toMap() {
    Map obj = new Map();
    obj['tableBooking'] = this._tableBooking.toMap();
    List mappedOrderList = new List();
    for (int i = 0; i < _orderList.length; i++) {
      mappedOrderList.add(_orderList[i].toMap());
    }
    obj['orderList'] = mappedOrderList.toString();
    obj['id'] = this._id;
    obj['userID'] = this._userID;
    obj['token'] = this._token;
    obj['date'] = this._date;
    obj['status'] = this._status;
    return obj;
  }

  @override
  String toString() {
    return tableBooking.tableName;
  }
}

class RequestOrder {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/kitchen';
  static final finalURL = baseURL + "/made_order_actions.php";

  Future<List<MadeOrder>> getOrderInventory(
      User user, String status, bool isToday) {
    String isTodayStr = "";
    if (isToday) {
      isTodayStr = "true";
    } else {
      isTodayStr = "false";
    }
    return _netUtil.post(finalURL, body: {
      "action": "1",
      "userID": user.id.toString(),
      "status": status,
      "isToday": isTodayStr,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int total = int.parse(res['totalRows'].toString());
      List<MadeOrder> madeOrderList = new List<MadeOrder>();
      for (int i = 0; i < total; i++) {
        madeOrderList.add(MadeOrder.map(res['madeOrder'][i]));
      }
      return madeOrderList;
    });
  }

  Future<List<MadeOrder>> changeOrderStatus(
      User user, MadeOrder madeOrder, String status, String waiterEmail) {
    String waiterStr;
    if (waiterEmail == null) {
      waiterStr = "null";
    } else {
      waiterStr = waiterEmail.toString();
    }
    return _netUtil.post(finalURL, body: {
      "action": "2",
      "userID": user.id.toString(),
      "orderID": madeOrder.id.toString(),
      "status": status,
      "waiterEmail": waiterStr,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int total = int.parse(res['totalRows'].toString());
      List<MadeOrder> madeOrderList = new List<MadeOrder>();
      for (int i = 0; i < total; i++) {
        madeOrderList.add(MadeOrder.map(res['madeOrder'][i]));
      }
      return madeOrderList;
    });
  }

  Future<List<User>> getWaiterList(User user) {
    return _netUtil.post(finalURL, body: {
      "action": "3",
      "userID": user.id.toString(),
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int total = int.parse(res['totalRows'].toString());
      List<User> waiterList = new List<User>();
      for (int i = 0; i < total; i++) {
        waiterList.add(User.map(res['waiter'][i]));
      }
      return waiterList;
    });
  }
}

abstract class OrderContract {
  void onSuccess(List<MadeOrder> madeOrderList);
  void onError(String errorString);
}

class OrderPresenter {
  OrderContract _view;
  RequestOrder api = new RequestOrder();
  OrderPresenter(this._view);

  doGetOrderInventory(User user, String status, bool isToday) async {
    try {
      List<MadeOrder> madeOrderList =
          await api.getOrderInventory(user, status, isToday);
      _view.onSuccess(madeOrderList);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }

  doChangeOrderStatus(
      User user, MadeOrder madeOrder, String status, String waiterEmail) async {
    try {
      List<MadeOrder> madeOrderList =
          await api.changeOrderStatus(user, madeOrder, status, waiterEmail);
      _view.onSuccess(madeOrderList);
    } on Exception catch (error) {
      _view.onError(error.toString());
    }
  }
}
