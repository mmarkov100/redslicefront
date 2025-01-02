import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import 'package:red_slice_project/features/chat/model/chat_model.dart';
import 'package:red_slice_project/features/message/model/message_model.dart';
import 'package:red_slice_project/features/chat/service/chat_service.dart';

import '../../auth/service/auth_service.dart';
import '../../message/service/message_service.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage({
    super.key,
    required this.chat,
  });

  @override
  ChatPageState createState() => ChatPageState();
}


class ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Message> _messages = [];
  final MessageService _messageService = MessageService();
  bool _isMessageEmpty = true;
  final ScrollController _scrollController = ScrollController(); // Добавляем ScrollController
  ChatService chatService = ChatService();
  bool _isGenerating = false; // Флаг для отслеживания состояния генерации
  bool _isLoading = false; // Флаг для первоначальной загрузки сообщений
  bool isSavingChat = false; // Флаг для настроек чата

  late String selectedModel;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _isMessageEmpty = _messageController.text.trim().isEmpty;
      });
    });

    // Инициализируем выбранную модель текущим значением чата
    selectedModel = widget.chat.modelUri;
    _fetchMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose(); // Не забываем освободить контроллер
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    try {
      _isLoading = true;

      final jwtToken = await AuthService.getToken();
      if (jwtToken == null) throw Exception('JWT-токен отсутствует.');

      final branchId = widget.chat.selectedBranchId;
      if (branchId == null) throw Exception('Branch ID отсутствует.');

      final messages = await _messageService.getBranchMessages(jwtToken, branchId);

      messages.sort((b, a) => b.id.compareTo(a.id));

      setState(() {
        final existingIds = _messages.map((msg) => msg.id).toSet();
        _messages.addAll(messages.where((msg) => !existingIds.contains(msg.id)));
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки сообщений: $e')),
      );
    } finally {
      _isLoading = false;
    }
  }

  void _scrollToBottom() {
    // Прокрутка вниз с анимацией
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    _scrollToBottom();
    final text = _messageController.text.trim();

    if (text.isNotEmpty && !_isGenerating) {

      setState(() {
        _isGenerating = true; // Начинаем генерацию
      });

      try {
        final jwtToken = await AuthService.getToken();
        if (jwtToken == null) throw Exception('JWT-токен отсутствует.');

        final branchId = widget.chat.selectedBranchId;
        if (branchId == null) throw Exception('Branch ID отсутствует.');

        // Преобразуем все сообщения в формате, ожидаемом сервером
        final messageHistory = _messages.map((message) {
          return {
            'role': message.role,
            'text': message.text,
          };
        }).toList();

        // Добавляем новое сообщение пользователя
        messageHistory.add({'role': 'user', 'text': text});

        // Генерация и сохранение новых сообщений
        final newMessages = await _messageService.generateAndSaveMessages(
          jwtToken,
          branchId,
          widget.chat.modelUri,
          widget.chat.temperature,
          widget.chat.context,
          messageHistory, // Отправляем всю историю сообщений
        );

        setState(() {
          final existingIds = _messages.map((msg) => msg.id).toSet();
          _messages.addAll(newMessages.where((msg) => !existingIds.contains(msg.id)));
        });

        _scrollToBottom();
        _messageController.clear();
        _focusNode.requestFocus();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки сообщения: $e')),
        );
      }
      finally {
        setState(() {
          _isGenerating = false; // Завершаем генерацию
          _messageController.clear();
          _focusNode.requestFocus();
        });
      }
    }
  }


