import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/accounts_controller.dart';
import '../shared/formatters.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final Transaction transaction = Get.arguments;

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

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Транзакция успешна';
      case 'pending':
        return 'В обработке';
      case 'failed':
        return 'Ошибка транзакции';
      default:
        return 'В обработке';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
        body: SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
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
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Информация о переводе',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 32),
                    ],
                  ),
                ),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getStatusColor(transaction.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusText(transaction.status),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${transaction.amount} ${transaction.currency}',
                            style: theme.textTheme.headlineMedium,
                          ),

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
                                      transaction.toAccount,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Transaction Details
                          _buildDetailRow('Тип перевода', transaction.type),
                          _buildDetailRow(
                              'ID транзакции', transaction.reference),
                          _buildDetailRow('Дата и время',
                              transaction.createdAt.toString().split('.')[0]),
                          _buildDetailRow(
                              'Комиссия', '0 ${transaction.currency}'),
                          _buildDetailRow('Отправитель',
                              transaction.fromUserName ?? 'Неизвестно'),
                          _buildDetailRow(
                              'Счет отправителя', transaction.fromAccount),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      'assets/icons/ic_share.svg',
                      'Поделиться',
                      () {},
                    ),
                    _buildActionButton(
                      context,
                      'assets/icons/ic_repeat.svg',
                      'Повторить',
                      () {},
                    ),
                    _buildActionButton(
                      context,
                      'assets/icons/ic_cancel.svg',
                      'Отменить',
                      () {},
                    ),
                    _buildActionButton(
                      context,
                      'assets/icons/ic_favorite.svg',
                      'В избранное',
                      () {},
                    ),
                  ],
                ),
              ),
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

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
    final double waveWidth = 8.0;

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