import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = StorageService.getApiKey() ?? '';
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Info
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/icons/app_icon.png',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fast Ai',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'نسخه 1.0.0',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // API Key Section
          const Text(
            'کلید API (xAI)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'برای استفاده از قابلیت‌های چت، عکس و ویدیو باید API Key خودت از console.x.ai را وارد کنی.',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKeyController,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: 'xai-...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final key = _apiKeyController.text.trim();
              if (key.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('کلید را وارد کنید')),
                );
                return;
              }
              await context.read<ChatService>().setApiKey(key);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API Key ذخیره شد ✓'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E5FF),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('ذخیره کلید'),
          ),

          const SizedBox(height: 40),
          const Divider(),

          // Danger Zone
          const SizedBox(height: 20),
          const Text(
            'منطقه خطر',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('پاک کردن همه گفتگوها؟'),
                  content: const Text('این عمل غیرقابل بازگشت است.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('پاک کن', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await StorageService.clearAllChats();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('همه گفتگوها پاک شدند')),
                  );
                }
              }
            },
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            label: const Text('پاک کردن همه تاریخچه', style: TextStyle(color: Colors.redAccent)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
