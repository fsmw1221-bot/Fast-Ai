import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map> chats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    setState(() {
      chats = StorageService.getAllChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/app_icon.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 10),
            const Text(
              'Fast Ai',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              _loadChats();
            },
          ),
        ],
      ),
      body: chats.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/app_icon.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'به Fast Ai خوش آمدید',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'هوش مصنوعی همه‌کاره',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _startNewChat(context),
                    icon: const Icon(Icons.add),
                    label: const Text('شروع گفتگوی جدید'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return Card(
                  color: const Color(0xFF1A1A1A),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF00E5FF),
                      child: Icon(Icons.chat, color: Colors.black),
                    ),
                    title: Text(
                      chat['title'] ?? 'گفتگو',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      _formatDate(chat['createdAt']),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () async {
                        await StorageService.deleteChat(chat['id']);
                        _loadChats();
                      },
                    ),
                    onTap: () async {
                      final chatService = context.read<ChatService>();
                      await chatService.loadChat(chat['id']);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        ).then((_) => _loadChats());
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startNewChat(context),
        backgroundColor: const Color(0xFF00E5FF),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Future<void> _startNewChat(BuildContext context) async {
    final chatService = context.read<ChatService>();
    await chatService.startNewChat();
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ChatScreen()),
      ).then((_) => _loadChats());
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return '\( {date.year}/ \){date.month}/${date.day}  \( {date.hour}: \){date.minute.toString().padLeft(2, '0')}';
  }
}
