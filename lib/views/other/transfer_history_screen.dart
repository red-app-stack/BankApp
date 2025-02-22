import 'dart:async';
import 'package:bank_app/views/shared/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../models/transaction_model.dart';
import '../../controllers/accounts_controller.dart';

class TransferHistoryController extends GetxController {
  void refreshData(GlobalKey<RefreshIndicatorState> refreshKey) {
    print('Starting refresh delay...');
    Future.delayed(const Duration(seconds: 5), () {
      print('Delay complete, showing refresh indicator');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshKey.currentState?.show();
        print('Refresh indicator shown');
      });
    });
  }

  List<Transaction> existingTransactions = [];

  final AccountsController accountsController = Get.find<AccountsController>();
  RxString accountId = ''.obs;
  RxString selectedPeriod = 'За неделю'.obs;
  RxString selectedPeriodDetail = ''.obs;
  RxMap<String, List<Transaction>> categorizedTransactions =
      <String, List<Transaction>>{'': []}.obs;

  Rx<DateTimeRange?> selectedDateRange = Rx<DateTimeRange?>(null);

  Future<void> selectDateRange(BuildContext context) async {
    final theme = Theme.of(context);
    DateTimeRange tempRange = selectedDateRange.value ??
        DateTimeRange(
          start: DateTime.now().subtract(Duration(days: 7)),
          end: DateTime.now(),
        );

    final picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Container(
          height: 400,
          width: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Выберите период',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(
                    tempRange.start,
                    tempRange.end,
                  ),
                  minDate: DateTime(2023),
                  maxDate: DateTime.now(),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                    showTrailingAndLeadingDates: true,
                  ),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    if (args.value is PickerDateRange &&
                        args.value.startDate != null) {
                      tempRange = DateTimeRange(
                        start: args.value.startDate,
                        end: args.value.endDate ?? args.value.startDate,
                      );
                    }
                  },
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: theme.colorScheme.surface,
                    textStyle: theme.textTheme.titleMedium,
                  ),
                  yearCellStyle: DateRangePickerYearCellStyle(
                    textStyle: theme.textTheme.bodyMedium,
                    todayTextStyle: theme.textTheme.bodyMedium,
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: theme.textTheme.bodyMedium,
                    todayTextStyle: theme.textTheme.bodyMedium,
                  ),
                  selectionColor: theme.colorScheme.primary,
                  todayHighlightColor: theme.colorScheme.primary,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Отмена',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, tempRange);
                    },
                    child: Text(
                      'Выбрать',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      selectedDateRange.value = picked;
      updatePeriod('Выбранный период');
    }
  }

  TransferHistoryController();

  @override
  void onInit() async {
    super.onInit();
    updatePeriod('За неделю');
    if (accountsController.transactionHistory.value != null) {
      existingTransactions = accountsController.transactionHistory.value!;
      _updateCategorizedTransactions(existingTransactions);
    }
    await loadTransactions();
  }

  void updatePeriod(String period) {
    selectedPeriod.value = period;
    final now = DateTime.now();

    String formatDate(DateTime date) {
      const months = [
        'января',
        'февраля',
        'марта',
        'апреля',
        'мая',
        'июня',
        'июля',
        'августа',
        'сентября',
        'октября',
        'ноября',
        'декабря'
      ];

      String yearSuffix =
          date.year != now.year ? " '${date.year.toString().substring(2)}" : "";
      return "${date.day} ${months[date.month - 1]}$yearSuffix";
    }

    switch (selectedPeriod.value) {
      case 'За неделю':
        final startDate = now.subtract(const Duration(days: 7));
        selectedPeriodDetail.value =
            "${formatDate(startDate)} - ${formatDate(now)}";
        break;
      case 'За месяц':
        final startDate = now.subtract(const Duration(days: 30));
        selectedPeriodDetail.value =
            "${formatDate(startDate)} - ${formatDate(now)}";
        break;
      case 'За 3 месяца':
        final startDate = now.subtract(const Duration(days: 90));
        selectedPeriodDetail.value =
            "${formatDate(startDate)} - ${formatDate(now)}";
        break;
      case 'Выбранный период':
        if (selectedDateRange.value != null) {
          selectedPeriodDetail.value = selectedDateRange
                      .value?.duration.inDays ==
                  0
              ? formatDate(selectedDateRange.value!.start)
              : "${formatDate(selectedDateRange.value!.start)} - ${formatDate(selectedDateRange.value!.end)}";
        }
        break;
    }

    loadTransactions();
  }

  Future<void> loadTransactions() async {
    if (existingTransactions.isNotEmpty) {
      _updateCategorizedTransactions(existingTransactions);
    }
    try {
      // Fetch new transactions in background
      List<Transaction> newTransactions =
          await accountsController.fetchTransactionHistory();

      // Filter and process new transactions
      newTransactions = newTransactions
          .where((transaction) =>
              transaction.type != 'internal_transfer' &&
              transaction.type != 'currency_conversion' &&
              (transaction.type != 'deposit' && transaction.amount != 1000.0))
          .toList();

      // Add only new transactions that don't exist
      List<Transaction> updatedTransactions = [];
      for (var newTx in newTransactions) {
        var existingTxIndex = existingTransactions
            .indexWhere((existingTx) => existingTx.id == newTx.id);
        if (existingTxIndex != -1) {
          // Update if status or any other field changed
          if (existingTransactions[existingTxIndex].status != newTx.status ||
              existingTransactions[existingTxIndex].amount != newTx.amount ||
              existingTransactions[existingTxIndex].currency !=
                  newTx.currency) {
            updatedTransactions.add(newTx);
          } else {
            updatedTransactions.add(existingTransactions[existingTxIndex]);
          }
        } else {
          // Add new transaction
          updatedTransactions.add(newTx);
        }
      }

      // Sort and update UI
      existingTransactions = updatedTransactions;
      existingTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _updateCategorizedTransactions(existingTransactions);

      // Update controller cache
      accountsController.transactionHistory.value = existingTransactions;
    } catch (e) {
      print('Error fetching new transactions: $e');
      // Still show existing transactions on error
      _updateCategorizedTransactions(existingTransactions);
    }
  }

  void _updateCategorizedTransactions(List<Transaction> transactions) {
    Map<String, List<Transaction>> categorized = {
      selectedPeriod.value: [],
    };

    final now = DateTime.now();

    for (var transaction in transactions) {
      switch (selectedPeriod.value) {
        case 'За неделю':
          if (transaction.createdAt
              .isAfter(now.subtract(const Duration(days: 7)))) {
            categorized[selectedPeriod.value]?.add(transaction);
          }
          break;
        // ... other cases remain the same
      }
    }

    categorizedTransactions.value = categorized;
  }
}

