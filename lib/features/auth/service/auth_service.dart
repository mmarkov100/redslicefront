
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Обновление токена
      return await user.getIdToken(true);
    } catch (e) {
      // Если токен устарел или пользователь не авторизован
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token); // Сохраняем токен с ключом 'authToken'
  }

  static Future<void> deleteToken() async {
    await FirebaseAuth.instance.signOut();
  }
}