import 'package:smart_kitchen/models/rest_ds.dart';
import 'package:smart_kitchen/models/user_data.dart';

abstract class LoginScreenContract {
  void onLoginSuccess(User user);
  void onLoginError(String errorTxt);
}

class LoginScreenPresenter {
  LoginScreenContract _view;
  RestDatasource api = new RestDatasource();
  LoginScreenPresenter(this._view);

  doLogin(String email, String password) async {
    try {
      var user = await api.login(email, password);
      _view.onLoginSuccess(user);
    } on Exception catch (error) {
      _view.onLoginError(error.toString());
    }
  }
}
