import 'package:http/http.dart' as http;
import 'package:red_slice_project/features/user/service/user_service.dart';
import 'dart:convert';

import '../model/branch_model.dart';

class BranchService {
  UserService userService = new UserService();
  String baseUrl = "";

  BranchService();

  // Создание новой ветки
  Future<Branch> createBranch(String jwtFirebase, int chatId, int? parentBranchId, int? messageStartId) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse('$baseUrl/branches'),
      headers: {
        'Content-Type': 'application/json',
        'JWTFirebase': jwtFirebase,
      },
      body: json.encode({
        'chatId': chatId,
        'parentBranchId': parentBranchId,
        'messageStartId': messageStartId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Branch.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create branch');
    }
  }

  // Получение всех веток чата
  Future<List<Branch>> getChatBranches(String jwtFirebase, int chatId) async {
    baseUrl = userService.baseUrl;

    final response = await http.post(
      Uri.parse('$baseUrl/branches/chat/$chatId'),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((branch) => Branch.fromJson(branch)).toList();
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch branches');
    }
  }

  // Удаление ветки
  Future<void> deleteBranch(String jwtFirebase, int branchId) async {
    baseUrl = userService.baseUrl;

    final response = await http.delete(
      Uri.parse('$baseUrl/branches/$branchId'),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 204) {
      return; // Успешное удаление
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete branch');
    }
  }
}