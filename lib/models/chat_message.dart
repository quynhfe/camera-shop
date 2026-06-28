class ChatMessage {
  final int id;
  final int userId;
  final String content;
  final bool isFromUser;
  final String createdAt;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isFromUser,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      content: (map['content'] as String?) ?? '',
      isFromUser: ((map['is_from_user'] as int?) ?? 1) == 1,
      createdAt: (map['created_at'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'content': content,
      'is_from_user': isFromUser ? 1 : 0,
    };
  }
}
