import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:red_slice_project/features/user/model/user_model.dart';

class UserService {
  final String baseUrl = 'http://localhost:8080';

  UserService();

  Future<UserModel> registerUser(String jwtFirebase, String email) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users"),
      headers: {
        'Content-Type': 'application/json',
        'JWTFirebase': jwtFirebase,
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to register user');
    }
  }

  Future<UserModel> getUser(String jwtFirebase) async {
    final response = await http.post(
      Uri.parse("$baseUrl/users/user"),
      headers: {
        'JWTFirebase': jwtFirebase,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserModel.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch user');
    }
  }
}