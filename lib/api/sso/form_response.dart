class SsoFormResponse {
  String _authId;
  List<_Callbacks> _callbacks = List<_Callbacks>.empty(growable: true);
  String _header;
  String _stage;
  String _template;

  bool get isCorrect =>
      _authId.isNotEmpty &&
      _header.isNotEmpty &&
      _stage.isNotEmpty &&
      _template.isEmpty &&
      _callbacks.length == 2;

  bool get canLogin =>
      _callbacks[0]._input[0]._value.isNotEmpty &&
      _callbacks[1]._input[0]._value.isNotEmpty;

  SsoFormResponse(
      this._authId, this._callbacks, this._header, this._stage, this._template);

  String get authId => _authId;

  factory SsoFormResponse.fromJson(Map<String, dynamic> json) {
    final authId = json['authId'];
    final callbacks = new List<_Callbacks>.empty(growable: true);
    final header = json['header'];
    final stage = json['stage'];
    final template = json['template'];

    if (json['callbacks'] != null) {
      json['callbacks'].forEach((v) {
        callbacks.add(new _Callbacks.fromJson(v));
      });
    }

    return new SsoFormResponse(authId, callbacks, header, stage, template);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['authId'] = this._authId;
    data['callbacks'] = this._callbacks.map((v) => v.toJson()).toList();
    data['header'] = this._header;
    data['stage'] = this._stage;
    data['template'] = this._template;

    return data;
  }

  void setEmailValue(String email) {
    _callbacks[0]._input[0]._value = email;
  }

  void setPassword(String password) {
    _callbacks[1]._input[0]._value = password;
  }
}

class _Callbacks {
  List<_Input> _input;
  List<_Output> _output;
  String _type;

  _Callbacks(this._input, this._output, this._type);

  factory _Callbacks.fromJson(Map<String, dynamic> json) {
    final input = List<_Input>.empty(growable: true);
    final output = List<_Output>.empty(growable: true);

    if (json['input'] != null) {
      json['input'].forEach((v) {
        input.add(new _Input.fromJson(v));
      });
    }
    if (json['output'] != null) {
      json['output'].forEach((v) {
        output.add(new _Output.fromJson(v));
      });
    }
    final type = json['type'] ?? '';

    return new _Callbacks(input, output, type);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['input'] = this._input.map((v) => v.toJson()).toList();
    data['output'] = this._output.map((v) => v.toJson()).toList();
    data['type'] = this._type;

    return data;
  }
}

class _Input {
  String _name;
  String _value;

  _Input(this._name, this._value);

  factory _Input.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final value = json['value'] ?? '';

    return new _Input(name, value);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this._name;
    data['value'] = this._value;
    return data;
  }
}

class _Output {
  String _name;
  String _value;

  _Output(this._name, this._value);

  factory _Output.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? '';
    final value = json['value'] ?? '';

    return new _Output(name, value);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this._name;
    data['value'] = this._value;
    return data;
  }
}
