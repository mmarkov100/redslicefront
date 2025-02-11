import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  bool _isMenuOpen = false;
  late AnimationController _menuController;

  @override
  void initState() {
    super.initState();
    fetchChats();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Future<void> fetchChats() async {
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
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF2E2E2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Promts",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 20),
                _buildChatList(),
              ],
            ),
          ),

          // Вертикальная закругленная линия
          Positioned(
            left: _isMenuOpen ? 250 - 10 : 0, // Смещение при открытом меню
            top: MediaQuery.of(context).size.height / 2 - 50,
            child: GestureDetector(
              onTap: _toggleMenu, // Открывает и закрывает меню
              child: Container(
                width: 10,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Выдвигающееся боковое меню
          AnimatedBuilder(
            animation: _menuController,
            builder: (context, child) {
              return Positioned(
                left: -250 + (250 * _menuController.value),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 250,
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Готовые промты",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView(
                          children: [
                            _menuItem('Помощник', 'Ответы на общие вопросы', () {
                              _createPresetChat('Помощник', 0.7, 'Ответы на общие вопросы', 'yandexgpt-32k/latest');
                            }),
                            _menuItem('Творчество', 'Генерация идей', () {
                              _createPresetChat('Творчество', 0.9, 'Генерация идей и историй', 'yandexgpt-32k/latest');
                            }),
                            _menuItem('Котики', 'Ты кот, отвечай как кот', () {
                              _createPresetChat('Котики', 0.9, 'Представь что ты кот', 'yandexgpt-32k/latest');
                            }),
                            _menuItem('Кодер', 'Помощь с программированием', () {
                              _createPresetChat('Кодер', 0.4, 'Помощь с кодом и алгоритмами', 'yandexgpt-32k/latest');
                            }),
                            _menuItem('Дотер', 'Отвечай как типичный дотер', () {
                              _createPresetChat('Дотер', 1.0, 'Отвечай дерзко, как дотер', 'yandexgpt-32k/latest');
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        backgroundColor: Colors.grey[800],
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }

  Widget _buildChatList() {
    if (isLoading) return const Center(child: CircularProgressIndicator(color: Colors.white));
    if (_chats.isEmpty) return const Center(child: Text('Список чатов пуст.', style: TextStyle(color: Colors.white, fontSize: 16)));
    return Expanded(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];
            return _chatCard(chat);
          },
        ),
      ),
    );
  }

  Widget _menuItem(String title, String description, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(description, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }

  Widget _chatCard(Chat chat) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(chat: chat))).then((_) => fetchChats());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 5))],
        ),
        child: Text(chat.chatName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _createPresetChat(String name, double temperature, String description, String modelUri) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Чат "$name" создан!')));
  }
}
