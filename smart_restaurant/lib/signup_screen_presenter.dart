import 'package:smart_restaurant/models/rest_ds.dart';
abstract class SignupScreenContract {
  void onSignupSuccess(Map res);
  void onSignupError(String errorTxt);
}

class SignupScreenPresenter {
  SignupScreenContract _view;
  RestDatasource api = new RestDatasource();
  SignupScreenPresenter(this._view);

  doSignup(String name, String email, String password, String address, String city, String contact) async{
    try {
      Map res = await api.signup(name, email, password, address, city, contact);
      _view.onSignupSuccess(res);
    } on Exception catch(error) {
      _view.onSignupError(error.toString());
    }
  }
}
