import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_database/firebase_database.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/widgets.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final AuthController controller = Get.find<AuthController>();
  final RxBool _isUploadingProfilePicture = false.obs;
  final RxDouble _uploadProgress = 0.0.obs;
  final Rx<String?> _profilePictureUrl = Rx<String?>(null);

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 500.0 : double.infinity,
                ),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildShimmerLoading(theme);
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    final userInfo = snapshot.data ?? {};
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          "Профиль",
                          style: theme.textTheme.headlineMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 20),
                        _buildProfilePicture(theme),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                          ),
                          child: Text('Изменить фото профиля'),
                        ),
                        SizedBox(height: 20),
                        _buildInfoCard('Полное имя',
                            userInfo['name'] ?? 'Не указано', theme),
                        _buildInfoCard(
                            'Email', userInfo['email'] ?? 'Не указано', theme),
                        _buildInfoCard('Статус', controller.userRole, theme),
                        _buildInfoCard('Дата рождения',
                            userInfo['dateOfBirth'] ?? 'Не указано', theme),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _openSettings(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                          ),
                          child: Text('Настройки'),
                        ),
                        SizedBox(height: 20),
                        fakeHero(
                          tag: 'main_button',
                          child: Obx(() => ElevatedButton(
                                onPressed: () async {
                                  if (!controller.status) {
                                    try {
                                      // await controller.signOut();
                                    } catch (e) {
                                      Get.snackbar('Ошибка',
                                          'Не удалось выйти из системы: ${e.toString()}');
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.error,
                                ),
                                child: controller.status
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ),
                                      )
                                    : Text('Выйти'),
                              )),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceContainer,
      highlightColor: theme.colorScheme.surfaceBright,
      period: Duration(seconds: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          // Заголовок "Профиль"
          Container(
            width: 200,
            height: theme.textTheme.headlineMedium!.fontSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 28),
          // Фото профиля
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
          ),
          SizedBox(height: 10),
          // Кнопка "Изменить фото профиля"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
          // Информационные карточки
          for (int i = 0; i < 4; i++) ...[
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 10),
            ),
          ],
          SizedBox(height: 20),
          // Кнопка "Настройки"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
          // Кнопка "Выйти"
          Container(
            width: double.infinity,
            height: 50, // Высота кнопки из темы
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30), // Скругление из темы
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(ThemeData theme) {
    return Obx(() {
      return Stack(
        alignment: Alignment.center,
        children: [
          if (_profilePictureUrl.value != null)
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.surfaceContainer,
              child: ClipOval(
                child: Image.network(
                  _profilePictureUrl.value!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Shimmer.fromColors(
                      baseColor: theme.colorScheme.surfaceContainer,
                      highlightColor: theme.colorScheme.surfaceBright,
                      child: Container(
                        width: 120,
                        height: 120,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: 60,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.primary,
              child: Icon(
                Icons.person,
                size: 60,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          if (_isUploadingProfilePicture.value)
            Positioned.fill(
              child: CircularProgressIndicator(
                value: _uploadProgress.value,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      );
    });
  }

  // Future<void> _changeProfilePicture() async {
  //   final picker = ImagePicker();

  //   final ImageSource? source = await Get.dialog<ImageSource>(
  //     Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(16.0),
  //       ),
  //       child: Container(
  //         padding: EdgeInsets.all(20.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Text(
  //               'Выберите изображение',
  //               style: Get.textTheme.headlineSmall,
  //             ),
  //             SizedBox(height: 32.0),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Get.back(result: ImageSource.camera);
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30.0),
  //                 ),
  //                 minimumSize: Size(double.infinity, 50),
  //               ),
  //               child: Text('Сделать фото'),
  //             ),
  //             SizedBox(height: 8.0),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Get.back(result: ImageSource.gallery);
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30.0),
  //                 ),
  //                 minimumSize: Size(double.infinity, 50),
  //               ),
  //               child: Text('Выбрать из галереи'),
  //             ),
  //             SizedBox(height: 32.0),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Get.back();
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Get.theme.colorScheme.error,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(30.0),
  //                 ),
  //                 minimumSize: Size(double.infinity, 50),
  //               ),
  //               child: Text('Отмена'),
  //             ),
  //             SizedBox(height: 8.0),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );

  //   if (source != null) {
  //     final pickedFile = await picker.pickImage(source: source);
  //     if (pickedFile != null) {
  //       File image = File(pickedFile.path);
  //       try {
  //         _isUploadingProfilePicture.value = true;
  //         // final user = controller.user;
  //         // if (user == null) return;

  //         final storagePath = _firebaseAuthService.getStoragePath();
  //         final ref = FirebaseStorage.instance.ref(storagePath);

  //         final uploadTask = ref.putFile(image);

  //         uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
  //           _uploadProgress.value =
  //               snapshot.bytesTransferred / snapshot.totalBytes;
  //         });

  //         await uploadTask;
  //         final url = await ref.getDownloadURL();

  //         String dbPath = _firebaseAuthService.getDbPath();
  //         await FirebaseDatabase.instance
  //             .ref('$dbPath/info')
  //             .update({'profilePicture': url});

  //         _profilePictureUrl.value = url;
  //         Get.snackbar('Успех', 'Фото профиля успешно обновлено');
  //       } catch (e) {
  //         Get.snackbar('Ошибка',
  //             'При изменении фото профиля произошла ошибка: ${e.toString()}');
  //       } finally {
  //         _isUploadingProfilePicture.value = false;
  //       }
  //     }
  //   }
  // }

  Widget _buildInfoCard(String title, String value, ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainer,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  // Future<Map<String, dynamic>> _getUserData() async {
  //   Stopwatch stopwatch = Stopwatch()..start(); // Начинаем отсчёт времени

  //   await _firebaseAuthService.initialize();
  //   _isLoadingProfilePicture.value = true;
  //   final user = controller.user;
  //   if (user == null) {
  //     _isLoadingProfilePicture.value = false;
  //     return {};
  //   }

  //   final dbRef = FirebaseDatabase.instance.ref();
  //   String dbPath = _firebaseAuthService.getDbPath();

  //   try {
  //     final snapshot = await dbRef.child('$dbPath/info').get();
  //     stopwatch.stop(); // Останавливаем отсчёт времени
  //     final elapsedTime = stopwatch.elapsed.inMilliseconds;
  //     if (snapshot.exists) {
  //       Map<String, dynamic> userInfo = {};

  //       final infoData = snapshot.value as Map<Object?, Object?>;
  //       print(infoData);
  //       userInfo['name'] = infoData['name'] as String? ?? 'Не указано';
  //       userInfo['email'] = infoData['email'] as String? ?? 'Не указано';
  //       userInfo['profilePicture'] = infoData['profilePicture'] as String?;

  //       if (userInfo['profilePicture'] == null) {
  //         final storagePath = _firebaseAuthService.getStoragePath();
  //         try {
  //           final url = await FirebaseStorage.instance
  //               .ref(storagePath)
  //               .getDownloadURL();
  //           userInfo['profilePicture'] = url;
  //         } catch (e) {
  //           print('Error getting profile picture URL: $e');
  //         }
  //       }
  //       if (elapsedTime < 2000) {
  //         await Future.delayed(Duration(milliseconds: 2000 - elapsedTime));
  //       }

  //       _profilePictureUrl.value = userInfo['profilePicture'];
  //       _isLoadingProfilePicture.value = false;
  //       return userInfo;
  //     }
  //   } catch (e) {
  //     print('Error fetching user data: $e');
  //   }
  //   _isLoadingProfilePicture.value = false;
  //   return {};
  // }

  void _openSettings() {
    Get.to(() => SettingsScreen());
  }
}
