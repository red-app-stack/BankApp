import 'dart:async';
import 'dart:math';
import 'package:bank_app/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';

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
  }

  // Если запрос не соответствует ни одному из условий
  _lastResponse = BotResponse(
    'Извините, я не совсем понял ваш вопрос. Можете переформулировать?',
  );
  return _lastResponse!;
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

void _showCardsGallery() {}

void _checkBalance() {}

void _initiatePhoneTransfer() {
  Get.toNamed('/phoneTransfer');
}

void _showContacts() {
  // Display contact information
}

class SlideMessageAnimation extends StatelessWidget {
  final Widget child;
  final bool isBot;
  final AnimationController controller;

  SlideMessageAnimation({
    required this.child,
    required this.isBot,
    required this.controller,
  }) : super(key: ValueKey(controller.value));

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(isBot ? -1.0 : 1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: controller,
        child: child,
      ),
    );
  }
}

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

  const SupportScreen({
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
      _addBotMessage("Здравствуйте! Как я могу вам помочь?");
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    for (var controller in _messageAnimations.values) {
      controller.dispose();
    }
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
        _scrollController.position.maxScrollExtent, // Adjust this value to control how far it scrolls
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeOut,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _addBotMessage(String text) {
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
    _addBotMessage(response.message);

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
                  final message = _messages[index - 1];
                  return _buildMessageBubble(message, theme);
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

  Widget _buildMessageBubble(Message message, ThemeData theme) {
    return SlideMessageAnimation(
      controller: _messageAnimations[message]!,
      isBot: message.isBot,
      child: Align(
        alignment: message.isBot ? Alignment.centerLeft : Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: message.isBot
                ? theme.colorScheme.surfaceContainer
                : theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(
              color: message.isBot
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onPrimary,
              fontSize: 14,
              fontFamily: 'OpenSans',
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
