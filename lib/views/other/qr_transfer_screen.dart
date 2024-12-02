import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/accounts_controller.dart';
import '../shared/animated_dropdown.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../shared/qr_widgets.dart';

class QRTtransferController extends GetxController {
  final AccountsController accountsController = Get.find<AccountsController>();
  MobileScannerController? scannerController;
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  final RxBool isScanning = true.obs;
  final Rx<AccountModel?> selectedAccount = Rx<AccountModel?>(null);
  final RxBool isAccountDropdownExpanded = false.obs;

  final Rx<Map<String, dynamic>?> scannedData = Rx<Map<String, dynamic>?>(null);
  final RxBool showPaymentView = false.obs;

  final RxString amount = ''.obs;
  final RxString formattedAmount = ''.obs;
  String previousNumber = '';
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  void toggleMode(bool scanning) {
    isScanning.value = scanning;
  }

  void focusNextInput() {
    if (amountFocusNode.hasFocus) {
      messageFocusNode.requestFocus();
    }
  }

  String generateQRData() {
    final user = accountsController.userService.currentUser;
    final selectedAcc = selectedAccount.value;

    if (user == null || selectedAcc == null) return '';

    Map<String, dynamic> qrData = {
      'fullName': user.fullName,
      'accountNumber': selectedAcc.accountNumber,
      'currency': selectedAcc.currency,
      'amount': amount.value,
      'message': messageController.text,
    };

    return jsonEncode(qrData);
  }

  void processScannedQR(String? rawData) {
    if (rawData == null) return;

    try {
      print('Scanned data: $rawData');
      final data = jsonDecode(rawData);
      if (data['accountNumber'] != null && data['currency'] != null) {
        scannedData.value = data;
        showPaymentView.value = true;
        // Pre-fill amount and message if present
        if (data['amount'] != null &&
            (data['amount']?.isNotEmpty ?? false) &&
            (int.tryParse(data['amount'] ?? '') ?? 0) > 0) {
          updateAmount(data['amount']);
          amountController.text = data['amount'];
        }
        if (data['message'] != null) {
          messageController.text = data['message'];
        }
      }
    } catch (e) {
      print('Invalid QR format: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeSelectedAccount();
    initializeScannerController();
    amountController.text = '0';
    updateAmount('0');
  }

  void initializeScannerController() {
    scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void onClose() {
    scannerController?.dispose();
    super.onClose();
  }

  void _initializeSelectedAccount() {
    if (accountsController.accounts.isNotEmpty) {
      selectedAccount.value = accountsController.accounts.first;
    }
  }

  void refreshCards() {
    accountsController
        .fetchAccounts()
        .then((_) => _initializeSelectedAccount());
  }

  void updateAmount(String value) {
    String digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    const int maxTransferAmount = 2000000;

    if (digitsOnly.isEmpty) {
      amount.value = '';
      formattedAmount.value = '';
      amountController.value = TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
      return;
    }

    int number = int.tryParse(digitsOnly) ?? 0;

    if (number > maxTransferAmount) {
      number = int.parse(previousNumber);
      String formatted = previousNumber.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]} ',
      );
      final oldCursor = amountController.selection.start;
      final oldTextLength = amountController.text.length;
      final distanceFromEnd = oldTextLength - oldCursor;

      amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(
          offset: formatted.length - distanceFromEnd,
        ),
      );
      return;
    }

    String formatted = number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );

    amount.value = digitsOnly;
    formattedAmount.value = digitsOnly;
    previousNumber = digitsOnly;

    final oldCursor = amountController.selection.start;
    final oldTextLength = amountController.text.length;
    final distanceFromEnd = oldTextLength - oldCursor;

    amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length - distanceFromEnd,
      ),
    );
  }
}

class QRTransferScreen extends StatelessWidget {
  final QRTtransferController controller = Get.put(QRTtransferController());
  final qrKey = GlobalKey(debugLabel: 'QR');

  QRTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildToggleSwitch(context),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() => controller.isScanning.value
                  ? _buildQrView(context)
                  : _buildCreator(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Card(
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
                    'QR',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),
        ));
  }

  Widget _buildToggleSwitch(BuildContext context) {
    return Obx(() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.inverseSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: controller.isScanning.value
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleMode(true),
                      behavior: HitTestBehavior.opaque,
                      child: _buildToggleOption(
                        context: context,
                        title: "Сканировать",
                        isSelected: controller.isScanning.value,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.toggleMode(false),
                      behavior: HitTestBehavior.opaque,
                      child: _buildToggleOption(
                        context: context,
                        title: "Создать",
                        isSelected: !controller.isScanning.value,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )));
  }

  Widget _buildToggleOption(
      {required BuildContext context,
      required String title,
      required bool isSelected}) {
    return AnimatedDefaultTextStyle(
      style: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.outline,
        fontWeight: FontWeight.bold,
      ),
      duration: Duration(milliseconds: 200),
      child: Center(child: Text(title)),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return Obx(() => controller.showPaymentView.value
        ? _buildPaymentView(context)
        : _buildScanner(context));
  }

  Widget _buildPaymentView(BuildContext context) {
    final scannedData = controller.scannedData.value!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  buildCardSelector(context),
                  const SizedBox(height: 16),
                  _buildAmountInput(
                    context,
                    readOnly: (scannedData['amount']?.isNotEmpty ?? false) &&
                        (int.tryParse(scannedData['amount'] ?? '') ?? 0) > 0,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Получатель: ${scannedData['fullName']}'),
                            if (scannedData['message']?.isNotEmpty ?? false)
                              Text('Сообщение: ${scannedData['message']}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final amount = controller.amount.value.isEmpty
                ? 0
                : int.parse(controller.amount.value);

            final formattedAmount = amount.toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]} ',
                );

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.selectedAccount.value == null) {
                    Get.snackbar('Ошибка', 'Пожалуйста, выберите карту');
                    return;
                  }

                  if (controller.amount.value.isEmpty ||
                      controller.amount.value == '0') {
                    Get.snackbar('Ошибка', 'Пожалуйста, введите сумму');
                    return;
                  }

                  if (scannedData['accountNumber'] == null) {
                    Get.snackbar('Ошибка', 'Получатель не найден');
                    return;
                  }

                  final transaction = await controller.accountsController
                      .createTransaction(
                          controller.selectedAccount.value!.accountNumber,
                          scannedData['accountNumber'],
                          double.parse(controller.amount.value),
                          controller.selectedAccount.value!.currency);
                  if (transaction != null && transaction.status == 'success') {
                    Get.snackbar('Успех', 'Перевод успешно выполнен');
                    controller.refreshCards();
                    Navigator.of(Get.context!).pop();
                  } else {
                    Get.snackbar('Ошибка', 'Перевод не выполнен');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: Text('Перевести $formattedAmount ₸',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                        )),
              ),
            );
          }),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      ],
    );
  }

  Widget _buildScanner(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.fromDirection(
          -pi / 2, MediaQuery.of(context).size.height * 0.15)),
      width: scanArea,
      height: scanArea,
    );

    return Stack(
      children: [
        MobileScanner(
          scanWindow: scanWindow,
          controller: controller.scannerController!,
          errorBuilder: (context, error, child) {
            return ScannerErrorWidget(error: error);
          },
          onDetect: (capture) {
            final String? code = capture.barcodes.firstOrNull?.rawValue;
            if (code != null) {
              controller.processScannedQR(code);
            }
          },
        ),
        ValueListenableBuilder(
          valueListenable: controller.scannerController!,
          builder: (context, value, child) {
            return CustomPaint(
              painter: ScannerOverlay(scanWindow: scanWindow),
            );
          },
        ),
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          final BarcodeCapture? barcodes = await controller
                              .scannerController!
                              .analyzeImage(image.path);
                          if (barcodes != null &&
                              barcodes.barcodes.isNotEmpty) {
                            final String? code =
                                barcodes.barcodes.first.rawValue;
                            if (code != null) {
                              controller.processScannedQR(code);
                            }
                          }
                        }
                      },
                      child: SvgPicture.asset('assets/icons/ic_gallery.svg'),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await controller.scannerController?.toggleTorch();
                      },
                      child: SvgPicture.asset('assets/icons/ic_flash.svg'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreator(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            buildCardSelector(context),
            const SizedBox(height: 16),
            _buildAmountInput(context, readOnly: false),
            const SizedBox(height: 16),
            _buildMessageInput(context),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SvgPicture.asset(
                      'assets/icons/attention.svg',
                      width: 40,
                      height: 40,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.outline,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Вы можете создать QR без суммы получаемого перевода или сообщения. Сумма перевода будет указана отправителем при сканировании вашего QR',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPadding(
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeInOut,
                padding: EdgeInsets.only(bottom: bottomInset),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: PrettyQrView.data(
                              data: controller.generateQRData(),
                              decoration: const PrettyQrDecoration(
                                  image: PrettyQrDecorationImage(
                                image: AssetImage(
                                    'assets/images/play_store_512_2.png'),
                              ))),
                        ),
                      ),
                    );
                  },
                  child: Text('Создать QR код',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            fontFamily: 'Roboto',
                          )),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ));
  }

  Widget _buildAmountInput(BuildContext context, {required readOnly}) {
    return GestureDetector(
      onTap: () {
        controller.amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.amountController.text.length),
        );
        controller.amountFocusNode.requestFocus();
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сумма получаемого перевода',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      focusNode: controller.amountFocusNode,
                      controller: controller.amountController,
                      keyboardType: TextInputType.number,
                      enabled: !readOnly,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: controller.focusNextInput,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto',
                              ),
                      decoration: InputDecoration(
                        hintText: '0',
                        border: InputBorder.none,
                        isDense: true,
                        suffixText: ' ₸',
                        suffixStyle: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: controller.updateAmount,
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.messageController.text.length),
        );
        controller.messageFocusNode.requestFocus();
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Сообщение отправителю',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  IntrinsicWidth(
                    child: TextField(
                      focusNode: controller.messageFocusNode,
                      controller: controller.messageController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Введите сообщение',
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Expanded(child: Container())
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardSelector(BuildContext context) {
    return Obx(() {
      if (controller.accountsController.accounts.isEmpty) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'У вас нет доступных счетов',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      }
      return AnimatedCardDropdown(
        accounts: controller.accountsController.accounts,
        selectedAccount: controller.selectedAccount.value,
        isExpanded: controller.isAccountDropdownExpanded.value,
        onAccountSelected: (account) {
          controller.selectedAccount.value = account;
          controller.isAccountDropdownExpanded.value = false;
        },
        onToggle: () => controller.isAccountDropdownExpanded.toggle(),
      );
    });
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
