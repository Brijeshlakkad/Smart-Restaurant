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