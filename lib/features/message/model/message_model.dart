// Модель данных сообщения
class Message {
  final int _id;
  final int _branchId;
  final String _role;
  final String _text;
  final int _totalTokens;
  final int _inputTokens;
  final int _completionTokens;
  final DateTime _dateCreate;

  Message({
    required int id,
    required int branchId,
    required String role,
    required String text,
    required int totalTokens,
    required int inputTokens,
    required int completionTokens,
    required DateTime dateCreate,
  })  : _id = id,
        _branchId = branchId,
        _role = role,
        _text = text,
        _totalTokens = totalTokens,
        _inputTokens = inputTokens,
        _completionTokens = completionTokens,
        _dateCreate = dateCreate;

  // Геттеры для доступа к полям
  int get id => _id;
  int get branchId => _branchId;
  String get role => _role;
  String get text => _text;
  int get totalTokens => _totalTokens;
  int get inputTokens => _inputTokens;
  int get completionTokens => _completionTokens;
  DateTime get dateCreate => _dateCreate;

  // Фабрика для создания объекта из JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      branchId: json['branchId'],
      role: json['role'],
      text: json['text'],
      totalTokens: json['totalTokens'],
      inputTokens: json['inputTokens'],
      completionTokens: json['completionTokens'],
      dateCreate: DateTime.parse(json['dateCreate']),
    );
  }

  // Конвертация объекта в JSON (если нужно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branchId': branchId,
      'role': role,
      'text': text,
      'totalTokens': totalTokens,
      'inputTokens': inputTokens,
      'completionTokens': completionTokens,
      'dateCreate': dateCreate.toIso8601String(),
    };
  }
}