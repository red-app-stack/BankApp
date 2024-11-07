import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';

class TransferHistoryController extends GetxController {
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final AccountsController accountsController = Get.find<AccountsController>();
  RxString accountId = ''.obs;

  TransferHistoryController();

  @override
  void onInit() async {
    super.onInit();
    print(accountsController.accounts.first.accountNumber.toString());
    accountId.value = accountsController.accounts.first.accountNumber;
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactionsList = await accountsController.fetchTransactionHistory(accountId.value);
    transactions.value = transactionsList;
  }
}

class TransferHistoryScreen extends StatelessWidget {
  final TransferHistoryController controller =
      Get.put(TransferHistoryController());

  TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildFilterCard(theme),
              const SizedBox(height: 16),
              Expanded(
                child: _buildTransactionsList(theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 32,
                height: 32,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const Expanded(
              child: Text(
                'История переводов',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'За эту неделю',
              style: theme.textTheme.titleMedium,
            ),
            IconButton(
              icon: SvgPicture.asset(
                'assets/icons/ic_filter.svg',
                width: 32,
                height: 32,
                // colorFilter: ColorFilter.mode(
                //   theme.colorScheme.primary,
                //   BlendMode.srcIn,
                // ),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    return Obx(() => ListView.builder(
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final transaction = controller.transactions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Перевод #${transaction.reference}',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${transaction.amount} ${transaction.currency}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'От: ${transaction.fromAccount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      'Кому: ${transaction.toAccount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transaction.createdAt.toString().split('.')[0],
                          style: theme.textTheme.bodySmall,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(transaction.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction.status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'reversed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
