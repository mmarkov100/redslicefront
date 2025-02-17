import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:red_slice_project/features/chat/service/chat_service.dart';
import '../model/chat_model.dart';
import '../../auth/service/auth_service.dart';
import '../../user/service/user_service.dart';
import 'chat_page.dart';
import '../../auth/widgets/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final List<Chat> _chats = [];
  final ChatService chatService = ChatService();
  final UserService userService = UserService();
  bool isLoading = true;
  late AnimationController _menuController;
  late Animation<Offset> _menuAnimation;
  bool _isMenuOpen = false;
  late String _randomGreeting;

  final List<String> greetings = [
    "Как я могу быть вам полезен?",
    "Чем могу вам содействовать?",
    "Какую помощь вам требуется?",
    "Ну, что у вас стряслось?",
    "Какой вопрос будем решать?",
    "Давайте разберёмся вместе!",
    "Чем могу облегчить вашу непростую судьбинушку?",
    "Давайте помогу, а то вдруг сами справитесь, и мне скучно будет!",
    "У вас вопрос, у меня (надеюсь) ответ — рискнём?",
    "Говорите, чем помочь, а я скажу, надо ли мне это вообще!",
    "Ваши желания — мои задачи, хотя желательно не слишком сложные.",
    "Волшебная лампа на месте, джинн готов! Что загадываем?",
    "Пишите ТЗ, будем разбираться!"
  ];

  @override
  void initState() {
    super.initState();
    _fetchChats();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    ));
    _randomGreeting = greetings[Random().nextInt(greetings.length)];
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _fetchChats() async {
    setState(() => isLoading = true);
    try {
      String? jwtToken = await AuthService.getToken();
      if (jwtToken == null) throw Exception('JWT-токен не найден.');
      final List<Chat> fetchedChats = await chatService.getUserChats(jwtToken);
      fetchedChats.sort((a, b) => b.dateEdit.compareTo(a.dateEdit));
      setState(() {
        _chats.clear();
        _chats.addAll(fetchedChats);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки чатов: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      _isMenuOpen ? _menuController.forward() : _menuController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "",
            style: TextStyle(color: Colors.grey[300], fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left, // Добавлено выравнивание по левому краю
            textDirection: TextDirection.ltr, // Направление текста слева направо
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMenuOpen ? Icons.close : Icons.menu, color: Colors.white),
            onPressed: _toggleMenu,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E2E2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 250,
                  color: Colors.grey[900],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Список чатов", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _chats.isEmpty
                                ? const Center(child: Text('Список чатов пуст.', style: TextStyle(color: Colors.white)))
                                : ListView.builder(
                                    itemCount: _chats.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text(_chats[index].chatName, style: const TextStyle(color: Colors.white)),
                                        onTap: () {},
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_randomGreeting, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 500),
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Сообщить...",
                            hintStyle: TextStyle(color: Colors.white70),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SlideTransition(
              position: _menuAnimation,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 300,
                  color: Colors.grey[900],
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Готовые промты", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 10),
                      ListTile(title: const Text('Помощник', style: TextStyle(color: Colors.white)), onTap: () {}),
                      ListTile(title: const Text('Творчество', style: TextStyle(color: Colors.white)), onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
