class TableBooking {
  int _id;
  String _tableID, _tableName, _slotID, _slotName, _date, _day;
  TableBooking(this._id, this._tableID, this._tableName, this._slotID,
      this._slotName, this._date, this._day);
  TableBooking.map(Map obj) {
    this._id = int.parse(obj['id'].toString());
    this._tableID = obj['tableID'];
    this._tableName = obj['tableName'];
    this._slotID = obj['slotID'];
    this._slotName = obj['slotName'];
    this._date = obj['date'];
    this._day = obj['day'];
  }
  int get id => _id;
  String get tableID => _tableID;
  String get tableName => _tableName;
  String get slotID => _slotID;
  String get slotName => _slotName;
  String get date => _date;
  String get day => _day;
  Map toMap() {
    Map obj = new Map();
    obj['id'] = this._id;
    obj['tableID'] = this._tableID;
    obj['tableName'] = this._tableName;
    obj['slotID'] = this._slotID;
    obj['slotName'] = this._slotName;
    obj['date'] = this._date;
    obj['day'] = this._day;
    return obj;
  }

  @override
  String toString() {
    return tableName;
  }
}
