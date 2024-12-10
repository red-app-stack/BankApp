import 'dart:convert';

import 'package:bank_app/widgets/common/custom_card.dart';
import 'package:bank_app/widgets/items/service_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../shared/formatters.dart';
import '../shared/secure_store.dart';
import '../../models/transaction_model.dart';

class TransactionDetailsController extends GetxController {
  Transaction transaction;
  final SecureStore secureStore = Get.find<SecureStore>();
  bool isFavorite = false;

  static const String favoritesKey = 'favorite_transfers';

  Future<List<Transaction>> getFavoriteTransfers() async {
    final favoritesJson = await secureStore.secureRead(favoritesKey);
    if (favoritesJson != null) {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.map((json) => Transaction.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> saveFavoriteTransfer(Transaction transaction) async {
    List<Transaction> favorites = await getFavoriteTransfers();
    favorites.add(transaction);
    print(favorites.map((e) => e.toJson()).toList());
    await secureStore.secureStore(
        favoritesKey, jsonEncode(favorites.map((e) => e.toJson()).toList()));
  }

  Future<void> removeFavoriteTransfer(String reference) async {
    List<Transaction> favorites = await getFavoriteTransfers();
    favorites.removeWhere((t) => t.reference == reference);
    await secureStore.secureStore(
        favoritesKey, jsonEncode(favorites.map((e) => e.toJson()).toList()));
  }

  TransactionDetailsController(this.transaction);

  @override
  void onInit() async {
    super.onInit();
    await loadTransferState();
  }

  loadTransferState() async {
    List<Transaction> favorites = await getFavoriteTransfers();
    for (Transaction element in favorites) {
      if (element.reference == transaction.reference) {
        isFavorite = true;
      }
    }
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction = Get.arguments;
  final TransactionDetailsController controller =
      Get.put(TransactionDetailsController(Get.arguments as Transaction));

  TransactionDetailsScreen({super.key});

  Widget _buildUserAvatar(ThemeData theme, String? userName) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Text(
        getInitials(userName ?? ''),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
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
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String type, String status) {
    switch (status) {
      case 'completed':
        return '${getTypeText(type)} успешно выполнен';
      case 'pending':
        return '${getTypeText(type)} в обработке';
      case 'failed':
        return '${getTypeText(type)} не выполнен';
      default:
        return '${getTypeText(type)} В обработке';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
        body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              CustomCard(
                padding: const EdgeInsets.all(6),
                startWidget: IconButton(
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
                endWidget: const SizedBox(width: 32),
                label: 'Информация о переводе',
              ),

              Card(
                shape: CustomBorder(),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/images/play_store_512.png'),
                              )),
                          SizedBox(height: 16),
                          // Status and Amount
                          Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _getStatusColor(transaction.status)
                                    .withOpacity(0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getStatusText(
                                          transaction.type, transaction.status),
                                      textAlign: TextAlign.left,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              color: theme.brightness ==
                                                      Brightness.light
                                                  ? _getStatusColor(
                                                          transaction.status)
                                                      .withGreen(120)
                                                  : _getStatusColor(
                                                          transaction.status)
                                                      .withGreen(220),
                                              fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      formatCurrency(transaction.amount,
                                          transaction.currency, 'ru_RU'),
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                              color: theme.brightness ==
                                                      Brightness.light
                                                  ? _getStatusColor(
                                                          transaction.status)
                                                      .withGreen(120)
                                                  : _getStatusColor(
                                                          transaction.status)
                                                      .withGreen(220),
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto'),
                                    ),
                                  ])),

                          const SizedBox(height: 24),

                          // Recipient Info
                          Row(
                            children: [
                              _buildUserAvatar(theme, transaction.toUserName),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.toUserName ?? 'Получатель',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Text(
                                      transaction.toUserPhone != null
                                          ? '+7 ${transaction.toUserPhone}'
                                          : censorCardNumber(
                                              transaction.toAccount),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow(
                              'Тип транзакции', getTypeText(transaction.type)),
                          const SizedBox(height: 4),
                          Divider(
                              height: 1,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1)),
                          _buildDetailRow(
                              'ID транзакции', transaction.reference),
                          const SizedBox(height: 4),
                          Divider(
                              height: 1,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1)),
                          _buildDetailRow(
                              'Дата и время', transaction.formattedCreatedAt),
                          const SizedBox(height: 4),
                          Divider(
                              height: 1,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1)),
                          _buildDetailRow(
                              'Комиссия', '0 ${transaction.currency}'),
                          const SizedBox(height: 4),
                          Divider(
                              height: 1,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1)),
                          _buildDetailRow('Отправитель',
                              transaction.fromUserName ?? 'Неизвестно'),
                          const SizedBox(height: 4),
                          Divider(
                              height: 1,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.1)),
                          _buildDetailRow(
                              'Счет отправителя', transaction.fromAccount),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Action Buttons
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Card(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ServiceItem(
                        iconData: Icons.share,
                        label: 'Поделиться',
                        labelSize: 13,
                        iconSize: 24,
                      ),
                      ServiceItem(
                        iconData: Icons.repeat,
                        label: 'Повторить',
                        labelSize: 13,
                        iconSize: 24,
                        onTap: () {
                          // ('deposit', 'withdrawal', 'phone_transfer', 'qr_transfer', 'currency_conversion',  'internal_transfer', 'card_transfer',  'swift_transfer'
                          Get.offAndToNamed('/main', arguments: '/transfers');
                          switch (transaction.type) {
                            case 'phone_transfer':
                              Get.toNamed('/phoneTransfer',
                                  arguments: transaction);
                              break;
                            case 'internal_transfer':
                              Get.toNamed('/selfTransfer',
                                  arguments: transaction);
                              break;
                            case 'card_transfer':
                              Get.toNamed('/cardTransfer',
                                  arguments: transaction);
                              break;
                            case 'swift_transfer':
                              Get.toNamed('/swiftTransfer',
                                  arguments: transaction);
                              break;
                            case 'currency_conversion':
                              Get.toNamed('/convertation',
                                  arguments: transaction);
                              break;
                            case 'qr_transfer':
                              Get.toNamed('/qrTransfer',
                                  arguments: transaction);
                              break;
                          }
                        },
                      ),
                      ServiceItem(
                        iconData: Icons.cancel,
                        label: 'Отменить',
                        labelSize: 13,
                        iconSize: 24,
                      ),
                      ServiceItem(
                          iconData: Icons.favorite,
                          label: 'В избранное',
                          labelSize: 13,
                          iconSize: 24,
                          onTap: () async {
                            if (controller.isFavorite) {
                              print('removing from favorite');
                              await controller.removeFavoriteTransfer(
                                  transaction.reference);
                            } else {
                              print('adding to favorite');

                              await controller
                                  .saveFavoriteTransfer(transaction);
                            }
                            controller.isFavorite = !controller.isFavorite;
                            // setState(() {});
                          }),
                    ],
                  ),
                )),
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }
}

class CustomBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double waveHeight = 6.0;
    final double waveWidth = 6.0;

    path.moveTo(rect.left, rect.top);

    bool up = true;
    for (double x = rect.left; x < rect.right; x += waveWidth) {
      if (up) {
        path.relativeQuadraticBezierTo(
          waveWidth / 2,
          -waveHeight,
          waveWidth,
          0,
        );
      } else {
        path.relativeQuadraticBezierTo(
          waveWidth / 2,
          waveHeight,
          waveWidth,
          0,
        );
      }
      up = !up;
    }

    // Right side
    path.lineTo(rect.right, rect.bottom);

    // Bottom waves
    up = true;
    for (double x = rect.right; x > rect.left; x -= waveWidth) {
      if (up) {
        path.relativeQuadraticBezierTo(
          -waveWidth / 2,
          waveHeight,
          -waveWidth,
          0,
        );
      } else {
        path.relativeQuadraticBezierTo(
          -waveWidth / 2,
          -waveHeight,
          -waveWidth,
          0,
        );
      }
      up = !up;
    }

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

class WavyLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Wave parameters
    final waveHeight = 3.0;
    final wavelength = 10.0;

    // Start path from left
    path.moveTo(0, 0);

    // Create wave pattern
    for (double i = 0; i < size.width; i += wavelength) {
      path.quadraticBezierTo(
        i + (wavelength / 4),
        waveHeight,
        i + (wavelength / 2),
        0,
      );
      path.quadraticBezierTo(
        i + (wavelength * 3 / 4),
        -waveHeight,
        i + wavelength,
        0,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 8;
    const dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
