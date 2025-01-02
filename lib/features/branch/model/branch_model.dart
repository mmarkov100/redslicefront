// Модель данных ветки
class Branch {
  final int _id;
  final int _chatId;
  final int? _parentBranchId;
  final int? _messageStartId;
  final bool _isRoot;
  final DateTime _dateEdit;
  final DateTime _dateCreate;

  Branch({
    required int id,
    required int chatId,
    int? parentBranchId,
    int? messageStartId,
    required bool isRoot,
    required DateTime dateEdit,
    required DateTime dateCreate,
  })  : _id = id,
        _chatId = chatId,
        _parentBranchId = parentBranchId,
        _messageStartId = messageStartId,
        _isRoot = isRoot,
        _dateEdit = dateEdit,
        _dateCreate = dateCreate;

  // Геттеры для доступа к полям
  int get id => _id;
  int get chatId => _chatId;
  int? get parentBranchId => _parentBranchId;
  int? get messageStartId => _messageStartId;
  bool get isRoot => _isRoot;
  DateTime get dateEdit => _dateEdit;
  DateTime get dateCreate => _dateCreate;

  // Фабрика для создания объекта из JSON
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      chatId: json['chatId'],
      parentBranchId: json['parentBranchId'],
      messageStartId: json['messageStartId'],
      isRoot: json['isRoot'],
      dateEdit: DateTime.parse(json['dateEdit']),
      dateCreate: DateTime.parse(json['dateCreate']),
    );
  }

  // Конвертация объекта в JSON (если нужно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'parentBranchId': parentBranchId,
      'messageStartId': messageStartId,
      'isRoot': isRoot,
      'dateEdit': dateEdit.toIso8601String(),
      'dateCreate': dateCreate.toIso8601String(),
    };
  }
}