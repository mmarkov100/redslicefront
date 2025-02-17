import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:red_slice_project/features/auth/widgets/register_page.dart';
import 'package:red_slice_project/features/chat/widgets/home_page.dart';
import 'package:red_slice_project/features/auth/widgets/login_page.dart';
import 'package:red_slice_project/features/auth/service/auth_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Инициализация Firebase

  String? token = await AuthService.getToken();

  runApp(MyApp(
    isLoggedIn: token != null,
  ));
}

class MyApp extends StatelessWidget {
  final dynamic isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Promts',
      home: isLoggedIn ? const HomePage() : const HomePage(),
    );
  }
}
