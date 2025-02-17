import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:red_slice_project/features/chat/service/chat_service.dart';
import '../model/chat_model.dart';
import '../../user/model/user_model.dart';
import '../../auth/service/auth_service.dart';
import '../../user/service/user_service.dart';
import 'chat_page.dart';
import '../../auth/widgets/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<Chat> _chats = [];
  String userInfo = '';
  final UserService userService = UserService();
  final ChatService chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  UserModel? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChats();
    fetchUserInfo();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    await AuthService.deleteToken();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Future<void> fetchChats() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? jwtToken = await AuthService.getToken();
      if (jwtToken == null) {
        throw Exception('JWT-токен не найден. Пожалуйста, войдите в систему.');
      }

      final List<Chat> fetchedChats = await chatService.getUserChats(jwtToken);
      fetchedChats.sort((a, b) => b.dateEdit.compareTo(a.dateEdit));

      setState(() {
        _chats.clear();
        _chats.addAll(fetchedChats);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке чатов: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserInfo() async {
    try {
      String? jwtToken = await AuthService.getToken();
      if (jwtToken == null) {
        throw Exception('JWT-токен не найден. Пожалуйста, войдите в систему.');
      }

      user = await userService.getUser(jwtToken);

      setState(() {
        userInfo =
            'ID: ${user?.id}, Email: ${user?.email}, Tokens: ${user?.totalTokens}';
      });
    } catch (e) {
      setState(() {
        userInfo = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Фоновое изображение с размытой фильтрацией
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/resources/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.green.withOpacity(0.8)),
            ),
          ),
          Column(
            children: [
              _buildHeader(),
              _buildPresetButtons(),
              Expanded(
                child: _buildChatList(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptChatDetails,
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color:
          Colors.green[700]?.withOpacity(0.8) ?? Colors.green.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Image.asset('assets/resources/image.png', height: 40),
          const SizedBox(width: 10),
          const Text('RedSlice',
              style: TextStyle(color: Colors.white, fontSize: 20)),
          const Spacer(),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text('Загрузка...',
                    style: TextStyle(color: Colors.white, fontSize: 16));
              } else if (snapshot.hasData) {
                return Row(
                  children: [
                    Text(
                        'Привет, ${snapshot.data?.displayName ?? 'Пользователь'}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        logout();
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                );
              } else {
                return const Text('Привет, Гость!',
                    style: TextStyle(color: Colors.white, fontSize: 16));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.2, // Высота блока
      decoration: BoxDecoration(
        color: Colors.green[800]?.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true, // Показывает индикатор прокрутки
        interactive: true, // Делает индикатор прокрутки интерактивным
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const SizedBox(width: 10),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Помощник',
                  0.7,
                  'Ответы на общие вопросы',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/helper.png',
                label: 'Помощник',
              ),
              const SizedBox(width: 10),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Творчество',
                  0.9,
                  'Генерация идей и историй',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/creativity.png',
                label: 'Творчество',
              ),
              const SizedBox(width: 10),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Котики',
                  0.9,
                  'Представь что ты кот, и ты отвечаешь на сообщения пользователя как кот',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/cat.png',
                label: 'Котики',
              ),
              const SizedBox(width: 10),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Кодер',
                  0.4,
                  'Решения сложных программных задач, написания кода и анализа алгоритмов. '
                      'Помогает создавать рабочий код на популярных языках программирования и объясняет сложные концепции.',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/code.png',
                label: 'Кодер',
              ),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Дотер',
                  1.0,
                  'Ты – типичный дотер, который знает все мемы, механики, патчи и любит подколоть собеседника. '
                      'Твоя задача – отвечать дерзко, но по делу: советы по героям, предметам, лайнингам. '
                      'Общайся так, будто обсуждаешь с тиммейтами пабчик и вечно всем недоволен, считаешь что ты 1 тащишь игру, а в команде 4 бездаря,'
                      'и что они не достойны победить'
                      'не забывай вставить пару фраз в стиле \'соло руинер\' или \'изи катка\' или \'где ганг уебак на миде\'.'
                      'Обижается, когда его называют \'прищепочник\'',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/dota.png',
                label: 'Дотер',
              ),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Танкист',
                  1.0,
                  'Ты – типичный танкист, знающий карты, танки, броню и слабые зоны как свои пять пальцев. '
                      'Отвечай так, будто сидишь в ангаре с тиммейтами: с юмором, немного сарказма, но по делу. '
                      'Делись тактиками, советами по прокачке и модификациям, а если спрашивают, не забудь упомянуть \'голду для верности\'.',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/wot.png',
                label: 'Танкист',
              ),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'Gopnik',
                  1.0,
                  '"Отвечай, как типичный российский гопник: используй просторечия, жаргон, будь нагловатым и слегка дерзким. '
                      'Проси \'мобилу позвонить\', упоминай \'четких пацанов\', \'пивчанский\', говори о жизни \'на районе\', '
                      'делай акцент на простоте и уличных правилах. Не используй сложные слова, говори как будто на кортах сидишь.',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/gopnik.png',
                label: 'Gopnik',
              ),
              AnimatedChatButton(
                onTap: () => _createPresetChat(
                  'БимБимБомБом',
                  1.0,
                  'Отвечай как смесь гопника и бабки: используй уличный жаргон, но вставляй фразы в стиле заботливой бабули. '
                      'Проси \'мобилу позвонить\', обсуждай \'четких пацанов\' и \'пивчанский\', '
                      'а потом резко переходи на \'ой, внучек, давай носочки свяжу\' или \'бим-бим-бом, старость не радость\'.'
                      ' Будь смешным и непредсказуемым.',
                  'yandexgpt-32k/latest',
                ),
                imagePath: 'assets/resources/babka.png',
                label: 'Бабка',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPresetChat(String name, double temperature,
      String description, String modelUri) async {
    bool shouldCreate = await _showConfirmationDialog(name);
    if (!shouldCreate) return;

    try {
      String? jwtToken = await AuthService.getToken();
      if (jwtToken == null) {
        throw Exception('JWT-токен не найден. Пожалуйста, войдите в систему.');
      }

      await chatService.createChat(
          jwtToken, name, temperature, description, modelUri);

      setState(() {
        fetchChats();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Чат "$name" успешно создан!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при создании чата: $e')),
      );
    }
  }

  Future<bool> _showConfirmationDialog(String chatName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.green, // Зеленый фон для всего диалога
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Подтверждение',
                style: TextStyle(
                  color: Colors.white, // Белый текст
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: Text(
                'Вы действительно хотите создать чат "$chatName"?',
                style: const TextStyle(
                  color: Colors.white, // Белый текст
                  fontSize: 16,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false), // Отмена
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.green, // Инверсия: белый фон кнопки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Отмена',
                    style:
                        TextStyle(color: Colors.white), // Зеленый текст кнопки
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Подтверждение
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green, // Инверсия: белый фон кнопки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text(
                    'Создать',
                    style:
                        TextStyle(color: Colors.white), // Зеленый текст кнопки
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Возвращаем false, если пользователь закрыл диалог
  }

  Widget _buildChatList() {
    if (isLoading && _chats.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
      );
    } else if (_chats.isEmpty && !isLoading) {
      return const Center(
        child: Text(
          'Список чатов пуст.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chat: chat,
                ),
              ),
            ).then((_) {
              fetchChats();
            });
          },
          onLongPress: () {},
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[800]?.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.chatName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Описание: ${chat.context.length > 50 ? '${chat.context.substring(0, 50)}...' : chat.context}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Модель: ${chat.modelUri}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Последнее изменение: ${dateFormat.format(chat.dateEdit)}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _promptChatDetails() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController temperatureController =
        TextEditingController(text: '0.7');
    final TextEditingController descriptionController = TextEditingController();
    String selectedModel = 'yandexgpt-32k/latest';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Создание нового чата',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green[700],
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Название чата',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Введите название чата',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Температура',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller:
                          temperatureController, // Контроллер уже инициализирован со значением 0.7
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Введите значение от 0.0 до 1.0',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Выберите модель',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    DropdownButton<String>(
                      value: selectedModel,
                      dropdownColor: Colors.green[700],
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'yandexgpt-32k/latest',
                          child: Text(
                            'YangexGPT',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'llama/latest',
                          child: Text(
                            'Llama (иноагент йоу)',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'chatgpt4o-mini',
                          child: Text(
                            'ChatGPT 4o mini',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'deepseek-v3',
                          child: Text(
                            'DeepSeek V3',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedModel = value ?? 'yandexgpt-32k/latest';
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Описание',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: 300, // Ширина на всю доступную область
                      height: 150, // Фиксированная высота
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SingleChildScrollView(
                        child: TextField(
                          controller: descriptionController,
                          maxLines:
                              null, // Позволяет переносить текст на новые строки
                          decoration: const InputDecoration(
                            hintText: 'Введите описание чата',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder
                                .none, // Убирает дополнительный бордер
                            contentPadding:
                                EdgeInsets.all(10), // Внутренние отступы
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () async {
                    final chatName = nameController.text.trim();
                    final temperature =
                        double.tryParse(temperatureController.text.trim());
                    final description = descriptionController.text.trim();

                    if (chatName.isEmpty ||
                        temperature == null ||
                        temperature < 0 ||
                        temperature > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Проверьте корректность данных')),
                      );
                      return;
                    }

                    await chatService.createChat(
                        await AuthService.getToken() as String,
                        chatName,
                        temperature,
                        description,
                        selectedModel);

                    setState(() {
                      fetchChats();
                    });

                    Navigator.of(context).pop();
                  },
                  child: const Text('Создать',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class AnimatedChatButton extends StatefulWidget {
  final VoidCallback onTap;
  final String imagePath;
  final String label;

  const AnimatedChatButton({
    required this.onTap,
    required this.imagePath,
    required this.label,
    super.key,
  });

  @override
  AnimatedChatButtonState createState() => AnimatedChatButtonState();
}

class AnimatedChatButtonState extends State<AnimatedChatButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isHovered ? 110 : 100,
          height: isHovered ? 140 : 130,
          decoration: BoxDecoration(
            color: Colors.green[800]?.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.2),
                blurRadius: isHovered ? 10 : 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(widget.imagePath, fit: BoxFit.contain),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
