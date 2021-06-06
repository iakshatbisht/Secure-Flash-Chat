class MessageModel{
  String? _content;
  String? _idFrom;
  String? _idTo;
  String? _isSeen;
  String? _timestamp;
  int? _type;

  String? get content => _content;

  set content(value) {
    _content = value;
  }

  String? get idFrom => _idFrom;

  set idFrom(value) {
    _idFrom = value;
  }

  String? get idTo => _idTo;

  set idTo(value) {
    _idTo = value;
  }

  String? get isSeen => _isSeen;

  set isSeen(value) {
    _isSeen = value;
  }

  String? get timestamp => _timestamp;

  set timestamp(value) {
    _timestamp = value;
  }

  int? get type => _type;

  set type(value) {
    _type = value;
  }

  Map toMap() {
    var map = Map<String, dynamic>();
    map['_content'] = content;
    map['_idFrom'] = idFrom;
    map['_idTo'] = idTo;
    map['_isSeen'] = isSeen;
    map['_timestamp'] = timestamp;
    map['_type'] = type;
    return map;
  }

  MessageModel fromMap(Map<String, dynamic> map) {
    MessageModel _message = MessageModel();
    _message.content = map['_content'];
    _message.idFrom = map['_idFrom'];
    _message.idTo = map['_idTo'];
    _message.isSeen = map['_isSeen'];
    _message.timestamp = map['_timestamp'];
    _message.type = map['_type'];
    return _message;
  }

}