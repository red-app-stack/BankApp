import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';

class TransferHistoryController extends GetxController {
  final AccountsController accountsController = Get.find<AccountsController>();
  RxString accountId = ''.obs;

  RxMap<String, List<Transaction>> categorizedTransactions =
      <String, List<Transaction>>{}.obs;

  TransferHistoryController();

  @override
  void onInit() async {
    super.onInit();
    await loadTransactions();
  }

  Future<void> loadTransactions() async {
    List<Transaction> allTransactions = [];

    for (var account in accountsController.accounts) {
      final transactions = await accountsController
          .fetchTransactionHistory(account.accountNumber);
      allTransactions.addAll(transactions);
      for (Transaction transaction in allTransactions) {
        print(transaction.fromAccount);
        print(transaction.toAccount);
        // print(transaction.fromUserName);
      }
    }

    // Sort transactions by date, most recent first
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Categorize transactions
    Map<String, List<Transaction>> categorized = {
      'На этой неделе': [],
      'Этот месяц': [],
      'Ранее': [],
    };

    final now = DateTime.now();
    for (var transaction in allTransactions) {
      if (transaction.createdAt
          .isAfter(now.subtract(Duration(days: now.weekday)))) {
        categorized['На этой неделе']?.add(transaction);
      } else if (transaction.createdAt.isAfter(DateTime(now.year, now.month))) {
        categorized['Этот месяц']?.add(transaction);
      } else {
        categorized['Ранее']?.add(transaction);
      }
    }

    categorizedTransactions.value = categorized;
    accountsController.transactionHistory.value = allTransactions;
  }
}

class TransferHistoryScreen extends StatelessWidget {
  final TransferHistoryController controller =
      Get.put(TransferHistoryController());

  TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: theme.brightness == Brightness.light
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surface,
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async {
              try {
                await Future.delayed(const Duration(milliseconds: 500));
              } on TimeoutException {
                print('Refresh operation timed out');
              } catch (e) {
                print('Error during refresh: $e');
              }
              return Future.value();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildFilterCard(theme),
                    const SizedBox(height: 16),
                    Obx(() => controller.accountsController.transactionHistory
                                .value?.isNotEmpty ??
                            false
                        ? _buildTransactionsList(context)
                        : _buildEmptyState(theme, size)),
                  ],
                ),
              ),
            ),
          ))
        ])));
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

  Widget _buildEmptyState(ThemeData theme, Size size) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: size.height * 0.15),
          SvgPicture.asset(
            'assets/icons/ic_empty_list.svg',
            height:
                size.width > size.height ? size.height * 0.3 : size.width * 0.3,
            colorFilter: ColorFilter.mode(
              theme.colorScheme.secondaryContainer,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            'Здесь будет отображаться \nистория ваших переводов',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.secondaryContainer,
              fontFamily: 'OpenSans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
          SizedBox(height: size.height * 0.02),
        ],
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

  Widget _buildTransactionsList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Obx(() {
        final categories = controller.categorizedTransactions.keys.toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final transactions =
                controller.categorizedTransactions[category] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    category,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                transactions.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, i) {
                          final transaction = transactions[i];
                          return _buildTransactionCard(context, transaction);
                        },
                      )
                    : Center(
                        child: Padding(
                            padding: EdgeInsets.all(size.height * 0.03),
                            child: SvgPicture.asset(
                              'assets/icons/ic_empty_list.svg',
                              height: size.width > size.height
                                  ? size.height * 0.3
                                  : size.width * 0.3,
                              colorFilter: ColorFilter.mode(
                                Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                BlendMode.srcIn,
                              ),
                            ))),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildTransactionCard(BuildContext context, Transaction transaction) {
    return GestureDetector(
      onTap: () => {
        Get.toNamed('/transferDetails', arguments: transaction),
      },
      behavior: HitTestBehavior.opaque,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Перевод',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${transaction.amount} ${transaction.currency}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              (transaction.fromUserName == null ||
                      transaction.fromAccount == '')
                  ? Container()
                  : Text(
                      'От: ${transaction.fromUserName ?? transaction.fromAccount}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              Text(
                'Кому: ${transaction.toUserName ?? transaction.toAccount}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.createdAt.toLocal().toString().split('.')[0],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(transaction.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(transaction.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'завершено';
      case 'pending':
        return 'в обработке';
      case 'failed':
        return 'ошибка';
      case 'reversed':
        return 'отменен';
      default:
        return 'в обработке';
    }
  }
}
