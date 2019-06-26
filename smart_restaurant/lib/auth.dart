import 'package:smart_restaurant/data/database_helper.dart';
import 'package:smart_restaurant/models/user_data.dart';
import 'package:smart_restaurant/utils/internet_access.dart';

enum AuthState { LOGGED_IN, LOGGED_OUT }

abstract class AuthStateListener {
  void onAuthStateChanged(AuthState state, User user);
}

class AuthStateProvider implements UserContract {
  static final AuthStateProvider _instance = new AuthStateProvider.internal();
  User user;
  UserPresenter _userPresenter;
  List<AuthStateListener> _subscribers;
  bool internetAccess = false;
  factory AuthStateProvider() => _instance;
  AuthStateProvider.internal() {
    _subscribers = new List<AuthStateListener>();
    _userPresenter = new UserPresenter(this);
    getInternetAccessObject();
  }
  Future getInternetAccessObject() async {
    CheckInternetAccess checkInternetAccess = new CheckInternetAccess();
    internetAccess = await checkInternetAccess.check();
  }

  void initState() async {
    var db = new DatabaseHelper();
    var isLoggedIn = await db.isLoggedIn();
    if (isLoggedIn) {
      if (internetAccess) {
        final user = await db.getUser();
        await _userPresenter.doGetUser(user);
      } else {
        final user = await db.getUserDetails();
        notify(AuthState.LOGGED_IN,user);
      }
    } else
      notify(AuthState.LOGGED_OUT, null);
  }

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(AuthStateListener listener) {
    for (var l in _subscribers) {
      if (l == listener) _subscribers.remove(l);
    }
  }

  void notify(AuthState state, User user) {
    _subscribers
        .forEach((AuthStateListener s) => s.onAuthStateChanged(state, user));
  }

  @override
  void onUserError() {
    user = null;
    var db = new DatabaseHelper();
    db.deleteUsers();
    notify(AuthState.LOGGED_OUT, null);
  }

  @override
  void onUserSuccess(User userDetails) {
    user = userDetails;
    notify(AuthState.LOGGED_IN, user);
  }
}
