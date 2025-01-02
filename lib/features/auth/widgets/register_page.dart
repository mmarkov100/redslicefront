import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_slice_project/features/auth/service/auth_service.dart';
import 'package:red_slice_project/features/user/service/user_service.dart';
import 'background_image.dart';
import 'login_page.dart';
import '../../chat/widgets/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserService userService = UserService();

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Обновление имени пользователя
      await userCredential.user
          ?.updateDisplayName(_usernameController.text.trim());

      // Получение токена Firebase
      String? token = await userCredential.user?.getIdToken();

      // Сохранение токена
      await AuthService.saveToken(token!);

      // Получение токена из AuthService
      String? jwtFirebase = await AuthService.getToken();
      if (jwtFirebase == null) {
        throw Exception('Токен Firebase не найден в SharedPreferences');
      }

      // Регистрация пользователя в базе данных
      await userService.registerUser(jwtFirebase, _emailController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Успешная регистрация: ${userCredential.user?.email}')),
      );

      // Перенаправление на главную страницу
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'Этот email уже используется';
            break;
          case 'invalid-email':
            errorMessage = 'Некорректный email';
            break;
          case 'weak-password':
            errorMessage = 'Пароль слишком слабый';
            break;
          default:
            errorMessage = 'Ошибка: ${e.message}';
        }
      } else {
        errorMessage = 'Неизвестная ошибка: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Введите имя пользователя';
    if (value.length > 10) return 'Имя не должно быть длиннее 10 символов';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBase(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  'assets/resources/image.png',
                  height: 80,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 450,
              child: TextFormField(
                controller: _usernameController,
                validator: _validateUsername,
                maxLength: 10,
                // Максимальная длина имени пользователя
                textInputAction: TextInputAction.next,
                // Переход к следующему полю
                decoration: InputDecoration(
                  labelText: 'Имя пользователя',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 450,
              child: TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                // Переход к следующему полю
                decoration: InputDecoration(
                  labelText: 'Email',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 450,
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: _validatePassword,
                textInputAction: TextInputAction.done,
                // Выполнение действия
                onFieldSubmitted: (value) => _register(),
                // Нажатие Enter
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      child: Text('Зарегистрироваться',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                'Авторизоваться',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
