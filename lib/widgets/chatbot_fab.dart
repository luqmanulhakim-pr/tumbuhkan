import 'package:flutter/material.dart';
import '../config/routes.dart';

class ChatBotFAB extends StatelessWidget {
  const ChatBotFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.of(context).pushNamed(AppRoutes.chatbot);
      },
      backgroundColor: const Color(0xFF2E7D32),
      elevation: 4,
      icon: const Icon(Icons.smart_toy, size: 24),
      label: const Text(
        'Tanya Tumu',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
