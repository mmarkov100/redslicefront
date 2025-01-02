// Модель данных пользователя
class UserModel {
  final int _id;
  final String _email;
  final String _uidFirebase;
  final int _totalTokens;
  final int? _starredChatId;
  final DateTime _dateCreate;

  UserModel({
    required int id,
    required String email,
    required String uidFirebase,
    required int totalTokens,
    int? starredChatId,
    required DateTime dateCreate,
  })  : _id = id,
        _email = email,
        _uidFirebase = uidFirebase,
        _totalTokens = totalTokens,
        _starredChatId = starredChatId,
        _dateCreate = dateCreate;

  // Геттеры для доступа к полям
  int get id => _id;
  String get email => _email;
  String get uidFirebase => _uidFirebase;
  int get totalTokens => _totalTokens;
  int? get starredChatId => _starredChatId;
  DateTime get dateCreate => _dateCreate;

  // Фабрика для создания объекта из JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      uidFirebase: json['uidFirebase'],
      totalTokens: json['totalTokens'],
      starredChatId: json['starredChatId'],
      dateCreate: DateTime.parse(json['dateCreate']),
    );
  }

  // Конвертация объекта в JSON (если нужно)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'uidFirebase': uidFirebase,
      'totalTokens': totalTokens,
      'starredChatId': starredChatId,
      'dateCreate': dateCreate.toIso8601String(),
    };
  }
}