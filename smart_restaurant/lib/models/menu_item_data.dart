import 'package:smart_restaurant/utils/network_util.dart';
import 'package:smart_restaurant/utils/custom_exception.dart';
import 'package:smart_restaurant/models/category_data.dart';

class MenuItemC {
  int _id;
  String _name, _image, _cid, _price, _description;
  MenuItemC(this._id, this._name, this._image);
  int get id => _id;
  String get name => _name;
  String get image => _image;
  String get cid => _cid;
  String get price => _price;
  String get description => _description;
  MenuItemC.map(Map obj) {
    this._id = int.parse(obj['id'].toString());
    this._name = obj['name'];
    this._image = obj['image'];
    this._cid = obj['cid'];
    this._price = obj['price'];
    this._description = obj['description'];
  }
  Map toMap() {
    Map<String, dynamic> obj = new Map<String, dynamic>();
    obj['id'] = _id;
    obj['name'] = _name;
    obj['image'] = _image;
    obj['cid'] = _cid;
    obj['price'] = _price;
    obj['description'] = _description;
    return obj;
  }
}

class RequestMenuItemC {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/customer';
  static final finalURL = baseURL + "/menu_item_actions.php";
  Future<List<MenuItemC>> getMenuItemCList(Category category) async {
    String cid = category.id.toString();
    return _netUtil.post(finalURL, body: {
      "action": "1",
      "cid": cid,
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int total = int.parse(res['user']['totalRows'].toString());
      List<MenuItemC> menuItemCList = new List<MenuItemC>();
      for (int i = 0; i < total; i++) {
        menuItemCList.add(MenuItemC.map(res['user']['menuItem'][i]));
      }
      return menuItemCList;
    });
  }
}

abstract class MenuItemCContract {
  void onMenuItemCSuccess(Map result);
  void onMenuItemCError(String errorString);
}

class MenuItemCPresenter {
  MenuItemCContract _view;
  RequestMenuItemC api = new RequestMenuItemC();
  MenuItemCPresenter(this._view);
}
