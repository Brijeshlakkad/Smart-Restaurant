import 'dart:async';
import 'package:smart_kitchen/utils/network_util.dart';
import 'package:smart_kitchen/models/user_data.dart';
import 'package:smart_kitchen/utils/custom_exception.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/kitchen';
  static final loginURL = baseURL + "/both_user_login_data.php";
  static final _apiKEY = "somerandomkey";

  Future<User> login(String email, String password) {
    return _netUtil.post(loginURL, body: {
      "token": _apiKEY,
      "email": email,
      "password": password,
      "type": "kitchen",
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"].toString());
      return new User.map(res["user"]);
    });
  }
}
