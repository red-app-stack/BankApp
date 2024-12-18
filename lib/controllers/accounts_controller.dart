import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/dio_manager.dart';
import '../services/user_service.dart';
import '../views/shared/secure_store.dart';
import '../models/account_model.dart';

class AccountsController extends GetxController {
  DioManager dio = Get.find();
  final UserService userService = Get.find<UserService>();
  final SecureStore secureStore = Get.find<SecureStore>();
  final Rx<AccountModel?> recipientAccount = Rx<AccountModel?>(null);
  final Rx<List<Transaction>?> transactionHistory =
      Rx<List<Transaction>?>(null);

  RxList<AccountModel> accounts = <AccountModel>[].obs;
  RxBool isLoading = false.obs;

  AccountsController();

  Future<void> fetchAccounts() async {
    try {
      print('fetching.');
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return;

      final response = await (dio.get(
        '/accounts/list',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      ));

      if (response.statusCode == 200) {
        final List<AccountModel> fetchedAccounts = (response.data as List)
            .map((account) => AccountModel.fromJson(account))
            .toList();

        fetchedAccounts.sort((a, b) {
          final typePriority = {
            'card': 0,
            'credit': 1,
            'deposit': 2,
          };

          final typeComparison =
              (typePriority[a.accountType.toLowerCase()] ?? 3)
                  .compareTo(typePriority[b.accountType.toLowerCase()] ?? 3);

          if (typeComparison == 0) {
            return b.balance.compareTo(a.balance);
          }

          return typeComparison;
        });

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

      final response = await dio.delete(
        '/accounts/delete-all',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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

      final response = await dio.delete(
        '/accounts/delete/$accountId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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

      final response = await dio.post(
        '/accounts/create',
        data: {
          'account_type': accountType,
          'currency': currency,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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

  Future<Transaction?> createTransaction(String fromAccountId,
      String toAccountId, double amount, String currency, String type,
      {String? message}) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return null;

      final response = await dio.post(
        '/transactions/create',
        data: {
          'from_account_id': fromAccountId,
          'to_account_id': toAccountId,
          'amount': amount,
          'transaction_type': type,
          'message': message
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 201) {
        await fetchAccounts();
        return Transaction.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error creating transaction: $e');
      return null;
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

  Future<AccountModel?> lookupAccount(
      {String? phoneNumber, String? accountNumber}) async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) return null;

      final data = phoneNumber != null
          ? {'phone_number': phoneNumber}
          : {'account_number': accountNumber};

      final response = await dio.post(
        '/accounts/lookup',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final recipient = AccountModel.fromJson(response.data);
        recipientAccount.value = recipient;
        return recipient;
      }
      return null;
    } catch (e) {
      print('Error looking up account: $e');
      return null;
    }
  }

  Future<bool> addTestMoney(String accountNumber, double amount) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await dio.post(
        '/transactions/add-test-money',
        data: {
          'account_number': accountNumber,
          'amount': amount,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        await fetchAccounts(); // Refresh accounts after adding test money
        // Get.snackbar('Success', 'Test money added successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding test money: $e');
      // Get.snackbar('Error', 'Failed to add test money');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Transaction>> fetchTransactionHistory(
      [String? accountNumber]) async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) return [];
      final endpoint = accountNumber != null
          ? '/transactions/history/$accountNumber'
          : '/transactions/history';
      final response = await dio.get(
        endpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        transactionHistory.value = (response.data as List)
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
        return transactionHistory.value!;
      }
      return [];
    } catch (e) {
      print('Error fetching transaction history: $e');
      return [];
    }
  }

  Future<bool> deleteTransactionHistory(String accountNumber) async {
    print('DELETING');
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await dio.delete(
        '/transactions/history/$accountNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        // Get.snackbar('Success', 'Transaction history deleted successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting transaction history: $e');
      // Get.snackbar('Error', 'Failed to delete transaction history');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
