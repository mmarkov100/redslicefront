import 'package:http/http.dart' as http;
import 'package:red_slice_project/features/user/service/user_service.dart';
import 'dart:convert';

import '../model/chat_model.dart';

class ChatService {
  UserService userService = new UserService();
  String baseUrl = "";

  ChatService();

  // Создание нового чата
  Future<Chat> createChat(
      String jwtFirebase,
      String chatName,
      double temperature,
      String context,
      String modelUri) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse("$baseUrl/chats"),
      headers: {
        'Content-Type': 'application/json',
        'JWTFirebase': jwtFirebase,
      },
      body: json.encode({
        'chatName': chatName,
        'temperature': temperature,
        'context': context,
        'modelUri': modelUri,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Chat.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create chat');
    }
  }

  // Получение списка чатов пользователя
  Future<List<Chat>> getUserChats(String jwtFirebase) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse('$baseUrl/chats/user'),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((chat) => Chat.fromJson(chat)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch user chats');
    }
  }

  // Обновление чата
  Future<Chat> updateChat(
      String jwtFirebase,
      int chatId,
      String chatName,
      double temperature,
      String context,
      String modelUri,
      int? selectedBranchId) async {
    baseUrl = userService.baseUrl;

    final response = await http.put(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {
        'Content-Type': 'application/json',
        'JWTFirebase': jwtFirebase,
      },
      body: json.encode({
        'chatName': chatName,
        'temperature': temperature,
        'context': context,
        'modelUri': modelUri,
        'selectedBranchId': selectedBranchId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Chat.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to update chat');
    }
  }

  // Удаление чата
  Future<void> deleteChat(String jwtFirebase, int chatId) async {
    baseUrl = userService.baseUrl;

    final response = await http.delete(
      Uri.parse('$baseUrl/chats/$chatId'),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 204) {
      return; // Успешное удаление
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete chat');
    }
  }
}