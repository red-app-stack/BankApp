import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../controllers/accounts_controller.dart';

class TransferHistoryController extends GetxController {
  final AccountsController accountsController = Get.find<AccountsController>();
  RxString accountId = ''.obs;
  RxString selectedPeriod = 'За текущую неделю'.obs;

  Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);
  Future<void> selectDateRange(BuildContext context) async {
    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) => DateRangePickerDialog(
        firstDate: DateTime(2023),
        lastDate: DateTime.now(),
        initialEntryMode: DatePickerEntryMode.input,
        initialDateRange: selectedDateRange.value ??
            DateTimeRange(
              start: DateTime.now().subtract(Duration(days: 7)),
              end: DateTime.now(),
            ),
        saveText: 'Выбрать',
        confirmText: 'Выбрать',
        cancelText: 'Отмена',
      ),
    );

    if (picked != null) {
      selectedDateRange.value = picked;
      selectedPeriod.value = 'Выбранный период';
      loadTransactions();
    }
  }

  RxMap<String, List<Transaction>> categorizedTransactions =
      <String, List<Transaction>>{}.obs;

  TransferHistoryController();

  @override
  void onInit() async {
    super.onInit();
    await loadTransactions();
  }

  void updatePeriod(String period) {
    selectedPeriod.value = period;
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    List<Transaction> allTransactions = [];
    final now = DateTime.now();

    for (var account in accountsController.accounts) {
      final transactions = await accountsController
          .fetchTransactionHistory(account.accountNumber);
      allTransactions.addAll(transactions);
    }

    // Sort transactions by date, most recent first
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Categorize transactions
    Map<String, List<Transaction>> categorized = {
      selectedPeriod.value: [],
    };

    for (var transaction in allTransactions) {
      switch (selectedPeriod.value) {
        case 'За текущую неделю':
          if (transaction.createdAt
              .isAfter(now.subtract(Duration(days: now.weekday)))) {
            categorized[selectedPeriod.value]?.add(transaction);
          }
          break;
        case 'За текущий месяц':
          if (transaction.createdAt.isAfter(DateTime(now.year, now.month))) {
            categorized[selectedPeriod.value]?.add(transaction);
          }
          break;
        case 'За 3 месяца':
          if (transaction.createdAt
              .isAfter(DateTime(now.year, now.month - 3))) {
            categorized[selectedPeriod.value]?.add(transaction);
          }
          break;
        case 'Выбранный период':
          if (selectedDateRange.value != null &&
              transaction.createdAt.isAfter(selectedDateRange.value!.start) &&
              transaction.createdAt.isBefore(
                  selectedDateRange.value!.end.add(Duration(days: 1)))) {
            categorized[selectedPeriod.value]?.add(transaction);
          }
          break;
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
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  _buildHeader(context),
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
                      physics: AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height -
                              MediaQuery.of(context).padding.top -
                              MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildFilterCard(context),
                            const SizedBox(height: 16),
                            Obx(() => controller.accountsController
                                        .transactionHistory.value?.isNotEmpty ??
                                    false
                                ? _buildTransactionsList(context)
                                : _buildEmptyState(theme, size)),
                          ],
                        ),
                      ),
                    ),
                  ))
                ]))));
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

  Widget _buildFilterCard(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Material(
        color: Colors.transparent,
        child: Ink(
            child: InkWell(
                onTap: () {
                  _showFilterBottomSheet(context);
                },
                borderRadius: BorderRadius.circular(12),
                splashFactory: InkRipple.splashFactory,
                splashColor: theme.colorScheme.primary.withOpacity(0.08),
                highlightColor: theme.colorScheme.primary.withOpacity(0.04),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                              controller.selectedPeriod.value,
                              style: Theme.of(context).textTheme.titleMedium,
                            )),
                        SvgPicture.asset(
                          'assets/icons/ic_filter.svg',
                          width: 32,
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                ))));
  }

  Widget _buildTransactionsList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      final categories = controller.categorizedTransactions.keys.toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                              Theme.of(context).colorScheme.secondaryContainer,
                              BlendMode.srcIn,
                            ),
                          ))),
            ],
          );
        },
      );
    });
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
                    transaction.formattedCreatedAt,
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

  void _showFilterBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/ic_back.svg',
                    width: 32,
                    height: 32,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Выберите период',
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
            SizedBox(height: 16),
            ...[
              'За текущую неделю',
              'За текущий месяц',
              'За 3 месяца',
              'Выбрать период в календаре'
            ].map((period) => ListTile(
                  leading: Container(
                    height: theme.textTheme.titleMedium!.fontSize! * 2 + 8,
                    width: theme.textTheme.titleMedium!.fontSize! * 2 + 8,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      period == 'За текущую неделю'
                          ? '7'
                          : period == 'За текущий месяц'
                              ? '30'
                              : period == 'За 3 месяца'
                                  ? '90'
                                  : '∞',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  title: Text(period),
                  onTap: () async {
                    if (period == 'Выбрать период в календаре') {
                      Navigator.pop(context);
                      await controller.selectDateRange(context);
                    } else {
                      controller.updatePeriod(period);
                      Navigator.pop(context);
                    }
                  },
                )),
          ],
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