//TODO Виджет показа настроек чата
  void _showChatSettings() {
    final TextEditingController nameController =
    TextEditingController(text: widget.chat.chatName);
    final TextEditingController temperatureController =
    TextEditingController(text: widget.chat.temperature.toString());
    final TextEditingController contextController =
    TextEditingController(text: widget.chat.context);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Настройки чата',
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
                      controller: temperatureController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                            'yandexgpt-32k/latest',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'llama/latest',
                          child: Text(
                            'llama/latest',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedModel = value ?? 'yandexgpt-32k/latest'; // Обновляем выбранную модель
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Описание',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: contextController,
                      decoration: InputDecoration(
                        hintText: 'Введите описание чата',
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Отмена', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: isSavingChat
                      ? null
                      : () async {
                    final updatedName = nameController.text.trim();
                    final updatedTemperature =
                    double.tryParse(temperatureController.text.trim());
                    final updatedContext = contextController.text.trim();

                    if (updatedName.isEmpty ||
                        updatedTemperature == null ||
                        updatedTemperature < 0 ||
                        updatedTemperature > 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Проверьте корректность данных'),
                        ),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSavingChat = true; // Показываем индикатор загрузки
                    });

                    try {
                      // Отправляем запрос на изменение настроек чата
                      final updatedChat = await chatService.updateChat(
                        await AuthService.getToken() as String, // JWT токен
                        widget.chat.id,
                        updatedName,
                        updatedTemperature,
                        updatedContext,
                        selectedModel,
                        widget.chat.selectedBranchId,
                      );

                      // Обновляем состояние чата
                      setState(() {
                        widget.chat.chatName = updatedChat.chatName;
                        widget.chat.temperature = updatedChat.temperature;
                        widget.chat.context = updatedChat.context;
                        widget.chat.modelUri = updatedChat.modelUri;
                        widget.chat.dateEdit = updatedChat.dateEdit;
                      });

                      Navigator.of(context).pop(); // Закрываем диалог настроек
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка обновления настроек: $e')),
                      );
                    } finally {
                      setDialogState(() {
                        isSavingChat = false; // Скрываем индикатор загрузки
                      });
                    }
                  },
                  child: isSavingChat
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.0,
                  )
                      : const Text(
                    'Сохранить',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: _confirmDeleteChat,
                  child: const Text('Удалить чат', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Todo Виджет подтверждения удаления чата
  void _confirmDeleteChat() {
    Navigator.of(context).pop(); // Закрываем меню настроек
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Удалить чат?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green[700],
          content: const Text(
            'Вы уверены, что хотите удалить этот чат?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Отменяем подтверждение и выходим
              child: const Text('Отмена', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final jwtToken = await AuthService.getToken();
                  if (jwtToken == null) throw Exception('JWT-токен отсутствует.');

                  await chatService.deleteChat(jwtToken, widget.chat.id);

                  // Показ сообщения об успешном удалении
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Чат успешно удалён.')),
                  );

                  Navigator.of(context).pop(); // Закрываем диалог
                  Navigator.of(context).pop(); // Возвращаемся на экран чатов
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Ошибка при удалении чата: $e')),
                  );
                }
              },
              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Todo Основной виджет
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chat.chatName,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showChatSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
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
              Expanded(
                child: Stack(
                  children: [
                    // Todo ListView
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    else if (_messages.isEmpty) const Center(
                      child: Text(
                        'Список сообщений пуст. Нажмите сообщение в чат!',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                    else
                      ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUserMessage = message.role == 'user';

                        // Форматируем дату
                        final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
                        final formattedDate = dateFormat.format(message.dateCreate);

                        return Align(
                          alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              // Текст сообщения
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 500,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isUserMessage ? Colors.blue : Colors.grey[700],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Html(
                                    data: message.text, // HTML-код сообщения
                                    style: {
                                      "body": Style(
                                        color: Colors.white,
                                        fontSize: FontSize(14),
                                        margin: Margins.zero,
                                      ),
                                    },
                                  ),
                                ),
                              ),


                              Row(
                                mainAxisSize: MainAxisSize.min, // Подгоняет по размеру контента
                                children: [
                                  // Дата создания
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 10), // Отступ между датой и кнопкой
                                  // Кнопка копирования
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.white70, size: 16),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: message.text));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Сообщение скопировано!'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    tooltip: 'Копировать сообщение', // Подсказка при наведении
                                    constraints: const BoxConstraints(), // Уменьшает размер кнопки
                                    padding: EdgeInsets.zero, // Убирает отступы внутри кнопки
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green[700],
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Введите сообщение...',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onSubmitted: (_) {
                          if (!_isMessageEmpty && !_isGenerating) {
                            _sendMessage();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      iconSize: 35,
                      icon: (_isGenerating)
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Icon(Icons.send,
                          color: (_isMessageEmpty || _isGenerating)
                              ? Colors.grey
                              : Colors.white),
                      onPressed: (_isMessageEmpty || _isGenerating)
                          ? null
                          : _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
