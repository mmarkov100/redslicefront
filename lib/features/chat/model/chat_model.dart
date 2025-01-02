class Chat {
  int _id;
  int _userId;
  String _chatName;
  double _temperature;
  String _context;
  String _modelUri;
  int? _selectedBranchId;
  DateTime _dateEdit;
  DateTime _dateCreate;

  Chat({
    required int id,
    required int userId,
    required String chatName,
    required double temperature,
    required String context,
    required String modelUri,
    int? selectedBranchId,
    required DateTime dateEdit,
    required DateTime dateCreate,
  })  : _id = id,
        _userId = userId,
        _chatName = chatName,
        _temperature = temperature,
        _context = context,
        _modelUri = modelUri,
        _selectedBranchId = selectedBranchId,
        _dateEdit = dateEdit,
        _dateCreate = dateCreate;

  // Геттеры
  int get id => _id;
  int get userId => _userId;
  String get chatName => _chatName;
  double get temperature => _temperature;
  String get context => _context;
  String get modelUri => _modelUri;
  int? get selectedBranchId => _selectedBranchId;
  DateTime get dateEdit => _dateEdit;
  DateTime get dateCreate => _dateCreate;

  // Сеттеры
  set chatName(String value) => _chatName = value;
  set temperature(double value) => _temperature = value;
  set context(String value) => _context = value;
  set modelUri(String value) => _modelUri = value;
  set selectedBranchId(int? value) => _selectedBranchId = value;
  set dateEdit(DateTime value) => _dateEdit = value;

  // Фабрика для создания объекта из JSON
  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      userId: json['userId'],
      chatName: json['chatName'],
      temperature: json['temperature'],
      context: json['context'],
      modelUri: json['modelUri'],
      selectedBranchId: json['selectedBranchId'],
      dateEdit: DateTime.parse(json['dateEdit']),
      dateCreate: DateTime.parse(json['dateCreate']),
    );
  }

  // Конвертация объекта в JSON (если нужно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'chatName': chatName,
      'temperature': temperature,
      'context': context,
      'modelUri': modelUri,
      'selectedBranchId': selectedBranchId,
      'dateEdit': dateEdit.toIso8601String(),
      'dateCreate': dateCreate.toIso8601String(),
    };
  }
}
