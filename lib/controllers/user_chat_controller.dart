// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import '../models/chat_message.dart';
// import '../models/user.dart';
// import '../services/record_service.dart';
// import 'package:file_picker/file_picker.dart';

// class UserChatController extends GetxController {
//   final messages = <ChatMessage>[].obs;
//   final isTyping = false.obs;
//   final currentUserId = ''.obs;
//   final selectedUser = Rxn<User>();
//   final _imagePicker = ImagePicker();
//   final _audioRecorder = AudioRecorder();

//   Future<void> pickImage() async {
//     final XFile? image =
//         await _imagePicker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       // Upload image and get URL
//       messages.add(ChatMessage(
//           id: DateTime.now().toString(),
//           content: 'Image',
//           senderId: currentUserId.value,
//           timestamp: DateTime.now(),
//           type: MessageType.image,
//           mediaUrl: image.path));
//     }
//   }

//   Future<void> pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: [
//           'pdf', 'doc', 'docx', 'txt', 'exe', 'pptx', 'xlsx', 'zip', 'rar',
//           'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', // Image formats
//           'mp3', 'wav', 'aac', 'ogg', 'flac', // Audio formats
//           'mp4', 'mov', 'avi', 'mkv', 'webm', // Video formats
//           'csv', 'rtf', 'svg', 'html', 'json' // Other formats
//         ],
//         allowMultiple: false);

//     if (result != null) {
//       final file = File(result.files.single.path!);
//       messages.add(ChatMessage(
//           id: DateTime.now().toString(),
//           content: result.files.single.name,
//           senderId: currentUserId.value,
//           timestamp: DateTime.now(),
//           type: MessageType.file,
//           mediaUrl: file.path));
//     }
//   }

//   Future<void> startRecording() async {
//     if (await _audioRecorder.hasPermission()) {
//       await _audioRecorder.start();
//     }
//   }

//   Future<void> stopRecording() async {
//     final path = await _audioRecorder.stop();
//     if (path != null) {
//       messages.add(ChatMessage(
//           id: DateTime.now().toString(),
//           content: 'Audio',
//           senderId: currentUserId.value,
//           timestamp: DateTime.now(),
//           type: MessageType.audio,
//           mediaUrl: path));
//     }
//   }

//   void sendMessage(String text) {
//     final message = ChatMessage(
//         id: DateTime.now().toString(),
//         content: text,
//         senderId: currentUserId.value,
//         timestamp: DateTime.now(),
//         type: MessageType.text);
//     messages.add(message);
//   }
// }
