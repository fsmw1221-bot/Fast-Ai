import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ChatService extends ChangeNotifier {
  bool isLoading = false;
  String? currentChatId;
  List<Map<String, dynamic>> messages = [];

  String? get apiKey => StorageService.getApiKey();

  Future<void> setApiKey(String key) async {
    await StorageService.saveApiKey(key.trim());
    notifyListeners();
  }

  Future<void> loadChat(String chatId) async {
    currentChatId = chatId;
    final chat = StorageService.getChat(chatId);
    messages = List<Map<String, dynamic>>.from(chat?['messages'] ?? []);
    notifyListeners();
  }

  Future<void> startNewChat() async {
    currentChatId = await StorageService.createNewChat();
    messages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? imageBase64}) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('لطفاً ابتدا API Key خود را وارد کنید');
    }

    if (currentChatId == null) {
      await startNewChat();
    }

    // Add user message
    final userMessage = {
      'role': 'user',
      'content': text,
      'timestamp': DateTime.now().toIso8601String(),
      if (imageBase64 != null) 'image': imageBase64,
    };
    messages.add(userMessage);
    await StorageService.addMessage(currentChatId!, userMessage);
    notifyListeners();

    isLoading = true;
    notifyListeners();

    try {
      // Build conversation history for context (memory)
      final history = messages.map((m) {
        if (m['image'] != null) {
          return {
            'role': m['role'],
            'content': [
              {'type': 'text', 'text': m['content']},
              {
                'type': 'image_url',
                'image_url': {'url': 'data:image/jpeg;base64,${m['image']}'}
              }
            ]
          };
        }
        return {
          'role': m['role'],
          'content': m['content'],
        };
      }).toList();

      final response = await http.post(
        Uri.parse('https://api.x.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'grok-4',
          'messages': [
            {
              'role': 'system',
              'content': '''تو Fast Ai هستی، یک هوش مصنوعی همه‌کاره، سریع، باهوش و مفید.
همیشه به زبان فارسی پاسخ بده مگر اینکه کاربر زبان دیگری بخواهد.
حافظه گفتگو داری و به پیام‌های قبلی توجه می‌کنی.
می‌تونی عکس و ویدیو بسازی و تحلیل کنی.'''
            },
            ...history,
          ],
          'stream': false,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantText = data['choices'][0]['message']['content'] as String;

        final assistantMessage = {
          'role': 'assistant',
          'content': assistantText,
          'timestamp': DateTime.now().toIso8601String(),
        };
        messages.add(assistantMessage);
        await StorageService.addMessage(currentChatId!, assistantMessage);
      } else {
        throw Exception('خطا از سمت سرور: \( {response.statusCode}\n \){response.body}');
      }
    } catch (e) {
      final errorMessage = {
        'role': 'assistant',
        'content': 'متأسفانه خطایی رخ داد:\n$e',
        'timestamp': DateTime.now().toIso8601String(),
        'isError': true,
      };
      messages.add(errorMessage);
      await StorageService.addMessage(currentChatId!, errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Image Generation
  Future<String?> generateImage(String prompt) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API Key وارد نشده');
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.x.ai/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'grok-imagine',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'] as String?;
      } else {
        throw Exception('خطا در ساخت عکس: ${response.statusCode}');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Video Generation
  Future<String?> generateVideo(String prompt) async {
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API Key وارد نشده');
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.x.ai/v1/videos/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'grok-imagine-video',
          'prompt': prompt,
          'duration': 5,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'] as String? ?? data['id'] as String?;
      } else {
        throw Exception('خطا در ساخت ویدیو: ${response.statusCode}');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
