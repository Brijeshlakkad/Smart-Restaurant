import 'package:smart_restaurant/utils/network_util.dart';
import 'package:smart_restaurant/utils/custom_exception.dart';

class Category {
  String _name, _image;
  int _id;
  Category(this._name, this._image, this._id);
  String get name => _name;
  String get image => _image;
  int get id => _id;
  Category.map(Map obj) {
    this._id = int.parse(obj['id'].toString());
    this._name = obj['name'];
    this._image = obj['image'];
  }
  Map toMap() {
    Map<String, dynamic> obj = new Map<String, dynamic>();
    obj['name'] = _name;
    obj['image'] = _image;
    obj['id'] = _id;
    return obj;
  }
}

class RequestCategory {
  NetworkUtil _netUtil = new NetworkUtil();
  static final baseURL = 'http://www.smartrestaurant.ml/server_files/customer';
  static final finalURL = baseURL + "/category_actions.php";
  Future<List<Category>> getCategoryList() async {
    return _netUtil.post(finalURL, body: {
      "action": "1",
    }).then((dynamic res) {
      print(res.toString());
      if (res["error"]) throw new FormException(res["errorMessage"]);
      int total = int.parse(res['user']['totalRows'].toString());
      List<Category> categoryList = new List<Category>();
      for (int i = 0; i < total; i++) {
        categoryList.add(Category.map(res['user']['category'][i]));
      }
      return categoryList;
    });
  }
}

abstract class CategoryContract {
  void onCategorySuccess();
  void onCategoryError();
}

class CategoryPresenter {
  CategoryContract _view;
  RequestCategory api = new RequestCategory();
  CategoryPresenter(this._view);
}
