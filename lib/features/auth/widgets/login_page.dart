import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_slice_project/features/auth/service/auth_service.dart';
import 'background_image.dart';
import 'register_page.dart';
import '../../chat/widgets/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  get userService => null;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Вход в Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Получение токена Firebase
      String? token = await userCredential.user?.getIdToken();
      // Сохранение токена
      await AuthService.saveToken(token!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Успешный вход: ${userCredential.user?.email}')));

      // Переход на главную страницу
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Пользователь не найден';
            break;
          case 'wrong-password':
            errorMessage = 'Неверный пароль';
            break;
          case 'invalid-email':
            errorMessage = 'Некорректный email';
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Введите email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Пароль должен быть не менее 6 символов';
    return null;
  }



  @override
  Widget build(BuildContext context) {
    return ScreenBase( // Виджет сначала фоновой картинки
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
                controller: _emailController,
                validator: _validateEmail,
                textInputAction: TextInputAction.next, // Переход к следующему полю
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
                textInputAction: TextInputAction.done, // Выполнение действия
                onFieldSubmitted: (value) => _login(), // Нажатие Enter
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                child: Text('Войти', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
                },
              child: const Text(
                'Регистрация',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
