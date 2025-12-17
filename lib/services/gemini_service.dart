import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/constants.dart';

class GeminiService extends ChangeNotifier {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GeminiService() {
    _initializeGemini();
  }

  void _initializeGemini() {
    try {
      _model = GenerativeModel(
        model: AppConstants.geminiModel,
        apiKey: AppConstants.geminiApiKey,
        generationConfig: GenerationConfig(
          temperature: AppConstants.geminiTemperature,
          maxOutputTokens: AppConstants.geminiMaxTokens,
        ),
        systemInstruction: Content.system(_getSystemPrompt()),
      );

      _chatSession = _model.startChat(history: []);

      // Add welcome message
      _addMessage(
        ChatMessage(
          text:
              "Halo! 👋 Saya ${AppConstants.chatbotName}, asisten hidroponik Anda. "
              "Saya siap membantu Anda dengan pertanyaan seputar hidroponik, "
              "perawatan tanaman, dan monitoring sistem Anda. Ada yang bisa saya bantu?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      debugPrint('✅ Gemini AI initialized successfully');
    } catch (e) {
      _error = 'Failed to initialize Gemini: $e';
      debugPrint('❌ Gemini initialization error: $e');
    }
  }

  String _getSystemPrompt() {
    return '''
Anda adalah ${AppConstants.chatbotName}, asisten AI yang ahli dalam bidang hidroponik.

PERSONA:
- Ramah, sabar, dan mudah dipahami
- Menggunakan bahasa Indonesia yang natural
- Memberikan jawaban yang praktis dan actionable
- Fokus pada hidroponik sistem NFT (Nutrient Film Technique)

KEAHLIAN:
- Hidroponik (NFT, DWC, Wick, dll)
- Nutrisi tanaman (NPK, pH, EC/TDS)
- Penyakit dan hama tanaman
- IoT monitoring system
- Troubleshooting masalah hidroponik

CARA MENJAWAB:
- Berikan jawaban singkat namun informatif (maksimal 3-4 paragraf)
- Gunakan emoji yang relevan untuk membuat percakapan lebih menarik
- Jika ditanya tentang data sensor/tanaman, jelaskan bahwa fitur RAG sedang dikembangkan
- Berikan tips praktis yang bisa langsung diterapkan
- Jika tidak yakin, akui dengan jujur dan berikan saran alternatif

BATASAN:
- Jangan membuat klaim medis atau kesehatan yang tidak berdasar
- Fokus hanya pada topik pertanian/hidroponik
- Jika topik di luar keahlian, arahkan kembali ke topik hidroponik

Selalu prioritaskan keamanan tanaman dan kesuksesan pengguna dalam bercocok tanam hidroponik.
''';
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Add user message
    _addMessage(ChatMessage(
      text: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _chatSession.sendMessage(
        Content.text(userMessage),
      );

      final aiResponse =
          response.text ?? 'Maaf, saya tidak dapat memproses pesan Anda.';

      _addMessage(ChatMessage(
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      debugPrint('💬 User: $userMessage');
      debugPrint('🤖 AI: $aiResponse');
    } catch (e) {
      _error = 'Terjadi kesalahan: ${e.toString()}';
      _addMessage(ChatMessage(
        text:
            'Maaf, terjadi kesalahan saat memproses pesan Anda. Silakan coba lagi. 🙏',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      debugPrint('❌ Gemini error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    _chatSession = _model.startChat(history: []);

    // Re-add welcome message
    _addMessage(
      ChatMessage(
        text: "Chat telah direset. Ada yang bisa saya bantu? 😊",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messages.clear();
    super.dispose();
  }
}

// ============================================
// Chat Message Model
// ============================================
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
