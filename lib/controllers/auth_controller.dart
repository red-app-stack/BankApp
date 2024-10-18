import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  static AuthController get instance => Get.find();

  final Rx<TextEditingController> fullName = TextEditingController().obs;
  final Rx<TextEditingController> email = TextEditingController().obs;
  final Rx<TextEditingController> password = TextEditingController().obs;

  final RxBool _status = false.obs;
  bool get status => _status.value;

  final Rx<User?> _user = Rx<User?>(null);
  User? get user => _user.value;

  final RxString _userRole = RxString('student');
  String get userRole => _userRole.value;

  final String serverUrl = 'https://collegedev.serveo.net/generateCustomToken';

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  String getRole() => _userRole.value;
  void setStatus(bool value) => _status.value = value;
  void setRole(String role) => _userRole.value = role;

  void _setInitialScreen(User? user) async {
    if (user == null) {
      Get.offAllNamed('/login');
    } else {
      await checkUserStatus(user);
      Get.offAllNamed('/main');
    }
  }

  void _saveUid(String uid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('uid', uid);
  }

  void _saveRole(String role) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString('userRole', role);
    print('SAVED $role');
  }

  Future<void> login(String email, String password) async {
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        setStatus(true);
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        print(userRole);

        await checkUserStatus(userCredential.user!);
        await getCustomToken(
            userCredential.user!.uid, {'role': _userRole.value});
        Get.offAllNamed('/main');
      } on FirebaseException catch (e) {
        Get.snackbar('Ошибка', getFirebaseErrorMessage(e));
      } catch (e) {
        Get.snackbar('Ошибка', e.toString());
      } finally {
        Get.snackbar('Успех', 'Вход прошел успешно!');
        setStatus(false);
      }
    } else {
      Get.snackbar('Ошибка', 'Заполните все поля.');
    }
  }

  Future<void> register(String email, String password, String role) async {
    setStatus(true);
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;
      String path = role == 'student' ? 'studentsTest' : 'teachers';

      // Create data map
      Map<String, dynamic> userData = {
        'info': {
          'name': fullName.value,
          'email': email,
        },
        'private': {
          'password': password,
        },
        'role': role,
        // Add any other fields you need
      };
      print(userData);

      // Set all data at once
      await _database.ref().child('college/$path/$uid').set(userData);
      print('DONEEEEEEEEEEEEEEEEEEE');
      Get.offAllNamed('/main');
      await getCustomToken(userCredential.user!.uid, {'role': role});
      _saveRole(role);
      _saveUid(userCredential.user!.uid);
      Get.snackbar('Успех', 'Регистрация прошла успешно!');
    } on FirebaseException catch (e) {
      Get.snackbar('Ошибка', getFirebaseErrorMessage(e));
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    } finally {
      setStatus(false);
    }
  }

  Future<void> signOut() async {
    try {
      setStatus(true);
      await Future.delayed(Duration(seconds: 1));
      await _auth.signOut();
      _user.value = null;
      _userRole.value.isEmpty;
      _saveUid('');
      _saveRole('');
      Get.snackbar('Успех', 'Вы успешно вышли.');
      Get.offAllNamed('/login');
    } on FirebaseException catch (e) {
      Get.snackbar('Ошибка', getFirebaseErrorMessage(e));
    } catch (e) {
      Get.snackbar('Ошибка', e.toString());
    } finally {
      setStatus(false);
    }
  }

  Future<void> checkLoginStatus() async {
    setStatus(true);
    final currentUser = _auth.currentUser;
    print(userRole);

    if (currentUser != null) {
      _user.value = currentUser;
      await checkUserStatus(currentUser);
    } else {
      _user.value = null;
      Get.offAllNamed('/login');
    }
    setStatus(false);
  }

  Future<void> checkUserStatus(User user) async {
    try {
      setStatus(true);
      final idTokenResult = await user.getIdTokenResult(true);
      String roleString = idTokenResult.claims?['role'] ?? '';
      _userRole.value = roleString;
      print(_userRole.value);
      if (_userRole.value.isEmpty) {
        DataSnapshot? userSnapshot;
        userSnapshot =
            await _database.ref('college/students/${user.uid}').get();
        if (userSnapshot.exists) {
          _userRole.value = 'student';
        } else {
          userSnapshot =
              await _database.ref('college/admins/${user.uid}').get();
          if (userSnapshot.exists) {
            _userRole.value = 'admin';
          } else {
            userSnapshot =
                await _database.ref('college/teachers/${user.uid}').get();
            if (userSnapshot.exists) {
              _userRole.value = 'teacher';
            }
          }
        }
      }

      _saveRole(_userRole.value);
      _saveUid(user.uid);
    } on FirebaseException catch (e) {
      Get.snackbar('Ошибка', getFirebaseErrorMessage(e));
    } catch (e) {
      print(e);
    } finally {
      setStatus(false);
    }
  }

  Future<void> getCustomToken(String uid, Map<String, dynamic> claims) async {
    try {
      final response = await Dio().post(
        serverUrl,
        data: {
          'uid': uid,
          'claims': claims,
        },
      );
      if (response.statusCode == 200) {
        String customToken = response.data['token'];
        loginWithCustomToken(customToken);
      } else {
        print('Ошибка, Не удалось получить токен: ${response.data}');
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Ошибка сети: Сервер недоступен');
    }
  }

  void loginWithCustomToken(String customToken) {
    try {
      _auth.signInWithCustomToken(customToken);
    } catch (e) {
      print(e);
    }
  }

  @override
  void onClose() {
    email.value.dispose();
    password.value.dispose();
    fullName.value.dispose();
    super.onClose();
  }

  String getFirebaseErrorMessage(FirebaseException e) {
    print(e.toString());
    switch (e.code) {
      case 'user-disabled':
        return 'Эта учетная запись пользователя была отключена.';
      case 'user-not-found':
        return 'Пользователь с указанным email или UID не найден.';
      case 'wrong-password':
        return 'Неверный пароль для указанного email.';
      case 'invalid-email':
        return 'Неверный формат email адреса.';
      case 'email-already-in-use':
        return 'Этот email уже используется другой учетной записью.';
      case 'weak-password':
        return 'Пароль должен содержать не менее 6 символов.';
      case 'operation-not-allowed':
        return 'Эта операция не разрешена.';
      case 'account-exists-with-different-credential':
        return 'Учетная запись с таким email уже существует, но с другими данными для входа.';
      case 'invalid-credential':
        return 'Предоставленные учетные данные имеют неверный формат или истекли.';
      case 'invalid-verification-code':
        return 'Неверный код подтверждения SMS.';
      case 'invalid-verification-id':
        return 'Неверный ID подтверждения.';

      // Дополнительные ошибки аутентификации
      case 'auth/admin-restricted-operation':
        return 'Эта операция доступна только администраторам.';
      case 'auth/argument-error':
        return 'Предоставлен неверный аргумент.';
      case 'auth/app-not-authorized':
        return 'Это приложение не имеет прав на выполнение операции.';
      case 'auth/app-not-installed':
        return 'Необходимое приложение не установлено.';
      case 'auth/captcha-check-failed':
        return 'Проверка CAPTCHA не прошла.';
      case 'auth/code-expired':
        return 'Срок действия кода подтверждения истек.';
      case 'auth/cordova-not-ready':
        return 'Фреймворк Cordova не готов.';
      case 'auth/cors-unsupported':
        return 'CORS не поддерживается в этой среде.';
      case 'auth/credential-already-in-use':
        return 'Эти учетные данные уже связаны с другим пользователем.';
      case 'auth/custom-token-mismatch':
        return 'Предоставленный пользовательский токен не соответствует формату.';
      case 'auth/requires-recent-login':
        return 'Для выполнения этой операции требуется недавний вход пользователя.';
      case 'auth/dependent-sdk-initialized-before-auth':
        return 'Зависимый SDK не был инициализирован перед аутентификацией.';
      case 'auth/dynamic-link-not-activated':
        return 'Динамические ссылки не активированы для этого проекта.';
      case 'auth/email-change-needs-verification':
        return 'Необходимо подтвердить email перед изменением.';
      case 'auth/emulator-config-failed':
        return 'Ошибка конфигурации эмулятора.';
      case 'auth/expired-action-code':
        return 'Срок действия кода действия истек.';
      case 'auth/cancelled-popup-request':
        return 'Запрос всплывающего окна был отменен.';
      case 'auth/internal-error':
        return 'Произошла внутренняя ошибка.';
      case 'auth/invalid-api-key':
        return 'Предоставленный API-ключ недействителен.';
      case 'auth/invalid-app-credential':
        return 'Учетные данные приложения недействительны.';
      case 'auth/invalid-app-id':
        return 'ID приложения недействителен.';
      case 'auth/invalid-user-token':
        return 'Токен пользователя недействителен.';
      case 'auth/invalid-auth-event':
        return 'Событие аутентификации недействительно.';
      case 'auth/invalid-cert-hash':
        return 'Хэш сертификата недействителен.';
      case 'auth/invalid-verification-code':
        return 'Код подтверждения недействителен.';
      case 'auth/invalid-continue-uri':
        return 'URI продолжения недействителен.';
      case 'auth/invalid-cordova-configuration':
        return 'Конфигурация Cordova недействительна.';
      case 'auth/invalid-custom-token':
        return 'Пользовательский токен недействителен.';
      case 'auth/invalid-dynamic-link-domain':
        return 'Домен динамической ссылки недействителен.';
      case 'auth/invalid-emulator-scheme':
        return 'Схема эмулятора недействительна.';
      case 'auth/invalid-credential':
        return 'Предоставленные учетные данные недействительны.';
      case 'auth/invalid-message-payload':
        return 'Неверный полезный груз сообщения.';
      case 'auth/invalid-multi-factor-session':
        return 'Сессия многофакторной аутентификации недействительна.';
      case 'auth/invalid-oauth-client-id':
        return 'ID клиента OAuth недействителен.';
      case 'auth/invalid-oauth-provider':
        return 'Поставщик OAuth недействителен.';
      case 'auth/invalid-action-code':
        return 'Код действия недействителен.';
      case 'auth/unauthorized-domain':
        return 'Запрос поступил с несанкционированного домена.';
      case 'auth/invalid-persistence-type':
        return 'Тип сохранения недействителен.';
      case 'auth/invalid-phone-number':
        return 'Неверный формат телефонного номера.';
      case 'auth/invalid-provider-id':
        return 'ID провайдера недействителен.';
      case 'auth/invalid-recipient-email':
        return 'Неверный email получателя.';
      case 'auth/invalid-sender':
        return 'Неверный отправитель.';
      case 'auth/invalid-verification-id':
        return 'Неверный ID подтверждения.';
      case 'auth/invalid-tenant-id':
        return 'ID арендатора недействителен.';
      case 'auth/multi-factor-info-not-found':
        return 'Информация о многофакторной аутентификации не найдена.';
      case 'auth/multi-factor-auth-required':
        return 'Необходима многофакторная аутентификация.';
      case 'auth/missing-android-pkg-name':
        return 'Отсутствует название пакета Android.';
      case 'auth/missing-app-credential':
        return 'Отсутствуют учетные данные приложения.';
      case 'auth/auth-domain-config-required':
        return 'Отсутствует домен авторизации в конфигурации.';
      case 'auth/missing-verification-code':
        return 'Отсутствует код подтверждения.';
      case 'auth/missing-continue-uri':
        return 'Отсутствует URI продолжения.';
      case 'auth/missing-iframe-start':
        return 'Отсутствует начало iframe.';
      case 'auth/missing-ios-bundle-id':
        return 'Отсутствует ID пакета iOS.';
      case 'auth/missing-or-invalid-nonce':
        return 'Отсутствует или недействителен nonce.';
      case 'auth/missing-multi-factor-info':
        return 'Отсутствует информация о многофакторной аутентификации.';
      case 'auth/missing-multi-factor-session':
        return 'Отсутствует сессия многофакторной аутентификации.';
      case 'auth/missing-phone-number':
        return 'Отсутствует телефонный номер.';
      case 'auth/missing-verification-id':
        return 'Отсутствует ID подтверждения.';
      case 'auth/app-deleted':
        return 'Приложение было удалено.';
      case 'auth/account-exists-with-different-credential':
        return 'Учетная запись с таким email уже существует, но с другими данными для входа.';
      case 'auth/network-request-failed':
        return 'Ошибка сети при выполнении запроса.';
      case 'auth/null-user':
        return 'Нет авторизованного пользователя.';
      case 'auth/no-auth-event':
        return 'Событие аутентификации не произошло.';
      case 'auth/no-such-provider':
        return 'Такой провайдер не существует.';
      case 'auth/operation-not-allowed':
        return 'Эта операция не разрешена.';
      case 'auth/operation-not-supported-in-this-environment':
        return 'Эта операция не поддерживается в данной среде.';
      case 'auth/popup-blocked':
        return 'Всплывающее окно было заблокировано.';
      case 'auth/popup-closed-by-user':
        return 'Всплывающее окно закрыто пользователем.';
      case 'auth/provider-already-linked':
        return 'Провайдер уже связан с этим пользователем.';
      case 'auth/quota-exceeded':
        return 'Превышен лимит для этой операции.';
      case 'auth/redirect-cancelled-by-user':
        return 'Переадресация была отменена пользователем.';
      case 'auth/redirect-operation-pending':
        return 'Ожидается другая операция переадресации.';
      case 'auth/rejected-credential':
        return 'Предоставленные учетные данные были отклонены.';
      case 'auth/second-factor-already-in-use':
        return 'Второй фактор уже зарегистрирован.';
      case 'auth/maximum-second-factor-count-exceeded':
        return 'Превышено максимальное количество вторых факторов.';
      case 'auth/tenant-id-mismatch':
        return 'ID арендатора не совпадает.';
      case 'auth/tenant-not-found':
        return 'Арендатор не найден.';
      case 'auth/user-not-found':
        return 'Пользователь не найден.';
      case 'auth/weak-password':
        return 'Пароль недостаточно надежный.';
      case 'auth/wrong-password':
        return 'Неверный пароль.';

      // Ошибки Realtime Database
      case 'permission-denied':
        return 'У клиента нет разрешения на доступ к запрашиваемым данным.';
      case 'write-cancelled':
        return 'Запись была отменена пользователем.';
      case 'data-stale':
        return 'Транзакция должна быть выполнена снова с актуальными данными.';
      case 'disconnected':
        return 'Операцию пришлось прервать из-за отключения сети.';
      case 'expired-token':
        return 'Предоставленный токен аутентификации истек.';
      case 'invalid-token':
        return 'Предоставленный токен аутентификации недействителен.';
      case 'max-retries':
        return 'Транзакция имела слишком много повторных попыток.';
      case 'overridden-by-set':
        return 'Транзакция была переопределена последующим установлением.';
      case 'unavailable-network':
        return 'Сеть недоступна.';
      case 'user-code-exception':
        return 'Произошло исключение в пользовательском коде.';

      // Ошибки Firestore
      case 'not-found':
        return 'Документ или коллекция не существуют.';
      case 'already-exists':
        return 'Документ, который мы пытались создать, уже существует.';
      case 'resource-exhausted':
        return 'Некоторый ресурс исчерпан.';
      case 'aborted':
        return 'Операция была отменена.';
      case 'unimplemented':
        return 'Операция не реализована или не поддерживается.';
      case 'data-loss':
        return 'Потеря данных или повреждение, которое невозможно восстановить.';

      // Ошибки Cloud Storage
      case 'object-not-found':
        return 'Объект не найден по указанной ссылке.';
      case 'bucket-not-found':
        return 'Для Cloud Storage не настроен ни один бакет.';
      case 'project-not-found':
        return 'Для Cloud Storage не настроен ни один проект.';
      case 'unauthorized':
        return 'Пользователь не имеет права выполнять запрашиваемое действие.';
      case 'retry-limit-exceeded':
        return 'Превышено максимальное время для операции (загрузка, скачивание и т. д.).';
      case 'invalid-checksum':
        return 'Файл на клиенте не соответствует контрольной сумме, полученной от сервера.';
      case 'canceled':
        return 'Операция была отменена пользователем.';
      case 'invalid-event-name':
        return 'Предоставлено неверное имя события.';
      case 'invalid-url':
        return 'Предоставлен неверный URL.';
      case 'invalid-argument':
        return 'Предоставленный аргумент недействителен.';
      case 'no-default-bucket':
        return 'Не установлен ни один бакет по умолчанию.';
      case 'cannot-slice-blob':
        return 'Не удалось разбить blob для загрузки.';
      case 'server-file-wrong-size':
        return 'Сервер зарегистрировал неправильный размер загружаемого файла.';

      // Другие исключения Firebase
      case 'app-not-installed':
        return 'Необходимо приложение не установлено.';
      case 'api-not-found':
        return 'Запрашиваемый API не найден.';
      case 'deadline-exceeded':
        return 'Операция заняла слишком много времени для выполнения.';
      case 'failed-precondition':
        return 'Операция не выполнена из-за невыполненного предшествующего условия.';
      case 'internal':
        return 'Произошла внутренняя ошибка.';
      case 'not-implemented':
        return 'Запрашиваемый метод не реализован.';
      case 'out-of-range':
        return 'Значение вне допустимого диапазона.';
      case 'unauthenticated':
        return 'Пользователь не аутентифицирован.';
      case 'cancelled':
        return 'Операция была отменена.';
      case 'quota-exceeded':
        return 'Квота для этой операции превышена.';
      case 'unavailable':
        return 'Сервис недоступен.';
      case 'unknown':
        return 'Произошла неизвестная ошибка.';
      default:
        return 'Произошла неизвестная ошибка: ${e.message}';
    }
  }
}
