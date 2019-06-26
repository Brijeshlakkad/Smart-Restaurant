import 'dart:async';
import 'package:smart_restaurant/utils/network_util.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/utils/custom_exception.dart';

class RestDatasource {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/customer';
  static final loginURL = baseURL + "/login_data.php";
  static final signupURL = baseURL + "/signup_data.php";
  static final _apiKEY = "somerandomkey";

  Future<User> login(String email, String password) {
    return _netUtil.post(loginURL, body: {
      "token": _apiKEY,
      "email": email,
      "password": password
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"].toString());
      return new User.map(res["user"]);
    });
  }

  Future<Map> signup(String name, String email, String password, String address,
      String city, String contact) {
    return _netUtil.post(signupURL, body: {
      "token": _apiKEY,
      "action": "1",
      "name": name,
      "email": email,
      "password": password.toString(),
      "address": address,
      "city": city,
      "mobile": contact.toString(),
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"].toString());
      return res;
    });
  }

  Future<bool> checkEmailExists(String value) {
    return _netUtil.post(signupURL, body: {
      "token": _apiKEY,
      "action": "1",
      "email": value,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new Exception(res["errorMessage"].toString());
      return res['isEmailExists'];
    });
  }

  Future<bool> checkMobileExists(String value) {
    return _netUtil.post(signupURL, body: {
      "token": _apiKEY,
      "action": "2",
      "mobile": value,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new Exception(res["errorMessage"].toString());
      return res['isMobileExists'];
    });
  }
}
