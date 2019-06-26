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