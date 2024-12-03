class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final MessageType type;
  final String? mediaUrl;
  final bool isSender;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.type = MessageType.text,
    this.mediaUrl,
    this.isSender = false,
    this.status = MessageStatus.sent,
  });
}

enum MessageType { text, image, audio, video, file }

enum MessageStatus { sending, sent, delivered, read }
