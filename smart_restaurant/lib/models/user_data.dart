import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/utils/network_util.dart';
import 'package:smart_restaurant/utils/custom_exception.dart';

class User {
  int _id;
  String _email, _password, _name, _city, _address, _mobile;
  User(this._id, this._email, this._password, this._name, this._city,
      this._mobile, this._address);

  User.map(dynamic obj) {
    this._id = int.parse(obj['id'].toString());
    this._email = obj["email"];
    this._password = obj["password"];
    this._name = obj["name"];
    this._city = obj["city"];
    this._mobile = obj["mobile"];
    this._address = obj["address"];
  }
  int get id => _id;
  String get email => _email;
  String get password => _password;
  String get name => _name;
  String get city => _city;
  String get mobile => _mobile;
  String get address => _address;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map["email"] = _email;
    map["password"] = _password;
    map["name"] = _name;
    map["city"] = _city;
    map["mobile"] = _mobile;
    map["address"] = _address;
    return map;
  }

  @override
  String toString() {
    return "User $name";
  }
}

class RequestUser {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/customer';
  static final finalURL = baseURL + "/user_actions.php";
  static final db = new DatabaseHelper();
  Future<User> getUserDetails(String user) async {
    return _netUtil.post(finalURL, body: {"email": user, "action": "1"}).then(
        (dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  Future<User> updateUser(email, name, address, city, mobile) async {
    return _netUtil.post(finalURL, body: {
      "email": email,
      "name": name,
      "address": address,
      "city": city,
      "mobile": mobile,
      "action": "2"
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      return User.map(res['user']);
    });
  }

  Future<User> changePassword(
      String email, String oldPassword, String newPassword) async {
    return _netUtil.post(finalURL, body: {
      "email": email,
      "oldPassword": oldPassword,
      "newPassword": newPassword,
      "action": "3"
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res['errorMessage']);
      return User.map(res['user']);
    });
  }
}

abstract class UserContract {
  void onUserSuccess(User userDetails);
  void onUserError();
}

class UserPresenter {
  UserContract _view;
  RequestUser api = new RequestUser();
  UserPresenter(this._view);

  doGetUser(String userEmail) async {
    try {
      var user = await api.getUserDetails(userEmail);
      if (user == null) {
        _view.onUserError();
      } else {
        _view.onUserSuccess(user);
      }
    } on Exception catch (error) {
      print(error.toString());
      _view.onUserError();
    }
  }
}

abstract class UserUpdateContract {
  void onUserUpdateSuccess(User userDetails);
  void onUserUpdateError(String errorString);
}

class UserUpdatePresenter {
  UserUpdateContract _view;
  RequestUser api = new RequestUser();
  UserUpdatePresenter(this._view);

  doUpdateUser(email, name, address, city, mobile) async {
    try {
      var user = await api.updateUser(email, name, address, city, mobile);
      if (user == null) {
        _view.onUserUpdateError("Update Failed");
      } else {
        _view.onUserUpdateSuccess(user);
      }
    } on Exception catch (error) {
      _view.onUserUpdateError(error.toString());
    }
  }

  doChangePassword(String email, String oldPassword, String newPassword) async {
    try {
      User user = await api.changePassword(email, oldPassword, newPassword);
      if (user == null) {
        _view.onUserUpdateError("Update Failed");
      } else {
        _view.onUserUpdateSuccess(user);
      }
    } on Exception catch (error) {
      _view.onUserUpdateError(error.toString());
    }
  }
}
