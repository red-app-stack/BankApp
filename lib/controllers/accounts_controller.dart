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
  final String reference;
  final String fromAccount;
  final String fromAccountType;
  final String toAccount;
  final String toAccountType;
  final double amount;
  final String currency;
  final String type;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? fromUserName;
  final String? fromUserPicture;
  final String? fromUserRole;
  final String? fromUserPhone;
  final String? toUserName;
  final String? toUserPicture;
  final String? toUserRole;
  final String? toUserPhone;
  final String formattedCreatedAt;

  Transaction({
    required this.id,
    required this.reference,
    required this.fromAccount,
    required this.fromAccountType,
    required this.toAccount,
    required this.toAccountType,
    required this.amount,
    required this.currency,
    required this.type,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.fromUserName,
    this.fromUserPicture,
    this.fromUserRole,
    this.fromUserPhone,
    this.toUserName,
    this.toUserPicture,
    this.toUserRole,
    this.toUserPhone,
    required this.formattedCreatedAt,
  });

  static Transaction fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      reference: json['transaction_reference'],
      fromAccount: json['from_account_number'] ?? '',
      fromAccountType: json['from_account_type'] ?? '',
      toAccount: json['to_account_number'] ?? '',
      toAccountType: json['to_account_type'] ?? '',
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      type: json['transaction_type'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      fromUserName: json['from_user_name'],
      fromUserPicture: json['from_user_picture'],
      fromUserRole: json['from_user_role'],
      fromUserPhone: json['from_user_phone_number'],
      toUserName: json['to_user_name'],
      toUserPicture: json['to_user_picture'],
      toUserRole: json['to_user_role'],
      toUserPhone: json['to_user_phone_number'],
      formattedCreatedAt: DateFormat('dd.MM.yyyy HH:mm:ss')
          .format(DateTime.parse(json['created_at']).toLocal()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_reference': reference,
      'from_account_number': fromAccount,
      'from_account_type': fromAccountType,
      'to_account_number': toAccount,
      'to_account_type': toAccountType,
      'amount': amount,
      'currency': currency,
      'transaction_type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'from_user_name': fromUserName,
      'from_user_picture': fromUserPicture,
      'from_user_role': fromUserRole,
      'from_user_phone_number': fromUserPhone,
      'to_user_name': toUserName,
      'to_user_picture': toUserPicture,
      'to_user_role': toUserRole,
      'to_user_phone_number': toUserPhone,
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

        // Sort accounts by type priority and balance
        fetchedAccounts.sort((a, b) {
          // Define type priority
          final typePriority = {
            'card': 0,
            'credit': 1,
            'deposit': 2,
          };

          // Compare by type first
          final typeComparison =
              (typePriority[a.accountType.toLowerCase()] ?? 3)
                  .compareTo(typePriority[b.accountType.toLowerCase()] ?? 3);

          // If same type, sort by balance (descending)
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
      String toAccountId, double amount, String currency, String type) async {
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
          'currency': currency,
          'transaction_type': type
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
