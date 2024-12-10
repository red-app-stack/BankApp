class AccountModel {
  final int id;
  final String accountNumber;
  final String accountType;
  final String currency;
  final double balance;
  final String status;
  final String fullName;
  final String phoneNumber;

  AccountModel({
    required this.id,
    required this.accountNumber,
    required this.accountType,
    required this.currency,
    required this.balance,
    required this.status,
    required this.fullName,
    required this.phoneNumber,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      accountNumber: json['account_number'],
      accountType: json['account_type'],
      currency: json['currency'],
      balance: double.parse(json['balance'].toString()),
      status: json['status'] ?? '',
      fullName: json['full_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
