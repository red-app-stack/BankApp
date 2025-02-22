import 'dart:async';
import 'dart:math';
import 'package:bank_app/controllers/auth_controller.dart';
import 'package:bank_app/services/server_check_helper.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';
import '../../models/account_model.dart';
import '../../services/user_service.dart';
import '../shared/animations.dart';

_SupportScreenState? _currentState;

// Add this class to handle response actions
class BotResponse {
  final String message;
  final bool? confirmation;
  final Function()? action;

  BotResponse(this.message, {this.action, this.confirmation = false});
}

BotResponse? _lastResponse;

// Replace the existing _getBotResponse method with this enhanced version
BotResponse _getBotResponse(String userMessage) {
  // Handle confirmations first
  if (_lastResponse?.action != null && _isCancelation(userMessage)) {
    BotResponse response = BotResponse('Действие отменено пользователем.',
        action: null, confirmation: false);
    _lastResponse = response;
    return response;
  }
  if (_lastResponse?.action != null &&
      _isConfirmation(userMessage) &&
      !_isCancelation(userMessage)) {
    BotResponse response = BotResponse('Отлично! Сейчас все сделаем.',
        action: _lastResponse!.action, confirmation: true);
    _lastResponse = response;
    return response;
  }
  if (userMessage.contains('привет')) {
    _lastResponse = BotResponse('Здравствуйте! Чем могу помочь?');
    return _lastResponse!;
  } else if (userMessage.contains('депозит')) {
    _lastResponse = BotResponse(
      'Для оформления депозита вам необходимо открыть страницу создания депозита. Хотите перейти к оформлению?',
      action: () => _startDepositApplication(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('кредит')) {
    _lastResponse = BotResponse(
      'Для оформления кредита вам необходимо подготовить паспорт и справку о доходах. Хотите перейти к оформлению?',
      action: () => _startCreditApplication(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('карт')) {
    _lastResponse = BotResponse(
      'У нас есть дебетовые и кредитные карты. Хотите перейти к оформлению?',
      action: () => _startDebitApplication(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('баланс')) {
    _lastResponse = BotResponse(
      'Хотите проверить баланс вашего счета?',
      action: () => _checkBalance(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('перевод')) {
    _lastResponse = BotResponse(
      'Готов помочь с переводом по номеру. Хотите открыть форму перевода?',
      action: () => _initiatePhoneTransfer(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('контакт')) {
    _lastResponse = BotResponse(
      'Вы можете связаться с нами по телефону или email. Открыть контакты?',
      action: () => _showContacts(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('silly')) {
    _lastResponse = BotResponse(
      'Вы хотите сделать что то глупое?',
      action: () => _doSomethingSilly(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('процент') || userMessage.contains('ставк')) {
    _lastResponse = BotResponse(
      'Наши ставки по депозитам начинаются от 14% годовых для KZT. Хотите узнать подробнее?',
      action: () => _startDepositApplication(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('валют') || userMessage.contains('курс')) {
    _lastResponse = BotResponse(
      'Актуальный курс валют: USD - 415 KZT, EUR - 495 KZT. Курсы могут изменяться в течение дня. Хотите перейти к обмену?',
    );
    return _lastResponse!;
  } else if (userMessage.contains('банкомат') || userMessage.contains('офис')) {
    _lastResponse = BotResponse(
      'Чтобы найти ближайший банкомат или отделение, воспользуйтесь нашим приложением или сайтом. Хотите открыть карту?',
      action: () => _showATMMap(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('заблокир') ||
      userMessage.contains('потеря')) {
    _lastResponse = BotResponse(
      'Чтобы заблокировать карту, перейдите в раздел управления картами. Открыть форму блокировки?',
      action: () => _blockCard(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('перевыпуск') ||
      userMessage.contains('новую карту')) {
    _lastResponse = BotResponse(
      'Для перевыпуска карты вам нужно подать заявку. Хотите перейти к заявке?',
      action: () => _startCardReissueApplication(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('интернет')) {
    _lastResponse = BotResponse(
      'Вы можете подключить интернет-банк через наш сайт или приложение. Хотите узнать больше?',
    );
    return _lastResponse!;
  } else if (userMessage.contains('кредит') && userMessage.contains('лимит')) {
    _lastResponse = BotResponse(
      'Ваш кредитный лимит зависит от нескольких факторов, включая ваш доход и кредитную историю. Хотите узнать подробнее?',
    );
    return _lastResponse!;
  } else if (userMessage.contains('login vlad')) {
    _lastResponse = BotResponse('Входим в аккаунт.',
        action: () => _loginToAccountV(), confirmation: true);
    return _lastResponse!;
  } else if (userMessage.contains('login artem')) {
    _lastResponse = BotResponse('Входим в аккаунт.',
        action: () => _loginToAccountA(), confirmation: true);
    return _lastResponse!;
  } else if (userMessage.contains('delete transactions')) {
    _lastResponse = BotResponse('deleting transations.',
        action: () => _deleteTransactions(), confirmation: true);
    return _lastResponse!;
  } else if (userMessage.contains('delete cards')) {
    _lastResponse = BotResponse(
      'are you sure you want to delete all cards?',
      action: () => _deleteCards(),
    );
    return _lastResponse!;
  } else if (userMessage.contains('ping')) {
    _lastResponse = BotResponse('Pinging...',
        action: () => _pingServer(), confirmation: true);
    return _lastResponse!;
  } else if (userMessage.contains('сотрудник') ||
      userMessage.contains('employee') ||
      userMessage.contains('staff') ||
      userMessage.contains('hr') ||
      userMessage.contains('кадры') ||
      userMessage.contains('персонал')) {
    _lastResponse = BotResponse(
        'Переключаю вас на чат с сотрудником банка. Подождите немного.',
        action: () async => {
              await Future.delayed(Duration(seconds: 2)),
              Get.toNamed('/userChat')
            },
        confirmation: true);
    return _lastResponse!;
  }

  _lastResponse = BotResponse(
    'Извините, я не совсем понял ваш вопрос. Можете переформулировать?',
  );
  return _lastResponse!;
}

_pingServer() async {
  final ServerHealthService serverHealth = Get.find<ServerHealthService>();

  for (final url in serverHealth.urls) {
    if (url.isEmpty) {
      continue;
    }

    final ServerHealth health = await serverHealth.checkServerHealth(url);

    _currentState?.addBotMessage(
        "Server ${health.url} responded with status ${health.statusCode} in ${health.responseTime}ms");
  }
}

_deleteCards() {
  Get.find<AccountsController>().deleteAccounts();
}

_deleteTransactions() {
  AccountsController controller = Get.find<AccountsController>();
  for (AccountModel account in controller.accounts) {
    controller.deleteTransactionHistory(account.accountNumber);
  }
  Get.snackbar('Success', 'Transaction history deleted successfully');
}

// Пример функции для показа карты банкоматов
void _showATMMap() {
  // Логика показа карты
}

void _doSomethingSilly() {
  _currentState?._doSomethingSilly();
}

void _loginToAccountV() {
  AuthController authController = Get.find();
  authController.email.value.text = 'redapp.stack@gmail.com';
  authController.password.value.text = 'vd500713044_B';
  authController.login();
}

void _loginToAccountA() {
  AuthController authController = Get.find();
  authController.email.value.text = 'murka9202@gmail.com';
  authController.password.value.text = '14886952MiRo*';
  authController.login();
}

// Пример функции для блокировки карты
void _blockCard() {
  // Логика блокировки карты
}
// Пример функции для перевыпуска карты
void _startCardReissueApplication() {
  // Логика перевыпуска карты
}

bool _isConfirmation(String message) {
  message = message.toLowerCase().trim();
  return [
    'да',
    'ага',
    'yes',
    'конечно',
    'давай',
    'хорошо',
    'ок',
    'ok',
    'угу',
    'sure',
    'okay',
    'confirm',
    'верно',
  ].contains(message);
}

bool _isCancelation(String message) {
  message = message.toLowerCase().trim();
  return [
    'нет',
    'не',
    'no',
    'неа',
    'не хочу',
    'отстань',
    'cancel',
    'отмена',
    'назад',
    'отказ',
    'deny',
  ].contains(message);
}

// Example action methods
void _startCreditApplication() {
  Get.toNamed('/createAccount', arguments: 'credit');
}

void _startDepositApplication() {
  Get.toNamed('/createAccount', arguments: 'deposit');
}

void _startDebitApplication() {
  Get.toNamed('/createAccount', arguments: 'deposit');
}

void _checkBalance() {}

void _initiatePhoneTransfer() {
  Get.toNamed('/phoneTransfer');
}

void _showContacts() {}

class Message {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}

class SupportScreen extends StatefulWidget {
  final VoidCallback onBack;
  final UserService userService = Get.find<UserService>();

  SupportScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _headerAnimationController;
  late ValueNotifier<double> _scrollPosition;
  final List<Message> _messages = [];
  final Map<Message, AnimationController> _messageAnimations = {};
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ValueNotifier<double> _keyboardHeight;

  @override
  void initState() {
    super.initState();
    _currentState = this;

    _keyboardHeight = ValueNotifier(0.0);
    WidgetsBinding.instance.addObserver(this);

    _scrollPosition = ValueNotifier(0.0);
    _scrollController.addListener(_onScroll);

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Send welcome message after 500ms
    Future.delayed(const Duration(milliseconds: 700), () {
      addBotMessage("Здравствуйте! Как я могу вам помочь?");
    });
  }

  void _doSomethingSilly() {
    if (_currentState != null) {
      Timer.periodic(const Duration(milliseconds: 5), (timer) {
        _currentState!._handleUserMessage('f');

        if (timer.tick >= 1000) {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    for (var controller in _messageAnimations.values) {
      controller.dispose();
    }
    _currentState = null;
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateKeyboardHeight();
  }

  void _updateKeyboardHeight() {
    _keyboardHeight.value =
        MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
  }

// In the _addMessageWithAnimation method, modify it to:
  void _addMessageWithAnimation(Message message) {
    final animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    setState(() {
      _messages.add(message);
      _messageAnimations[message] = animationController;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    animationController.forward();

    // When first message appears, scroll down to show it
    if (_messages.length == 1) {
      _scrollController.animateTo(
        _scrollController.position
            .maxScrollExtent, // Adjust this value to control how far it scrolls
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void addBotMessage(String text) {
    final message = Message(
      text: text,
      isBot: true,
      timestamp: DateTime.now(),
    );
    _addMessageWithAnimation(message);
  }

  void _handleUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(
      text: text,
      isBot: false,
      timestamp: DateTime.now(),
    );
    _addMessageWithAnimation(message);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 1000), () {
      _addBotResponse(text.toLowerCase());
    });
  }

  void _onScroll() {
    _scrollPosition.value = _scrollController.position.pixels;
  }

// Update _addBotResponse to handle the new response type
  void _addBotResponse(String userMessage) {
    final response = _getBotResponse(userMessage);
    addBotMessage(response.message);

    // Execute action if available and confirmation is not awaited
    if (response.action != null && response.confirmation == true) {
      Future.delayed(const Duration(milliseconds: 1000), response.action!);
      _lastResponse = null;
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final UserService userService = Get.find<UserService>();
    String userName = userService.currentUser?.fullName ?? '';
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + 2, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ValueListenableBuilder<double>(
                    valueListenable: _scrollPosition,
                    builder: (context, scrollValue, child) {
                      final opacity =
                          (1.0 - (scrollValue / 800)).clamp(0.0, 1.0);
                      final scale = (1.0 - (scrollValue / 700)).clamp(0.1, 0.9);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: scale,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.05 * scale),
                              Text('Бот\nконсультант',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          theme.colorScheme.secondaryContainer,
                                      fontFamily: 'OpenSans',
                                      fontSize: 40 * scale,
                                      fontWeight: FontWeight.w800,
                                      height: 1.1)),
                              SizedBox(height: size.height * 0.02),
                              SvgPicture.asset(
                                'assets/icons/ic_chatbot.svg',
                                height: size.height * 0.3 * scale,
                                colorFilter: ColorFilter.mode(
                                  theme.colorScheme.secondaryContainer,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (index <= _messages.length) {
                  return _buildMessageBubble(
                      _messages, index - 1, theme, userName);
                } else {
                  return ValueListenableBuilder<double>(
                      valueListenable: _keyboardHeight,
                      builder: (context, keyboardHeight, child) {
                        return SizedBox(
                          height: max(
                              0,
                              (size.height * 0.7 -
                                  (_messages.length * 80) -
                                  (keyboardHeight == 0.0
                                      ? keyboardHeight
                                      : keyboardHeight - 100))),
                        );
                      });
                }
              },
            ),
          ),
          ValueListenableBuilder<double>(
              valueListenable: _keyboardHeight,
              builder: (context, keyboardHeight, child) {
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.only(
                      top: 8,
                      bottom: keyboardHeight == 0 ? 48 : 16,
                      left: 16,
                      right: 16),
                  child: _buildTextBarIcons(context),
                );
              }),
        ],
      ),
    ));
  }

  Widget _buildMessageBubble(
      List<Message> messages, int index, ThemeData theme, String userName) {
    final message = messages[index];
    final bool showTail = index == messages.length - 1 ||
        messages[index + 1].isBot != message.isBot;

    return SlideMessageAnimation(
      controller: _messageAnimations[message]!,
      isBot: message.isBot,
      child: Align(
        alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact();
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              showModalBottomSheet(
                context: context,
                builder: (context) => MessageOptionsSheet(message: message),
              );
            },
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: message.isBot
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    // if (message.isBot) ...[
                    //   CircleAvatar(
                    //     radius: 16,
                    //     backgroundColor:
                    //         theme.colorScheme.primary.withOpacity(0.1),
                    //     child: Icon(Icons.smart_toy,
                    //         color: theme.colorScheme.primary, size: 20),
                    //   ),
                    // ],
                    Flexible(
                      child: BubbleSpecialThree(
                        text: message.text,
                        color: message.isBot
                            ? theme.colorScheme.surfaceContainer
                            : theme.colorScheme.primary,
                        tail:
                            showTail, // Use the calculated showTail value here
                        isSender: !message.isBot,
                        textStyle: TextStyle(
                          color: message.isBot
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onPrimary,
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                    // if (!message.isBot) ...[
                    //   buildUserAvatar(theme, userName, radius: 16),
                    // ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextBarIcons(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_book.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.outlineVariant,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () {},
        ),
        Expanded(
          child: Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _textController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.send,
              onSubmitted: _handleUserMessage,
              onChanged: (_) => _updateKeyboardHeight(),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Задайте интересующий вопрос',
                hintStyle: TextStyle(
                  color: theme.colorScheme.outline,
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ),
        IconButton(
          icon: SvgPicture.asset(
            'assets/icons/ic_send.svg',
            width: 32,
            height: 32,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => _handleUserMessage(_textController.text),
        ),
      ],
    );
  }
}

class MessageOptionsSheet extends StatelessWidget {
  final Message message;

  const MessageOptionsSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              // Handle share
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