class TransferHistoryScreen extends StatelessWidget {
  final TransferHistoryController controller =
      Get.put(TransferHistoryController());
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    controller.refreshData(_refreshIndicatorKey);
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  _buildHeader(context),
                  Expanded(
                      child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    onRefresh: () async {
                      try {
                        await controller.loadTransactions();
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
    return Card(
        child: InkWell(
      onTap: () {
        _showFilterBottomSheet(context);
      },
      borderRadius: BorderRadius.circular(12),
      splashFactory: InkRipple.splashFactory,
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
                  controller.selectedPeriodDetail.value,
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
    ));
  }

  Widget _buildTransactionsList(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Obx(() {
      final categories = controller.categorizedTransactions.keys.toList();
      final transactions =
          controller.categorizedTransactions[categories[0]] ?? [];

      // Group transactions by date
      Map<String, List<Transaction>> transactionsByDate = {};
      for (var transaction in transactions) {
        String dateKey =
            DateFormat('d MMMM', 'ru').format(transaction.createdAt);
        transactionsByDate.putIfAbsent(dateKey, () => []);
        transactionsByDate[dateKey]!.add(transaction);
      }

      final now = DateTime.now();
      final today = DateFormat('d MMMM', 'ru').format(now);

      return transactions.isEmpty
          ? Center(
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
                  )))
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactionsByDate.length,
              itemBuilder: (context, index) {
                String date = transactionsByDate.keys.elementAt(index);
                List<Transaction> dayTransactions = transactionsByDate[date]!;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16, left: 16),
                        child: Text(
                          date == today ? 'Сегодня, $date' : date,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      ...dayTransactions.map((transaction) => Column(
                            children: [
                              dayTransactions.first != transaction
                                  ? Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color:
                                          Theme.of(context).colorScheme.outline)
                                  : Container(),
                              _buildTransactionContent(context, transaction),
                            ],
                          )),
                    ],
                  ),
                );
              },
            );
    });
  }

  Widget _buildTransactionContent(
      BuildContext context, Transaction transaction) {
    return InkWell(
        onTap: () {
          Get.toNamed('/transferDetails', arguments: transaction);
        },
        splashColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        highlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTypeText(transaction.type),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                  ),
                  Text(
                    formatCurrency(transaction.amount, transaction.currency,
                        Get.locale.toString()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: transaction.status != 'completed'
                              ? _getStatusColor(transaction.status)
                              : Theme.of(context).textTheme.titleMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (transaction.fromUserName != null &&
                  transaction.fromAccount != '')
                Text(
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
                  Container(),
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
        ));
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
                  icon: Transform.rotate(
                      angle: -90 * 3.14159 / 180, // 90 degrees in radians
                      child: SvgPicture.asset(
                        'assets/icons/ic_back.svg',
                        width: 32,
                        height: 32,
                        colorFilter: ColorFilter.mode(
                          theme.colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      )),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Выберите период',
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.start,
                      )),
                ),
                SizedBox(width: 48),
              ],
            ),
            SizedBox(height: 16),
            ...[
              'За неделю',
              'За месяц',
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
                      period == 'За неделю'
                          ? '7'
                          : period == 'За месяц'
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
            SizedBox(height: 32),
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
