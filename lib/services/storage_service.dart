import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String chatBoxName = 'chats';
  static const String settingsBoxName = 'settings';
  static late Box chatBox;
  static late Box settingsBox;

  static Future<void> init() async {
    chatBox = await Hive.openBox(chatBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);
  }

  // Save API Key
  static Future<void> saveApiKey(String key) async {
    await settingsBox.put('api_key', key);
  }

  static String? getApiKey() {
    return settingsBox.get('api_key');
  }

  // Chat History
  static Future<String> createNewChat({String title = 'گفتگوی جدید'}) async {
    final id = const Uuid().v4();
    final chat = {
      'id': id,
      'title': title,
      'createdAt': DateTime.now().toIso8601String(),
      'messages': [],
    };
    await chatBox.put(id, chat);
    return id;
  }

  static List<Map> getAllChats() {
    return chatBox.values.map((e) => Map<String, dynamic>.from(e)).toList()
      ..sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt'] as String));
  }

  static Map? getChat(String id) {
    final data = chatBox.get(id);
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  static Future<void> addMessage(String chatId, Map message) async {
    final chat = getChat(chatId);
    if (chat == null) return;
    
    final messages = List<Map>.from(chat['messages'] ?? []);
    messages.add(message);
    chat['messages'] = messages;
    
    // Update title from first user message if still default
    if (chat['title'] == 'گفتگوی جدید' && message['role'] == 'user') {
      final content = message['content'] as String? ?? '';
      chat['title'] = content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }
    
    await chatBox.put(chatId, chat);
  }

  static Future<void> deleteChat(String id) async {
    await chatBox.delete(id);
  }

  static Future<void> clearAllChats() async {
    await chatBox.clear();
  }
}
