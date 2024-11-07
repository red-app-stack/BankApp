import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../services/dio_helper.dart';
import '../services/user_service.dart';
import '../views/shared/secure_store.dart';

class AccountModel {
  final int id;
  final String accountNumber;
  final String accountType;
  final String currency;
  final double balance;
  final String status;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.balance,
    required this.status,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      accountNumber: json['account_number'],
      accountType: json['account_type'],
      currency: json['currency'],
      balance: double.parse(json['balance'].toString()),
      status: json['status'],
    );
  }
}

class RecipientModel {
  final int id;
  final String accountNumber;
  final String accountType;
  final String currency;
  final double balance;
  final String fullName;
  final String phoneNumber;

  RecipientModel({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.balance,
    required this.fullName,
    required this.phoneNumber,
  });

  factory RecipientModel.fromJson(Map<String, dynamic> json) {
    return RecipientModel(
      id: json['id'],
      accountNumber: json['account_number'],
      accountType: json['account_type'],
      currency: json['currency'],
      balance: double.parse(json['balance'].toString()),
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
    );
  }
}

class AccountsController extends GetxController {
  final Dio dio;
  final UserService userService = Get.find<UserService>();
  final SecureStore secureStore = Get.find<SecureStore>();
  final Rx<RecipientModel?> recipientAccount = Rx<RecipientModel?>(null);
  RxList<AccountModel> accounts = <AccountModel>[].obs;
  RxBool isLoading = false.obs;

  AccountsController({required this.dio});

  Future<void> fetchAccounts() async {
    try {
      print('fetching.');
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return;

      final response = await DioRetryHelper.retryRequest(() => dio.get(
            '/accounts/list',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 200) {
        final List<AccountModel> fetchedAccounts = (response.data as List)
            .map((account) => AccountModel.fromJson(account))
            .toList();
        accounts.value = fetchedAccounts;
      }
    } catch (e) {
      print('Error fetching accounts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccounts() async {
    try {
      print('Deleting all accounts...');
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return;

      final response = await DioRetryHelper.retryRequest(() => dio.delete(
            '/accounts/delete-all',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 200) {
        print('Successfully deleted ${response.data['count']} accounts');
        accounts.value = []; // Clear the accounts list
        Get.snackbar('Success', 'All accounts deleted successfully');
      }
    } catch (e) {
      print('Error deleting accounts: $e');
      Get.snackbar('Error', 'Failed to delete accounts');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSingleAccount(String accountId) async {
    try {
      print('Deleting account $accountId...');
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return;

      final response = await DioRetryHelper.retryRequest(() => dio.delete(
            '/accounts/delete/$accountId',
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 200) {
        print('Account deleted successfully');
        accounts.value = accounts
            .where((account) => account.id != int.parse(accountId))
            .toList();
        Get.snackbar('Success', 'Account deleted successfully');
      }
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAccount(String accountType, String currency) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/accounts/create',
            data: {
              'account_type': accountType,
              'currency': currency,
            },
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 201) {
        await fetchAccounts();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating account: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTransaction(String fromAccountId, String toAccountId,
      double amount, String currency) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/transactions/create',
            data: {
              'from_account_id': fromAccountId,
              'to_account_id': toAccountId,
              'amount': amount,
              'currency': currency,
              'transaction_type': 'transfer'
            },
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 201) {
        await fetchAccounts(); // Refresh accounts after transaction
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating transaction: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, List<AccountModel>> getAccountsByCurrency() {
    return {
      'KZT': accounts.where((acc) => acc.currency == 'KZT').toList(),
      'USD': accounts.where((acc) => acc.currency == 'USD').toList(),
      'EUR': accounts.where((acc) => acc.currency == 'EUR').toList(),
    };
  }

  String getFormattedBalance(String currency) {
    double total = accounts
        .where((acc) => acc.currency == currency)
        .fold(0, (sum, acc) => sum + acc.balance);

    switch (currency) {
      case 'KZT':
        return '₸ ${total.toStringAsFixed(2)}';
      case 'USD':
        return '\$ ${total.toStringAsFixed(2)}';
      case 'EUR':
        return '€ ${total.toStringAsFixed(2)}';
      default:
        return total.toStringAsFixed(2);
    }
  }

  Future<RecipientModel?> getAccountByPhone(String phoneNumber) async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/accounts/lookup-by-phone',
            data: {'phone_number': phoneNumber},
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 200) {
        final recipient = RecipientModel.fromJson(response.data);
        recipientAccount.value = recipient;
        return recipient;
      }
      return null;
    } catch (e) {
      print('Error looking up account by phone: $e');
      return null;
    }
  }

  Future<bool> addTestMoney(String accountNumber, double amount) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await DioRetryHelper.retryRequest(() => dio.post(
            '/transactions/add-test-money',
            data: {
              'account_number': accountNumber,
              'amount': amount,
            },
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          ));

      if (response.statusCode == 200) {
        await fetchAccounts(); // Refresh accounts after adding test money
        Get.snackbar('Success', 'Test money added successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding test money: $e');
      Get.snackbar('Error', 'Failed to add test money');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
