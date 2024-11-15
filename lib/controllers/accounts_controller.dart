import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../services/dio_manager.dart';
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

class Transaction {
  final int id;
  final String fromAccount;
  final String toAccount;
  final String reference;
  final double amount;
  final String currency;
  final String type;
  final String status;
  final DateTime createdAt;
  final String formattedCreatedAt;
  final String? fromUserName;
  final String? toUserName;

  Transaction({
    required this.id,
    required this.fromAccount,
    required this.toAccount,
    required this.reference,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.formattedCreatedAt,
    this.fromUserName,
    this.toUserName,
  });

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      fromAccount: json['from_account'] ?? '',
      toAccount: json['to_account'] ?? '',
      reference: json['reference'] ?? '',
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      formattedCreatedAt: json['formatted_created_at'] ?? '',
      fromUserName: json['from_user_name'],
      toUserName: json['to_user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from_account': fromAccount,
      'to_account': toAccount,
      'reference': reference,
      'amount': amount,
      'currency': currency,
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'formatted_created_at': formattedCreatedAt,
      'from_user_name': fromUserName,
      'to_user_name': toUserName,
    };
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
  DioManager dio = Get.find();
  final UserService userService = Get.find<UserService>();
  final SecureStore secureStore = Get.find<SecureStore>();
  final Rx<RecipientModel?> recipientAccount = Rx<RecipientModel?>(null);
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

  Future<bool> createTransaction(String fromAccountId, String toAccountId,
      double amount, String currency) async {
    try {
      isLoading.value = true;
      final token = await secureStore.secureStorage.read(key: 'auth_token');

      if (token == null) return false;

      final response = await dio.post(
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
      );

      if (response.statusCode == 201) {
        await fetchAccounts();
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

      final response = await dio.post(
        '/accounts/lookup-by-phone',
        data: {'phone_number': phoneNumber},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

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
      String accountNumber) async {
    try {
      final token = await secureStore.secureStorage.read(key: 'auth_token');
      if (token == null) return [];

      final response = await dio.get(
        '/transactions/history/$accountNumber',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if (response.statusCode == 200 && response.data is List) {
        transactionHistory.value = (response.data as List).map((transaction) {
          final createdAtString = transaction['created_at'];
          DateTime createdAt = DateTime.parse(createdAtString).toLocal();

          final formattedDate =
              DateFormat('dd.MM.yyyy HH:mm:ss').format(createdAt);

          return Transaction(
            id: (response.data as List).indexOf(transaction),
            fromAccount: transaction['from_account_number'] ?? '',
            toAccount: transaction['to_account_number'] ?? '',
            reference: transaction['transaction_reference'],
            amount: double.parse(transaction['amount'].toString()),
            currency: transaction['currency'],
            type: transaction['transaction_type'],
            status: transaction['status'],
            createdAt: createdAt,
            formattedCreatedAt: formattedDate,
            fromUserName: transaction['from_user_name'],
            toUserName: transaction['to_user_name'],
          );
        }).toList();
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
