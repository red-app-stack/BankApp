import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/user_service.dart';

class UserChatScreen extends StatefulWidget {
  const UserChatScreen({super.key});

  @override
  UserChatScreenState createState() => UserChatScreenState();
}

class UserChatScreenState extends State<UserChatScreen>
    with TickerProviderStateMixin {
  // final controller = Get.put(UserChatController());
  final TextEditingController _textController = TextEditingController();
  // final ScrollController _scrollController = ScrollController();
  final UserService userService = Get.find<UserService>();
  // final Map<ChatMessage, AnimationController> _messageAnimations = {};

  Duration duration = Duration();
  Duration position = Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  // Widget _buildMessageContent(
  //     ChatMessage message, ThemeData theme, String userName, bool showTail) {
  //   switch (message.type) {
  //     case MessageType.audio:
  //       return BubbleNormalAudio(
  //         color: theme.colorScheme.surfaceContainer,
  //         duration: duration.inSeconds.toDouble(),
  //         position: position.inSeconds.toDouble(),
  //         isPlaying: isPlaying,
  //         isLoading: isLoading,
  //         isPause: isPause,
  //         onSeekChanged: _changeSeek,
  //         onPlayPauseButtonClick: _playAudio,
  //         sent: true,
  //       );
  //     case MessageType.image:
  //       return BubbleNormalImage(
  //         id: message.id,
  //         image: Image.file(File(message.mediaUrl!)),
  //         color: message.isSender
  //             ? theme.colorScheme.primary
  //             : theme.colorScheme.surfaceContainer,
  //         tail: false,
  //         delivered: true,
  //       );
  //     case MessageType.file:
  //       return BubbleSpecialThree(
  //         text: "📎 ${message.content}",
  //         color: message.isSender
  //             ? theme.colorScheme.primary
  //             : theme.colorScheme.surfaceContainer,
  //         tail: false,
  //         isSender: message.isSender,
  //       );
  //     default:
  //       return BubbleSpecialThree(
  //         text: message.content,
  //         color: message.isSender
  //             ? theme.colorScheme.primary
  //             : theme.colorScheme.surfaceContainer,
  //         tail: showTail,
  //         isSender: message.isSender,
  //         textStyle: TextStyle(
  //           color: message.isSender
  //               ? theme.colorScheme.onPrimary
  //               : theme.colorScheme.onSurface,
  //         ),
  //       );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // String userName = userService.currentUser?.fullName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с поддержкой'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(),
          // Expanded(
          //   child: Obx(() => ListView.builder(
          //         controller: _scrollController,
          //         padding: EdgeInsets.all(16),
          //         itemCount: controller.messages.length,
          //         itemBuilder: (context, index) {
          //           final message = controller.messages[index];
          //           final showTail = index == controller.messages.length - 1 ||
          //               controller.messages[index + 1].senderId !=
          //                   message.senderId;

          //           return SlideMessageAnimation(
          //             controller: _getAnimationController(message),
          //             isBot: !message.isSender,
          //             child: Align(
          //               alignment: message.isSender
          //                   ? Alignment.centerRight
          //                   : Alignment.centerLeft,
          //               child: Row(
          //                 crossAxisAlignment: CrossAxisAlignment.end,
          //                 mainAxisAlignment: message.isSender
          //                     ? MainAxisAlignment.end
          //                     : MainAxisAlignment.start,
          //                 children: [
          //                   if (!message.isSender) ...[
          //                     CircleAvatar(
          //                       radius: 16,
          //                       backgroundColor:
          //                           theme.colorScheme.primary.withOpacity(0.1),
          //                       child: Icon(Icons.support_agent,
          //                           color: theme.colorScheme.primary, size: 20),
          //                     ),
          //                   ],
          //                   Flexible(
          //                     child: _buildMessageContent(
          //                         message, theme, userName, showTail),
          //                   ),
          //                   if (message.isSender) ...[
          //                     buildUserAvatar(theme, userName, radius: 16),
          //                   ],
          //                 ],
          //               ),
          //             ),
          //           );
          //         },
          //       )),
          // ),
          // Container(
          //   padding: EdgeInsets.all(16),
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: Icon(Icons.attach_file),
          //         onPressed: controller.pickFile,
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.photo_camera),
          //         onPressed: controller.pickImage,
          //       ),
          //       Expanded(
          //         child: Container(
          //           height: 48,
          //           margin: EdgeInsets.symmetric(horizontal: 12),
          //           decoration: BoxDecoration(
          //             color: theme.colorScheme.surfaceContainer,
          //             borderRadius: BorderRadius.circular(20),
          //           ),
          //           child: TextField(
          //             controller: _textController,
          //             decoration: InputDecoration(
          //               border: InputBorder.none,
          //               hintText: 'Введите сообщение...',
          //               contentPadding: EdgeInsets.all(12),
          //             ),
          //             onSubmitted: _sendMessage,
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //         icon: Icon(
          //             _textController.text.isEmpty ? Icons.mic : Icons.send),
          //         onPressed: _textController.text.isEmpty
          //             ? controller.startRecording
          //             : () => _sendMessage(_textController.text),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // AnimationController _getAnimationController(ChatMessage message) {
  //   if (!_messageAnimations.containsKey(message)) {
  //     _messageAnimations[message] = AnimationController(
  //       vsync: this,
  //       duration: Duration(milliseconds: 400),
  //     )..forward();
  //   }
  //   return _messageAnimations[message]!;
  // }

  // void _sendMessage(String text) {
  //   if (text.isNotEmpty) {
  //     controller.sendMessage(text);
  //     _textController.clear();
  //     _scrollToBottom();
  //   }
  // }

  // void _scrollToBottom() {
  //   if (_scrollController.hasClients) {
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: Duration(milliseconds: 500),
  //       curve: Curves.easeOut,
  //     );
  //   }
  // }

  // void _changeSeek(double value) {
  //   setState(() {
  //     position = Duration(seconds: value.toInt());
  //   });
  // }

  // void _playAudio() {
  //   setState(() {
  //     isPlaying = !isPlaying;
  //     isPause = !isPause;
  //   });
  // }
}
