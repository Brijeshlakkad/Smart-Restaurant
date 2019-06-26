import 'package:smart_kitchen/data/database_helper.dart';
import 'package:smart_kitchen/utils/network_util.dart';
import 'package:smart_kitchen/utils/custom_exception.dart';

class User {
  int _id;
  String _email, _password, _name, _mobile, _type;
  User(this._id, this._email, this._password, this._name, this._type,
      this._mobile);

  User.map(dynamic obj) {
    this._id = int.parse(obj['id'].toString());
    this._email = obj["email"];
    this._password = obj["password"];
    this._name = obj["name"];
    this._type = obj["type"];
    this._mobile = obj["mobile"];
  }
  int get id => _id;
  String get email => _email;
  String get password => _password;
  String get name => _name;
  String get type => _type;
  String get mobile => _mobile;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map["email"] = _email;
    map["password"] = _password;
    map["name"] = _name;
    map["type"] = _type;
    map["mobile"] = _mobile;
    return map;
  }

  @override
  String toString() {
    return "User $name";
  }
}

class RequestUser {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/kitchen';
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
