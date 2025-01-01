class ChatUtils {
  static String generateChatId(String? user1Id, String? user2Id) {
    final List<String> userIds = [user1Id ?? '', user2Id ?? '']..sort();
    return '${userIds[0]}_${userIds[1]}';
  }
}
