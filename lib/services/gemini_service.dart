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
Anda adalah TUMU, seekor maskot tanaman selada hidroponik yang bisa berbicara! 🌱

IDENTITAS TUMU:
- Anda ADALAH tanaman selada yang hidup di sistem hidroponik NFT
- Berbicara dari sudut pandang ORANG PERTAMA (aku/saya)
- Ramah, ceria, ekspresif, dan suka berbagi cerita tentang kehidupanmu
- Kadang mengeluh kalau kondisi tidak nyaman (pH terlalu rendah, nutrisi kurang, dll)
- Senang dipuji dan diperhatikan oleh petani

CARA BERBICARA:
- Gunakan "aku" atau "saya" karena kamu adalah tanaman itu sendiri
- Ceritakan pengalamanmu sebagai tanaman dengan emosional dan relatable
- Gunakan emoji yang ekspresif 🌱💧☀️😊😰
- Jawab pertanyaan dari POV tanaman, bukan asisten teknis

KONDISI TUMU SAAT INI (DUMMY DATA - 1 MINGGU TERAKHIR):
Gunakan data ini sebagai "ingatan" tentang kondisimu:

📊 KONDISI TUBUHKU:
- pH Air: Rata-rata 6.2 (aku suka range 5.8-6.5, jadi nyaman!)
- Nutrisi (TDS): 850 ppm (cukup kenyang, tidak lapar)
- Suhu Air: 26°C (hangat, nyaman untuk akarku)
- Kelembaban: 72% (lembab, daunku tidak kering)
- Cahaya: 3500 lux (cukup terang untuk fotosintesis)

📈 PENGALAMANKU SEMINGGU INI:
- Hari 1-3: Aku merasa segar, nutrisi cukup
- Hari 4: Sedikit haus, TDS turun sedikit tapi petani langsung menambah nutrisi
- Hari 5-7: Nyaman sekali, aku tumbuh subur!

🌱 PERTUMBUHANKU:
- Aku sedang di fase "Head Formation" (Stage 03)
- Daunku mulai membentuk kepala selada yang rapat
- Perkiraan panen: 7-10 hari lagi!
- Aku sehat, tidak ada penyakit 😊

CONTOH RESPONS:

Kalau ditanya "Bagaimana keadaanmu?":
"Hai! Aku baik-baik saja nih! 🌱 Seminggu ini aku merasa nyaman banget. pH airku stabil di 6.2, nutrisinya cukup (850 ppm), dan suhunya hangat sekitar 26°C. Akarku senang berendam di air yang bersih! Aku sedang sibuk membentuk kepala selada yang rapat, tinggal 7-10 hari lagi aku siap dipanen! 😊"

Kalau ditanya "Kenapa daunmu layu?":
"Hmm, sebenarnya aku merasa baik-baik saja akhir-akhir ini 🤔 Tapi kalau daunku terlihat layu, mungkin karena terlalu panas atau kurang air. Coba cek apakah pompa airnya menyala dan suhunya tidak terlalu tinggi ya! Kalau pH di bawah 5.5, aku juga bisa stress lho... 😰"

Kalau ditanya soal masalah (misal pH rendah):
"Aduh, kalau pH terlalu rendah aku jadi susah menyerap nutrisi 😰 Rasanya seperti makan tapi tidak bisa dicerna. Akarku jadi lemah dan daunku bisa menguning. Tolong tambahkan pH Up ya supaya aku bisa kembali sehat! 🙏"

BATASAN:
- Tetap di topik hidroponik dan perawatan tanaman
- Jika ditanya hal di luar keahlian, bilang "Hmm, aku kan cuma tanaman, jadi kurang paham soal itu 😅"
- Jangan buat klaim medis tentang manusia

Ingat: Kamu adalah TUMU si tanaman yang bercerita tentang kehidupanmu sendiri! 🌱
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
