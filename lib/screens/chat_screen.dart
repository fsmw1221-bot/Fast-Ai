import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatService>(
      builder: (context, chatService, _) {
        _scrollToBottom();
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Fast Ai'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'image') {
                    _showImagePrompt(context, chatService);
                  } else if (value == 'video') {
                    _showVideoPrompt(context, chatService);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'image',
                    child: Row(
                      children: [
                        Icon(Icons.image, color: Color(0xFF00E5FF)),
                        SizedBox(width: 8),
                        Text('ساخت عکس'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'video',
                    child: Row(
                      children: [
                        Icon(Icons.videocam, color: Color(0xFF7C4DFF)),
                        SizedBox(width: 8),
                        Text('ساخت ویدیو'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatService.messages.length + (chatService.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatService.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('در حال فکر کردن...'),
                          ],
                        ),
                      );
                    }

                    final msg = chatService.messages[index];
                    final isUser = msg['role'] == 'user';
                    final isError = msg['isError'] == true;

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF00E5FF).withOpacity(0.2)
                              : isError
                                  ? Colors.red.withOpacity(0.2)
                                  : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUser
                                ? const Color(0xFF00E5FF).withOpacity(0.5)
                                : Colors.white10,
                          ),
                        ),
                        child: MarkdownBody(
                          data: msg['content'] ?? '',
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white, fontSize: 15),
                            code: const TextStyle(
                              backgroundColor: Colors.black54,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input area
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(chatService),
                          decoration: InputDecoration(
                            hintText: 'پیام خود را بنویسید...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFF0A0A0A),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF00E5FF),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.black),
                          onPressed: chatService.isLoading
                              ? null
                              : () => _send(chatService),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _send(ChatService chatService) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    chatService.sendMessage(text);
  }

  void _showImagePrompt(BuildContext context, ChatService chatService) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('ساخت عکس با Fast Ai'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'توضیح عکس را بنویسید...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prompt = controller.text.trim();
              if (prompt.isEmpty) return;
              
              await chatService.sendMessage('لطفاً این عکس را بساز: $prompt');
              
              try {
                final url = await chatService.generateImage(prompt);
                if (url != null) {
                  await chatService.sendMessage('عکس ساخته شد:\n$url');
                }
              } catch (e) {
                // Error already handled in service
              }
            },
            child: const Text('بساز'),
          ),
        ],
      ),
    );
  }

  void _showVideoPrompt(BuildContext context, ChatService chatService) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('ساخت ویدیو با Fast Ai'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'توضیح ویدیو را بنویسید...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prompt = controller.text.trim();
              if (prompt.isEmpty) return;
              
              await chatService.sendMessage('لطفاً این ویدیو را بساز: $prompt');
              
              try {
                final result = await chatService.generateVideo(prompt);
                if (result != null) {
                  await chatService.sendMessage('ویدیو در حال ساخت است یا آماده شد:\n$result');
                }
              } catch (e) {
                // handled
              }
            },
            child: const Text('بساز'),
          ),
        ],
      ),
    );
  }
}
