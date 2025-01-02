import 'package:http/http.dart' as http;
import 'package:red_slice_project/features/user/service/user_service.dart';
import 'dart:convert';

import '../model/message_model.dart';

class MessageService {
  UserService userService = UserService();
  String baseUrl = "";

  MessageService();

  // Генерация и сохранение сообщения
  Future<List<Message>> generateAndSaveMessages(
      String jwtFirebase,
      int branchId,
      String modelUri,
      double temperature,
      String context,
      List<Map<String, String>> messages,
      ) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {
        'Content-Type': 'application/json',
        'JWTFirebase': jwtFirebase,
      },
      body: json.encode({
        'branchId': branchId,
        'modelUri': modelUri,
        'temperature': temperature,
        'context': context,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((message) => Message.fromJson(message)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to generate and save messages');
    }
  }

  // Получение всех сообщений ветки
  Future<List<Message>> getBranchMessages(String jwtFirebase, int branchId) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse('$baseUrl/messages/branch/$branchId'),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((message) => Message.fromJson(message)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch branch messages');
    }
  }
}
